package com.vehiclerental;

import com.vehiclerental.model.User;
import com.vehiclerental.model.CustomerProfile;
import com.vehiclerental.notification.NotificationService;
import com.vehiclerental.repository.AuditRepository;
import com.vehiclerental.repository.UserRepository;
import com.vehiclerental.security.PasswordUtil;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpSession;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.*;
import java.net.URLEncoder;
import java.nio.charset.StandardCharsets;
import java.sql.SQLException;
import java.util.regex.Pattern;
import java.time.LocalDate;
import java.time.format.DateTimeParseException;

@Controller
public class UserController {

    /*
     * EMAIL
     * Example: customer@gmail.com
     */
    private static final Pattern EMAIL = Pattern.compile(
            "^[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,}$"
    );

    /*
     * Sri Lankan MOBILE PHONE NUMBER
     *
     * Accepted:
     * 0771234567
     * 077 123 4567
     * 077-123-4567
     * +94771234567
     * +94 77 123 4567
     * 94771234567
     *
     * Must be a Sri Lankan mobile number beginning 07.
     */
    private static final Pattern PHONE = Pattern.compile(
            "^(?:\\+94|94|0)7[0-9](?:[ -]?[0-9]){7}$"
    );

    /*
     * Person name
     *
     * Allows letters, spaces, apostrophe, dot and hyphen.
     */
    private static final Pattern NAME = Pattern.compile(
            "^[\\p{L}][\\p{L} .'-]{1,119}$"
    );

    /*
     * Driving licence / ID
     *
     * Allows letters, numbers, spaces, / and -
     */
    private static final Pattern LICENSE = Pattern.compile(
            "^[A-Za-z0-9/ -]{3,80}$"
    );

    private final UserRepository users;
    private final AuditRepository audit;
    private final NotificationService notifications;

    public UserController(
            UserRepository users,
            AuditRepository audit,
            NotificationService notifications) {

        this.users = users;
        this.audit = audit;
        this.notifications = notifications;
    }

    // =========================================================
    // PAGE ROUTES
    // =========================================================

    @GetMapping("/register")
    public String register() {
        return "register";
    }

    @GetMapping("/login")
    public String login() {
        return "login";
    }

    @GetMapping("/change-password")
    public String changePasswordPage() {
        return "changePassword";
    }

    @GetMapping("/profile")
    public String profile(HttpSession session, Model model) {
        Object x = session.getAttribute("loggedUser");
        if (!(x instanceof User logged)) return "redirect:/login";
        try {
            User fresh = users.findById(logged.getId());
            if (fresh == null || !"ACTIVE".equalsIgnoreCase(fresh.getStatus())) {
                session.invalidate();
                return "redirect:/login";
            }
            session.setAttribute("loggedUser", fresh);
            if ("CUSTOMER".equalsIgnoreCase(fresh.getRole())) {
                model.addAttribute("customerProfile", users.findCustomerProfileByUserId(fresh.getId()));
            }
            return "profile";
        } catch (SQLException e) {
            System.err.println("[UserController] Profile load database error: " + e.getMessage());
            return "profile";
        }
    }

    // =========================================================
    // LOGOUT
    // =========================================================

    @GetMapping("/logout")
    public String logout(HttpSession session) {

        Object x = session.getAttribute("loggedUser");

        if (x instanceof User u) {
            audit.log(
                    u.getId(),
                    "LOGOUT",
                    u.getId(),
                    "User signed out"
            );
        }

        session.invalidate();

        return "redirect:/login?msg=loggedout";
    }

    // =========================================================
    // CUSTOMER REGISTRATION
    // =========================================================

    @PostMapping("/user/register")
    public String handleRegister(
            @RequestParam String name,
            @RequestParam String email,
            @RequestParam String password,
            @RequestParam String phone,
            @RequestParam String licenseNo) {

        // Trim user input
        name = safeTrim(name);
        email = safeTrim(email).toLowerCase();
        phone = safeTrim(phone);
        licenseNo = safeTrim(licenseNo);

        // Server-side validation
        String error = validateRegistration(
                name,
                email,
                password,
                phone,
                licenseNo
        );

        if (error != null) {

            return registrationErrorRedirect(
                    error,
                    name,
                    email,
                    phone,
                    licenseNo
            );
        }

        // Store phone in one standard format
        phone = normalizeSriLankanPhone(phone);

        try {

            boolean ok = users.insert(
                    name,
                    email,
                    password,
                    "CUSTOMER",
                    phone,
                    licenseNo
            );

            if (!ok) {

                return registrationErrorRedirect(
                        "emailExists",
                        name,
                        email,
                        phone,
                        licenseNo
                );
            }

            User created = users.findByEmail(email);

            if (created != null) {

                audit.log(
                        created.getId(),
                        "REGISTER",
                        created.getId(),
                        "Customer registration"
                );

                notifications.userRegistered(created);
            }

            return "redirect:/login?msg=registered";

        } catch (SQLException e) {

            System.err.println(
                    "[UserController] Registration database error: "
                            + e.getMessage()
            );

            e.printStackTrace();

            return registrationErrorRedirect(
                    "db",
                    name,
                    email,
                    phone,
                    licenseNo
            );        }
    }

    // =========================================================
    // LOGIN
    // =========================================================

    @PostMapping("/user/login")
    public String handleLogin(
            @RequestParam String email,
            @RequestParam String password,
            HttpServletRequest request) {

        email = safeTrim(email).toLowerCase();

        if (email.isBlank()
                || password == null
                || email.length() > 180
                || password.length() > 200
                || !EMAIL.matcher(email).matches()) {

            return "redirect:/login?error=invalid";
        }

        try {

            User u = users.findByEmail(email);

            if (u != null
                    && "ACTIVE".equalsIgnoreCase(u.getStatus())
                    && PasswordUtil.matches(password, u.getPassword())) {

                /*
                 * Prevent session fixation.
                 * Destroy old session and create a new one.
                 */
                HttpSession oldSession = request.getSession(false);

                if (oldSession != null) {
                    oldSession.invalidate();
                }

                HttpSession newSession = request.getSession(true);

                // 30 minutes
                newSession.setMaxInactiveInterval(30 * 60);

                newSession.setAttribute("loggedUser", u);

                users.updateLastLogin(u.getId());

                audit.log(
                        u.getId(),
                        "LOGIN",
                        u.getId(),
                        "Successful login"
                );

                // Best-effort SMTP alert. Email failure never blocks login.
                notifications.loginSucceeded(u);

                return "redirect:" + u.getDashboardUrl();
            }

            return "redirect:/login?error=invalid";

        } catch (SQLException e) {

            System.err.println(
                    "[UserController] Login database error: "
                            + e.getMessage()
            );

            e.printStackTrace();

            return "redirect:/login?error=db";
        }
    }

    // =========================================================
    // CHANGE PASSWORD
    // =========================================================

    @PostMapping("/user/change-password")
    public String changePassword(
            @RequestParam(defaultValue = "") String email,
            @RequestParam String currentPassword,
            @RequestParam String newPassword,
            @RequestParam String confirmPassword,
            HttpSession session) {

        Object sessionUser = session.getAttribute("loggedUser");
        User logged = sessionUser instanceof User ? (User) sessionUser : null;
        boolean authenticatedFlow = logged != null;

        email = safeTrim(email).toLowerCase();

        if (!authenticatedFlow && (email.isBlank() || email.length() > 180 || !EMAIL.matcher(email).matches())) {
            return "redirect:/change-password?error=invalid";
        }

        if (currentPassword == null || currentPassword.isBlank()) {
            return passwordErrorRedirect(authenticatedFlow, "current");
        }

        if (!validNewPassword(newPassword)) {
            return passwordErrorRedirect(authenticatedFlow, "weak");
        }

        if (!newPassword.equals(confirmPassword)) {
            return passwordErrorRedirect(authenticatedFlow, "mismatch");
        }

        try {
            User account = authenticatedFlow
                    ? users.findById(logged.getId())
                    : users.findByEmail(email);

            // Use one generic error for the public flow to avoid revealing whether an email exists.
            if (account == null
                    || !"ACTIVE".equalsIgnoreCase(account.getStatus())
                    || !PasswordUtil.matches(currentPassword, account.getPassword())) {
                return passwordErrorRedirect(authenticatedFlow, "current");
            }

            if (PasswordUtil.matches(newPassword, account.getPassword())) {
                return passwordErrorRedirect(authenticatedFlow, "same");
            }

            if (!users.updatePassword(account.getId(), newPassword)) {
                return passwordErrorRedirect(authenticatedFlow, "db");
            }

            User refreshed = users.findById(account.getId());
            if (authenticatedFlow && refreshed != null) {
                session.setAttribute("loggedUser", refreshed);
            }

            audit.log(account.getId(), "PASSWORD_CHANGE", account.getId(),
                    authenticatedFlow ? "Password changed from profile" : "Password changed from sign-in help");

            // Best-effort SMTP alert. Mail failure never rolls back the password update.
            notifications.passwordChanged(refreshed != null ? refreshed : account);

            return authenticatedFlow
                    ? "redirect:/profile?passwordMsg=changed"
                    : "redirect:/login?msg=passwordChanged";

        } catch (SQLException e) {
            System.err.println("[UserController] Password change database error: " + e.getMessage());
            return passwordErrorRedirect(authenticatedFlow, "db");
        }
    }

    // =========================================================
    // UPDATE CUSTOMER PROFILE
    // =========================================================

    @PostMapping("/user/update")
    public String handleUpdate(
            @RequestParam String name,
            @RequestParam String email,
            @RequestParam String phone,
            @RequestParam String licenseNo,
            @RequestParam(defaultValue = "") String idDocumentNo,
            @RequestParam(defaultValue = "") String addressLine,
            @RequestParam(defaultValue = "") String city,
            @RequestParam(defaultValue = "") String dateOfBirth,
            HttpSession session) {

        Object x = session.getAttribute("loggedUser");
        if (!(x instanceof User logged)) return "redirect:/login";

        name = safeTrim(name);
        email = safeTrim(email).toLowerCase();
        phone = safeTrim(phone);
        licenseNo = safeTrim(licenseNo);
        idDocumentNo = safeTrim(idDocumentNo).toUpperCase();
        addressLine = safeTrim(addressLine);
        city = safeTrim(city);
        dateOfBirth = safeTrim(dateOfBirth);

        String error = validateProfile(name,email,phone,licenseNo);
        if (error != null) return "redirect:/profile?error=" + error;

        boolean customer = "CUSTOMER".equalsIgnoreCase(logged.getRole());
        LocalDate dob = null;
        if (customer) {
            if (!validIdDocument(idDocumentNo)) {
                return "redirect:/profile?error=invalidDocument";
            }
            if (addressLine.length() > 220) return "redirect:/profile?error=invalidAddress";
            if (city.length() > 80 || (!city.isBlank() && !city.matches("^[\\p{L}0-9 .,'/-]{2,80}$")))
                return "redirect:/profile?error=invalidCity";
            if (!dateOfBirth.isBlank()) {
                try {
                    dob = LocalDate.parse(dateOfBirth);
                } catch (DateTimeParseException e) {
                    return "redirect:/profile?error=invalidDob";
                }
                if (dob.isAfter(LocalDate.now()) || dob.isBefore(LocalDate.now().minusYears(100)))
                    return "redirect:/profile?error=invalidDob";
            }
        }

        if (!validIdDocument(idDocumentNo)) {
            return "redirect:/profile?error=invalidDocument";
        }

        phone = normalizeSriLankanPhone(phone);
        try {
            boolean ok = users.updateProfile(
                    logged.getId(),name,email,phone,licenseNo,
                    idDocumentNo,addressLine,city,dob,customer);
            if (!ok) return "redirect:/profile?error=emailExists";

            User fresh = users.findById(logged.getId());
            if (fresh != null) session.setAttribute("loggedUser", fresh);

            audit.log(logged.getId(),"UPDATE_PROFILE",logged.getId(),
                    customer ? "Profile and verification details updated" : "Profile updated");
            return "redirect:/profile?msg=updated";
        } catch (SQLException e) {
            System.err.println("[UserController] Profile update database error: " + e.getMessage());
            e.printStackTrace();
            return "redirect:/profile?error=db";
        }
    }

    // =========================================================
    // DELETE / DEACTIVATE CUSTOMER ACCOUNT
    // =========================================================

    @PostMapping("/user/delete")
    public String handleDelete(HttpSession session) {

        Object x = session.getAttribute("loggedUser");

        if (!(x instanceof User logged)) {
            return "redirect:/login";
        }

        if (!"CUSTOMER".equalsIgnoreCase(logged.getRole())) {
            return "redirect:/profile?error=notAllowed";
        }

        try {

            users.softDelete(logged.getId());

            audit.log(
                    logged.getId(),
                    "DEACTIVATE_ACCOUNT",
                    logged.getId(),
                    "Customer deactivated own account"
            );

            session.invalidate();

            return "redirect:/login?msg=deleted";

        } catch (SQLException e) {

            System.err.println(
                    "[UserController] Delete account database error: "
                            + e.getMessage()
            );

            e.printStackTrace();

            return "redirect:/profile?error=db";
        }
    }

    // =========================================================
    // REGISTRATION VALIDATION
    // =========================================================

    private static String validateRegistration(
            String name,
            String email,
            String password,
            String phone,
            String licenseNo) {

        String profileError = validateProfile(
                name,
                email,
                phone,
                licenseNo
        );

        if (profileError != null) {
            return profileError;
        }

        /*
         * Password:
         * 8-128 characters
         * at least one letter
         * at least one number
         */
        if (password == null
                || password.length() < 8
                || password.length() > 128
                || !password.matches(".*[A-Za-z].*")
                || !password.matches(".*\\d.*")) {

            return "weakPassword";
        }

        return null;
    }

    // =========================================================
    // PROFILE VALIDATION
    // =========================================================

    private static String validateProfile(
            String name,
            String email,
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
        // Phone
        // -------------------------

        if (phone == null
                || phone.isBlank()
                || !PHONE.matcher(phone).matches()) {

            return "invalidPhone";
        }

        // -------------------------
        // Driving licence / ID
        // -------------------------

        if (licenseNo == null
                || licenseNo.isBlank()
                || !LICENSE.matcher(licenseNo).matches()) {

            return "invalidLicense";
        }

        return null;
    }
    private static boolean validIdDocument(String value) {

        if (value == null || value.isBlank()) {
            return true;
        }

        String document = value.trim();

        return document.matches(
                "(?:\\d{12}|\\d{9}[VvXx]|[A-Za-z]\\d{7})"
        );
    }
    private static boolean validNewPassword(String password) {
        return password != null
                && password.length() >= 8
                && password.length() <= 128
                && password.matches(".*[A-Za-z].*")
                && password.matches(".*\\d.*");
    }

    private static String passwordErrorRedirect(boolean authenticatedFlow, String error) {
        return authenticatedFlow
                ? "redirect:/profile?passwordError=" + url(error)
                : "redirect:/change-password?error=" + url(error);
    }

    // =========================================================
    // PHONE NORMALIZATION
    // =========================================================

    /**
     * Converts accepted Sri Lankan mobile formats into:
     *
     * 0771234567
     *
     * Examples:
     * +94771234567 -> 0771234567
     * 94771234567  -> 0771234567
     * 077 123 4567 -> 0771234567
     */
    private static String normalizeSriLankanPhone(String phone) {

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
    private static String registrationErrorRedirect(
            String error,
            String name,
            String email,
            String phone,
            String licenseNo) {

        return "redirect:/register"
                + "?error=" + url(error)
                + "&name=" + url(name)
                + "&email=" + url(email)
                + "&phone=" + url(phone)
                + "&licenseNo=" + url(licenseNo);
    }

    private static String url(String value) {

        return URLEncoder.encode(
                value == null ? "" : value,
                StandardCharsets.UTF_8
        );
    }

    // =========================================================
    // SAFE STRING HANDLING
    // =========================================================

    private static String safeTrim(String value) {

        return value == null
                ? ""
                : value.trim();
    }
}
