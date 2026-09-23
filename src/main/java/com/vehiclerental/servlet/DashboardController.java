package com.vehiclerental.servlet;

import com.vehiclerental.booking.Booking;
import com.vehiclerental.booking.BookingFileHandler;
import com.vehiclerental.model.User;
import com.vehiclerental.model.Vehicle;
import com.vehiclerental.payment.PaymentFileHandler;
import com.vehiclerental.util.FileHelper;
import com.vehiclerental.util.UserFileHandler;
import com.vehiclerental.repository.UserRepository;
import com.vehiclerental.util.VehicleFileHandler;
import jakarta.servlet.http.HttpSession;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.GetMapping;

import java.io.IOException;
import java.util.ArrayList;
import java.util.Collections;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

/**
 * Splits /dashboard by role:
 *   - ADMIN    → analytics + revenue + recent reservations (dashboard.jsp)
 *   - REGULAR  → personal bookings, pickups, payments, recommendations (userDashboard.jsp)
 *   - guest    → /login
 */
@Controller
public class DashboardController {

    private final VehicleFileHandler vehicleHandler = new VehicleFileHandler();
    private final UserRepository userRepository;

    public DashboardController(UserRepository userRepository) { this.userRepository = userRepository; }

    @GetMapping("/dashboard")
    public String dashboard(HttpSession session, Model model) {
        Object logged = session.getAttribute("loggedUser");
        if (!(logged instanceof User u)) return "redirect:/login";

        if ("ADMIN".equalsIgnoreCase(u.getRole())) {
            return "redirect:/admin/dashboard";
        }
        return renderUser(u, model);
    }

    /* ─────────────────────────  ADMIN  ───────────────────────── */

    private String renderAdmin(Model model) {
        // C01/C05 — Vehicles
        List<Vehicle> vehicles = vehicleHandler.getAllVehicles();
        long total     = vehicles.size();
        long available = vehicles.stream().filter(Vehicle::isAvailable).count();
        long rented    = total - available;

        // C02 — Bookings
        List<Booking> bookings;
        try { bookings = BookingFileHandler.readAllBookings(); }
        catch (IOException e) { bookings = Collections.emptyList(); }
        long activeBookings = bookings.stream().filter(b -> "ACTIVE".equalsIgnoreCase(b.getStatus())).count();

        // C03 — Users
        long totalUsers = 0;
        try { totalUsers = userRepository.findAll().size(); }
        catch (Exception ignored) {}

        // C04 — Payments
        List<String> payments = PaymentFileHandler.readAllPayments();
        long totalPayments = payments.size();
        double totalRevenue = payments.stream()
                .mapToDouble(line -> {
                    String[] parts = line.split("[|,]");
                    if (parts.length < 4) return 0;
                    try { return Double.parseDouble(parts[3]); } catch (Exception e) { return 0; }
                }).sum();

        // C06 — Reviews
        long totalReviews = FileHelper.readAllReviews().size();

        model.addAttribute("totalVehicles",     total);
        model.addAttribute("availableVehicles", available);
        model.addAttribute("rentedVehicles",    rented);
        model.addAttribute("totalBookings",     bookings.size());
        model.addAttribute("activeBookings",    activeBookings);
        model.addAttribute("totalUsers",        totalUsers);
        model.addAttribute("totalPayments",     totalPayments);
        model.addAttribute("totalRevenue",      totalRevenue);
        model.addAttribute("totalReviews",      totalReviews);

        model.addAttribute("recentBookings",
                bookings.stream().limit(5).toList());

        // Weekly revenue (last 8 weeks) for the dashboard line chart. Anchor the window
        // to the latest payment date so the chart stays consistent with seeded data
        // regardless of the host clock (see PaymentFileHandler.latestPaymentDate).
        java.time.temporal.WeekFields wf = java.time.temporal.WeekFields.ISO;
        java.util.LinkedHashMap<String, Double> weekly = new java.util.LinkedHashMap<>();
        java.time.LocalDate today = PaymentFileHandler.latestPaymentDate(payments);
        for (int i = 7; i >= 0; i--) {
            java.time.LocalDate d = today.minusWeeks(i);
            weekly.put(d.getYear() + "-W" + String.format("%02d", d.get(wf.weekOfWeekBasedYear())), 0.0);
        }
        for (String line : payments) {
            String[] parts = line.split("[|,]");
            if (parts.length < 5) continue;
            try {
                java.time.LocalDate d = java.time.LocalDate.parse(parts[4]);
                String key = d.getYear() + "-W" + String.format("%02d", d.get(wf.weekOfWeekBasedYear()));
                if (weekly.containsKey(key)) weekly.merge(key, Double.parseDouble(parts[3]), Double::sum);
            } catch (Exception ignored) {}
        }
        model.addAttribute("weeklyRevenue", weekly);

        // Booking mix (Instant vs Advance) — non-cancelled
        long instantCount = bookings.stream()
                .filter(b -> !"CANCELLED".equalsIgnoreCase(b.getStatus()))
                .filter(b -> "INSTANT".equalsIgnoreCase(b.getBookingType())).count();
        long advanceCount = bookings.stream()
                .filter(b -> !"CANCELLED".equalsIgnoreCase(b.getStatus()))
                .filter(b -> "ADVANCE".equalsIgnoreCase(b.getBookingType())).count();
        model.addAttribute("instantCount", instantCount);
        model.addAttribute("advanceCount", advanceCount);

        return "dashboard";
    }

    /* ─────────────────────────  USER  ───────────────────────── */

    private String renderUser(User u, Model model) {
        // 1. The user's own bookings, partitioned by payment state
        List<Booking> mine = new ArrayList<>();
        try {
            for (Booking b : BookingFileHandler.readAllBookings()) {
                if (u.getId().equalsIgnoreCase(b.getUserId())) mine.add(b);
            }
        } catch (IOException ignored) {}

        // 2. Index user's payments by bookingId so we know what's paid
        Map<String, String[]> paidByBooking = new HashMap<>();
        double totalSpent = 0;
        for (String line : PaymentFileHandler.readAllPayments()) {
            String[] parts = line.split("\\|");
            if (parts.length < 6) continue;
            if (!u.getName().equalsIgnoreCase(parts[2].trim())) continue;
            if (parts.length >= 10) {
                String bid = parts[9].trim();
                if (!bid.isEmpty()) paidByBooking.put(bid, parts);
            }
            if ("Success".equalsIgnoreCase(parts[5].trim())) {
                try { totalSpent += Double.parseDouble(parts[3].trim()); }
                catch (NumberFormatException ignored) {}
            }
        }

        List<Booking> pending = new ArrayList<>();
        List<Booking> paid    = new ArrayList<>();
        for (Booking b : mine) {
            if ("CANCELLED".equalsIgnoreCase(b.getStatus())) continue;
            if (paidByBooking.containsKey(b.getBookingId())) paid.add(b);
            else pending.add(b);
        }

        // 3. Recommended vehicles — show up to 4 available cars/vans/s
        List<Vehicle> recommended = new ArrayList<>();
        for (Vehicle v : vehicleHandler.getAllVehicles()) {
            if (v.isAvailable()) recommended.add(v);
            if (recommended.size() == 4) break;
        }

        // Last 6 months of this user's successful spend. Anchor to the latest payment in
        // the file (not LocalDate.now()) so seeded forward-dated rows still appear.
        java.util.LinkedHashMap<String, Double> spendByMonth = new java.util.LinkedHashMap<>();
        java.time.LocalDate today = PaymentFileHandler.latestPaymentDate(
                PaymentFileHandler.readAllPayments());
        for (int i = 5; i >= 0; i--) {
            java.time.LocalDate d = today.minusMonths(i);
            spendByMonth.put(d.getYear() + "-" + String.format("%02d", d.getMonthValue()), 0.0);
        }
        for (String line : PaymentFileHandler.readAllPayments()) {
            String[] parts = line.split("\\|");
            if (parts.length < 6) continue;
            if (!u.getName().equalsIgnoreCase(parts[2].trim())) continue;
            if (!"Success".equalsIgnoreCase(parts[5].trim())) continue;
            try {
                java.time.LocalDate d = java.time.LocalDate.parse(parts[4].trim());
                String key = d.getYear() + "-" + String.format("%02d", d.getMonthValue());
                if (spendByMonth.containsKey(key)) spendByMonth.merge(key, Double.parseDouble(parts[3].trim()), Double::sum);
            } catch (Exception ignored) {}
        }

        // Bookings by status (Pending / Paid / Cancelled) for this user
        long cancelledCount = mine.stream().filter(b -> "CANCELLED".equalsIgnoreCase(b.getStatus())).count();

        model.addAttribute("pendingBookings",    pending);
        model.addAttribute("paidBookings",       paid);
        model.addAttribute("recommendedVehicles", recommended);
        model.addAttribute("pendingCount",       pending.size());
        model.addAttribute("paidCount",          paid.size());
        model.addAttribute("cancelledCount",     cancelledCount);
        model.addAttribute("spendByMonth",       spendByMonth);
        model.addAttribute("totalSpent",         totalSpent);
        return "userDashboard";
    }
}
