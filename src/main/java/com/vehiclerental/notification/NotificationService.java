package com.vehiclerental.notification;

import com.vehiclerental.booking.Booking;
import com.vehiclerental.model.User;
import com.vehiclerental.model.Vehicle;

import java.time.LocalDateTime;
import java.util.ArrayList;
import java.util.List;

/**
 * Orchestrates notification fan-out across channels. Servlets call high-level
 * methods like {@link #bookingConfirmed(Booking, User, Vehicle, String)} and the
 * service decides which channels to fire.
 * <p>
 * <b>Viva structure:</b>
 * <ul>
 *   <li>{@link MessageChannel} is the strategy interface.</li>
 *   <li>{@link InAppChannel} and {@link WhatsAppChannel} are concrete strategies.</li>
 *   <li>This service holds them in a {@code List<MessageChannel>} and dispatches
 *       polymorphically — no instanceof, no switch.</li>
 *   <li>Adding email later means writing {@code EmailChannel implements MessageChannel}
 *       and adding one line to the constructor's channel list.</li>
 * </ul>
 */
public class NotificationService {

    /* Singleton — servlets aren't Spring beans here, so we expose a static instance.
       Channels are immutable after construction; the file handler is thread-safe. */
    private static final NotificationService INSTANCE = new NotificationService();

    public static NotificationService get() { return INSTANCE; }

    private final List<MessageChannel> defaultChannels;
    private final InAppChannel    inApp    = new InAppChannel();
    private final WhatsAppChannel whatsApp = new WhatsAppChannel();

    private NotificationService() {
        this.defaultChannels = new ArrayList<>();
        this.defaultChannels.add(inApp);
        // WhatsApp channel is only added for events that should reach the customer's phone.
    }

    /* ─────────────────── User-facing events ─────────────────── */

    /**
     * Fired when a booking is created/confirmed. Both channels run — in-app for the
     * bell icon, WhatsApp for the click-to-chat link the staff member opens.
     *
     * @param totalCost   the breakdown total in LKR; pass 0 or negative to hide
     * @param contextPath servlet context path (e.g. "" or "/vrms") for invoice links
     * @param baseUrl     scheme + host for absolute links sent to WhatsApp (e.g.
     *                    "http://localhost:8080"); pass empty for relative paths
     */
    public void bookingConfirmed(Booking booking, User user, Vehicle vehicle,
                                 String customerPhone, double totalCost,
                                 String contextPath, String baseUrl) {

        String vName = vehicle == null
                ? booking.getVehicleId()
                : (vehicle.getBrand() + " " + vehicle.getModel());

        // The full structured message — same text the admin will fire over WhatsApp,
        // so the bell preview and the actual WhatsApp body stay in lockstep.
        String message = WhatsAppMessages.buildConfirmation(
                booking, user, vehicle, totalCost, contextPath, baseUrl);

        Notification n = build(booking.getUserId(), "BOOKING_CONFIRMED",
                "Booking confirmed", message, booking.getBookingId());

        // Both channels for confirmations — bell + WhatsApp deep link.
        deliver(n, user, customerPhone, inApp, whatsApp);

        // Mirror this to admins so the dashboard sees activity.
        Notification adminCopy = build(Notification.RECIPIENT_ADMIN_BROADCAST, "NEW_BOOKING",
                "New booking #" + booking.getBookingId(),
                (user == null ? "A guest" : user.getName())
                        + " just booked " + vName
                        + " for " + booking.getStartDate()
                        + " · " + emptyToFallback(booking.getPickupLocation(), "—") + ".",
                booking.getBookingId());
        deliver(adminCopy, null, null, inApp);
    }

    /** Fired by the cancel handler. Notifies both the user and the admins. */
    public void bookingCancelled(String bookingId, User user) {
        String message = "Your booking " + bookingId + " has been cancelled. "
                + "If this was a mistake or you would like to rebook, contact our team.";

        Notification toUser = build(user.getId(), "BOOKING_CANCELLED",
                "Booking cancelled", message, bookingId);
        deliver(toUser, user, null, inApp);

        Notification toAdmins = build(Notification.RECIPIENT_ADMIN_BROADCAST, "BOOKING_CANCELLED",
                "Booking cancelled by user",
                "Booking " + bookingId + " was cancelled by " + user.getName() + ".",
                bookingId);
        deliver(toAdmins, null, null, inApp);
    }

    /** Generic status-change ping — used by admin status updates. */
    public void bookingStatusChanged(String bookingId, User user, String newStatus) {
        String message = "Update on booking " + bookingId + ": status is now "
                + newStatus + ".";
        Notification n = build(user.getId(), "BOOKING_STATUS",
                "Booking status update", message, bookingId);
        deliver(n, user, null, inApp);
    }

    /* ─────────────────── Admin-only events ─────────────────── */

    /** A new review landed — flag it for the moderation team. */
    public void reviewSubmitted(String reviewerName, int rating, String vehicleLabel) {
        String stars = "★".repeat(Math.max(1, Math.min(5, rating)));
        String message = "New review from " + reviewerName + ": " + stars
                + " (" + rating + " stars) for " + vehicleLabel + ".";
        Notification n = build(Notification.RECIPIENT_ADMIN_BROADCAST, "NEW_REVIEW",
                "New review submitted", message, "");
        deliver(n, null, null, inApp);
    }

    /** Someone just signed up. */
    public void userRegistered(User newUser) {
        String message = "New user registered: " + newUser.getName()
                + " (" + newUser.getEmail() + ").";
        Notification n = build(Notification.RECIPIENT_ADMIN_BROADCAST, "NEW_USER",
                "New user registered", message, "");
        deliver(n, null, null, inApp);
    }

    /* ─────────────────── plumbing ─────────────────── */

    private Notification build(String recipientId, String type, String title,
                               String message, String relatedBookingId) {
        return new Notification(
                NotificationFileHandler.generateId(),
                recipientId,
                type,
                title,
                message,
                false,
                relatedBookingId == null ? "" : relatedBookingId,
                LocalDateTime.now());
    }

    /**
     * Loops the requested channels, swallowing per-channel failures so one dead
     * channel cannot break booking creation. A failed channel is logged to stderr
     * by the channel itself.
     */
    private void deliver(Notification n, User recipient, String phone, MessageChannel... channels) {
        for (MessageChannel ch : channels) {
            try {
                boolean ok = ch.deliver(n, recipient, phone);
                if (!ok) {
                    System.err.println("[NotificationService] channel " + ch.getChannelName()
                            + " skipped notification " + n.getId());
                }
            } catch (RuntimeException ex) {
                System.err.println("[NotificationService] channel " + ch.getChannelName()
                        + " threw: " + ex.getMessage());
            }
        }
    }

    private static String emptyToFallback(String s, String fallback) {
        return (s == null || s.isBlank()) ? fallback : s;
    }
}
