package com.vehiclerental.repository;

import com.vehiclerental.db.MssqlConnection;
import com.vehiclerental.notification.Notification;
import org.springframework.stereotype.Repository;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.sql.Timestamp;
import java.time.LocalDateTime;
import java.util.ArrayList;
import java.util.List;

@Repository
public class NotificationRepository {
    private final MssqlConnection db;

    public NotificationRepository(MssqlConnection db) {
        this.db = db;
    }

    public boolean save(Notification n) throws SQLException {
        if (Notification.RECIPIENT_ADMIN_BROADCAST.equals(n.getRecipientId())) {
            return saveForAdmins(n);
        }
        try (Connection c = db.getConnection()) {
            return insert(c, n.getRecipientId(), n.getType(), n.getTitle(), n.getMessage(), n.getRelatedBookingId()) == 1;
        }
    }

    private boolean saveForAdmins(Notification n) throws SQLException {
        try (Connection c = db.getConnection()) {
            c.setAutoCommit(false);
            try {
                List<String> admins = new ArrayList<>();
                try (PreparedStatement ps = c.prepareStatement("select user_id from dbo.users where role='ADMIN' and status='ACTIVE'");
                     ResultSet rs = ps.executeQuery()) {
                    while (rs.next()) admins.add(rs.getString(1));
                }
                int count = 0;
                for (String adminId : admins) count += insert(c, adminId, n.getType(), n.getTitle(), n.getMessage(), n.getRelatedBookingId());
                c.commit();
                return count > 0 || admins.isEmpty();
            } catch (SQLException | RuntimeException ex) {
                c.rollback();
                throw ex;
            } finally { c.setAutoCommit(true); }
        }
    }

    public List<Notification> forRecipient(String userId) throws SQLException {
        String sql = "select notification_id,recipient_user_id,notification_type,title,message,is_read,related_booking_id,created_at " +
                "from dbo.notifications where recipient_user_id=? order by created_at desc,notification_id desc";
        List<Notification> out = new ArrayList<>();
        try (Connection c = db.getConnection(); PreparedStatement ps = c.prepareStatement(sql)) {
            ps.setString(1, userId);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) out.add(map(rs));
            }
        }
        return out;
    }

    public int unreadCount(String userId) throws SQLException {
        try (Connection c = db.getConnection(); PreparedStatement ps = c.prepareStatement(
                "select count(*) from dbo.notifications where recipient_user_id=? and is_read=0")) {
            ps.setString(1, userId);
            try (ResultSet rs = ps.executeQuery()) { rs.next(); return rs.getInt(1); }
        }
    }

    public boolean markRead(String id, String userId) throws SQLException {
        try (Connection c = db.getConnection(); PreparedStatement ps = c.prepareStatement(
                "update dbo.notifications set is_read=1,read_at=coalesce(read_at,sysdatetime()) where notification_id=? and recipient_user_id=?")) {
            ps.setString(1, id); ps.setString(2, userId); return ps.executeUpdate() == 1;
        }
    }

    public int markAllRead(String userId) throws SQLException {
        try (Connection c = db.getConnection(); PreparedStatement ps = c.prepareStatement(
                "update dbo.notifications set is_read=1,read_at=coalesce(read_at,sysdatetime()) where recipient_user_id=? and is_read=0")) {
            ps.setString(1, userId); return ps.executeUpdate();
        }
    }

    private int insert(Connection c, String recipientId, String type, String title, String message, String bookingId) throws SQLException {
        String id = nextId(c);
        try (PreparedStatement ps = c.prepareStatement(
                "insert into dbo.notifications(notification_id,recipient_user_id,notification_type,title,message,is_read,related_booking_id,created_at) values(?,?,?,?,?,0,?,sysdatetime())")) {
            ps.setString(1, id); ps.setString(2, recipientId); ps.setString(3, type); ps.setString(4, title); ps.setString(5, message);
            ps.setString(6, bookingId == null || bookingId.isBlank() ? null : bookingId);
            return ps.executeUpdate();
        }
    }

    private String nextId(Connection c) throws SQLException {
        try (PreparedStatement ps = c.prepareStatement(
                "select isnull(max(try_cast(substring(notification_id,2,29) as bigint)),0)+1 from dbo.notifications with (updlock,holdlock)");
             ResultSet rs = ps.executeQuery()) {
            rs.next(); return String.format("N%08d", rs.getLong(1));
        }
    }

    private Notification map(ResultSet rs) throws SQLException {
        Timestamp ts = rs.getTimestamp("created_at");
        LocalDateTime created = ts == null ? LocalDateTime.now() : ts.toLocalDateTime();
        return new Notification(rs.getString("notification_id"), rs.getString("recipient_user_id"),
                rs.getString("notification_type"), rs.getString("title"), rs.getString("message"),
                rs.getBoolean("is_read"), rs.getString("related_booking_id"), created);
    }
}
