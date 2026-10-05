package com.vehiclerental.notification;

import com.vehiclerental.booking.Booking;
import com.vehiclerental.model.User;
import com.vehiclerental.model.Vehicle;
import org.springframework.stereotype.Service;

import java.time.LocalDateTime;

/**
 * Notification service. Strategy pattern is used through MessageChannel:
 * InAppChannel persists to MSSQL, WhatsAppChannel builds an optional click-to-chat link,
 * and EmailChannel sends optional best-effort SMTP security alerts.
 */
@Service
public class NotificationService {
    private final InAppChannel inApp;
    private final WhatsAppChannel whatsApp;
    private final EmailChannel email;

    public NotificationService(InAppChannel inApp, WhatsAppChannel whatsApp, EmailChannel email) {
        this.inApp = inApp;
        this.whatsApp = whatsApp;
        this.email = email;
    }

    public String bookingCreated(Booking booking, User user, Vehicle vehicle, String phone,
                                 double totalCost, String contextPath, String baseUrl) {
        String message = WhatsAppMessages.buildConfirmation(booking, user, vehicle, totalCost, contextPath, baseUrl);
        Notification n = build(booking.getUserId(), "BOOKING_CONFIRMED", "Booking created", message, booking.getBookingId());
        deliver(n, user, phone, inApp);
        // Build a click-to-chat link, but do not claim it was sent.
        deliver(n, user, phone, whatsApp);

        String vName = vehicle == null ? booking.getVehicleId() : vehicle.getBrand() + " " + vehicle.getModel();
        Notification admin = build(Notification.RECIPIENT_ADMIN_BROADCAST, "NEW_BOOKING",
                "New booking #" + booking.getBookingId(),
                (user == null ? "A customer" : user.getName()) + " reserved " + vName + " for " + booking.getStartDate() + ".",
                booking.getBookingId());
        deliver(admin, null, null, inApp);
        return whatsApp.getLastBuiltUrl();
    }

    public void bookingCancelled(String bookingId, User user) {
        Notification toUser = build(user.getId(), "BOOKING_CANCELLED", "Booking cancelled",
                "Your booking " + bookingId + " has been cancelled.", bookingId);
        deliver(toUser, user, null, inApp);
        Notification admin = build(Notification.RECIPIENT_ADMIN_BROADCAST, "BOOKING_CANCELLED", "Booking cancelled",
                "Booking " + bookingId + " was cancelled by " + user.getName() + ".", bookingId);
        deliver(admin, null, null, inApp);
    }

    public void bookingStatusChanged(String bookingId, User user, String newStatus) {
        Notification n = build(user.getId(), "BOOKING_STATUS", "Booking status update",
                "Booking " + bookingId + " is now " + newStatus + ".", bookingId);
        deliver(n, user, null, inApp);
    }

    public void reviewSubmitted(String reviewerName, int rating, String vehicleLabel) {
        Notification n = build(Notification.RECIPIENT_ADMIN_BROADCAST, "NEW_REVIEW", "New review submitted",
                "New " + rating + "-star review from " + reviewerName + " for " + vehicleLabel + ".", "");
        deliver(n, null, null, inApp);
    }

    public void userRegistered(User newUser) {
        Notification n = build(Notification.RECIPIENT_ADMIN_BROADCAST, "NEW_USER", "New user registered",
                "New user registered: " + newUser.getName() + " (" + newUser.getEmail() + ").", "");
        deliver(n, null, null, inApp);
    }

    /** Sends a best-effort security alert to the real account email after a successful login. */
    public void loginSucceeded(User user) {
        if (user == null) return;
        Notification n = build(user.getId(), "SECURITY_LOGIN",
                "RideLanka FleetHire - New sign in",
                "Hello " + user.getName() + ",\n\n"
                        + "Your RideLanka FleetHire account was successfully signed in.\n\n"
                        + "If this was you, no action is required. If you did not sign in, "
                        + "please change your password.\n\nRideLanka FleetHire", "");
        deliver(n, user, null, email);
    }

    /** Sends a best-effort security alert after the account password is changed. */
    public void passwordChanged(User user) {
        if (user == null) return;
        Notification n = build(user.getId(), "SECURITY_PASSWORD_CHANGED",
                "RideLanka FleetHire - Password changed",
                "Hello " + user.getName() + ",\n\n"
                        + "The password for your RideLanka FleetHire account was changed successfully.\n\n"
                        + "If you did not make this change, please contact RideLanka FleetHire immediately.\n\n"
                        + "RideLanka FleetHire", "");
        deliver(n, user, null, email);
    }

    private Notification build(String recipient, String type, String title, String message, String bookingId) {
        return new Notification("DB", recipient, type, title, message, false, bookingId, LocalDateTime.now());
    }

    private void deliver(Notification n, User recipient, String phone, MessageChannel... channels) {
        for (MessageChannel channel : channels) {
            try { channel.deliver(n, recipient, phone); }
            catch (RuntimeException ex) { System.err.println("[NotificationService] " + channel.getChannelName() + ": " + ex.getMessage()); }
        }
    }
}
