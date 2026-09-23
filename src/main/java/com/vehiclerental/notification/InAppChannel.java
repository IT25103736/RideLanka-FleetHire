package com.vehiclerental.notification;

import com.vehiclerental.model.User;

/**
 * Persists the notification to data/notifications.txt so the bell icon picks it up
 * on its next poll. Default channel — every notification goes through here.
 */
public class InAppChannel implements MessageChannel {

    @Override
    public boolean deliver(Notification notification, User recipient, String phone) {
        return NotificationFileHandler.save(notification);
    }

    @Override
    public String getChannelName() {
        return "in-app";
    }
}
