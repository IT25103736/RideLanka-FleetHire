package com.vehiclerental.notification;

import com.vehiclerental.model.User;
import org.springframework.stereotype.Component;

import java.net.URLEncoder;
import java.nio.charset.StandardCharsets;

/**
 * Click-to-chat WhatsApp strategy. It does not pretend to send a message and it
 * does not persist system data to a text log. It only builds a wa.me URL that a
 * user/staff member may choose to open.
 */
@Component
public class WhatsAppChannel implements MessageChannel {
    private final ThreadLocal<String> lastBuiltUrl = ThreadLocal.withInitial(() -> "");

    public String getLastBuiltUrl() { return lastBuiltUrl.get(); }

    @Override
    public boolean deliver(Notification notification, User recipient, String phone) {
        String normalized = normalizePhone(phone);
        if (normalized.isEmpty()) { lastBuiltUrl.set(""); return false; }
        String text = URLEncoder.encode(notification.getMessage(), StandardCharsets.UTF_8);
        lastBuiltUrl.set("https://wa.me/" + normalized + "?text=" + text);
        return true;
    }

    @Override public String getChannelName() { return "whatsapp-click-to-chat"; }

    public static String normalizePhone(String raw) {
        if (raw == null) return "";
        String digits = raw.replaceAll("[^0-9]", "");
        if (digits.startsWith("94") && digits.length() == 11) return digits;
        if (digits.startsWith("0") && digits.length() == 10) return "94" + digits.substring(1);
        if (digits.length() == 9) return "94" + digits;
        return "";
    }
}
