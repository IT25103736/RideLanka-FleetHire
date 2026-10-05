package com.vehiclerental.repository;

import com.vehiclerental.db.MssqlConnection;
import com.vehiclerental.model.AdminUser;
import com.vehiclerental.model.RegularUser;
import com.vehiclerental.model.User;
import com.vehiclerental.model.CustomerProfile;
import com.vehiclerental.security.PasswordUtil;
import org.springframework.stereotype.Repository;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.util.ArrayList;
import java.util.List;
import java.util.LinkedHashMap;
import java.util.Map;
import java.util.Objects;
import java.time.LocalDate;

@Repository
public class UserRepository {
    private final MssqlConnection db;

    public UserRepository(MssqlConnection db) {
        this.db = db;
    }

    public List<User> findAll() throws SQLException {
        String sql = "select user_id,name,email,password_hash,role,created_date,status,phone,license_no from dbo.users order by user_id";
        List<User> out = new ArrayList<>();
        try (Connection c = db.getConnection();
             PreparedStatement ps = c.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {
            while (rs.next()) out.add(map(rs));
        }
        return out;
    }

    public User findByEmail(String email) throws SQLException {
        if (email == null || email.isBlank()) return null;
        String sql = "select user_id,name,email,password_hash,role,created_date,status,phone,license_no from dbo.users where lower(email)=lower(?)";
        try (Connection c = db.getConnection(); PreparedStatement ps = c.prepareStatement(sql)) {
            ps.setString(1, email.trim());
            try (ResultSet rs = ps.executeQuery()) {
                return rs.next() ? map(rs) : null;
            }
        }
    }

    public User findById(String id) throws SQLException {
        String sql = "select user_id,name,email,password_hash,role,created_date,status,phone,license_no from dbo.users where user_id=?";
        try (Connection c = db.getConnection(); PreparedStatement ps = c.prepareStatement(sql)) {
            ps.setString(1, id);
            try (ResultSet rs = ps.executeQuery()) {
                return rs.next() ? map(rs) : null;
            }
        }
    }

    public String findCustomerIdByUserId(String userId) throws SQLException {
        try (Connection c = db.getConnection();
             PreparedStatement ps = c.prepareStatement("select customer_id from dbo.customers where user_id=?")) {
            ps.setString(1, userId);
            try (ResultSet rs = ps.executeQuery()) {
                return rs.next() ? rs.getString(1) : null;
            }
        }
    }

    public boolean authenticate(String email, String rawPassword) throws SQLException {
        User u = findByEmail(email);
        return u != null && "ACTIVE".equalsIgnoreCase(u.getStatus())
                && PasswordUtil.matches(rawPassword, u.getPassword());
    }

    /**
     * Registers a user and the corresponding customer subtype in one transaction.
     * Public registration is expected to pass role=CUSTOMER.
     */
    public boolean insert(String name, String email, String rawPassword, String role,
                          String phone, String licenseNo) throws SQLException {
        try (Connection c = db.getConnection()) {
            c.setAutoCommit(false);
            try {
                if (emailExists(c, email, null)) {
                    c.rollback();
                    return false;
                }
                String userId = nextId(c, "users", "user_id", "U");
                try (PreparedStatement ps = c.prepareStatement(
                        "insert into dbo.users(user_id,name,email,password_hash,role,created_date,status,phone,license_no) " +
                                "values(?,?,?,?,?,cast(getdate() as date),'ACTIVE',?,?)")) {
                    ps.setString(1, userId);
                    ps.setString(2, name.trim());
                    ps.setString(3, email.trim());
                    ps.setString(4, PasswordUtil.hash(rawPassword));
                    ps.setString(5, role.toUpperCase());
                    ps.setString(6, blankToNull(phone));
                    ps.setString(7, blankToNull(licenseNo));
                    ps.executeUpdate();
                }

                if ("CUSTOMER".equalsIgnoreCase(role)) {
                    String customerId = nextId(c, "customers", "customer_id", "C");
                    try (PreparedStatement ps = c.prepareStatement(
                            "insert into dbo.customers(customer_id,user_id,driving_license,verification_status) values(?,?,?,'PENDING')")) {
                        ps.setString(1, customerId);
                        ps.setString(2, userId);
                        ps.setString(3, blankToNull(licenseNo));
                        if (ps.executeUpdate() != 1) throw new SQLException("Customer subtype insert failed for " + userId);
                    }
                } else if (!"ADMIN".equalsIgnoreCase(role)) {
                    String staffId = nextId(c, "staff", "staff_id", "S");
                    try (PreparedStatement ps = c.prepareStatement(
                            "insert into dbo.staff(staff_id,user_id,job_title) values(?,?,?)")) {
                        ps.setString(1, staffId);
                        ps.setString(2, userId);
                        ps.setString(3, role.replace('_', ' '));
                        if (ps.executeUpdate() != 1) throw new SQLException("Staff subtype insert failed for " + userId);
                    }
                }
                c.commit();
                return true;
            } catch (SQLException | RuntimeException ex) {
                c.rollback();
                throw ex;
            } finally {
                c.setAutoCommit(true);
            }
        }
    }

    public CustomerProfile findCustomerProfileByUserId(String userId) throws SQLException {
        String sql = "select customer_id,user_id,driving_license,id_document_no,address_line,city,date_of_birth,verification_status from dbo.customers where user_id=?";
        try (Connection c = db.getConnection(); PreparedStatement ps = c.prepareStatement(sql)) {
            ps.setString(1, userId);
            try (ResultSet rs = ps.executeQuery()) {
                return rs.next() ? mapCustomerProfile(rs) : null;
            }
        }
    }

    public Map<String, CustomerProfile> findAllCustomerProfiles() throws SQLException {
        Map<String, CustomerProfile> out = new LinkedHashMap<>();
        String sql = "select customer_id,user_id,driving_license,id_document_no,address_line,city,date_of_birth,verification_status from dbo.customers order by customer_id";
        try (Connection c = db.getConnection(); PreparedStatement ps = c.prepareStatement(sql); ResultSet rs = ps.executeQuery()) {
            while (rs.next()) {
                CustomerProfile p = mapCustomerProfile(rs);
                out.put(p.getUserId(), p);
            }
        }
        return out;
    }

    /** Backward-compatible profile update used by existing callers. */
    public boolean updateProfile(String id, String name, String email, String phone, String licenseNo) throws SQLException {
        return updateProfile(id,name,email,phone,licenseNo,null,null,null,null,false);
    }

    public boolean updateProfile(String id, String name, String email, String phone, String licenseNo,
                                 String idDocumentNo, String addressLine, String city, LocalDate dateOfBirth,
                                 boolean updateCustomerVerificationFields) throws SQLException {
        try (Connection c = db.getConnection()) {
            c.setAutoCommit(false);
            try {
                if (emailExists(c, email, id)) {
                    c.rollback();
                    return false;
                }
                try (PreparedStatement ps = c.prepareStatement(
                        "update dbo.users set name=?,email=?,phone=?,license_no=? where user_id=?")) {
                    ps.setString(1, name.trim());
                    ps.setString(2, email.trim());
                    ps.setString(3, blankToNull(phone));
                    ps.setString(4, blankToNull(licenseNo));
                    ps.setString(5, id);
                    if (ps.executeUpdate() != 1) {
                        c.rollback();
                        return false;
                    }
                }
                if (updateCustomerVerificationFields) {
                    boolean verificationDataChanged = false;
                    try (PreparedStatement ps = c.prepareStatement(
                            "select driving_license,id_document_no,address_line,city,date_of_birth from dbo.customers where user_id=?")) {
                        ps.setString(1, id);
                        try (ResultSet rs = ps.executeQuery()) {
                            if (!rs.next()) {
                                c.rollback();
                                return false;
                            }
                            java.sql.Date oldDob = rs.getDate("date_of_birth");
                            verificationDataChanged =
                                    !Objects.equals(blankToNull(rs.getString("driving_license")), blankToNull(licenseNo)) ||
                                    !Objects.equals(blankToNull(rs.getString("id_document_no")), blankToNull(idDocumentNo)) ||
                                    !Objects.equals(blankToNull(rs.getString("address_line")), blankToNull(addressLine)) ||
                                    !Objects.equals(blankToNull(rs.getString("city")), blankToNull(city)) ||
                                    !Objects.equals(oldDob == null ? null : oldDob.toLocalDate(), dateOfBirth);
                        }
                    }
                    try (PreparedStatement ps = c.prepareStatement(
                            "update dbo.customers set driving_license=?,id_document_no=?,address_line=?,city=?,date_of_birth=?," +
                            "verification_status=case when ?=1 and verification_status='VERIFIED' then 'PENDING' else verification_status end where user_id=?")) {
                        ps.setString(1, blankToNull(licenseNo));
                        ps.setString(2, blankToNull(idDocumentNo));
                        ps.setString(3, blankToNull(addressLine));
                        ps.setString(4, blankToNull(city));
                        if (dateOfBirth == null) ps.setNull(5, java.sql.Types.DATE); else ps.setDate(5, java.sql.Date.valueOf(dateOfBirth));
                        ps.setInt(6, verificationDataChanged ? 1 : 0);
                        ps.setString(7, id);
                        if (ps.executeUpdate() != 1) {
                            c.rollback();
                            return false;
                        }
                    }
                } else {
                    try (PreparedStatement ps = c.prepareStatement("update dbo.customers set driving_license=? where user_id=?")) {
                        ps.setString(1, blankToNull(licenseNo));
                        ps.setString(2, id);
                        ps.executeUpdate();
                    }
                }
                c.commit();
                return true;
            } catch (SQLException | RuntimeException ex) {
                c.rollback();
                throw ex;
            } finally {
                c.setAutoCommit(true);
            }
        }
    }

    public boolean updateVerificationStatus(String userId, String status) throws SQLException {
        String normalized = status == null ? "" : status.trim().toUpperCase();
        if (!normalized.matches("PENDING|VERIFIED|REJECTED")) return false;
        try (Connection c = db.getConnection(); PreparedStatement ps = c.prepareStatement(
                "update dbo.customers set verification_status=? where user_id=?")) {
            ps.setString(1, normalized);
            ps.setString(2, userId);
            return ps.executeUpdate() == 1;
        }
    }


    public boolean updateAdminFields(String id, String name, String email, String role,
                                     String status, String phone, String licenseNo) throws SQLException {
        try (Connection c = db.getConnection()) {
            if (emailExists(c, email, id)) return false;
            String sql = "update dbo.users set name=?,email=?,role=?,status=?,phone=?,license_no=? where user_id=?";
            try (PreparedStatement ps = c.prepareStatement(sql)) {
                ps.setString(1, name.trim());
                ps.setString(2, email.trim());
                ps.setString(3, role.toUpperCase());
                ps.setString(4, status.toUpperCase());
                ps.setString(5, blankToNull(phone));
                ps.setString(6, blankToNull(licenseNo));
                ps.setString(7, id);
                return ps.executeUpdate() == 1;
            }
        }
    }

    public boolean updatePassword(String userId, String newRawPassword) throws SQLException {
        if (userId == null || userId.isBlank() || newRawPassword == null) return false;
        try (Connection c = db.getConnection();
             PreparedStatement ps = c.prepareStatement(
                     "update dbo.users set password_hash=? where user_id=?")) {
            ps.setString(1, PasswordUtil.hash(newRawPassword));
            ps.setString(2, userId);
            return ps.executeUpdate() == 1;
        }
    }

    public boolean updateStatus(String id, String status) throws SQLException {
        try (Connection c = db.getConnection();
             PreparedStatement ps = c.prepareStatement("update dbo.users set status=? where user_id=?")) {
            ps.setString(1, status.toUpperCase());
            ps.setString(2, id);
            return ps.executeUpdate() == 1;
        }
    }

    public boolean updateLastLogin(String id) throws SQLException {
        try (Connection c = db.getConnection();
             PreparedStatement ps = c.prepareStatement("update dbo.users set last_login_at=sysdatetime() where user_id=?")) {
            ps.setString(1, id);
            return ps.executeUpdate() == 1;
        }
    }

    public boolean softDelete(String id) throws SQLException {
        return updateStatus(id, "DEACTIVATED");
    }

    private boolean emailExists(Connection c, String email, String excludingUserId) throws SQLException {
        String sql = excludingUserId == null
                ? "select 1 from dbo.users where lower(email)=lower(?)"
                : "select 1 from dbo.users where lower(email)=lower(?) and user_id<>?";
        try (PreparedStatement ps = c.prepareStatement(sql)) {
            ps.setString(1, email == null ? "" : email.trim());
            if (excludingUserId != null) ps.setString(2, excludingUserId);
            try (ResultSet rs = ps.executeQuery()) {
                return rs.next();
            }
        }
    }

    private static String nextId(Connection c, String table, String column, String prefix) throws SQLException {
        // table/column are constants controlled by this class, not user input.
        String sql = "select isnull(max(try_cast(substring(" + column + ",2,20) as int)),0)+1 from dbo." + table + " with (updlock,holdlock)";
        try (PreparedStatement ps = c.prepareStatement(sql); ResultSet rs = ps.executeQuery()) {
            rs.next();
            return String.format(prefix + "%03d", rs.getInt(1));
        }
    }

    private User map(ResultSet rs) throws SQLException {
        String role = rs.getString("role");
        String created = rs.getDate("created_date") == null ? "" : rs.getDate("created_date").toLocalDate().toString();
        User u = "ADMIN".equalsIgnoreCase(role)
                ? new AdminUser(rs.getString("user_id"), rs.getString("name"), rs.getString("email"), rs.getString("password_hash"), role, created)
                : new RegularUser(rs.getString("user_id"), rs.getString("name"), rs.getString("email"), rs.getString("password_hash"), role, created);
        u.setStatus(rs.getString("status"));
        u.setPhone(rs.getString("phone"));
        u.setLicenseNo(rs.getString("license_no"));
        return u;
    }


    private static CustomerProfile mapCustomerProfile(ResultSet rs) throws SQLException {
        CustomerProfile p = new CustomerProfile();
        p.setCustomerId(rs.getString("customer_id"));
        p.setUserId(rs.getString("user_id"));
        p.setDrivingLicense(rs.getString("driving_license"));
        p.setIdDocumentNo(rs.getString("id_document_no"));
        p.setAddressLine(rs.getString("address_line"));
        p.setCity(rs.getString("city"));
        java.sql.Date d = rs.getDate("date_of_birth");
        p.setDateOfBirth(d == null ? null : d.toLocalDate());
        p.setVerificationStatus(rs.getString("verification_status"));
        return p;
    }
    private static String blankToNull(String s) {
        return s == null || s.isBlank() ? null : s.trim();
    }
}
