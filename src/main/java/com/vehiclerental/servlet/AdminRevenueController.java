package com.vehiclerental.servlet;

import com.vehiclerental.booking.Booking;
import com.vehiclerental.booking.BookingFileHandler;
import com.vehiclerental.model.User;
import com.vehiclerental.model.Vehicle;
import com.vehiclerental.payment.PaymentFileHandler;
import com.vehiclerental.util.VehicleFileHandler;
import jakarta.servlet.http.HttpSession;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.GetMapping;

import java.io.IOException;
import java.time.LocalDate;
import java.time.temporal.ChronoUnit;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.LinkedHashMap;
import java.util.List;
import java.util.Map;

/**
 * C05 — Revenue & rental analytics (admin only).
 * URL: GET /admin/revenue
 */
@Controller
public class AdminRevenueController {

    private final VehicleFileHandler vehicleHandler = new VehicleFileHandler();

    @GetMapping("/admin/revenue")
    public String revenue(Model model) {

        List<Booking> bookings;
        try { bookings = BookingFileHandler.readAllBookings(); }
        catch (IOException e) { bookings = java.util.Collections.emptyList(); }

        List<String> payments = PaymentFileHandler.readAllPayments();
        List<Vehicle> vehicles = vehicleHandler.getAllVehicles();

        // Total revenue from payments
        double totalRevenue = payments.stream()
                .mapToDouble(line -> {
                    String[] parts = line.split("[|,]");
                    if (parts.length < 4) return 0;
                    try { return Double.parseDouble(parts[3]); } catch (Exception e) { return 0; }
                }).sum();

        // Average rental duration (active + completed)
        double avgDuration = bookings.stream()
                .filter(b -> !"CANCELLED".equalsIgnoreCase(b.getStatus()))
                .mapToLong(this::durationDays)
                .average().orElse(0.0);

        // Most-rented vehicle
        Map<String, Integer> rentalCount = new HashMap<>();
        for (Booking b : bookings) {
            if ("CANCELLED".equalsIgnoreCase(b.getStatus())) continue;
            rentalCount.merge(b.getVehicleId(), 1, Integer::sum);
        }
        String mostRentedId = rentalCount.entrySet().stream()
                .max(Map.Entry.comparingByValue())
                .map(Map.Entry::getKey)
                .orElse("—");

        // Monthly revenue series (last 6 months)
        Map<String, Double> monthly = monthlyRevenue(payments);

        model.addAttribute("totalRevenue",   totalRevenue);
        model.addAttribute("totalBookings",  bookings.size());
        model.addAttribute("avgDuration",    avgDuration);
        model.addAttribute("mostRentedId",   mostRentedId);
        model.addAttribute("fleetSize",      vehicles.size());
        model.addAttribute("monthly",        monthly);
        model.addAttribute("rentalCount",    rentalCount);
        model.addAttribute("weekly",         weeklyRevenue(payments));
        model.addAttribute("revenueByType",  revenueByType(payments, bookings, vehicles));
        model.addAttribute("topN",           topNRentals(rentalCount, 5));
        return "admin-revenue";
    }

    /** Last 8 weeks revenue map, key=yyyy-Www, used for sparklines. */
    private Map<String, Double> weeklyRevenue(List<String> payments) {
        java.time.temporal.WeekFields wf = java.time.temporal.WeekFields.ISO;
        Map<String, Double> map = new LinkedHashMap<>();
        LocalDate today = PaymentFileHandler.latestPaymentDate(payments);
        for (int i = 7; i >= 0; i--) {
            LocalDate d = today.minusWeeks(i);
            map.put(d.getYear() + "-W" + String.format("%02d", d.get(wf.weekOfWeekBasedYear())), 0.0);
        }
        for (String line : payments) {
            String[] parts = line.split("[|,]");
            if (parts.length < 5) continue;
            try {
                LocalDate d = LocalDate.parse(parts[4]);
                String key = d.getYear() + "-W" + String.format("%02d", d.get(wf.weekOfWeekBasedYear()));
                if (map.containsKey(key)) map.merge(key, Double.parseDouble(parts[3]), Double::sum);
            } catch (Exception ignored) {}
        }
        return map;
    }

    /**
     * Revenue split by the 7-category display label (Sedan / Hybrid / SUV / Hatchback /
     * Electric / Van — the same breakdown the home-page tiles use.
     * <p>
     * Joins payment row → booking row → vehicle row, then dispatches polymorphically to
     * {@code Vehicle.getDisplayCategory()} (Car narrows by seat count + model;
     * Van just returns its type). All six slots are pre-populated with 0.0 so
     * the donut chart legend is stable even when a category has no revenue yet.
     */
    private Map<String, Double> revenueByType(List<String> payments, List<Booking> bookings, List<Vehicle> vehicles) {
        Map<String, String> categoryByVehicle = new HashMap<>();
        for (Vehicle v : vehicles) categoryByVehicle.put(v.getVehicleId(), v.getDisplayCategory());
        Map<String, String> categoryByBooking = new HashMap<>();
        for (Booking b : bookings) categoryByBooking.put(b.getBookingId(), categoryByVehicle.get(b.getVehicleId()));

        // Order here drives the donut slice order + the data table beneath it.
        Map<String, Double> map = new LinkedHashMap<>();
        map.put("Sedan",     0.0);
        map.put("Hybrid",    0.0);
        map.put("SUV",       0.0);
        map.put("Hatchback", 0.0);
        map.put("Electric",  0.0);
        map.put("Van",       0.0);

        for (String line : payments) {
            String[] parts = line.split("\\|");
            if (parts.length < 10) continue;
            if (!"Success".equalsIgnoreCase(parts[5].trim())) continue;
            String category = categoryByBooking.get(parts[9].trim());
            if (category == null || !map.containsKey(category)) continue;
            try { map.merge(category, Double.parseDouble(parts[3].trim()), Double::sum); }
            catch (NumberFormatException ignored) {}
        }
        return map;
    }

    /** Top N most-rented vehicles for the bar chart. */
    private List<Map.Entry<String, Integer>> topNRentals(Map<String, Integer> rentalCount, int limit) {
        return rentalCount.entrySet().stream()
                .sorted((a, b) -> Integer.compare(b.getValue(), a.getValue()))
                .limit(limit).toList();
    }

    @GetMapping("/admin/top-vehicles")
    public String topVehicles(HttpSession session, Model model) {
        Object logged = session.getAttribute("loggedUser");
        if (!(logged instanceof User u)) return "redirect:/login";
        if (!"ADMIN".equalsIgnoreCase(u.getRole())) return "redirect:/dashboard";

        List<Booking> bookings;
        try { bookings = BookingFileHandler.readAllBookings(); }
        catch (IOException e) { bookings = java.util.Collections.emptyList(); }

        List<Vehicle> vehicles = vehicleHandler.getAllVehicles();
        Map<String, Vehicle> byId = new HashMap<>();
        for (Vehicle v : vehicles) byId.put(v.getVehicleId(), v);

        // bookingId -> vehicleId for the payment-join below
        Map<String, String> vehicleByBooking = new HashMap<>();
        Map<String, Integer> rentals    = new HashMap<>();
        Map<String, Long>    daysTotal  = new HashMap<>();
        for (Booking b : bookings) {
            vehicleByBooking.put(b.getBookingId(), b.getVehicleId());
            if ("CANCELLED".equalsIgnoreCase(b.getStatus())) continue;
            rentals.merge(b.getVehicleId(), 1, Integer::sum);
            daysTotal.merge(b.getVehicleId(), durationDays(b), Long::sum);
        }

        Map<String, Double> revenue = new HashMap<>();
        for (String line : PaymentFileHandler.readAllPayments()) {
            String[] parts = line.split("\\|");
            if (parts.length < 10) continue;            // legacy rows have no bookingId, skip
            if (!"Success".equalsIgnoreCase(parts[5].trim())) continue;
            String vid = vehicleByBooking.get(parts[9].trim());
            if (vid == null) continue;
            try { revenue.merge(vid, Double.parseDouble(parts[3].trim()), Double::sum); }
            catch (NumberFormatException ignored) {}
        }

        // Build a sortable view-model list, skip vehicles that no longer exist in vehicles.txt
        List<TopVehicleRow> rows = new ArrayList<>();
        for (Map.Entry<String, Integer> e : rentals.entrySet()) {
            String vid = e.getKey();
            Vehicle veh = byId.get(vid);
            if (veh == null) continue;
            int count = e.getValue();
            double avg = count > 0 ? daysTotal.getOrDefault(vid, 0L).doubleValue() / count : 0;
            rows.add(new TopVehicleRow(veh, count,
                    revenue.getOrDefault(vid, 0.0), avg));
        }
        rows.sort((a, b) -> Integer.compare(b.rentals, a.rentals));

        model.addAttribute("rows", rows);
        return "adminTopVehicles";
    }

    /** Sortable view-model for the Top Vehicles leaderboard. */
    public static class TopVehicleRow {
        private final Vehicle vehicle;
        public final int rentals;
        public final double revenue;
        public final double avgTripDays;
        public TopVehicleRow(Vehicle v, int rentals, double revenue, double avg) {
            this.vehicle = v; this.rentals = rentals; this.revenue = revenue; this.avgTripDays = avg;
        }
        public Vehicle getVehicle()    { return vehicle; }
        public int     getRentals()    { return rentals; }
        public double  getRevenue()    { return revenue; }
        public double  getAvgTripDays(){ return avgTripDays; }
    }

    private long durationDays(Booking b) {
        try {
            LocalDate s = LocalDate.parse(b.getStartDate());
            LocalDate e = LocalDate.parse(b.getEndDate());
            return Math.max(1, ChronoUnit.DAYS.between(s, e));
        } catch (Exception ex) { return 1; }
    }

    /**
     * Last 4 months of revenue, keyed yyyy-MM. Pre-populates every month in the
     * window with 0.0 BEFORE merging payment totals — otherwise sparse data (e.g.
     * payments only in May + Jun) produces a 2-point series and Chart.js draws
     * a straight line. Window is anchored to the latest payment date so seeded
     * forward-dated rows still appear (see PaymentFileHandler.latestPaymentDate).
     */
    private Map<String, Double> monthlyRevenue(List<String> payments) {
        Map<String, Double> map = new LinkedHashMap<>();
        LocalDate today = PaymentFileHandler.latestPaymentDate(payments);
        for (int i = 3; i >= 0; i--) {
            LocalDate d = today.minusMonths(i);
            map.put(d.getYear() + "-" + String.format("%02d", d.getMonthValue()), 0.0);
        }
        for (String line : payments) {
            String[] parts = line.split("[|,]");
            if (parts.length < 5) continue;
            try {
                LocalDate d = LocalDate.parse(parts[4]);
                String key = d.getYear() + "-" + String.format("%02d", d.getMonthValue());
                if (map.containsKey(key)) map.merge(key, Double.parseDouble(parts[3]), Double::sum);
            } catch (Exception ignored) {}
        }
        return map;
    }
}
