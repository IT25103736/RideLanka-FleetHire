package com.vehiclerental.repository;

import com.vehiclerental.db.MssqlConnection;
import com.vehiclerental.fleet.ManagedVehicle;
import com.vehiclerental.model.Car;
import com.vehiclerental.model.Van;
import com.vehiclerental.model.Vehicle;
import org.springframework.stereotype.Repository;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.sql.Types;
import java.time.LocalDate;
import java.util.ArrayList;
import java.util.List;

@Repository
public class VehicleRepository {
    private final MssqlConnection db;

    public VehicleRepository(MssqlConnection db) {
        this.db = db;
    }

    public List<ManagedVehicle> findAll() throws SQLException {
        String sql = baseSelect() + " order by v.vehicle_id";
        List<ManagedVehicle> out = new ArrayList<>();
        try (Connection c = db.getConnection(); PreparedStatement ps = c.prepareStatement(sql); ResultSet rs = ps.executeQuery()) {
            while (rs.next()) out.add(map(rs));
        }
        return out;
    }

    public List<Vehicle> findAllDomain() throws SQLException {
        List<Vehicle> out = new ArrayList<>();
        for (ManagedVehicle v : findAll()) out.add(toDomain(v));
        return out;
    }

    public ManagedVehicle findById(String id) throws SQLException {
        try (Connection c = db.getConnection(); PreparedStatement ps = c.prepareStatement(baseSelect() + " where v.vehicle_id=?")) {
            ps.setString(1, id);
            try (ResultSet rs = ps.executeQuery()) {
                return rs.next() ? map(rs) : null;
            }
        }
    }

    public Vehicle findDomainById(String id) throws SQLException {
        ManagedVehicle v = findById(id);
        return v == null ? null : toDomain(v);
    }

    public List<String[]> branches() throws SQLException {
        List<String[]> out = new ArrayList<>();
        try (Connection c = db.getConnection();
             PreparedStatement ps = c.prepareStatement("select branch_id,branch_name from dbo.branches where status='ACTIVE' order by branch_name");
             ResultSet rs = ps.executeQuery()) {
            while (rs.next()) out.add(new String[]{rs.getString(1), rs.getString(2)});
        }
        return out;
    }

    public List<String[]> categories() throws SQLException {
        List<String[]> out = new ArrayList<>();
        try (Connection c = db.getConnection();
             PreparedStatement ps = c.prepareStatement("select category_id,category_name from dbo.vehicle_categories order by category_name");
             ResultSet rs = ps.executeQuery()) {
            while (rs.next()) out.add(new String[]{rs.getString(1), rs.getString(2)});
        }
        return out;
    }

    public boolean exists(String id) throws SQLException {
        try (Connection c = db.getConnection(); PreparedStatement ps = c.prepareStatement("select 1 from dbo.vehicles where vehicle_id=?")) {
            ps.setString(1, id);
            try (ResultSet rs = ps.executeQuery()) { return rs.next(); }
        }
    }

    public boolean plateExists(String plate, String excludingVehicleId) throws SQLException {
        String sql = excludingVehicleId == null
                ? "select 1 from dbo.vehicles where upper(plate_no)=upper(?)"
                : "select 1 from dbo.vehicles where upper(plate_no)=upper(?) and vehicle_id<>?";
        try (Connection c = db.getConnection(); PreparedStatement ps = c.prepareStatement(sql)) {
            ps.setString(1, plate);
            if (excludingVehicleId != null) ps.setString(2, excludingVehicleId);
            try (ResultSet rs = ps.executeQuery()) { return rs.next(); }
        }
    }

    public boolean insert(String id, String plate, String make, String model, int year, String transmission,
                          String fuel, int seats, int mileage, double rate, String categoryId, String branchId,
                          String imageUrl, String regExp, String insExp, String permitExp, String type) throws SQLException {
        String sql = "insert into dbo.vehicles(vehicle_id,plate_no,make,model,vehicle_year,transmission,fuel_type,seats,mileage,daily_rate,status,category_id,branch_id,image_url,registration_expiry,insurance_expiry,permit_expiry,vehicle_type) " +
                "values(?,?,?,?,?,?,?,?,?,?,'AVAILABLE',?,?,?,?,?,?,?)";
        try (Connection c = db.getConnection(); PreparedStatement ps = c.prepareStatement(sql)) {
            ps.setString(1, id); ps.setString(2, plate); ps.setString(3, make); ps.setString(4, model); ps.setInt(5, year);
            ps.setString(6, transmission.toUpperCase()); ps.setString(7, fuel.toUpperCase()); ps.setInt(8, seats); ps.setInt(9, mileage); ps.setDouble(10, rate);
            ps.setString(11, categoryId); ps.setString(12, branchId); ps.setString(13, blankToNull(imageUrl));
            dateOrNull(ps, 14, regExp); dateOrNull(ps, 15, insExp); dateOrNull(ps, 16, permitExp); ps.setString(17, normalizeType(type));
            return ps.executeUpdate() == 1;
        }
    }

    /** Updates master information and records a branch transfer when branch_id changes. */
    public boolean updateWithBranchHistory(String id, String plate, String make, String model, int year,
                                           String transmission, String fuel, int seats, int mileage, double rate,
                                           String categoryId, String branchId, String imageUrl, String regExp,
                                           String insExp, String permitExp, String type, String actor) throws SQLException {
        try (Connection c = db.getConnection()) {
            c.setAutoCommit(false);
            try {
                String oldBranch = null;
                try (PreparedStatement ps = c.prepareStatement("select branch_id from dbo.vehicles with (updlock,holdlock) where vehicle_id=?")) {
                    ps.setString(1, id);
                    try (ResultSet rs = ps.executeQuery()) {
                        if (!rs.next()) { c.rollback(); return false; }
                        oldBranch = rs.getString(1);
                    }
                }

                String sql = "update dbo.vehicles set plate_no=?,make=?,model=?,vehicle_year=?,transmission=?,fuel_type=?,seats=?,mileage=?,daily_rate=?,category_id=?,branch_id=?,image_url=?,registration_expiry=?,insurance_expiry=?,permit_expiry=?,vehicle_type=? where vehicle_id=?";
                try (PreparedStatement ps = c.prepareStatement(sql)) {
                    ps.setString(1, plate); ps.setString(2, make); ps.setString(3, model); ps.setInt(4, year);
                    ps.setString(5, transmission.toUpperCase()); ps.setString(6, fuel.toUpperCase()); ps.setInt(7, seats); ps.setInt(8, mileage); ps.setDouble(9, rate);
                    ps.setString(10, categoryId); ps.setString(11, branchId); ps.setString(12, blankToNull(imageUrl));
                    dateOrNull(ps, 13, regExp); dateOrNull(ps, 14, insExp); dateOrNull(ps, 15, permitExp); ps.setString(16, normalizeType(type)); ps.setString(17, id);
                    if (ps.executeUpdate() != 1) { c.rollback(); return false; }
                }

                if (oldBranch != null && !oldBranch.equals(branchId)) {
                    try (PreparedStatement ps = c.prepareStatement(
                            "insert into dbo.vehicle_branch_transfers(vehicle_id,from_branch_id,to_branch_id,transferred_by,notes) values(?,?,?,?,?)")) {
                        ps.setString(1, id); ps.setString(2, oldBranch); ps.setString(3, branchId); ps.setString(4, blankToNull(actor));
                        ps.setString(5, "Branch changed through Vehicle Management");
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

    public boolean delete(String id) throws SQLException {
        try (Connection c = db.getConnection(); PreparedStatement ps = c.prepareStatement("delete from dbo.vehicles where vehicle_id=?")) {
            ps.setString(1, id);
            return ps.executeUpdate() == 1;
        }
    }

    public boolean updateStatus(String id, String status) throws SQLException {
        try (Connection c = db.getConnection(); PreparedStatement ps = c.prepareStatement("update dbo.vehicles set status=? where vehicle_id=?")) {
            ps.setString(1, status.toUpperCase()); ps.setString(2, id); return ps.executeUpdate() == 1;
        }
    }

    private static String baseSelect() {
        return "select v.vehicle_id,v.plate_no,v.make,v.model,v.vehicle_year,v.transmission,v.fuel_type," +
                "v.seats,v.mileage,v.daily_rate,v.status,v.category_id,c.category_name,v.branch_id,b.branch_name," +
                "v.image_url,v.registration_expiry,v.insurance_expiry,v.permit_expiry,coalesce(v.vehicle_type,'Car') vehicle_type " +
                "from dbo.vehicles v join dbo.vehicle_categories c on c.category_id=v.category_id " +
                "join dbo.branches b on b.branch_id=v.branch_id";
    }

    private ManagedVehicle map(ResultSet rs) throws SQLException {
        java.sql.Date reg = rs.getDate("registration_expiry");
        java.sql.Date ins = rs.getDate("insurance_expiry");
        java.sql.Date permit = rs.getDate("permit_expiry");
        return new ManagedVehicle(rs.getString("vehicle_id"), rs.getString("plate_no"), rs.getString("make"), rs.getString("model"),
                rs.getInt("vehicle_year"), rs.getString("transmission"), rs.getString("fuel_type"), rs.getInt("seats"),
                rs.getInt("mileage"), rs.getDouble("daily_rate"), rs.getString("status"), rs.getString("category_id"),
                rs.getString("category_name"), rs.getString("branch_id"), rs.getString("branch_name"), rs.getString("image_url"),
                reg == null ? null : reg.toLocalDate(), ins == null ? null : ins.toLocalDate(), permit == null ? null : permit.toLocalDate(),
                rs.getString("vehicle_type"));
    }

    public static Vehicle toDomain(ManagedVehicle mv) {
        boolean available = "AVAILABLE".equalsIgnoreCase(mv.getStatus());
        Vehicle v;
        if ("Van".equalsIgnoreCase(mv.getVehicleType())) {
            // The schema stores passenger seats (not a separate cargo capacity), so the
            // legacy Van extra field is populated with seats for display compatibility.
            v = new Van(mv.getVehicleId(), mv.getMake(), mv.getModel(), mv.getVehicleYear(), mv.getDailyRate(), available, mv.getSeats());
        } else {
            v = new Car(mv.getVehicleId(), mv.getMake(), mv.getModel(), mv.getVehicleYear(), mv.getDailyRate(), available, mv.getSeats());
        }
        v.setImageUrl(mv.getImageUrl());
        return v;
    }

    private static void dateOrNull(PreparedStatement ps, int index, String value) throws SQLException {
        if (value == null || value.isBlank()) ps.setNull(index, Types.DATE);
        else ps.setDate(index, java.sql.Date.valueOf(LocalDate.parse(value)));
    }

    private static String normalizeType(String type) {
        return "Van".equalsIgnoreCase(type) ? "Van" : "Car";
    }

    private static String blankToNull(String s) {
        return s == null || s.isBlank() ? null : s.trim();
    }
}
