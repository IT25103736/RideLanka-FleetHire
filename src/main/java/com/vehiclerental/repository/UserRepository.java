package com.vehiclerental.repository;

import com.vehiclerental.db.MssqlConnection;
import com.vehiclerental.model.AdminUser;
import com.vehiclerental.model.RegularUser;
import com.vehiclerental.model.User;
import com.vehiclerental.security.PasswordUtil;
import org.springframework.stereotype.Repository;

import java.sql.*;
import java.time.LocalDate;
import java.util.ArrayList;
import java.util.List;

@Repository
public class UserRepository {
    private final MssqlConnection db;
    public UserRepository(MssqlConnection db) { this.db = db; }

    public List<User> findAll() throws SQLException {
        String sql = "select user_id, name, email, password_hash, role, created_date, status, phone, license_no from users order by user_id";
        List<User> out = new ArrayList<>();
        try (Connection c = db.getConnection(); PreparedStatement ps = c.prepareStatement(sql); ResultSet rs = ps.executeQuery()) {
            while (rs.next()) out.add(map(rs));
        }
        return out;
    }

    public User findByEmail(String email) throws SQLException {
        String sql = "select user_id, name, email, password_hash, role, created_date, status, phone, license_no from users where lower(email)=lower(?)";
        try (Connection c = db.getConnection(); PreparedStatement ps = c.prepareStatement(sql)) {
            ps.setString(1, email);
            try (ResultSet rs = ps.executeQuery()) { return rs.next() ? map(rs) : null; }
        }
    }

    public User findById(String id) throws SQLException {
        String sql = "select user_id, name, email, password_hash, role, created_date, status, phone, license_no from users where user_id=?";
        try (Connection c = db.getConnection(); PreparedStatement ps = c.prepareStatement(sql)) {
            ps.setString(1, id);
            try (ResultSet rs = ps.executeQuery()) { return rs.next() ? map(rs) : null; }
        }
    }

    public boolean authenticate(String email, String rawPassword) throws SQLException {
        User u = findByEmail(email);
        return u != null && "ACTIVE".equalsIgnoreCase(u.getStatus()) && PasswordUtil.matches(rawPassword, u.getPassword());
    }

    public String nextUserId() throws SQLException {
        String sql = "select isnull(max(try_cast(substring(user_id,2,20) as int)),0)+1 from users";
        try (Connection c = db.getConnection(); PreparedStatement ps = c.prepareStatement(sql); ResultSet rs = ps.executeQuery()) {
            rs.next(); return String.format("U%03d", rs.getInt(1));
        }
    }

    public boolean insert(String name, String email, String rawPassword, String role, String phone, String licenseNo) throws SQLException {
        if (findByEmail(email) != null) return false;
        String sql="insert into users(user_id,name,email,password_hash,role,created_date,status,phone,license_no) values(?,?,?,?,?,cast(getdate() as date),'ACTIVE',?,?)";
        try (Connection c=db.getConnection(); PreparedStatement ps=c.prepareStatement(sql)) {
            ps.setString(1,nextUserId()); ps.setString(2,name); ps.setString(3,email); ps.setString(4,PasswordUtil.hash(rawPassword));
            ps.setString(5,role); ps.setString(6,phone); ps.setString(7,licenseNo); return ps.executeUpdate()==1;
        }
    }

    public boolean updateProfile(String id,String name,String email,String phone,String licenseNo) throws SQLException {
        String sql="update users set name=?, email=?, phone=?, license_no=? where user_id=?";
        try(Connection c=db.getConnection();PreparedStatement ps=c.prepareStatement(sql)){
            ps.setString(1,name);ps.setString(2,email);ps.setString(3,phone);ps.setString(4,licenseNo);ps.setString(5,id);return ps.executeUpdate()==1;
        }
    }

    public boolean updateAdminFields(String id,String name,String email,String role,String status,String phone,String licenseNo) throws SQLException {
        String sql="update users set name=?, email=?, role=?, status=?, phone=?, license_no=? where user_id=?";
        try(Connection c=db.getConnection();PreparedStatement ps=c.prepareStatement(sql)){
            ps.setString(1,name);ps.setString(2,email);ps.setString(3,role);ps.setString(4,status);ps.setString(5,phone);ps.setString(6,licenseNo);ps.setString(7,id);return ps.executeUpdate()==1;
        }
    }

    public boolean updateStatus(String id,String status) throws SQLException {
        try(Connection c=db.getConnection();PreparedStatement ps=c.prepareStatement("update users set status=? where user_id=?")){
            ps.setString(1,status);ps.setString(2,id);return ps.executeUpdate()==1;
        }
    }

    public boolean softDelete(String id) throws SQLException { return updateStatus(id, "DEACTIVATED"); }

    private User map(ResultSet rs) throws SQLException {
        String role=rs.getString(5);
        User u = "ADMIN".equalsIgnoreCase(role) ? new AdminUser(rs.getString(1),rs.getString(2),rs.getString(3),rs.getString(4),role,rs.getDate(6).toLocalDate().toString())
                : new RegularUser(rs.getString(1),rs.getString(2),rs.getString(3),rs.getString(4),role,rs.getDate(6).toLocalDate().toString());
        u.setStatus(rs.getString(7));u.setPhone(rs.getString(8));u.setLicenseNo(rs.getString(9));return u;
    }
}
