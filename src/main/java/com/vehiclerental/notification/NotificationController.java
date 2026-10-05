package com.vehiclerental.notification;

import com.vehiclerental.model.User;
import com.vehiclerental.repository.NotificationRepository;
import jakarta.servlet.http.HttpSession;
import org.springframework.web.bind.annotation.*;

import java.time.format.DateTimeFormatter;
import java.util.*;

@RestController
@RequestMapping("/notifications")
public class NotificationController {
    private static final DateTimeFormatter STAMP = DateTimeFormatter.ofPattern("yyyy-MM-dd HH:mm");
    private static final int LIST_LIMIT = 20;
    private final NotificationRepository repository;

    public NotificationController(NotificationRepository repository) { this.repository = repository; }

    @GetMapping
    public Map<String,Object> list(HttpSession session) {
        User user = currentUser(session); if (user == null) return unauthorized();
        try {
            List<Notification> all = repository.forRecipient(user.getId());
            if (all.size() > LIST_LIMIT) all = all.subList(0, LIST_LIMIT);
            List<Map<String,Object>> rows = new ArrayList<>();
            int unread = 0;
            for (Notification n : all) {
                if (!n.isRead()) unread++;
                Map<String,Object> row = new LinkedHashMap<>();
                row.put("id", n.getId()); row.put("type", n.getType()); row.put("title", n.getTitle()); row.put("message", n.getMessage());
                row.put("read", n.isRead()); row.put("bookingId", n.getRelatedBookingId()); row.put("createdAt", n.getCreatedAt().format(STAMP));
                row.put("icon", iconFor(n.getType())); row.put("href", hrefFor(n, "ADMIN".equalsIgnoreCase(user.getRole()))); rows.add(row);
            }
            Map<String,Object> body = new LinkedHashMap<>(); body.put("notifications", rows); body.put("unreadCount", unread); return body;
        } catch (Exception ex) { return errorPayload(); }
    }

    @GetMapping("/unread-count")
    public Map<String,Object> unreadCount(HttpSession session) {
        User user=currentUser(session); if(user==null)return unauthorized();
        try { return Map.of("unreadCount", repository.unreadCount(user.getId())); }
        catch(Exception ex){ return Map.of("unreadCount",0); }
    }

    @PostMapping("/read")
    public Map<String,Object> markRead(@RequestParam String id,HttpSession session){
        User user=currentUser(session); if(user==null)return unauthorized();
        try{return Map.of("ok",repository.markRead(id,user.getId()));}catch(Exception ex){return Map.of("ok",false);}
    }

    @PostMapping("/read-all")
    public Map<String,Object> markAll(HttpSession session){
        User user=currentUser(session); if(user==null)return unauthorized();
        try{return Map.of("ok",true,"marked",repository.markAllRead(user.getId()));}catch(Exception ex){return Map.of("ok",false,"marked",0);}
    }

    private static User currentUser(HttpSession s){Object u=s==null?null:s.getAttribute("loggedUser");return u instanceof User?(User)u:null;}
    private static Map<String,Object> unauthorized(){Map<String,Object>b=new HashMap<>();b.put("unauthorized",true);b.put("notifications",List.of());b.put("unreadCount",0);return b;}
    private static Map<String,Object> errorPayload(){Map<String,Object>b=new HashMap<>();b.put("notifications",List.of());b.put("unreadCount",0);b.put("error",true);return b;}
    private static String iconFor(String t){if(t==null)return"ti ti-bell";return switch(t){case"BOOKING_CONFIRMED"->"ti ti-circle-check";case"BOOKING_CANCELLED"->"ti ti-circle-x";case"BOOKING_STATUS"->"ti ti-refresh";case"NEW_BOOKING"->"ti ti-calendar-plus";case"NEW_REVIEW"->"ti ti-star";case"NEW_USER"->"ti ti-user-plus";default->"ti ti-bell";};}
    private static String hrefFor(Notification n,boolean admin){if(admin){return switch(n.getType()){case"NEW_BOOKING","BOOKING_CANCELLED"->"/admin/bookings";case"NEW_REVIEW"->"/review/moderate";case"NEW_USER"->"/admin/members";default->"#";};}return n.getType()!=null&&n.getType().startsWith("BOOKING_")?"/booking?action=list":"#";}
}
