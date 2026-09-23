package com.vehiclerental.notification;

import java.io.*;
import java.nio.charset.StandardCharsets;
import java.util.ArrayList;
import java.util.List;

/**
 * File-I/O layer for notifications. Mirrors VehicleFileHandler / BookingFileHandler:
 * pipe-delimited rows in data/notifications.txt, # comment lines skipped, malformed
 * rows logged & dropped rather than crashing the read.
 */
public class NotificationFileHandler {

    private static final String FILE_PATH = "data/notifications.txt";

    /** Append-only persistence — every new notification goes on the tail of the file. */
    public static synchronized boolean save(Notification n) {
        try {
            ensureFile();
            try (BufferedWriter bw = new BufferedWriter(new OutputStreamWriter(new FileOutputStream(FILE_PATH, true), StandardCharsets.UTF_8))) {
                bw.write(n.toFileString());
                bw.newLine();
            }
            return true;
        } catch (IOException ex) {
            System.err.println("[NotificationFileHandler] save failed: " + ex.getMessage());
            return false;
        }
    }

    public static synchronized List<Notification> readAll() {
        List<Notification> out = new ArrayList<>();
        File f = new File(FILE_PATH);
        if (!f.exists()) return out;
        try (BufferedReader br = new BufferedReader(new InputStreamReader(new FileInputStream(f), StandardCharsets.UTF_8))) {
            String line;
            while ((line = br.readLine()) != null) {
                line = line.trim();
                if (line.isEmpty() || line.startsWith("#")) continue;
                Notification n = Notification.parse(line);
                if (n != null) out.add(n);
            }
        } catch (IOException ex) {
            System.err.println("[NotificationFileHandler] read failed: " + ex.getMessage());
        }
        return out;
    }

    /**
     * Returns notifications addressed to this user (their own id) plus any admin
     * broadcast rows when the caller is an admin. Newest first.
     */
    public static List<Notification> forRecipient(String userId, boolean isAdmin) {
        List<Notification> all = readAll();
        List<Notification> mine = new ArrayList<>();
        for (Notification n : all) {
            if (n.getRecipientId().equalsIgnoreCase(userId)) {
                mine.add(n);
            } else if (isAdmin && Notification.RECIPIENT_ADMIN_BROADCAST.equalsIgnoreCase(n.getRecipientId())) {
                mine.add(n);
            }
        }
        mine.sort((a, b) -> b.getCreatedAt().compareTo(a.getCreatedAt()));
        return mine;
    }

    /** Flips one notification's read flag and rewrites the whole file. */
    public static synchronized boolean markRead(String notificationId) {
        List<Notification> all = readAll();
        boolean changed = false;
        for (Notification n : all) {
            if (n.getId().equals(notificationId) && !n.isRead()) {
                n.setRead(true);
                changed = true;
            }
        }
        return changed && rewriteAll(all);
    }

    /** Bulk version — marks every notification addressed to this user/admin as read. */
    public static synchronized int markAllRead(String userId, boolean isAdmin) {
        List<Notification> all = readAll();
        int n = 0;
        for (Notification x : all) {
            boolean mine = x.getRecipientId().equalsIgnoreCase(userId)
                    || (isAdmin && Notification.RECIPIENT_ADMIN_BROADCAST.equalsIgnoreCase(x.getRecipientId()));
            if (mine && !x.isRead()) { x.setRead(true); n++; }
        }
        if (n > 0) rewriteAll(all);
        return n;
    }

    /** Auto-incrementing id with N prefix — "N001", "N002", … */
    public static synchronized String generateId() {
        List<Notification> all = readAll();
        return String.format("N%04d", all.size() + 1);
    }

    /* ────────────────────────── helpers ────────────────────────── */

    private static void ensureFile() throws IOException {
        File f = new File(FILE_PATH);
        if (!f.exists()) {
            File parent = f.getParentFile();
            if (parent != null) parent.mkdirs();
            try (BufferedWriter bw = new BufferedWriter(new FileWriter(f, true))) {
                bw.write("# notifications.txt — VRMS in-app notification ledger");
                bw.newLine();
                bw.write("# Format: id|recipientId|type|title|message|isRead|relatedBookingId|createdAt");
                bw.newLine();
            }
        }
    }

    private static boolean rewriteAll(List<Notification> all) {
        try {
            ensureFile();
            try (BufferedWriter bw = new BufferedWriter(new FileWriter(FILE_PATH, false))) {
                bw.write("# notifications.txt — VRMS in-app notification ledger");
                bw.newLine();
                bw.write("# Format: id|recipientId|type|title|message|isRead|relatedBookingId|createdAt");
                bw.newLine();
                for (Notification n : all) {
                    bw.write(n.toFileString());
                    bw.newLine();
                }
            }
            return true;
        } catch (IOException ex) {
            System.err.println("[NotificationFileHandler] rewrite failed: " + ex.getMessage());
            return false;
        }
    }
}
