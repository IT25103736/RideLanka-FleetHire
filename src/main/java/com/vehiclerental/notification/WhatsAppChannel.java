package com.vehiclerental.notification;

import com.vehiclerental.model.User;

import java.io.BufferedWriter;
import java.io.File;
import java.io.FileOutputStream;
import java.io.IOException;
import java.io.OutputStreamWriter;
import java.net.URLEncoder;
import java.nio.charset.StandardCharsets;
import java.time.LocalDateTime;
import java.time.format.DateTimeFormatter;

/**
 * Click-to-chat WhatsApp delivery. We do NOT call Twilio/Meta — instead we:
 * <ol>
 *   <li>format the message text</li>
 *   <li>build a {@code wa.me/&lt;phone&gt;?text=&lt;encoded&gt;} deep link</li>
 *   <li>append both to {@code data/whatsapp-log.txt} for audit / staff follow-up</li>
 *   <li>stash the link on a static "last URL" field so the BookingServlet can hand
 *       it to the confirmation JSP to render an "Open WhatsApp" button</li>
 * </ol>
 * Why: paid WhatsApp APIs (Twilio sandbox, Meta Cloud) require provisioning that
 * we cannot complete before viva. The wa.me approach is a real send — just initiated
 * by the staff member who clicks the link — and zero external dependency to break
 * during the demo.
 */
public class WhatsAppChannel implements MessageChannel {

    private static final String LOG_PATH = "data/whatsapp-log.txt";
    private static final String OFFICIAL_NUMBER = "94778119913";   // matches Change 1
    private static final DateTimeFormatter STAMP = DateTimeFormatter.ofPattern("yyyy-MM-dd HH:mm:ss");

    /** Last generated wa.me URL — exposed so the controller can stash it on the request. */
    private static volatile String lastBuiltUrl = "";

    public static String getLastBuiltUrl() {
        return lastBuiltUrl;
    }

    @Override
    public boolean deliver(Notification notification, User recipient, String phone) {
        if (phone == null || phone.isBlank()) {
            log("SKIP (no phone)", notification, "");
            return false;
        }
        String normalized = normalizePhone(phone);
        if (normalized.isEmpty()) {
            log("SKIP (bad phone: " + phone + ")", notification, "");
            return false;
        }
        String text = URLEncoder.encode(notification.getMessage(), StandardCharsets.UTF_8);
        String url  = "https://wa.me/" + normalized + "?text=" + text;
        lastBuiltUrl = url;
        log("OK from=" + OFFICIAL_NUMBER + " to=" + normalized, notification, url);
        return true;
    }

    @Override
    public String getChannelName() {
        return "whatsapp";
    }

    /**
     * Sri Lankan numbers come in two common shapes:
     *   • "0771234567"   → strip leading 0, prefix 94 → "94771234567"
     *   • "+94771234567" → strip +                  → "94771234567"
     *   • "94771234567"  → keep                     → "94771234567"
     * Anything else returns "" (caller treats as skip).
     */
    private static String normalizePhone(String raw) {
        String digits = raw.replaceAll("[^0-9]", "");
        if (digits.startsWith("94") && digits.length() >= 11) return digits;
        if (digits.startsWith("0")  && digits.length() == 10) return "94" + digits.substring(1);
        if (digits.length() == 9) return "94" + digits;   // missing both 0 and 94
        return "";
    }

    private static void log(String result, Notification n, String url) {
        try {
            File f = new File(LOG_PATH);
            File parent = f.getParentFile();
            if (parent != null) parent.mkdirs();
            try (BufferedWriter bw = new BufferedWriter(new OutputStreamWriter(new FileOutputStream(f, true), StandardCharsets.UTF_8))) {
                bw.write(LocalDateTime.now().format(STAMP)
                        + " | " + result
                        + " | " + n.getId()
                        + " | " + n.getType()
                        + " | " + n.getRelatedBookingId()
                        + " | " + url);
                bw.newLine();
            }
        } catch (IOException ex) {
            // Logging must never break booking flow — just print to stderr.
            System.err.println("[WhatsAppChannel] could not write log: " + ex.getMessage());
        }
    }
}
