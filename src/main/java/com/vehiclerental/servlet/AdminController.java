package com.vehiclerental.servlet;

import com.vehiclerental.booking.Booking;
import com.vehiclerental.model.User;
import com.vehiclerental.model.Vehicle;
import com.vehiclerental.payment.PaymentRecord;
import com.vehiclerental.repository.*;

import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpSession;

import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.*;

import java.net.URLEncoder;
import java.nio.charset.StandardCharsets;
import java.sql.SQLException;
import java.util.*;
import java.util.regex.Pattern;

@Controller
@RequestMapping("/admin")
public class AdminController {

    // =========================================================
    // VALIDATION PATTERNS
    // =========================================================

    private static final Pattern EMAIL = Pattern.compile(
            "^[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,}$"
    );

    private static final Pattern NAME = Pattern.compile(
            "^[\\p{L}][\\p{L} .'-]{1,119}$"
    );

    /*
     * Sri Lankan mobile numbers.
     *
     * Accepted:
     * 0771234567
     * 077 123 4567
     * 077-123-4567
     * +94771234567
     * +94 77 123 4567
     * 94771234567
     */
    private static final Pattern PHONE = Pattern.compile(
            "^(?:\\+94|94|0)7[0-9](?:[ -]?[0-9]){7}$"
    );

    private static final Pattern LICENSE = Pattern.compile(
            "^[A-Za-z0-9/ -]{3,80}$"
    );

    private static final Set<String> ROLES = Set.of(
            "CUSTOMER",
            "BRANCH_STAFF",
            "ADMIN",
            "VEHICLE",
            "FINANCE",
            "MAINTENANCE",
            "FLEET"
    );

    private static final Set<String> STATUSES = Set.of(
            "ACTIVE",
            "SUSPENDED",
            "DEACTIVATED"
    );

    // =========================================================
    // REPOSITORIES
    // =========================================================

    private final UserRepository users;
    private final AuditRepository audit;
    private final BookingRepository bookings;
    private final PaymentRepository payments;
    private final VehicleRepository vehicles;

    public AdminController(
            UserRepository users,
            AuditRepository audit,
            BookingRepository bookings,
            PaymentRepository payments,
            VehicleRepository vehicles) {

        this.users = users;
        this.audit = audit;
        this.bookings = bookings;
        this.payments = payments;
        this.vehicles = vehicles;
    }

    // =========================================================
    // MEMBER MANAGEMENT PAGE
    // =========================================================

    @GetMapping("/members")
    public String members(
            HttpSession session,
            Model model) {

        String guard = requireAdmin(session);

        if (guard != null) {
            return guard;
        }

        try {

            List<User> list = users.findAll();

            Map<String, Integer> count = new HashMap<>();

            for (Booking b : bookings.findAll()) {

                if (!"CANCELLED".equalsIgnoreCase(b.getStatus())) {
                    count.merge(
                            b.getUserId(),
                            1,
                            Integer::sum
                    );
                }
            }

            Map<String, Double> spend = new HashMap<>();

            for (PaymentRecord p : payments.findAll()) {

                if ("SUCCESS".equalsIgnoreCase(p.getStatus())) {

                    spend.merge(
                            p.getCustomerName(),
                            p.getAmount(),
                            Double::sum
                    );
                }
            }

            model.addAttribute("users", list);
            model.addAttribute("bookingCount", count);
            model.addAttribute("spendByName", spend);
            model.addAttribute("customerProfiles", users.findAllCustomerProfiles());

        } catch (SQLException e) {

            System.err.println(
                    "[AdminController] Member load error: "
                            + e.getMessage()
            );

            e.printStackTrace();

            model.addAttribute(
                    "users",
                    Collections.emptyList()
            );

            model.addAttribute(
                    "bookingCount",
                    Collections.emptyMap()
            );

            model.addAttribute(
                    "spendByName",
                    Collections.emptyMap()
            );

            model.addAttribute(
                    "customerProfiles",
                    Collections.emptyMap()
            );

            model.addAttribute(
                    "errorMessage",
                    "Member data is temporarily unavailable."
            );
        }

        return "adminMembers";
    }

    // =========================================================
    // CREATE USER
    // =========================================================

    @PostMapping("/users/create")
    public String createUser(
            @RequestParam String name,
            @RequestParam String email,
            @RequestParam String password,
            @RequestParam String role,
            @RequestParam(defaultValue = "") String phone,
            @RequestParam(defaultValue = "") String licenseNo,
            HttpSession session) {

        String guard = requireAdmin(session);

        if (guard != null) {
            return guard;
        }

        User admin =
                (User) session.getAttribute("loggedUser");

        name = safeTrim(name);
        email = safeTrim(email).toLowerCase();
        phone = safeTrim(phone);
        licenseNo = safeTrim(licenseNo);
        role = safeTrim(role).toUpperCase();

        String err = validateUser(
                name,
                email,
                password,
                role,
                "ACTIVE",
                phone,
                licenseNo
        );

        if (err != null) {
            return memberErrorRedirect(err, name, email, phone, licenseNo, role);
        }

        /*
         * Phone is optional for admin-created users.
         * If provided, store it in standard format.
         */
        if (!phone.isBlank()) {
            phone = normalizeSriLankanPhone(phone);
        }

        try {

            boolean ok = users.insert(
                    name,
                    email,
                    password,
                    role,
                    phone,
                    licenseNo
            );

            if (ok) {

                audit.log(
                        admin.getId(),
                        "CREATE_USER",
                        email,
                        role
                );

                return "redirect:/admin/members?msg=created";
            }

            return memberErrorRedirect("emailExists", name, email, phone, licenseNo, role);

        } catch (SQLException e) {

            System.err.println(
                    "[AdminController] Create user database error: "
                            + e.getMessage()
            );

            e.printStackTrace();

            return memberErrorRedirect("db", name, email, phone, licenseNo, role);
        }
    }

    private static String memberErrorRedirect(String error, String name, String email, String phone, String licenseNo, String role) {
        return "redirect:/admin/members?error=" + enc(error)
                + "&name=" + enc(name)
                + "&email=" + enc(email)
                + "&phone=" + enc(phone)
                + "&licenseNo=" + enc(licenseNo)
                + "&role=" + enc(role);
    }

    // =========================================================
    // UPDATE USER STATUS
    // =========================================================

    @PostMapping("/users/status")
    public String status(
            @RequestParam String id,
            @RequestParam String status,
            HttpSession session) {

        String guard = requireAdmin(session);

        if (guard != null) {
            return guard;
        }

        User admin =
                (User) session.getAttribute("loggedUser");

        id = safeTrim(id);
        status = safeTrim(status).toUpperCase();

        if (id.isBlank()) {
            return "redirect:/admin/members?error=invalidUser";
        }

        if (!STATUSES.contains(status)) {
            return "redirect:/admin/members?error=invalidStatus";
        }

        /*
         * Admin cannot suspend/deactivate own account.
         */
        if (admin.getId().equals(id)
                && !"ACTIVE".equals(status)) {

            return "redirect:/admin/members?error=cannotSuspendSelf";
        }

        try {

            boolean updated =
                    users.updateStatus(id, status);

            if (!updated) {
                return "redirect:/admin/members?error=notFound";
            }

            audit.log(
                    admin.getId(),
                    "UPDATE_USER_STATUS",
                    id,
                    status
            );

            return "redirect:/admin/members?msg=status";

        } catch (SQLException e) {

            System.err.println(
                    "[AdminController] Status update error: "
                            + e.getMessage()
            );

            e.printStackTrace();

            return "redirect:/admin/members?error=db";
        }
    }

    // =========================================================
    // UPDATE USER
    // =========================================================

    @PostMapping("/users/update")
    public String update(
            @RequestParam String id,
            @RequestParam String name,
            @RequestParam String email,
            @RequestParam String role,
            @RequestParam String status,
            @RequestParam(defaultValue = "") String phone,
            @RequestParam(defaultValue = "") String licenseNo,
            HttpSession session) {

        String guard = requireAdmin(session);

        if (guard != null) {
            return guard;
        }

        User admin =
                (User) session.getAttribute("loggedUser");

        id = safeTrim(id);
        name = safeTrim(name);
        email = safeTrim(email).toLowerCase();
        phone = safeTrim(phone);
        licenseNo = safeTrim(licenseNo);

        String normalizedRole =
                safeTrim(role).toUpperCase();

        String normalizedStatus =
                safeTrim(status).toUpperCase();

        if (id.isBlank()) {
            return "redirect:/admin/members?error=invalidUser";
        }

        String err = validateUser(
                name,
                email,
                null,
                normalizedRole,
                normalizedStatus,
                phone,
                licenseNo
        );

        if (err != null) {
            return "redirect:/admin/members?error=" + enc(err);
        }

        /*
         * Prevent administrator from removing own
         * admin privileges or disabling own account.
         */
        if (admin.getId().equals(id)
                && (!"ADMIN".equals(normalizedRole)
                || !"ACTIVE".equals(normalizedStatus))) {

            return "redirect:/admin/members?error=cannotDemoteSelf";
        }

        if (!phone.isBlank()) {
            phone = normalizeSriLankanPhone(phone);
        }

        try {

            boolean ok = users.updateAdminFields(
                    id,
                    name,
                    email,
                    normalizedRole,
                    normalizedStatus,
                    phone,
                    licenseNo
            );

            if (!ok) {
                return "redirect:/admin/members?error=notFound";
            }

            audit.log(
                    admin.getId(),
                    "UPDATE_USER",
                    id,
                    normalizedRole + "/" + normalizedStatus
            );

            return "redirect:/admin/members?msg=updated";

        } catch (SQLException e) {

            System.err.println(
                    "[AdminController] User update error: "
                            + e.getMessage()
            );

            e.printStackTrace();

            return "redirect:/admin/members?error=db";
        }
    }

    // =========================================================
    // CUSTOMER PROFILE VERIFICATION
    // =========================================================

    @PostMapping("/users/verification")
    public String verification(
            @RequestParam String id,
            @RequestParam String verificationStatus,
            HttpSession session) {

        String guard = requireAdmin(session);
        if (guard != null) return guard;

        User admin = (User) session.getAttribute("loggedUser");
        id = safeTrim(id);
        verificationStatus = safeTrim(verificationStatus).toUpperCase();

        if (id.isBlank()) return "redirect:/admin/members?error=invalidUser";
        if (!Set.of("PENDING", "VERIFIED", "REJECTED").contains(verificationStatus))
            return "redirect:/admin/members?error=invalidVerification";

        try {
            if (!users.updateVerificationStatus(id, verificationStatus))
                return "redirect:/admin/members?error=notFound";

            audit.log(admin.getId(), "UPDATE_CUSTOMER_VERIFICATION", id, verificationStatus);
            return "redirect:/admin/members?msg=verification";
        } catch (SQLException e) {
            System.err.println("[AdminController] Verification update error: " + e.getMessage());
            e.printStackTrace();
            return "redirect:/admin/members?error=db";
        }
    }

    // =========================================================
    // BOOKINGS
    // =========================================================

    @GetMapping("/bookings")
    public String bookings(
            HttpServletRequest request,
            HttpSession session,
            Model model) {

        String guard = requireAdmin(session);

        if (guard != null) {
            return guard;
        }

        try {

            List<Booking> all = bookings.findAll();

            Map<String, String> names =
                    new HashMap<>();

            for (User u : users.findAll()) {
                names.put(
                        u.getId(),
                        u.getName()
                );
            }

            Map<String, String> vehicleNames =
                    new HashMap<>();

            Map<String, Vehicle> byId =
                    new HashMap<>();

            for (Vehicle v : vehicles.findAllDomain()) {

                vehicleNames.put(
                        v.getVehicleId(),
                        v.getBrand() + " " + v.getModel()
                );

                byId.put(
                        v.getVehicleId(),
                        v
                );
            }

            Map<String, String> wa =
                    new HashMap<>();

            for (Booking b : all) {

                String phone =
                        normalizePhoneForWhatsApp(
                                b.getCustomerPhone()
                        );

                if (phone.isBlank()) {
                    continue;
                }

                String text =
                        "RideLanka FleetHire booking "
                                + b.getBookingId()
                                + " | "
                                + vehicleNames.getOrDefault(
                                b.getVehicleId(),
                                b.getVehicleId()
                        )
                                + " | "
                                + b.getStartDate()
                                + " to "
                                + b.getEndDate();

                wa.put(
                        b.getBookingId(),
                        "https://wa.me/"
                                + phone
                                + "?text="
                                + URLEncoder.encode(
                                text,
                                StandardCharsets.UTF_8
                        )
                );
            }

            model.addAttribute(
                    "bookings",
                    all
            );

            model.addAttribute(
                    "nameById",
                    names
            );

            model.addAttribute(
                    "vehicleById",
                    vehicleNames
            );

            model.addAttribute(
                    "waUrlByBooking",
                    wa
            );

        } catch (SQLException e) {

            System.err.println(
                    "[AdminController] Booking load error: "
                            + e.getMessage()
            );

            e.printStackTrace();

            model.addAttribute(
                    "bookings",
                    Collections.emptyList()
            );

            model.addAttribute(
                    "nameById",
                    Collections.emptyMap()
            );

            model.addAttribute(
                    "vehicleById",
                    Collections.emptyMap()
            );

            model.addAttribute(
                    "waUrlByBooking",
                    Collections.emptyMap()
            );

            model.addAttribute(
                    "errorMessage",
                    "Booking data is temporarily unavailable."
            );
        }

        return "adminBookings";
    }

    // =========================================================
    // USER VALIDATION
    // =========================================================

    private static String validateUser(
            String name,
            String email,
            String password,
            String role,
            String status,
            String phone,
            String licenseNo) {

        // -------------------------
        // Name
        // -------------------------

        if (name == null
                || name.length() < 2
                || name.length() > 120
                || !NAME.matcher(name).matches()) {

            return "invalidName";
        }

        // -------------------------
        // Email
        // -------------------------

        if (email == null
                || email.isBlank()
                || email.length() > 180
                || !EMAIL.matcher(email).matches()) {

            return "invalidEmail";
        }

        // -------------------------
        // Password
        // -------------------------

        if (password != null
                && (password.length() < 8
                || password.length() > 128
                || !password.matches(".*[A-Za-z].*")
                || !password.matches(".*\\d.*"))) {

            return "weakPassword";
        }

        // -------------------------
        // Role
        // -------------------------

        if (role == null
                || !ROLES.contains(role.toUpperCase())) {

            return "invalidRole";
        }

        // -------------------------
        // Status
        // -------------------------

        if (status == null
                || !STATUSES.contains(status.toUpperCase())) {

            return "invalidStatus";
        }

        // -------------------------
        // Phone
        // Optional for admin-created staff.
        // But if entered, it MUST be valid.
        // -------------------------

        if (phone != null
                && !phone.isBlank()
                && !PHONE.matcher(phone).matches()) {

            return "invalidPhone";
        }

        // -------------------------
        // Licence / ID
        // Optional for staff.
        // But if entered, it MUST match pattern.
        // -------------------------

        if (licenseNo != null
                && !licenseNo.isBlank()
                && !LICENSE.matcher(licenseNo).matches()) {

            return "invalidLicense";
        }

        return null;
    }

    // =========================================================
    // PHONE NORMALIZATION FOR DATABASE
    // =========================================================

    private static String normalizeSriLankanPhone(
            String phone) {

        if (phone == null) {
            return "";
        }

        String value = phone
                .trim()
                .replace(" ", "")
                .replace("-", "");

        if (value.startsWith("+94")) {
            return "0" + value.substring(3);
        }

        if (value.startsWith("94")) {
            return "0" + value.substring(2);
        }

        return value;
    }

    // =========================================================
    // WHATSAPP PHONE FORMAT
    // =========================================================

    private static String normalizePhoneForWhatsApp(
            String raw) {

        if (raw == null) {
            return "";
        }

        String value = raw
                .trim()
                .replace(" ", "")
                .replace("-", "");

        if (!PHONE.matcher(value).matches()) {
            return "";
        }

        if (value.startsWith("+94")) {
            return value.substring(1);
        }

        if (value.startsWith("94")) {
            return value;
        }

        if (value.startsWith("0")) {
            return "94" + value.substring(1);
        }

        return "";
    }

    // =========================================================
    // URL ENCODING
    // =========================================================

    private static String enc(String value) {

        return URLEncoder.encode(
                value,
                StandardCharsets.UTF_8
        );
    }

    // =========================================================
    // SAFE STRING
    // =========================================================

    private static String safeTrim(String value) {

        return value == null
                ? ""
                : value.trim();
    }

    // =========================================================
    // ADMIN SECURITY
    // =========================================================

    static String requireAdmin(
            HttpSession session) {

        Object logged =
                session.getAttribute("loggedUser");

        if (!(logged instanceof User u)) {
            return "redirect:/login";
        }

        return "ADMIN".equalsIgnoreCase(u.getRole())
                ? null
                : "redirect:/dashboard";
    }
}