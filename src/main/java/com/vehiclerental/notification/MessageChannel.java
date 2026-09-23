package com.vehiclerental.notification;

import com.vehiclerental.model.User;

/**
 * Strategy interface for delivering a notification through a single channel.
 * <p>
 * VRMS ships two concrete channels:
 * <ul>
 *   <li>{@link InAppChannel}    — persists to data/notifications.txt for the bell icon</li>
 *   <li>{@link WhatsAppChannel} — writes a wa.me click-to-chat URL for staff to send</li>
 * </ul>
 * Adding email/SMS later is one new implementer + one line in NotificationService.
 * <p>
 * <b>Viva:</b> classic Strategy pattern. NotificationService holds a {@code List<MessageChannel>}
 * and dispatches polymorphically — it never knows or cares which channels are wired.
 */
public interface MessageChannel {

    /**
     * Deliver the notification through this channel. Implementers must NOT throw —
     * a failed channel is logged and the next channel still runs. We never want a
     * dead third-party SMS gateway to take down booking creation.
     *
     * @param notification the notification record
     * @param recipient    the user receiving it (may be null for admin broadcast)
     * @param phone        the recipient's phone number for SMS/WhatsApp channels;
     *                     pass null when irrelevant
     * @return true when delivery succeeded; false when this channel skipped or errored
     */
    boolean deliver(Notification notification, User recipient, String phone);

    /** Human-readable channel name, for logs. */
    String getChannelName();
}
