package com.vehiclerental.notification;

import com.vehiclerental.model.User;
import jakarta.servlet.http.HttpSession;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.RestController;

import java.time.format.DateTimeFormatter;
import java.util.HashMap;
import java.util.LinkedHashMap;
import java.util.List;
import java.util.Map;

/**
 * REST endpoints powering the navbar bell icon. All endpoints assume a logged-in
 * user — anonymous callers get {@code unauthorized=true} and an empty payload.
 *
 * Routes:
 *   GET  /notifications              → list user's notifications (newest first)
 *   GET  /notifications/unread-count → unread badge value
 *   POST /notifications/read?id=X    → mark single notification read
 *   POST /notifications/read-all     → mark every notification read
 */
@RestController
@RequestMapping("/notifications")
public class NotificationController {

    private static final DateTimeFormatter STAMP = DateTimeFormatter.ofPattern("yyyy-MM-dd HH:mm");
    private static final int LIST_LIMIT = 20;

    @GetMapping("")
    public Map<String, Object> list(HttpSession session) {
        User user = currentUser(session);
        if (user == null) return unauthorized();

        boolean isAdmin = "ADMIN".equalsIgnoreCase(user.getRole());
        List<Notification> all = NotificationFileHandler.forRecipient(user.getId(), isAdmin);

        // Cap the payload — bell dropdown shows the most recent 20.
        if (all.size() > LIST_LIMIT) all = all.subList(0, LIST_LIMIT);

        int unread = 0;
        var rows = new java.util.ArrayList<Map<String, Object>>();
        for (Notification n : all) {
            if (!n.isRead()) unread++;
            Map<String, Object> row = new LinkedHashMap<>();
            row.put("id",         n.getId());
            row.put("type",       n.getType());
            row.put("title",      n.getTitle());
            row.put("message",    n.getMessage());
            row.put("read",       n.isRead());
            row.put("bookingId",  n.getRelatedBookingId());
            row.put("createdAt",  n.getCreatedAt().format(STAMP));
            row.put("icon",       iconFor(n.getType()));
            row.put("href",       hrefFor(n, isAdmin));
            rows.add(row);
        }

        Map<String, Object> body = new LinkedHashMap<>();
        body.put("notifications", rows);
        body.put("unreadCount",   unread);
        return body;
    }

    @GetMapping("/unread-count")
    public Map<String, Object> unreadCount(HttpSession session) {
        User user = currentUser(session);
        if (user == null) return unauthorized();

        boolean isAdmin = "ADMIN".equalsIgnoreCase(user.getRole());
        int unread = 0;
        for (Notification n : NotificationFileHandler.forRecipient(user.getId(), isAdmin)) {
            if (!n.isRead()) unread++;
        }
        return Map.of("unreadCount", unread);
    }

    @PostMapping("/read")
    public Map<String, Object> markRead(@RequestParam String id, HttpSession session) {
        User user = currentUser(session);
        if (user == null) return unauthorized();
        boolean ok = NotificationFileHandler.markRead(id);
        return Map.of("ok", ok);
    }

    @PostMapping("/read-all")
    public Map<String, Object> markAllRead(HttpSession session) {
        User user = currentUser(session);
        if (user == null) return unauthorized();
        boolean isAdmin = "ADMIN".equalsIgnoreCase(user.getRole());
        int n = NotificationFileHandler.markAllRead(user.getId(), isAdmin);
        return Map.of("ok", true, "marked", n);
    }

    /* ─────────────── helpers ─────────────── */

    private static User currentUser(HttpSession session) {
        if (session == null) return null;
        Object u = session.getAttribute("loggedUser");
        return u instanceof User ? (User) u : null;
    }

    private static Map<String, Object> unauthorized() {
        Map<String, Object> body = new HashMap<>();
        body.put("unauthorized", true);
        body.put("notifications", List.of());
        body.put("unreadCount", 0);
        return body;
    }

    /** Maps notification type → Tabler icon class for the dropdown row. */
    private static String iconFor(String type) {
        if (type == null) return "ti ti-bell";
        switch (type) {
            case "BOOKING_CONFIRMED": return "ti ti-circle-check";
            case "BOOKING_CANCELLED": return "ti ti-circle-x";
            case "BOOKING_STATUS":    return "ti ti-refresh";
            case "NEW_BOOKING":       return "ti ti-calendar-plus";
            case "NEW_REVIEW":        return "ti ti-star";
            case "NEW_USER":          return "ti ti-user-plus";
            default:                  return "ti ti-bell";
        }
    }

    /**
     * Click target for a notification row. Admin notifications about new bookings
     * deep-link into the admin bookings list; user notifications go to "My Bookings".
     */
    private static String hrefFor(Notification n, boolean isAdmin) {
        String type = n.getType() == null ? "" : n.getType();
        if (isAdmin) {
            switch (type) {
                case "NEW_BOOKING":
                case "BOOKING_CANCELLED": return "/admin/bookings";
                case "NEW_REVIEW":        return "/review/moderate";
                case "NEW_USER":          return "/admin/members";
                default:                  return "#";
            }
        }
        switch (type) {
            case "BOOKING_CONFIRMED":
            case "BOOKING_STATUS":
            case "BOOKING_CANCELLED": return "/booking?action=list";
            default:                  return "#";
        }
    }
}
