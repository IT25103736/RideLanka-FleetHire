package com.vehiclerental.notification;

import java.time.LocalDateTime;
import java.time.format.DateTimeFormatter;

/**
 * In-app notification record. Persisted one-per-line in data/notifications.txt
 * (pipe-delimited, same convention as every other VRMS data file).
 *
 * The "type" field classifies the notification for UI (icon + colour) and lets
 * future filtering work without parsing the title.
 */
public class Notification {

    public static final String RECIPIENT_ADMIN_BROADCAST = "ADMIN";

    private static final DateTimeFormatter STAMP = DateTimeFormatter.ofPattern("yyyy-MM-dd HH:mm:ss");

    private String        id;
    private String        recipientId;       // user id, or "ADMIN" for broadcast
    private String        type;              // BOOKING_CONFIRMED, BOOKING_CANCELLED, NEW_BOOKING, NEW_REVIEW, NEW_USER, BOOKING_STATUS
    private String        title;
    private String        message;
    private boolean       read;
    private String        relatedBookingId;  // optional, "" when not applicable
    private LocalDateTime createdAt;

    public Notification(String id, String recipientId, String type, String title,
                        String message, boolean read, String relatedBookingId,
                        LocalDateTime createdAt) {
        this.id               = id;
        this.recipientId      = recipientId;
        this.type             = type;
        this.title            = title;
        this.message          = message;
        this.read             = read;
        this.relatedBookingId = relatedBookingId == null ? "" : relatedBookingId;
        this.createdAt        = createdAt == null ? LocalDateTime.now() : createdAt;
    }

    public String        getId()               { return id; }
    public String        getRecipientId()      { return recipientId; }
    public String        getType()             { return type; }
    public String        getTitle()            { return title; }
    public String        getMessage()          { return message; }
    public boolean       isRead()              { return read; }
    public String        getRelatedBookingId() { return relatedBookingId; }
    public LocalDateTime getCreatedAt()        { return createdAt; }

    public void setRead(boolean read) { this.read = read; }

    /** Pipe-delimited row. Order is load-bearing — append new fields, never reorder. */
    public String toFileString() {
        return escape(id) + "|" + escape(recipientId) + "|" + escape(type) + "|"
                + escape(title) + "|" + escape(message) + "|" + read + "|"
                + escape(relatedBookingId) + "|" + createdAt.format(STAMP);
    }

    /**
     * Escape characters that would corrupt a one-row-per-line pipe-delimited record:
     *   • literal pipes  →  forward slash
     *   • newlines (LF and CR) → "\n" / "\r" two-character sequences (round-trippable)
     *   • literal backslash → "\\" so the unescape pass is unambiguous
     * Round-trip preserves message structure when reading the file back.
     */
    private static String escape(String s) {
        if (s == null) return "";
        return s.replace("\\", "\\\\")
                .replace("|",  "/")
                .replace("\r", "\\r")
                .replace("\n", "\\n");
    }

    /** Inverse of {@link #escape(String)} — restore newlines and backslashes. */
    private static String unescape(String s) {
        if (s == null || s.isEmpty()) return "";
        StringBuilder sb = new StringBuilder(s.length());
        for (int i = 0; i < s.length(); i++) {
            char c = s.charAt(i);
            if (c == '\\' && i + 1 < s.length()) {
                char next = s.charAt(i + 1);
                if      (next == 'n')  { sb.append('\n'); i++; }
                else if (next == 'r')  { sb.append('\r'); i++; }
                else if (next == '\\') { sb.append('\\'); i++; }
                else                   { sb.append(c); }
            } else {
                sb.append(c);
            }
        }
        return sb.toString();
    }

    public static Notification parse(String line) {
        String[] parts = line.split("\\|", -1);
        if (parts.length < 8) return null;
        try {
            LocalDateTime ts = LocalDateTime.parse(parts[7].trim(), STAMP);
            return new Notification(
                    unescape(parts[0].trim()),
                    unescape(parts[1].trim()),
                    unescape(parts[2].trim()),
                    unescape(parts[3].trim()),
                    unescape(parts[4].trim()),
                    Boolean.parseBoolean(parts[5].trim()),
                    unescape(parts[6].trim()),
                    ts);
        } catch (RuntimeException ex) {
            System.err.println("[Notification] skipping malformed row: " + line);
            return null;
        }
    }
}
