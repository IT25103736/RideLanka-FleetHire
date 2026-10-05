package com.vehiclerental.booking;

import java.time.LocalDate;
import java.time.LocalDateTime;
import java.time.format.DateTimeFormatter;
import java.time.temporal.ChronoUnit;

public class AdvanceBooking extends Booking {
    public static final int ADVANCE_LEAD_DAYS = 7;
    private static final DateTimeFormatter FMT = DateTimeFormatter.ofPattern("yyyy-MM-dd");
    private int daysInAdvance;

    public AdvanceBooking(String bookingId, String userId, String vehicleId,
                          String startDate, String endDate, int daysInAdvance) {
        super(bookingId, userId, vehicleId, startDate, endDate);
        this.daysInAdvance = daysInAdvance;
    }

    public int getDaysInAdvance() { return daysInAdvance; }

    @Override public String getBookingType() { return "ADVANCE"; }
    @Override public double calculateBaseCost(double dailyRate, int days, LocalDate today) { return Math.max(1, days) * dailyRate; }
    @Override public double getAppliedSurcharge(LocalDate today) { return 0.0; }

    @Override
    public String validateBookingRules(LocalDateTime now) {
        if (now == null) now = LocalDateTime.now();
        LocalDate today = now.toLocalDate();
        LocalDate start = LocalDate.parse(getStartDate(), FMT);
        long daysAhead = ChronoUnit.DAYS.between(today, start);
        if (daysAhead < ADVANCE_LEAD_DAYS) {
            return "Advance bookings must start at least " + ADVANCE_LEAD_DAYS
                    + " days from today — payment is due " + ADVANCE_LEAD_DAYS
                    + " days before pickup. Pick a later start date.";
        }
        return null;
    }

    @Override public boolean requiresImmediatePayment() { return false; }
}
