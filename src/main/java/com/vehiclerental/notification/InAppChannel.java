package com.vehiclerental.notification;

import com.vehiclerental.model.User;
import com.vehiclerental.repository.NotificationRepository;
import org.springframework.stereotype.Component;

/** Database-backed in-app notification delivery strategy. */
@Component
public class InAppChannel implements MessageChannel {
    private final NotificationRepository repository;

    public InAppChannel(NotificationRepository repository) {
        this.repository = repository;
    }

    @Override
    public boolean deliver(Notification notification, User recipient, String phone) {
        try {
            return repository.save(notification);
        } catch (Exception ex) {
            System.err.println("[InAppChannel] notification persistence failed: " + ex.getMessage());
            return false;
        }
    }

    @Override public String getChannelName() { return "in-app"; }
}
