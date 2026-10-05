package com.vehiclerental.notification;

import com.vehiclerental.model.User;

/** Strategy interface for notification delivery channels. */
public interface MessageChannel {
    boolean deliver(Notification notification, User recipient, String phone);
    String getChannelName();
}
