package com.vehiclerental.notification;

import com.vehiclerental.booking.Booking;
import com.vehiclerental.model.User;
import com.vehiclerental.model.Vehicle;
import com.vehiclerental.payment.PaymentFileHandler;

import java.net.URLEncoder;
import java.nio.charset.StandardCharsets;
import java.text.NumberFormat;
import java.time.LocalDate;
import java.time.format.DateTimeFormatter;
import java.time.temporal.ChronoUnit;
import java.util.Locale;

/**
 * Single source of truth for the professional WhatsApp confirmation message + the
 * {@code wa.me/...?text=...} deep link that the admin clicks to send it.
 * <p>
 * Both the in-app notification body (NotificationService) and the admin "Send via
 * WhatsApp" button (adminBookings.jsp) consume the same formatted output, so the
 * customer sees the same wording on the bell and in their WhatsApp chat.
 * <p>
 * <b>Why is this not a method on Booking?</b> Building the message needs Vehicle data
 * (brand/model/category) and Payment data (paid status, invoice URL) — Booking has
 * neither, and we want it to stay a pure domain object.
 */
public final class WhatsAppMessages {

    private static final String OFFICIAL_NUMBER_HR = "+94 77 811 9913";
    private static final DateTimeFormatter DATE_PRETTY = DateTimeFormatter.ofPattern("d MMM yyyy");
    private static final NumberFormat LKR = NumberFormat.getNumberInstance(Locale.US);

    private WhatsAppMessages() { }

    /**
     * Build the full multi-line confirmation message. Safe to call with null user,
     * vehicle, or totalCost — missing pieces fall back to sensible placeholders so
     * we still send something useful.
     *
     * @param booking      saved booking (required)
     * @param user         booking owner (optional — pulls name into greeting)
     * @param vehicle      reserved vehicle (optional — pulls brand/model/category)
     * @param totalCost    in LKR; pass 0 or negative to hide the price line
     * @param contextPath  servlet context path for building absolute links
     * @param baseUrl      scheme + host (e.g. http://localhost:8080) for links sent
     *                     to the customer; pass empty to send relative paths only
     */
    public static String buildConfirmation(Booking booking, User user, Vehicle vehicle,
                                           double totalCost, String contextPath, String baseUrl) {

        String customerName = user != null ? user.getName() : "Customer";
        String vehicleLine  = vehicleLine(vehicle, booking);
        String start        = prettyDate(booking.getStartDate());
        String end          = prettyDate(booking.getEndDate());
        long   duration     = durationDays(booking);
        String pickupTime   = booking.getPickupTime().isEmpty()  ? "TBC" : booking.getPickupTime();
        String pickupLoc    = booking.getPickupLocation().isEmpty() ? "TBC" : booking.getPickupLocation();
        boolean paid        = isPaid(booking.getBookingId());
        String invoiceUrl   = (baseUrl == null ? "" : baseUrl)
                              + (contextPath == null ? "" : contextPath)
                              + "/payment/history";
        String checkoutUrl  = (baseUrl == null ? "" : baseUrl)
                              + (contextPath == null ? "" : contextPath)
                              + "/payment/checkout?bookingId=" + booking.getBookingId();

        StringBuilder sb = new StringBuilder(640);
        sb.append("*VRMS — Booking Confirmed*\n\n");
        sb.append("Hello ").append(customerName).append(",\n\n");
        sb.append("Your reservation with VRMS is confirmed. Here are your booking details:\n\n");

        sb.append("*Booking Ref:* ").append(booking.getBookingId()).append('\n');
        sb.append("*Vehicle:* ").append(vehicleLine).append('\n');
        sb.append("*Pickup Date:* ").append(start).append('\n');
        sb.append("*Pickup Time:* ").append(pickupTime).append('\n');
        sb.append("*Pickup Location:* ").append(pickupLoc).append('\n');
        sb.append("*Return Date:* ").append(end).append('\n');
        sb.append("*Duration:* ").append(duration).append(duration == 1 ? " day" : " days").append('\n');
        sb.append("*Booking Type:* ")
          .append("INSTANT".equalsIgnoreCase(booking.getBookingType()) ? "Instant" : "Advance")
          .append('\n');
        if (booking.isWithDriver()) {
            sb.append("*Chauffeur:* Included (English-speaking)\n");
        }
        if (totalCost > 0) {
            sb.append("*Total:* LKR ").append(LKR.format(totalCost)).append('\n');
        }
        sb.append("*Payment Status:* ").append(paid ? "Paid ✓" : "Pending").append("\n\n");

        if (paid) {
            sb.append("*Invoice:* ").append(invoiceUrl).append("\n");
            sb.append("(sign in with your VRMS account to view & download)\n\n");
        } else {
            sb.append("*Pay now:* ").append(checkoutUrl).append("\n\n");
        }

        sb.append("Please bring:\n");
        sb.append("• Valid driving licence (passport if non-resident)\n");
        sb.append("• Booking reference ").append(booking.getBookingId()).append("\n\n");

        sb.append("24/7 support: ").append(OFFICIAL_NUMBER_HR).append('\n');
        sb.append("Safe travels — the VRMS team");

        return sb.toString();
    }

    /**
     * Build a wa.me click-to-chat URL that opens WhatsApp on the clicker's device,
     * pre-filled with the message and addressed to the customer's phone. When the
     * admin (whose WhatsApp is logged into the official 94778119913 business
     * number) taps this, the message is sent FROM the business number TO the
     * customer — which is the direction the staff want.
     *
     * @return empty string when the customer phone is missing/invalid
     */
    public static String buildWaUrl(Booking booking, User user, Vehicle vehicle,
                                    double totalCost, String contextPath, String baseUrl) {
        String phone = normalizePhone(booking.getCustomerPhone());
        if (phone.isEmpty()) return "";
        String text = buildConfirmation(booking, user, vehicle, totalCost, contextPath, baseUrl);
        return "https://wa.me/" + phone + "?text=" + URLEncoder.encode(text, StandardCharsets.UTF_8);
    }

    /* ─────────────────── helpers ─────────────────── */

    /** Returns true when a Success payment row exists for this booking. */
    private static boolean isPaid(String bookingId) {
        if (bookingId == null || bookingId.isEmpty()) return false;
        for (String line : PaymentFileHandler.readAllPayments()) {
            String[] parts = line.split("\\|");
            if (parts.length < 10) continue;
            if (!"Success".equalsIgnoreCase(parts[5].trim())) continue;
            if (bookingId.equals(parts[9].trim())) return true;
        }
        return false;
    }

    private static String vehicleLine(Vehicle v, Booking b) {
        if (v == null) return b.getVehicleId();
        StringBuilder s = new StringBuilder(64);
        s.append(v.getBrand()).append(' ').append(v.getModel());
        s.append(" (").append(v.getYear()).append(" · ").append(v.getDisplayCategory()).append(')');
        return s.toString();
    }

    private static String prettyDate(String iso) {
        try { return LocalDate.parse(iso).format(DATE_PRETTY); }
        catch (Exception ex) { return iso; }
    }

    private static long durationDays(Booking b) {
        try {
            LocalDate s = LocalDate.parse(b.getStartDate());
            LocalDate e = LocalDate.parse(b.getEndDate());
            return Math.max(1, ChronoUnit.DAYS.between(s, e));
        } catch (Exception ex) { return 1; }
    }

    /** Same normalisation as WhatsAppChannel — kept here so the admin button can
     *  decide whether to render at all without instantiating the channel. */
    private static String normalizePhone(String raw) {
        if (raw == null) return "";
        String digits = raw.replaceAll("[^0-9]", "");
        if (digits.startsWith("94") && digits.length() >= 11) return digits;
        if (digits.startsWith("0")  && digits.length() == 10) return "94" + digits.substring(1);
        if (digits.length() == 9) return "94" + digits;
        return "";
    }
}
