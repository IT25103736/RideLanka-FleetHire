package com.vehiclerental.notification;

import com.vehiclerental.model.User;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.mail.SimpleMailMessage;
import org.springframework.mail.javamail.JavaMailSender;
import org.springframework.stereotype.Component;

/**
 * Optional SMTP notification strategy for account-security messages.
 * Delivery is deliberately best-effort: a mail outage must never break
 * login or password changes. Enable it with RIDELANKA_MAIL_ENABLED=true.
 */
@Component
public class EmailChannel implements MessageChannel {
    private final JavaMailSender mailSender;
    private final boolean enabled;
    private final String configuredFrom;
    private final String mailUsername;
    private final String mailPassword;

    public EmailChannel(JavaMailSender mailSender,
                        @Value("${ridelanka.mail.enabled:false}") boolean enabled,
                        @Value("${ridelanka.mail.from:}") String configuredFrom,
                        @Value("${spring.mail.username:}") String mailUsername,
                        @Value("${spring.mail.password:}") String mailPassword) {
        this.mailSender = mailSender;
        this.enabled = enabled;
        this.configuredFrom = configuredFrom == null ? "" : configuredFrom.trim();
        this.mailUsername = mailUsername == null ? "" : mailUsername.trim();
        this.mailPassword = mailPassword == null ? "" : mailPassword.trim();
    }

    @Override
    public boolean deliver(Notification notification, User recipient, String phone) {
        if (!enabled || notification == null || recipient == null) return false;
        String to = recipient.getEmail();
        String from = configuredFrom.isBlank() ? mailUsername : configuredFrom;
        if (to == null || to.isBlank() || from.isBlank() || mailUsername.isBlank() || mailPassword.isBlank()) {
            return false;
        }
        to = to.trim();
        if (!to.matches("^[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,}$")) {
            return false;
        }

        try {
            SimpleMailMessage message = new SimpleMailMessage();
            message.setFrom(from);
            message.setTo(to);
            message.setSubject(notification.getTitle());
            message.setText(notification.getMessage());
            mailSender.send(message);
            return true;
        } catch (RuntimeException ex) {
            System.err.println("[EmailChannel] SMTP delivery failed (login/password action still succeeded): " + ex.getMessage());
            return false;
        }
    }

    @Override
    public String getChannelName() {
        return "email";
    }
}
