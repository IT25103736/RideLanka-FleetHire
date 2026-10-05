package com.vehiclerental.repository;

import com.vehiclerental.booking.AdvanceBooking;
import com.vehiclerental.booking.Booking;
import com.vehiclerental.booking.InstantBooking;
import com.vehiclerental.db.MssqlConnection;
import org.springframework.stereotype.Repository;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.sql.Time;
import java.sql.Types;
import java.time.LocalDate;
import java.util.ArrayList;
import java.util.List;

@Repository
public class BookingRepository {
    private final MssqlConnection db;

    public BookingRepository(MssqlConnection db) {
        this.db = db;
    }

    public List<Booking> findAll() throws SQLException {
        return queryBookings(null, null);
    }

    public List<Booking> findByUserId(String userId) throws SQLException {
        return queryBookings(" where c.user_id=?", userId);
    }

    public Booking findById(String bookingId) throws SQLException {
        List<Booking> list = queryBookings(" where b.booking_id=?", bookingId);
        return list.isEmpty() ? null : list.get(0);
    }

    public BookingInfo findInfo(String bookingId) throws SQLException {
        String sql = "select b.booking_id,b.customer_id,c.user_id,b.vehicle_id,b.start_date,b.end_date,b.pickup_time," +
                "b.customer_phone,b.booking_type,b.days_in_advance,b.with_driver,b.base_amount,b.discount_amount," +
                "b.driver_charge,b.total_amount,b.status,b.pickup_branch_id,b.return_branch_id,u.name customer_name,v.make,v.model " +
                "from dbo.bookings b join dbo.customers c on c.customer_id=b.customer_id " +
                "join dbo.users u on u.user_id=c.user_id join dbo.vehicles v on v.vehicle_id=b.vehicle_id where b.booking_id=?";
        try (Connection c = db.getConnection(); PreparedStatement ps = c.prepareStatement(sql)) {
            ps.setString(1, bookingId);
            try (ResultSet rs = ps.executeQuery()) {
                if (!rs.next()) return null;
                return new BookingInfo(
                        rs.getString("booking_id"), rs.getString("customer_id"), rs.getString("user_id"), rs.getString("vehicle_id"),
                        rs.getDate("start_date").toLocalDate(), rs.getDate("end_date").toLocalDate(),
                        rs.getTime("pickup_time") == null ? "" : rs.getTime("pickup_time").toLocalTime().toString().substring(0, 5),
                        rs.getString("customer_phone"), rs.getString("booking_type"), rs.getInt("days_in_advance"),
                        rs.getBoolean("with_driver"), rs.getDouble("base_amount"), rs.getDouble("discount_amount"),
                        rs.getDouble("driver_charge"), rs.getDouble("total_amount"), rs.getString("status"),
                        rs.getString("pickup_branch_id"), rs.getString("return_branch_id"), rs.getString("customer_name"),
                        rs.getString("make") + " " + rs.getString("model"));
            }
        }
    }

    public String customerIdForUser(String userId) throws SQLException {
        try (Connection c = db.getConnection(); PreparedStatement ps = c.prepareStatement("select customer_id from dbo.customers where user_id=?")) {
            ps.setString(1, userId);
            try (ResultSet rs = ps.executeQuery()) { return rs.next() ? rs.getString(1) : null; }
        }
    }

    public String branchIdForLocation(String location, String vehicleId) throws SQLException {
        if (location != null && !location.isBlank()) {
            try (Connection c = db.getConnection(); PreparedStatement ps = c.prepareStatement(
                    "select top 1 branch_id from dbo.branches where status='ACTIVE' and lower(city)=lower(?) order by branch_id")) {
                ps.setString(1, location.trim());
                try (ResultSet rs = ps.executeQuery()) { if (rs.next()) return rs.getString(1); }
            }
        }
        try (Connection c = db.getConnection(); PreparedStatement ps = c.prepareStatement("select branch_id from dbo.vehicles where vehicle_id=?")) {
            ps.setString(1, vehicleId);
            try (ResultSet rs = ps.executeQuery()) { return rs.next() ? rs.getString(1) : null; }
        }
    }

    public String nextId() throws SQLException {
        try (Connection c = db.getConnection()) { return nextId(c); }
    }

    /**
     * Creates a booking under SERIALIZABLE isolation and repeats the overlap/maintenance
     * checks while the relevant rows are locked. This prevents two concurrent requests
     * from reserving the same vehicle for overlapping dates.
     */
    public boolean createIfAvailable(Booking booking, String customerId, String pickupBranchId,
                                     double baseAmount, double driverCharge, double totalAmount) throws SQLException {
        try (Connection c = db.getConnection()) {
            c.setAutoCommit(false);
            c.setTransactionIsolation(Connection.TRANSACTION_SERIALIZABLE);
            try {
                if (!isVehicleAvailable(c, booking.getVehicleId(), LocalDate.parse(booking.getStartDate()),
                        LocalDate.parse(booking.getEndDate()), null)) {
                    c.rollback();
                    return false;
                }
                String sql = "insert into dbo.bookings(booking_id,customer_id,vehicle_id,pickup_branch_id,return_branch_id,start_date,end_date,pickup_time,customer_phone,booking_type,days_in_advance,with_driver,base_amount,discount_amount,driver_charge,total_amount,status) " +
                        "values(?,?,?,?,?,?,?,?,?,?,?,?,?,0,?,?,'PENDING')";
                try (PreparedStatement ps = c.prepareStatement(sql)) {
                    ps.setString(1, booking.getBookingId()); ps.setString(2, customerId); ps.setString(3, booking.getVehicleId());
                    ps.setString(4, pickupBranchId); ps.setString(5, pickupBranchId);
                    ps.setDate(6, java.sql.Date.valueOf(booking.getStartDate())); ps.setDate(7, java.sql.Date.valueOf(booking.getEndDate()));
                    setTimeOrNull(ps, 8, booking.getPickupTime()); ps.setString(9, blankToNull(booking.getCustomerPhone()));
                    ps.setString(10, booking.getBookingType());
                    if (booking instanceof AdvanceBooking a) ps.setInt(11, a.getDaysInAdvance()); else ps.setNull(11, Types.INTEGER);
                    ps.setBoolean(12, booking.isWithDriver()); ps.setDouble(13, baseAmount); ps.setDouble(14, driverCharge); ps.setDouble(15, totalAmount);
                    ps.executeUpdate();
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

    public boolean isVehicleAvailable(String vehicleId, LocalDate start, LocalDate end, String excludingBookingId) throws SQLException {
        try (Connection c = db.getConnection()) {
            return isVehicleAvailable(c, vehicleId, start, end, excludingBookingId);
        }
    }

    private boolean isVehicleAvailable(Connection c, String vehicleId, LocalDate start, LocalDate end,
                                       String excludingBookingId) throws SQLException {
        String statusSql = "select status from dbo.vehicles with (updlock,holdlock) where vehicle_id=?";
        try (PreparedStatement ps = c.prepareStatement(statusSql)) {
            ps.setString(1, vehicleId);
            try (ResultSet rs = ps.executeQuery()) {
                if (!rs.next()) return false;
                String s = rs.getString(1);
                if ("MAINTENANCE".equalsIgnoreCase(s) || "OUT_OF_SERVICE".equalsIgnoreCase(s)) return false;
            }
        }

        String overlapSql = "select top 1 1 from dbo.bookings with (updlock,holdlock) where vehicle_id=? " +
                "and status in ('PENDING','CONFIRMED','ACTIVE') and start_date < ? and end_date > ?" +
                (excludingBookingId == null ? "" : " and booking_id<>?");
        try (PreparedStatement ps = c.prepareStatement(overlapSql)) {
            ps.setString(1, vehicleId); ps.setDate(2, java.sql.Date.valueOf(end)); ps.setDate(3, java.sql.Date.valueOf(start));
            if (excludingBookingId != null) ps.setString(4, excludingBookingId);
            try (ResultSet rs = ps.executeQuery()) { if (rs.next()) return false; }
        }

        String maintenanceSql = "select top 1 1 from dbo.maintenance_records with (updlock,holdlock) where vehicle_id=? " +
                "and status in ('SCHEDULED','IN_PROGRESS') and scheduled_date>=? and scheduled_date<?";
        try (PreparedStatement ps = c.prepareStatement(maintenanceSql)) {
            ps.setString(1, vehicleId); ps.setDate(2, java.sql.Date.valueOf(start)); ps.setDate(3, java.sql.Date.valueOf(end));
            try (ResultSet rs = ps.executeQuery()) { return !rs.next(); }
        }
    }

    /** Only the owning customer may modify an unpaid PENDING booking. */
    public boolean updatePending(String bookingId, String userId, LocalDate start, LocalDate end,
                                 String pickupBranchId, String pickupTime, String phone, boolean withDriver,
                                 String bookingType, Integer daysInAdvance, double baseAmount,
                                 double driverCharge, double totalAmount) throws SQLException {
        try (Connection c = db.getConnection()) {
            c.setAutoCommit(false);
            c.setTransactionIsolation(Connection.TRANSACTION_SERIALIZABLE);
            try {
                String vehicleId;
                String status;
                try (PreparedStatement ps = c.prepareStatement(
                        "select b.vehicle_id,b.status from dbo.bookings b join dbo.customers c on c.customer_id=b.customer_id " +
                                "where b.booking_id=? and c.user_id=?")) {
                    ps.setString(1, bookingId); ps.setString(2, userId);
                    try (ResultSet rs = ps.executeQuery()) {
                        if (!rs.next()) { c.rollback(); return false; }
                        vehicleId = rs.getString(1); status = rs.getString(2);
                    }
                }
                if (!"PENDING".equalsIgnoreCase(status) || hasSuccessfulOrPendingPayment(c, bookingId)) {
                    c.rollback(); return false;
                }
                if (!isVehicleAvailable(c, vehicleId, start, end, bookingId)) { c.rollback(); return false; }

                String sql = "update dbo.bookings set pickup_branch_id=?,return_branch_id=?,start_date=?,end_date=?,pickup_time=?,customer_phone=?,booking_type=?,days_in_advance=?,with_driver=?,base_amount=?,discount_amount=0,driver_charge=?,total_amount=? where booking_id=? and status='PENDING'";
                try (PreparedStatement ps = c.prepareStatement(sql)) {
                    ps.setString(1, pickupBranchId); ps.setString(2, pickupBranchId); ps.setDate(3, java.sql.Date.valueOf(start)); ps.setDate(4, java.sql.Date.valueOf(end));
                    setTimeOrNull(ps, 5, pickupTime); ps.setString(6, blankToNull(phone)); ps.setString(7, bookingType);
                    if (daysInAdvance == null) ps.setNull(8, Types.INTEGER); else ps.setInt(8, daysInAdvance);
                    ps.setBoolean(9, withDriver); ps.setDouble(10, baseAmount); ps.setDouble(11, driverCharge); ps.setDouble(12, totalAmount); ps.setString(13, bookingId);
                    if (ps.executeUpdate() != 1) { c.rollback(); return false; }
                }
                c.commit(); return true;
            } catch (SQLException | RuntimeException ex) {
                c.rollback(); throw ex;
            } finally { c.setAutoCommit(true); }
        }
    }

    /**
     * Cancels an owned PENDING/CONFIRMED booking. Any PENDING payment is voided;
     * a successful demo payment is marked VOID and the invoice is voided so finance
     * state cannot remain "paid" after cancellation.
     */
    public boolean cancelOwned(String bookingId, String userId, String reason) throws SQLException {
        try (Connection c = db.getConnection()) {
            c.setAutoCommit(false);
            try {
                int changed;
                try (PreparedStatement ps = c.prepareStatement(
                        "update b set status='CANCELLED',cancelled_at=sysdatetime(),cancellation_reason=? " +
                                "from dbo.bookings b join dbo.customers c on c.customer_id=b.customer_id " +
                                "where b.booking_id=? and c.user_id=? and b.status in ('PENDING','CONFIRMED')")) {
                    ps.setString(1, blankToNull(reason)); ps.setString(2, bookingId); ps.setString(3, userId);
                    changed = ps.executeUpdate();
                }
                if (changed != 1) { c.rollback(); return false; }
                try (PreparedStatement ps = c.prepareStatement(
                        "update dbo.payments set status='VOID',gateway_response=coalesce(gateway_response,'')+' | Voided because booking was cancelled' where booking_id=? and status in ('PENDING','SUCCESS')")) {
                    ps.setString(1, bookingId); ps.executeUpdate();
                }
                try (PreparedStatement ps = c.prepareStatement("update dbo.invoices set status='VOID' where booking_id=? and status in ('ISSUED','PAID')")) {
                    ps.setString(1, bookingId); ps.executeUpdate();
                }
                c.commit(); return true;
            } catch (SQLException | RuntimeException ex) {
                c.rollback(); throw ex;
            } finally { c.setAutoCommit(true); }
        }
    }

    public long countByUser(String userId) throws SQLException {
        try (Connection c = db.getConnection(); PreparedStatement ps = c.prepareStatement(
                "select count(*) from dbo.bookings b join dbo.customers c on c.customer_id=b.customer_id where c.user_id=? and b.status<>'CANCELLED'")) {
            ps.setString(1, userId); try (ResultSet rs = ps.executeQuery()) { rs.next(); return rs.getLong(1); }
        }
    }

    public boolean hasCompletedBooking(String userId, String bookingId, String vehicleId) throws SQLException {
        String sql = "select 1 from dbo.bookings b join dbo.customers c on c.customer_id=b.customer_id where c.user_id=? and b.booking_id=? and b.vehicle_id=? and b.status='COMPLETED'";
        try (Connection c = db.getConnection(); PreparedStatement ps = c.prepareStatement(sql)) {
            ps.setString(1, userId); ps.setString(2, bookingId); ps.setString(3, vehicleId);
            try (ResultSet rs = ps.executeQuery()) { return rs.next(); }
        }
    }

    private List<Booking> queryBookings(String where, String param) throws SQLException {
        String sql = "select b.booking_id,c.user_id,b.vehicle_id,b.start_date,b.end_date,b.status,b.booking_type,b.days_in_advance,b.with_driver," +
                "br.city pickup_location,b.pickup_time,b.customer_phone from dbo.bookings b " +
                "join dbo.customers c on c.customer_id=b.customer_id join dbo.branches br on br.branch_id=b.pickup_branch_id" +
                (where == null ? "" : where) + " order by b.created_at desc,b.booking_id desc";
        List<Booking> out = new ArrayList<>();
        try (Connection c = db.getConnection(); PreparedStatement ps = c.prepareStatement(sql)) {
            if (param != null) ps.setString(1, param);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) out.add(map(rs));
            }
        }
        return out;
    }

    private Booking map(ResultSet rs) throws SQLException {
        String type = rs.getString("booking_type");
        Booking b = "ADVANCE".equalsIgnoreCase(type)
                ? new AdvanceBooking(rs.getString("booking_id"), rs.getString("user_id"), rs.getString("vehicle_id"),
                rs.getDate("start_date").toLocalDate().toString(), rs.getDate("end_date").toLocalDate().toString(), rs.getInt("days_in_advance"))
                : new InstantBooking(rs.getString("booking_id"), rs.getString("user_id"), rs.getString("vehicle_id"),
                rs.getDate("start_date").toLocalDate().toString(), rs.getDate("end_date").toLocalDate().toString());
        b.setStatus(rs.getString("status")); b.setWithDriver(rs.getBoolean("with_driver"));
        b.setPickupLocation(rs.getString("pickup_location"));
        Time t = rs.getTime("pickup_time"); b.setPickupTime(t == null ? "" : t.toLocalTime().toString().substring(0, 5));
        b.setCustomerPhone(rs.getString("customer_phone"));
        return b;
    }

    private boolean hasSuccessfulOrPendingPayment(Connection c, String bookingId) throws SQLException {
        try (PreparedStatement ps = c.prepareStatement("select top 1 1 from dbo.payments where booking_id=? and status in ('PENDING','SUCCESS')")) {
            ps.setString(1, bookingId); try (ResultSet rs = ps.executeQuery()) { return rs.next(); }
        }
    }

    private String nextId(Connection c) throws SQLException {
        try (PreparedStatement ps = c.prepareStatement(
                "select isnull(max(try_cast(substring(booking_id,2,20) as bigint)),0)+1 from dbo.bookings with (updlock,holdlock)");
             ResultSet rs = ps.executeQuery()) {
            rs.next(); return String.format("B%06d", rs.getLong(1));
        }
    }

    private static void setTimeOrNull(PreparedStatement ps, int index, String hhmm) throws SQLException {
        if (hhmm == null || hhmm.isBlank()) ps.setNull(index, Types.TIME);
        else ps.setTime(index, Time.valueOf(hhmm + ":00"));
    }

    private static String blankToNull(String s) { return s == null || s.isBlank() ? null : s.trim(); }

    public static class BookingInfo {
        private final String bookingId, customerId, userId, vehicleId, pickupTime, customerPhone, bookingType, status,
                pickupBranchId, returnBranchId, customerName, vehicleLabel;
        private final LocalDate startDate, endDate;
        private final int daysInAdvance;
        private final boolean withDriver;
        private final double baseAmount, discountAmount, driverCharge, totalAmount;

        public BookingInfo(String bookingId, String customerId, String userId, String vehicleId, LocalDate startDate,
                           LocalDate endDate, String pickupTime, String customerPhone, String bookingType,
                           int daysInAdvance, boolean withDriver, double baseAmount, double discountAmount,
                           double driverCharge, double totalAmount, String status, String pickupBranchId,
                           String returnBranchId, String customerName, String vehicleLabel) {
            this.bookingId=bookingId; this.customerId=customerId; this.userId=userId; this.vehicleId=vehicleId;
            this.startDate=startDate; this.endDate=endDate; this.pickupTime=pickupTime; this.customerPhone=customerPhone;
            this.bookingType=bookingType; this.daysInAdvance=daysInAdvance; this.withDriver=withDriver;
            this.baseAmount=baseAmount; this.discountAmount=discountAmount; this.driverCharge=driverCharge; this.totalAmount=totalAmount;
            this.status=status; this.pickupBranchId=pickupBranchId; this.returnBranchId=returnBranchId;
            this.customerName=customerName; this.vehicleLabel=vehicleLabel;
        }
        public String getBookingId(){return bookingId;} public String getCustomerId(){return customerId;} public String getUserId(){return userId;}
        public String getVehicleId(){return vehicleId;} public LocalDate getStartDate(){return startDate;} public LocalDate getEndDate(){return endDate;}
        public String getPickupTime(){return pickupTime;} public String getCustomerPhone(){return customerPhone;} public String getBookingType(){return bookingType;}
        public int getDaysInAdvance(){return daysInAdvance;} public boolean isWithDriver(){return withDriver;} public double getBaseAmount(){return baseAmount;}
        public double getDiscountAmount(){return discountAmount;} public double getDriverCharge(){return driverCharge;} public double getTotalAmount(){return totalAmount;}
        public String getStatus(){return status;} public String getPickupBranchId(){return pickupBranchId;} public String getReturnBranchId(){return returnBranchId;}
        public String getCustomerName(){return customerName;} public String getVehicleLabel(){return vehicleLabel;}
    }
}
