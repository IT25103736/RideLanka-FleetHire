package com.vehiclerental.booking;

import java.time.*;
import java.time.format.*;
import java.time.temporal.ChronoUnit;
import java.util.List;

public class DateValidator {

    private static final DateTimeFormatter FORMAT =
            DateTimeFormatter.ofPattern("yyyy-MM-dd");

    public static String validate(String startDate, String endDate,
                                  List<Booking> existingBookings,
                                  String vehicleId) {
        try {
            LocalDate start = LocalDate.parse(startDate, FORMAT);
            LocalDate end   = LocalDate.parse(endDate, FORMAT);
            LocalDate today = LocalDate.now();

            // Rule 1: Start date cannot be in the past
            if (start.isBefore(today)) {
                return "Start date cannot be in the past.";
            }

            // Rule 2: End date must be after start date
            if (!end.isAfter(start)) {
                return "End date must be after start date.";
            }

            // Rule 3: No overlap with existing bookings for same vehicle
            for (Booking b : existingBookings) {
                if (b.getVehicleId().equals(vehicleId)
                        && b.getStatus().equals("ACTIVE")) {

                    LocalDate existingStart = LocalDate.parse(b.getStartDate(), FORMAT);
                    LocalDate existingEnd   = LocalDate.parse(b.getEndDate(), FORMAT);

                    if (start.isBefore(existingEnd) && end.isAfter(existingStart)) {
                        return "Vehicle is already booked for the selected dates.";
                    }
                }
            }

        } catch (Exception e) {
            return "Invalid date format. Please use yyyy-MM-dd.";
        }

        return null; // null means no error
    }

    public static long daysBetweenTodayAndStart(String startDate) {
        LocalDate start = LocalDate.parse(startDate,FORMAT);
        return ChronoUnit.DAYS.between(LocalDate.now(), start);
    }
}
