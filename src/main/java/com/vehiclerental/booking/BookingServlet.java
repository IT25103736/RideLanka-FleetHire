package com.vehiclerental.booking;

import com.vehiclerental.model.User;
import com.vehiclerental.model.Vehicle;
import com.vehiclerental.notification.NotificationService;
import com.vehiclerental.notification.WhatsAppChannel;
import com.vehiclerental.util.VehicleFileHandler;
import jakarta.servlet.ServletException;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import java.io.IOException;
import java.time.LocalDate;
import java.time.LocalDateTime;
import java.time.format.DateTimeFormatter;
import java.util.ArrayList;
import java.util.List;

/**
 * C02 — Booking Servlet.
 * Routes:
 *   GET  /booking?action=list   → My Bookings
 *   GET  /booking?action=form   → New Booking form (optionally pre-fills ?vehicleId=&dailyRate=)
 *   POST /booking?action=create → save booking, forward to confirmation
 *   POST /booking?action=cancel → soft-delete (status=CANCELLED)
 */
public class BookingServlet extends HttpServlet {

    private static final Logger log = LoggerFactory.getLogger(BookingServlet.class);
    private static final DateTimeFormatter FMT = DateTimeFormatter.ofPattern("yyyy-MM-dd");
    private final VehicleFileHandler vehicleHandler = new VehicleFileHandler();

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        String action = request.getParameter("action");
        if (action == null) action = "list";

        String userId = requireLoggedUserId(request, response);
        if (userId == null) return;

        switch (action) {
            case "list":
                renderMyBookings(userId, request, response);
                break;
            case "form":
                renderForm(request, response);
                break;
            case "cancel":
                cancel(request, response);
                break;
            default:
                response.sendRedirect(request.getContextPath() + "/booking?action=list");
        }
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        String action = request.getParameter("action");
        if (action == null) action = "create";

        String userId = requireLoggedUserId(request, response);
        if (userId == null) return;

        if ("cancel".equalsIgnoreCase(action)) {
            cancel(request, response);
            return;
        }

        // default action = create
        create(userId, request, response);
    }

    /* ─────────────────────────  HANDLERS  ───────────────────────── */

    private void renderMyBookings(String userId, HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        List<Booking> all = readAllSafe();

        // OOP: load into linked list (demonstrates BookingLinkedList)
        BookingLinkedList list = new BookingLinkedList();
        for (Booking b : all) list.addBooking(b);

        List<Booking> userAll       = new ArrayList<>();
        List<Booking> active        = new ArrayList<>();
        List<Booking> cancelled     = new ArrayList<>();
        for (Booking b : all) {
            if (!b.getUserId().equalsIgnoreCase(userId)) continue;
            userAll.add(b);
            if ("ACTIVE".equalsIgnoreCase(b.getStatus()))     active.add(b);
            else if ("CANCELLED".equalsIgnoreCase(b.getStatus())) cancelled.add(b);
        }

        request.setAttribute("bookings",          userAll);
        request.setAttribute("activeBookings",    active);
        request.setAttribute("cancelledBookings", cancelled);
        request.getRequestDispatcher("/WEB-INF/views/booking/myBookings.jsp")
                .forward(request, response);
    }

    private void renderForm(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        // Optional pre-fill if coming from search results
        String vehicleId = request.getParameter("vehicleId");
        if (vehicleId != null && !vehicleId.isEmpty()) {
            Vehicle v = vehicleHandler.getVehicleById(vehicleId);
            if (v != null) {
                request.setAttribute("selectedVehicle", v);
                request.setAttribute("dailyRate",       v.getRentalPricePerDay());
            }
            request.setAttribute("vehicleId", vehicleId);
        }

        // Provide the full vehicle list + pickup option lists to the dropdowns
        request.setAttribute("vehicleList",     vehicleHandler.getAllVehicles());
        request.setAttribute("pickupLocations", PICKUP_LOCATIONS);
        request.setAttribute("pickupTimes",     PICKUP_TIMES);
        request.setAttribute("advanceLeadDays", ADVANCE_PAY_LEAD_DAYS);
        request.getRequestDispatcher("/WEB-INF/views/booking/bookingForm.jsp")
                .forward(request, response);
    }

    /** Fixed per-rental fees — wired to the price-breakdown box in bookingForm.jsp. */
    public static final double DRIVER_FEE_PER_DAY = 4500.0;
    public static final double INSURANCE_PER_DAY  = 1200.0;
    public static final double DELIVERY_FEE       = 1500.0;
    public static final double SECURITY_DEPOSIT   = 25_000.0;

    /** Pick-up cities the operator services. */
    public static final List<String> PICKUP_LOCATIONS = List.of("Colombo", "Kandy");

    /** Pick-up time slots, hourly 09:00–21:00 inclusive (24h, "HH:00"). */
    public static final List<String> PICKUP_TIMES = List.of(
            "09:00", "10:00", "11:00", "12:00", "13:00", "14:00",
            "15:00", "16:00", "17:00", "18:00", "19:00", "20:00", "21:00");

    /** Advance bookings must be paid (and therefore booked) at least this many days before start. */
    public static final int ADVANCE_PAY_LEAD_DAYS = 7;

    private void create(String userId, HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        String vehicleId      = request.getParameter("vehicleId");
        String startStr       = request.getParameter("startDate");
        String durationStr    = request.getParameter("duration");
        String dailyRateStr   = request.getParameter("dailyRate");
        String withDriver     = request.getParameter("withDriver");
        String acceptTerms    = request.getParameter("acceptTerms");
        String pickupLocation = request.getParameter("pickupLocation");
        String pickupTime     = request.getParameter("pickupTime");

        if (vehicleId == null || startStr == null || durationStr == null) {
            forwardFormWithError("Missing required fields.", request, response);
            return;
        }
        if (!"true".equalsIgnoreCase(acceptTerms) && !"on".equalsIgnoreCase(acceptTerms)) {
            forwardFormWithError("You must accept the rental policies before booking.",
                    request, response);
            return;
        }
        if (pickupLocation == null || !PICKUP_LOCATIONS.contains(pickupLocation)) {
            forwardFormWithError("Please pick a pick-up location (Colombo or Kandy).",
                    request, response);
            return;
        }
        if (pickupTime == null || !PICKUP_TIMES.contains(pickupTime)) {
            forwardFormWithError("Please pick a pick-up time between 9:00 AM and 9:00 PM.",
                    request, response);
            return;
        }

        int    duration  = parseInt(durationStr, 1);
        double dailyRate = parseDouble(dailyRateStr, 0);

        LocalDate start;
        try { start = LocalDate.parse(startStr, FMT); }
        catch (Exception ex) {
            forwardFormWithError("Invalid start date.", request, response);
            return;
        }
        LocalDate end = start.plusDays(Math.max(1, duration));

        String bookingId = "B" + System.currentTimeMillis();
        boolean driverChecked = "true".equalsIgnoreCase(withDriver) || "on".equalsIgnoreCase(withDriver);

        LocalDate     today = LocalDate.now();
        LocalDateTime now   = LocalDateTime.now();

        // CLASSIFY — pure routing, no failure mode.
        Booking booking = Booking.classify(bookingId, userId, vehicleId, start, end, today);
        booking.setWithDriver(driverChecked);
        booking.setPickupLocation(pickupLocation);
        booking.setPickupTime(pickupTime);
        booking.setCustomerPhone(request.getParameter("phone"));

        long daysAhead = java.time.temporal.ChronoUnit.DAYS.between(today, start);
        log.info("Booking {} classified as {} (daysAhead={}, start={}, today={})",
                 bookingId, booking.getBookingType(), daysAhead, start, today);

        // TYPE-SPECIFIC RULES — polymorphic. Subclass owns its own constraints.
        String ruleError = booking.validateBookingRules(now);
        if (ruleError != null) {
            log.warn("Booking {} rejected by {} rule: {} (daysAhead={}, duration={}, pickup={})",
                     bookingId, booking.getBookingType(), ruleError, daysAhead, duration, pickupTime);
            forwardFormWithError(ruleError, request, response);
            return;
        }

        // GENERIC DATE/OVERLAP — unchanged DateValidator call.
        List<Booking> existing = readAllSafe();
        String dateError = DateValidator.validate(start.toString(), end.toString(), existing, vehicleId);
        if (dateError != null) {
            log.warn("Booking {} rejected by date validator: {}", bookingId, dateError);
            forwardFormWithError(dateError, request, response);
            return;
        }

        try { BookingFileHandler.saveBooking(booking); }
        catch (IOException ex) {
            forwardFormWithError("Could not save booking: " + ex.getMessage(), request, response);
            return;
        }

        // ── Polymorphic cost (tiered Instant / flat Advance) + fixed fees ──
        // Computed BEFORE notification fan-out so the WhatsApp message can include
        // the total — otherwise the customer's confirmation has no price line.
        double baseCost  = booking.calculateBaseCost(dailyRate, duration, today);
        double driverFee = driverChecked ? DRIVER_FEE_PER_DAY * duration : 0;
        double insurance = INSURANCE_PER_DAY * duration;
        double delivery  = DELIVERY_FEE;
        double totalCost = baseCost + driverFee + insurance + delivery;

        // ── Notifications + WhatsApp click-to-chat (post-save, never blocks booking) ──
        try {
            HttpSession session = request.getSession(false);
            User user = (session != null && session.getAttribute("loggedUser") instanceof User u) ? u : null;
            Vehicle vehicle = vehicleHandler.getVehicleById(vehicleId);
            String customerPhone = request.getParameter("phone");
            String baseUrl = request.getScheme() + "://" + request.getServerName()
                           + (request.getServerPort() == 80 || request.getServerPort() == 443
                              ? "" : (":" + request.getServerPort()));
            NotificationService.get().bookingConfirmed(booking, user, vehicle,
                    customerPhone, totalCost, request.getContextPath(), baseUrl);
            // Expose the wa.me URL so bookingConfirmation.jsp can render an "Open WhatsApp" button.
            request.setAttribute("whatsappUrl", WhatsAppChannel.getLastBuiltUrl());
        } catch (RuntimeException notifyEx) {
            // A failed notification must NEVER break the booking response.
            log.warn("Notification fan-out failed for booking {}: {}",
                    bookingId, notifyEx.getMessage());
        }

        // Log applied surcharge tier (Advance returns 0 → no log line).
        double pct = booking.getAppliedSurcharge(today);
        if (pct > 0) {
            double raw = Math.max(1, duration) * dailyRate;
            log.info("Booking {} surcharge applied: tier={}%, raw={}, surchargeAmount={}, total={}",
                     bookingId, (int)(pct * 100), raw, baseCost - raw, totalCost);
        }
        request.setAttribute("appliedSurcharge", pct);  // for confirmation JSP

        String customerName = request.getParameter("customerName");

        // Polymorphic post-create routing — Instant pays now, Advance previews.
        if (booking.requiresImmediatePayment()) {
            response.sendRedirect(request.getContextPath()
                    + "/payment/checkout?bookingId=" + bookingId
                    + "&amount=" + totalCost
                    + "&customerName=" + java.net.URLEncoder.encode(
                            customerName == null ? "" : customerName,
                            java.nio.charset.StandardCharsets.UTF_8));
            return;
        }

        request.setAttribute("booking",      booking);
        request.setAttribute("customerName", customerName);
        request.setAttribute("totalCost",    totalCost);
        request.setAttribute("baseCost",     baseCost);
        request.setAttribute("driverFee",    driverFee);
        request.setAttribute("insurance",    insurance);
        request.setAttribute("delivery",     delivery);
        request.setAttribute("deposit",      SECURITY_DEPOSIT);
        request.setAttribute("duration",     duration);
        request.setAttribute("dailyRate",    dailyRate);
        request.setAttribute("withDriver",   driverChecked);
        request.getRequestDispatcher("/WEB-INF/views/booking/bookingConfirmation.jsp")
                .forward(request, response);
    }

    private void cancel(HttpServletRequest request, HttpServletResponse response) throws IOException {
        String bookingId = request.getParameter("bookingId");
        if (bookingId != null && !bookingId.isEmpty()) {
            try { BookingFileHandler.updateBookingStatus(bookingId, "CANCELLED"); }
            catch (IOException ignored) {}

            // Notify the user + admins. Wrapped — a notification failure cannot
            // break the redirect back to "My Bookings".
            try {
                HttpSession session = request.getSession(false);
                User user = (session != null && session.getAttribute("loggedUser") instanceof User u) ? u : null;
                if (user != null) {
                    NotificationService.get().bookingCancelled(bookingId, user);
                }
            } catch (RuntimeException notifyEx) {
                log.warn("Cancel notification failed for booking {}: {}",
                        bookingId, notifyEx.getMessage());
            }
        }
        response.sendRedirect(request.getContextPath() + "/booking?action=list");
    }

    /* ─────────────────────────  HELPERS  ───────────────────────── */

    private void forwardFormWithError(String msg, HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        request.setAttribute("errorMsg", msg);
        request.setAttribute("vehicleList",     vehicleHandler.getAllVehicles());
        request.setAttribute("pickupLocations", PICKUP_LOCATIONS);
        request.setAttribute("pickupTimes",     PICKUP_TIMES);
        request.setAttribute("advanceLeadDays", ADVANCE_PAY_LEAD_DAYS);
        request.getRequestDispatcher("/WEB-INF/views/booking/bookingForm.jsp")
                .forward(request, response);
    }

    private List<Booking> readAllSafe() {
        try { return BookingFileHandler.readAllBookings(); }
        catch (IOException e) { return new ArrayList<>(); }
    }

    /**
     * Pull the logged-in user's ID from session; redirect to /login when missing.
     * Returns null if redirected.
     */
    private String requireLoggedUserId(HttpServletRequest request, HttpServletResponse response) throws IOException {
        HttpSession session = request.getSession(false);
        Object logged = session == null ? null : session.getAttribute("loggedUser");
        if (logged instanceof User u) return u.getId();
        response.sendRedirect(request.getContextPath() + "/login");
        return null;
    }

    private static int    parseInt(String s, int def)    { try { return Integer.parseInt(s); } catch (Exception e) { return def; } }
    private static double parseDouble(String s, double d){ try { return Double.parseDouble(s); } catch (Exception e) { return d; } }
}
