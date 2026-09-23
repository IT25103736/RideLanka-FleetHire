package com.vehiclerental;

import com.vehiclerental.booking.Booking;
import com.vehiclerental.booking.BookingFileHandler;
import com.vehiclerental.booking.BookingServlet;
import com.vehiclerental.model.User;
import com.vehiclerental.model.Vehicle;
import com.vehiclerental.payment.*;
import com.vehiclerental.util.UserFileHandler;
import com.vehiclerental.util.VehicleFileHandler;
import jakarta.servlet.http.HttpSession;
import org.springframework.stereotype.Controller;
import org.springframework.web.bind.annotation.*;
import org.springframework.ui.Model;

import java.io.IOException;
import java.time.Instant;
import java.time.LocalDate;
import java.time.ZoneId;
import java.time.temporal.ChronoUnit;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.HashSet;
import java.util.List;
import java.util.Map;
import java.util.Set;

/**
 * C04 — Payment Gateway.
 * Routes:
 *   GET  /payment/checkout    → checkout form
 *   POST /payment/process     → process and persist payment, render invoice
 *   GET  /payment/promotions  → promo/loyalty page
 *   GET  /payment/list        → admin payment list
 *   GET  /payment/delete?id=  → admin delete
 */
@Controller //telling this is the controller class
//acts as the middleman b/w the user interface and the backend logic
//handle http request
@RequestMapping("/payment")
public class PaymentServlet {

    private static double loyaltyPoints = 100.0;

    @GetMapping("/checkout") //use this when user want to view something
    public String showCheckout(
            @RequestParam(required = false) String bookingId,
            @RequestParam(required = false, defaultValue = "0") double amount,
            @RequestParam(required = false) String customerName,
            Model model) {

        // Without a booking + non-zero amount there is nothing to pay for —
        // bounce to My Bookings so the user can pick one.
        if (bookingId == null || bookingId.isBlank() || amount <= 0) {
            return "redirect:/booking?action=list";
        }

        Booking booking = findBooking(bookingId);
        if (booking == null) return "redirect:/booking?action=list";

        model.addAttribute("bookingId",     bookingId);
        model.addAttribute("amount",        amount);
        model.addAttribute("customerName",  customerName);
        model.addAttribute("vehicleId",     booking.getVehicleId());
        model.addAttribute("startDate",     booking.getStartDate());
        model.addAttribute("endDate",       booking.getEndDate());
        model.addAttribute("duration",      durationDays(booking));
        model.addAttribute("loyaltyPoints", loyaltyPoints);
        return "checkout";
    }

    @PostMapping("/process") //use this when user submits sensitive data
    public String processPayment(
            @RequestParam String paymentMethod,
            @RequestParam(defaultValue = "Guest") String customerName,
            @RequestParam(defaultValue = "0") double amount,
            @RequestParam(required = false) String cardNumber,
            @RequestParam(required = false) String cardHolderName,
            @RequestParam(required = false) String expiryDate,
            @RequestParam(required = false) String walletType,
            @RequestParam(required = false) String walletNumber,
            @RequestParam(required = false, defaultValue = "0") double walletBalance,
            @RequestParam(required = false) String promoCode,
            @RequestParam(required = false) String bookingId,
            Model model) {

        // Server-side guard: don't process a payment without a real booking + amount.
        if (bookingId == null || bookingId.isBlank() || amount <= 0) {
            model.addAttribute("errorMsg",
                    "We couldn't find a booking to charge against. Please start checkout from My Bookings.");
            model.addAttribute("loyaltyPoints", loyaltyPoints);
            return "checkout";
        }

        // Enforce the advance-payment deadline: payment must land at least
        // BookingServlet.ADVANCE_PAY_LEAD_DAYS days before the pickup date.
        Booking bookingForCheck = findBooking(bookingId);
        if (bookingForCheck != null && "ADVANCE".equalsIgnoreCase(bookingForCheck.getBookingType())) {
            try {
                long daysToStart = ChronoUnit.DAYS.between(
                        LocalDate.now(), LocalDate.parse(bookingForCheck.getStartDate()));
                if (daysToStart < BookingServlet.ADVANCE_PAY_LEAD_DAYS) {
                    model.addAttribute("errorMsg",
                            "Payment for advance booking " + bookingId + " is past the "
                            + BookingServlet.ADVANCE_PAY_LEAD_DAYS + "-day deadline (start date "
                            + bookingForCheck.getStartDate() + "). Please contact support.");
                    model.addAttribute("bookingId",     bookingId);
                    model.addAttribute("amount",        amount);
                    model.addAttribute("customerName",  customerName);
                    model.addAttribute("loyaltyPoints", loyaltyPoints);
                    return "checkout";
                }
            } catch (Exception ignored) {}
        }

        String paymentId = nextPaymentId();
        String date      = LocalDate.now().toString();

        // Promo & loyalty
        double finalAmount = amount;
        String promoMessage = "";
        if ("SAVE10".equalsIgnoreCase(promoCode)) {
            finalAmount = amount * 0.90;
            promoMessage = "Promo code applied! 10% discount.";
        } else if ("AVURUDU20".equalsIgnoreCase(promoCode)) {
            finalAmount = amount * 0.80;
            promoMessage = "Avurudu special! 20% discount.";
        } else if ("LOYAL20".equalsIgnoreCase(promoCode)) {
            if (loyaltyPoints >= 20) {
                finalAmount = Math.max(0, amount - 20);
                loyaltyPoints -= 20;
                promoMessage = "20 loyalty points redeemed (LKR 20 off).";
            } else {
                promoMessage = "Not enough loyalty points.";
            }
        }

        Payment payment;
        if ("card".equalsIgnoreCase(paymentMethod)) {
            String masked = maskCard(cardNumber);
            payment = new CardPayment(paymentId, customerName, finalAmount,
                    date, masked, cardHolderName, expiryDate);
        } else {
            payment = new WalletPayment(paymentId, customerName, finalAmount,
                    date, walletType, walletNumber, walletBalance);
        }
        // Link this payment back to its booking — drives myPayments status badge
        // and lets us show payment receipt info on the booking row.
        payment.setBookingId(bookingId);

        String result = payment.processPayment();
        PaymentFileHandler.savePayment(payment);

        // Mark linked booking ACTIVE after successful pay
        if (bookingId != null && !bookingId.isEmpty() && "Success".equals(payment.getStatus())) {
            try { com.vehiclerental.booking.BookingFileHandler.updateBookingStatus(bookingId, "ACTIVE"); }
            catch (java.io.IOException ignored) {}
        }

        // Award loyalty: 1 point per 1000 LKR spent
        if ("Success".equals(payment.getStatus())) {
            loyaltyPoints += Math.floor(finalAmount / 1000.0);
        }

        String invoice = generateInvoice(payment, promoMessage);
        PaymentFileHandler.saveInvoice(invoice);

        // Resolve booking once so the invoice can show vehicle + dates without
        // relying on form params that the checkout page never carried.
        Booking booking = findBooking(bookingId);
        if (booking != null) {
            model.addAttribute("vehicleId", booking.getVehicleId());
            model.addAttribute("startDate", booking.getStartDate());
            model.addAttribute("endDate",   booking.getEndDate());
            model.addAttribute("duration",  durationDays(booking));
        }

        model.addAttribute("bookingId",     bookingId);
        model.addAttribute("paymentMethod", paymentMethod);
        model.addAttribute("result",        result);
        model.addAttribute("invoice",       invoice);
        model.addAttribute("promoMessage",  promoMessage);
        model.addAttribute("payment",       payment);
        return "invoice";
    }

    @GetMapping("/promotions")
    public String showPromotions(Model model) {
        model.addAttribute("loyaltyPoints", loyaltyPoints);
        return "promotions";
    }

    @GetMapping("/delete")
    public String deletePayment(@RequestParam String paymentId, Model model) {
        boolean deleted = PaymentFileHandler.deletePayment(paymentId);
        model.addAttribute("payments",        PaymentFileHandler.readAllPayments());
        model.addAttribute("pendingAdvances", computePendingAdvances());
        model.addAttribute("message",
                deleted ? "Payment " + paymentId + " deleted." : "Payment not found.");
        return "paymentList";
    }

    @GetMapping("/list")
    public String showPayments(Model model) {
        model.addAttribute("payments",        PaymentFileHandler.readAllPayments());
        model.addAttribute("pendingAdvances", computePendingAdvances());
        model.addAttribute("message",         "");
        return "paymentList";
    }

    /**
     * Find every ACTIVE Advance booking that does not yet have a {@code Success}
     * payment row in {@code data/payments.txt}. The result drives the
     * "Pending advance payments" section on the admin payment-log page so staff
     * can see who still owes money and chase those bookings before the 7-day
     * payment deadline.
     * <p>
     * Cancelled bookings and Instant bookings (which must pay immediately) are
     * excluded — Instants without a payment are pathological edge cases, not
     * a pending workflow item.
     */
    private List<PendingAdvanceRow> computePendingAdvances() {
        // 1) Set of bookingIds that already have a Success payment.
        Set<String> paidBookingIds = new HashSet<>();
        for (String line : PaymentFileHandler.readAllPayments()) {
            String[] parts = line.split("\\|");
            if (parts.length < 10) continue;
            if (!"Success".equalsIgnoreCase(parts[5].trim())) continue;
            paidBookingIds.add(parts[9].trim());
        }

        // 2) User + Vehicle lookup so we can render names instead of bare IDs.
        Map<String, String> nameByUser = new HashMap<>();
        try {
            for (User u : UserFileHandler.getAllUsers()) nameByUser.put(u.getId(), u.getName());
        } catch (IOException ignored) {}

        Map<String, Vehicle> vehicleById = new HashMap<>();
        for (Vehicle v : new VehicleFileHandler().getAllVehicles()) {
            vehicleById.put(v.getVehicleId(), v);
        }

        // 3) Scan bookings, keep ACTIVE Advances without a payment.
        List<Booking> bookings;
        try { bookings = BookingFileHandler.readAllBookings(); }
        catch (IOException e) { bookings = new ArrayList<>(); }

        List<PendingAdvanceRow> rows = new ArrayList<>();
        LocalDate today = LocalDate.now();
        for (Booking b : bookings) {
            if (!"ADVANCE".equalsIgnoreCase(b.getBookingType())) continue;
            if (!"ACTIVE".equalsIgnoreCase(b.getStatus()))       continue;
            if (paidBookingIds.contains(b.getBookingId()))       continue;

            Vehicle v = vehicleById.get(b.getVehicleId());
            String customerName  = nameByUser.getOrDefault(b.getUserId(), b.getUserId());
            String vehicleLabel  = v == null ? b.getVehicleId() : (v.getBrand() + " " + v.getModel());
            long   duration      = durationDays(b);
            double dailyRate     = v == null ? 0.0 : v.getRentalPricePerDay();
            double estimatedCost = estimateCost(dailyRate, duration, b.isWithDriver());
            LocalDate dueDate    = computeDueDate(b);
            long daysUntilDue    = dueDate == null ? Long.MAX_VALUE
                                                   : ChronoUnit.DAYS.between(today, dueDate);

            rows.add(new PendingAdvanceRow(b.getBookingId(), customerName, vehicleLabel,
                    b.getStartDate(), b.getEndDate(), duration, dueDate, daysUntilDue,
                    estimatedCost, b.isWithDriver(), b.getPickupLocation()));
        }

        // Soonest-due first so admins triage the most urgent rows.
        rows.sort((a, b) -> Long.compare(a.daysUntilDue, b.daysUntilDue));
        return rows;
    }

    /** Same fee formula as BookingServlet so the estimate matches what the
     *  customer was shown on the confirmation page. */
    private static double estimateCost(double dailyRate, long days, boolean withDriver) {
        if (days <= 0) days = 1;
        double base      = dailyRate * days;
        double driver    = withDriver ? BookingServlet.DRIVER_FEE_PER_DAY * days : 0;
        double insurance = BookingServlet.INSURANCE_PER_DAY  * days;
        double delivery  = BookingServlet.DELIVERY_FEE;
        return base + driver + insurance + delivery;
    }

    private static LocalDate computeDueDate(Booking b) {
        try {
            // Advance bookings: payment is due 7 days before pickup.
            return LocalDate.parse(b.getStartDate())
                    .minusDays(BookingServlet.ADVANCE_PAY_LEAD_DAYS);
        } catch (Exception ex) { return null; }
    }

    /**
     * View-model row for the "Pending advance payments" table. Public fields so
     * the JSP can read them with the standard property syntax (Spring's EL
     * resolver wraps these like beans).
     */
    public static class PendingAdvanceRow {
        public final String    bookingId;
        public final String    customerName;
        public final String    vehicleLabel;
        public final String    startDate;
        public final String    endDate;
        public final long      duration;
        public final LocalDate dueDate;
        public final long      daysUntilDue;
        public final double    estimatedTotal;
        public final boolean   withDriver;
        public final String    pickupLocation;

        public PendingAdvanceRow(String bookingId, String customerName, String vehicleLabel,
                                 String startDate, String endDate, long duration,
                                 LocalDate dueDate, long daysUntilDue, double estimatedTotal,
                                 boolean withDriver, String pickupLocation) {
            this.bookingId      = bookingId;
            this.customerName   = customerName;
            this.vehicleLabel   = vehicleLabel;
            this.startDate      = startDate;
            this.endDate        = endDate;
            this.duration       = duration;
            this.dueDate        = dueDate;
            this.daysUntilDue   = daysUntilDue;
            this.estimatedTotal = estimatedTotal;
            this.withDriver     = withDriver;
            this.pickupLocation = pickupLocation;
        }

        public String    getBookingId()      { return bookingId; }
        public String    getCustomerName()   { return customerName; }
        public String    getVehicleLabel()   { return vehicleLabel; }
        public String    getStartDate()      { return startDate; }
        public String    getEndDate()        { return endDate; }
        public long      getDuration()       { return duration; }
        public LocalDate getDueDate()        { return dueDate; }
        public long      getDaysUntilDue()   { return daysUntilDue; }
        public double    getEstimatedTotal() { return estimatedTotal; }
        public boolean   isWithDriver()      { return withDriver; }
        public String    getPickupLocation() { return pickupLocation; }
    }

    /**
     * GET /payment/history — the signed-in user's bookings with payment status.
     *
     * Each booking is joined to its payment (via the bookingId pipe-field
     * appended to payment lines) so the view can show Pending / Paid / Cancelled
     * / Completed badges and offer Pay-or-Cancel affordances on pending rows.
     *
     * Legacy payment lines without a bookingId are surfaced in a separate
     * "unlinked transactions" section so older receipts don't vanish silently.
     */
    @GetMapping("/history")
    public String showMyPayments(HttpSession session, Model model) {
        Object logged = session.getAttribute("loggedUser");
        if (!(logged instanceof User u)) {
            return "redirect:/login";
        }

        // 1. Index this user's payments by bookingId (where present)
        Map<String, String[]> paidByBooking = new HashMap<>();
        List<String> unlinkedPayments = new ArrayList<>();
        for (String line : PaymentFileHandler.readAllPayments()) {
            String[] parts = line.split("\\|");
            if (parts.length < 6) continue;
            if (!u.getName().equalsIgnoreCase(parts[2].trim())) continue;

            String bid = (parts.length >= 10) ? parts[9].trim() : "";
            if (!bid.isEmpty()) {
                paidByBooking.put(bid, parts);
            } else {
                unlinkedPayments.add(line);
            }
        }

        // 2. Walk this user's bookings, joining the payment side-data
        List<BookingPayView> rows = new ArrayList<>();
        double totalSpent  = 0;
        int    pendingCount = 0;
        int    paidCount    = 0;
        for (Booking b : readUserBookings(u.getId())) {
            BookingPayView v = new BookingPayView(b, computeBookingTotal(b));

            String[] p = paidByBooking.get(b.getBookingId());
            boolean cancelled = "CANCELLED".equalsIgnoreCase(b.getStatus());
            boolean completed = "COMPLETED".equalsIgnoreCase(b.getStatus());

            if (cancelled) {
                v.setPayStatus("CANCELLED");
            } else if (p != null && "Success".equalsIgnoreCase(p[5].trim())) {
                v.setPayStatus(completed ? "COMPLETED" : "PAID");
                v.setPaymentMethod(p[0]);
                v.setPaymentId(p[1]);
                v.setPaymentDate(p[4]);
                try { v.setPaymentAmount(Double.parseDouble(p[3].trim())); }
                catch (NumberFormatException ignored) {}
                totalSpent += v.getPaymentAmount();
                paidCount++;
            } else if (completed) {
                v.setPayStatus("COMPLETED_UNPAID");
            } else {
                v.setPayStatus("PENDING");
                pendingCount++;
            }
            rows.add(v);
        }

        model.addAttribute("rows",             rows);
        model.addAttribute("unlinkedPayments", unlinkedPayments);
        model.addAttribute("totalSpent",       totalSpent);
        model.addAttribute("pendingCount",     pendingCount);
        model.addAttribute("paidCount",        paidCount);
        model.addAttribute("loyaltyPoints",    loyaltyPoints);
        return "myPayments";
    }

    /* ─────────────────────────  HELPERS  ───────────────────────── */

    /** Read existing payments and return the next free PAY### identifier. */
    private static String nextPaymentId() {
        List<String> all = PaymentFileHandler.readAllPayments();
        int max = 0;
        for (String line : all) {
            // method|PAY00X|... — pipe or comma compatible
            String[] parts = line.split("[|,]");
            if (parts.length < 2) continue;
            String id = parts[1].trim();
            if (id.toUpperCase().startsWith("PAY")) {
                try { max = Math.max(max, Integer.parseInt(id.substring(3))); }
                catch (Exception ignored) {}
            }
        }
        return String.format("PAY%03d", max + 1);
    }

    private static final VehicleFileHandler VEHICLES = new VehicleFileHandler();

    /** Bookings belonging to a given user id, in file order. */
    private static List<Booking> readUserBookings(String userId) {
        List<Booking> mine = new ArrayList<>();
        try {
            for (Booking b : BookingFileHandler.readAllBookings()) {
                if (userId.equalsIgnoreCase(b.getUserId())) mine.add(b);
            }
        } catch (IOException ignored) {}
        return mine;
    }

    /**
     * Replicates the cost math in BookingServlet#create so the myPayments page
     * can display a pre-computed Pay-now amount for unpaid bookings. Mirrors
     * the polymorphic base cost + flat per-rental fees from BookingServlet.
     */
    private static double computeBookingTotal(Booking b) {
        Vehicle v = VEHICLES.getVehicleById(b.getVehicleId());
        if (v == null) return 0;
        int duration  = durationDays(b);
        double rate   = v.getRentalPricePerDay();
        double base   = b.calculateBaseCost(rate, duration, creationDateOf(b));
        double driver = b.isWithDriver() ? BookingServlet.DRIVER_FEE_PER_DAY * duration : 0;
        double ins    = BookingServlet.INSURANCE_PER_DAY * duration;
        double del    = BookingServlet.DELIVERY_FEE;
        return base + driver + ins + del;
    }

    /**
     * Booking + payment join row used by myPayments.jsp. Status is one of
     * PENDING / PAID / CANCELLED / COMPLETED / COMPLETED_UNPAID.
     */
    public static class BookingPayView {
        private final Booking booking;
        private final double  computedTotal;
        private String payStatus = "PENDING";
        private String paymentId;
        private String paymentDate;
        private String paymentMethod;   // "CARD" or "WALLET"
        private double paymentAmount;

        public BookingPayView(Booking booking, double computedTotal) {
            this.booking       = booking;
            this.computedTotal = computedTotal;
        }

        public Booking getBooking()        { return booking; }
        public double  getComputedTotal()  { return computedTotal; }
        public String  getPayStatus()      { return payStatus; }
        public String  getPaymentId()      { return paymentId; }
        public String  getPaymentDate()    { return paymentDate; }
        public String  getPaymentMethod()  { return paymentMethod; }
        public double  getPaymentAmount()  { return paymentAmount; }
        public int     getDurationDays()   { return durationDays(booking); }

        public boolean isPending()   { return "PENDING".equals(payStatus); }
        public boolean isPaid()      { return "PAID".equals(payStatus) || "COMPLETED".equals(payStatus); }
        public boolean isCancelled() { return "CANCELLED".equals(payStatus); }

        public void setPayStatus(String s)         { this.payStatus = s; }
        public void setPaymentId(String s)         { this.paymentId = s; }
        public void setPaymentDate(String s)       { this.paymentDate = s; }
        public void setPaymentMethod(String s)     { this.paymentMethod = s; }
        public void setPaymentAmount(double a)     { this.paymentAmount = a; }
    }

    /** Look up a booking by id from bookings.txt, returns null on miss or I/O error. */
    private static Booking findBooking(String bookingId) {
        if (bookingId == null || bookingId.isBlank()) return null;
        try {
            for (Booking b : BookingFileHandler.readAllBookings()) {
                if (bookingId.equals(b.getBookingId())) return b;
            }
        } catch (IOException ignored) {}
        return null;
    }

    /** Days between booking start and end dates, clamped to at least 1. */
    private static int durationDays(Booking booking) {
        try {
            long days = ChronoUnit.DAYS.between(
                    LocalDate.parse(booking.getStartDate()),
                    LocalDate.parse(booking.getEndDate()));
            return (int) Math.max(1, days);
        } catch (Exception e) {
            return 1;
        }
    }

    private static String maskCard(String cardNumber) {
        if (cardNumber == null) return "";
        String digits = cardNumber.replaceAll("\\D", "");
        if (digits.length() < 4) return digits;
        return "**** **** **** " + digits.substring(digits.length() - 4);
    }

    private String generateInvoice(Payment payment, String promoMessage) {
        return "INVOICE\n" +
                "Payment ID: " + payment.getPaymentId() + "\n" +
                "Customer: "   + payment.getCustomerName() + "\n" +
                "Amount: LKR " + payment.getAmount() + "\n" +
                "Date: "       + payment.getDate() + "\n" +
                "Status: "     + payment.getStatus() + "\n" +
                "Promo: "      + promoMessage;
    }

    /**
     * Derive a booking's creation date from its bookingId.
     * BookingServlet assigns bookingId as "B" + System.currentTimeMillis(), so
     * the timestamp is recoverable. Falling back to LocalDate.now() is safer
     * than throwing — surcharge drift on a malformed legacy ID is preferable
     * to a hard error in the payment view.
     */
    private static LocalDate creationDateOf(Booking b) {
        String id = b.getBookingId();
        if (id != null && id.length() > 1 && id.startsWith("B")) {
            try {
                long ts = Long.parseLong(id.substring(1));
                return Instant.ofEpochMilli(ts).atZone(ZoneId.systemDefault()).toLocalDate();
            } catch (NumberFormatException ignored) {
                // fall through
            }
        }
        return LocalDate.now();
    }
}
