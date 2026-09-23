package com.vehiclerental.booking;

import java.io.*;
import java.util.ArrayList;
import java.util.List;

/**
 * File I/O for bookings.txt — pipe '|' delimited.
 * Line format (withDriver + pickupLocation + pickupTime are appended, optional
 * for backward-compat with older rows that omit them):
 *   INSTANT: bookingId|userId|vehicleId|startDate|endDate|status|INSTANT[|withDriver[|pickupLocation|pickupTime]]
 *   ADVANCE: bookingId|userId|vehicleId|startDate|endDate|status|ADVANCE|daysInAdvance[|withDriver[|pickupLocation|pickupTime]]
 */
public class BookingFileHandler {

    private static final String FILE_PATH = "data/bookings.txt";

    public static void saveBooking(Booking booking) throws IOException {
        File f = new File(FILE_PATH);
        if (f.getParentFile() != null) f.getParentFile().mkdirs();
        try (BufferedWriter bw = new BufferedWriter(new FileWriter(f, true))) {
            bw.write(booking.toFileString());
            bw.newLine();
        }
    }

    public static List<Booking> readAllBookings() throws IOException {
        List<Booking> bookings = new ArrayList<>();
        File f = new File(FILE_PATH);
        if (!f.exists()) return bookings;

        try (BufferedReader br = new BufferedReader(new FileReader(f))) {
            String line;
            while ((line = br.readLine()) != null) {
                String trimmed = line.trim();
                if (trimmed.isEmpty() || trimmed.startsWith("#")) continue;

                String[] parts = trimmed.split("\\|");
                if (parts.length < 7) continue;

                String bookingId = parts[0];
                String userId    = parts[1];
                String vehicleId = parts[2];
                String startDate = parts[3];
                String endDate   = parts[4];
                String status    = parts[5];
                String type      = parts[6];

                Booking booking;
                boolean withDriver;
                int driverIdx;          // index of withDriver — pickup fields follow it
                if ("ADVANCE".equalsIgnoreCase(type)) {
                    int daysInAdvance = parts.length > 7 ? safeInt(parts[7]) : 0;
                    booking = new AdvanceBooking(bookingId, userId, vehicleId,
                            startDate, endDate, daysInAdvance);
                    driverIdx = 8;
                } else {
                    booking = new InstantBooking(bookingId, userId, vehicleId,
                            startDate, endDate);
                    driverIdx = 7;
                }
                withDriver = parts.length > driverIdx && Boolean.parseBoolean(parts[driverIdx].trim());
                String pickupLocation = parts.length > driverIdx + 1 ? parts[driverIdx + 1].trim() : "";
                String pickupTime     = parts.length > driverIdx + 2 ? parts[driverIdx + 2].trim() : "";
                String customerPhone  = parts.length > driverIdx + 3 ? parts[driverIdx + 3].trim() : "";

                booking.setStatus(status);
                booking.setWithDriver(withDriver);
                booking.setPickupLocation(pickupLocation);
                booking.setPickupTime(pickupTime);
                booking.setCustomerPhone(customerPhone);
                bookings.add(booking);
            }
        }
        return bookings;
    }

    public static void updateBookingStatus(String bookingId, String newStatus) throws IOException {
        File f = new File(FILE_PATH);
        if (!f.exists()) return;

        List<String> lines = new ArrayList<>();
        try (BufferedReader br = new BufferedReader(new FileReader(f))) {
            String line;
            while ((line = br.readLine()) != null) lines.add(line);
        }

        try (BufferedWriter bw = new BufferedWriter(new FileWriter(f, false))) {
            for (String l : lines) {
                if (l.trim().isEmpty() || l.trim().startsWith("#")) {
                    bw.write(l); bw.newLine(); continue;
                }
                String[] parts = l.split("\\|");
                if (parts.length >= 6 && parts[0].equals(bookingId)) {
                    parts[5] = newStatus;
                    l = String.join("|", parts);
                }
                bw.write(l);
                bw.newLine();
            }
        }
    }

    private static int safeInt(String s) {
        try { return Integer.parseInt(s.trim()); } catch (Exception e) { return 0; }
    }
}
