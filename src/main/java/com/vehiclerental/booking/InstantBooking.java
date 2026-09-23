package com.vehiclerental.booking;

import java.time.LocalDate;
import java.time.LocalDateTime;
import java.time.format.DateTimeFormatter;
import java.time.temporal.ChronoUnit;

public class InstantBooking extends Booking {

    /** Maximum rental nights for an Instant booking. */
    public static final int MAX_INSTANT_DAYS = 5;

    /** Minimum hours between booking creation and pickup when start == today. */
    public static final int SAME_DAY_LEAD_HOURS = 5;

    /** Surcharge rates — closer pickup, higher premium. */
    public static final double SAME_DAY_SURCHARGE         = 0.25;  // daysAhead == 0
    public static final double WITHIN_3_DAYS_SURCHARGE    = 0.10;  // daysAhead 1..3
    public static final double STANDARD_INSTANT_SURCHARGE = 0.05;  // daysAhead 4..6

    private static final DateTimeFormatter FMT = DateTimeFormatter.ofPattern("yyyy-MM-dd");

    public InstantBooking(String bookingId, String userId, String vehicleId,
                          String startDate, String endDate) {
        super(bookingId, userId, vehicleId, startDate, endDate);
    }

    @Override
    public String getBookingType() {
        return "INSTANT";
    }

    @Override
    public double calculateBaseCost(double dailyRate, int days, LocalDate today) {
        return Math.max(1, days) * dailyRate * (1 + surchargeFor(today));
    }

    @Override
    public double getAppliedSurcharge(LocalDate today) {
        return surchargeFor(today);
    }

    @Override
    public String validateBookingRules(LocalDateTime now) {
        if (now == null) now = LocalDateTime.now();
        LocalDate today = now.toLocalDate();
        LocalDate start = LocalDate.parse(getStartDate(), FMT);
        LocalDate end   = LocalDate.parse(getEndDate(),   FMT);
        long durationDays = ChronoUnit.DAYS.between(start, end);

        // 1) Duration cap
        if (durationDays > MAX_INSTANT_DAYS) {
            return "Instant bookings can be at most " + MAX_INSTANT_DAYS
                 + " days. Pick a shorter rental or choose a pickup date 7+ days "
                 + "from today for Advance booking.";
        }

        // 2) Same-day 5-hour lead (only when start == today)
        if (isSameDayPickup(today)) {
            String pickup = getPickupTime();  // "HH:00"
            if (pickup == null || pickup.isEmpty()) {
                return "Pickup time is required for same-day bookings.";
            }
            int hour = Integer.parseInt(pickup.substring(0, 2));
            LocalDateTime pickupDt = LocalDateTime.of(start, java.time.LocalTime.of(hour, 0));
            if (pickupDt.isBefore(now.plusHours(SAME_DAY_LEAD_HOURS))) {
                int earliest = (int) Math.ceil(
                        (now.getHour() + SAME_DAY_LEAD_HOURS) + (now.getMinute() / 60.0));
                if (earliest > 21) {
                    return "No same-day slots remaining. Pick tomorrow or later.";
                }
                String earliestSlot = String.format("%02d:00", earliest);
                return "Same-day pickups need at least " + SAME_DAY_LEAD_HOURS
                     + " hours notice. Earliest available time today is " + earliestSlot + ".";
            }
        }

        // 3) Past-date guard — gives a friendly message instead of the
        //    upstream DateValidator's "cannot be in the past" check
        //    (which can't fire because we run before it).
        long daysAhead = ChronoUnit.DAYS.between(today, start);
        if (daysAhead < 0) {
            return "Start date cannot be in the past.";
        }
        // Defensive: classifier should never hand us a > 6 lead Instant.
        if (daysAhead > 6) {
            return "Internal error: instant booking outside 7-day window.";
        }

        return null;
    }

    @Override
    public boolean requiresImmediatePayment() {
        return true;
    }

    /** True when the pickup date equals today. */
    private boolean isSameDayPickup(LocalDate today) {
        return LocalDate.parse(getStartDate(), FMT).equals(today);
    }

    /** Picks the surcharge tier for the current daysAhead. */
    private double surchargeFor(LocalDate today) {
        long daysAhead = ChronoUnit.DAYS.between(today, LocalDate.parse(getStartDate(), FMT));
        if (daysAhead == 0)  return SAME_DAY_SURCHARGE;
        if (daysAhead <= 3)  return WITHIN_3_DAYS_SURCHARGE;
        return STANDARD_INSTANT_SURCHARGE;  // daysAhead 4..6
    }

    /**
     * Row layout: ...|status|INSTANT|withDriver|pickupLocation|pickupTime|customerPhone
     * Append-only — phone was added last so legacy 10-field rows still parse.
     */
    @Override
    public String toFileString() {
        return super.toFileString() + "|" + isWithDriver()
                + "|" + getPickupLocation() + "|" + getPickupTime()
                + "|" + getCustomerPhone();
    }
}
