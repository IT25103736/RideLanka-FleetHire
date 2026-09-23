package com.vehiclerental.booking;

import java.time.LocalDate;
import java.time.LocalDateTime;
import java.time.temporal.ChronoUnit;
import java.time.format.DateTimeFormatter;

public abstract class Booking {
    private String bookingId;
    private String userId;
    private String vehicleId;
    private String startDate;
    private String endDate;
    private String status;
    private boolean withDriver; // Sri Lanka market reality — chauffeur option per booking
    private String pickupLocation; // "Colombo" or "Kandy"
    private String pickupTime; // 24h "HH:00", 09:00–21:00
    private String customerPhone; // captured from booking form; powers admin-side WhatsApp send

    public Booking(String bookingId, String userId, String vehicleId,
            String startDate, String endDate) {
        this.bookingId = bookingId;
        this.userId = userId;
        this.vehicleId = vehicleId;
        this.startDate = startDate;
        this.endDate = endDate;
        this.status = "ACTIVE"; // every new booking starts as ACTIVE
        this.withDriver = false;
        this.pickupLocation = "";
        this.pickupTime = "";
        this.customerPhone = "";
    }

    public String getBookingId() {
        return bookingId;
    }

    public String getUserId() {
        return userId;
    }

    public String getVehicleId() {
        return vehicleId;
    }

    public String getStartDate() {
        return startDate;
    }

    public String getEndDate() {
        return endDate;
    }

    public String getStatus() {
        return status;
    }

    public boolean isWithDriver() {
        return withDriver;
    }

    public void setStatus(String status) {
        this.status = status;
    }

    public void setWithDriver(boolean withDriver) {
        this.withDriver = withDriver;
    }

    public String getPickupLocation() {
        return pickupLocation == null ? "" : pickupLocation;
    }

    public String getPickupTime() {
        return pickupTime == null ? "" : pickupTime;
    }

    public void setPickupLocation(String pickupLocation) {
        this.pickupLocation = pickupLocation == null ? "" : pickupLocation;
    }

    public void setPickupTime(String pickupTime) {
        this.pickupTime = pickupTime == null ? "" : pickupTime;
    }

    public String getCustomerPhone() {
        return customerPhone == null ? "" : customerPhone;
    }

    public void setCustomerPhone(String customerPhone) {
        this.customerPhone = customerPhone == null ? "" : customerPhone.trim();
    }

    // Polymorphism — each subclass MUST provide its own version
    public abstract String getBookingType();

    /**
     * Polymorphic cost calculation. Each subclass applies its own surcharge
     * logic; pass `today` so tiered pricing is deterministic regardless of
     * when this method is called.
     */
    public abstract double calculateBaseCost(double dailyRate, int days, LocalDate today);

    /**
     * Returns the applied surcharge rate (0.00, 0.05, 0.10, or 0.25). Used by
     * the servlet for logging and by the confirmation JSP for the line-item
     * label. Avoids an instanceof check in the servlet.
     */
    public abstract double getAppliedSurcharge(LocalDate today);

    /**
     * Polymorphic validation of type-specific business rules.
     * Returns null when OK, or a user-facing error string when a rule is broken.
     * Mirrors the DateValidator.validate(...) contract that already exists.
     */
    public abstract String validateBookingRules(LocalDateTime now);

    /**
     * Instant bookings must be paid up-front (true); Advance bookings show a
     * confirmation interstitial first (false). The servlet uses this to decide
     * the post-create redirect target.
     */
    public abstract boolean requiresImmediatePayment();

    // Converts this booking to one line for saving to bookings.txt (pipe-delimited)
    public String toFileString() {
        return bookingId + "|" + userId + "|" + vehicleId + "|"
                + startDate + "|" + endDate + "|" + status + "|" + getBookingType();
    }

    /**
     * Routes a candidate booking to the correct subclass based on lead time.
     * daysAhead < 7 → InstantBooking
     * daysAhead ≥ 7 → AdvanceBooking (with daysInAdvance precomputed)
     * Pure routing — never throws, never returns null when given valid dates.
     */
    public static Booking classify(String bookingId, String userId, String vehicleId,
            LocalDate start, LocalDate end, LocalDate today) {
        long daysAhead = ChronoUnit.DAYS.between(today, start);
        if (daysAhead < 7) {
            return new InstantBooking(bookingId, userId, vehicleId,
                    start.toString(), end.toString());
        }
        return new AdvanceBooking(bookingId, userId, vehicleId,
                start.toString(), end.toString(),
                (int) daysAhead);
    }
}
