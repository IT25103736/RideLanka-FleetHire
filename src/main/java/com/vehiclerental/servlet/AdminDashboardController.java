package com.vehiclerental.servlet;

import com.vehiclerental.fleet.MaintenanceRecord;
import com.vehiclerental.fleet.VehicleOption;
import com.vehiclerental.model.User;
import com.vehiclerental.repository.MaintenanceRepository;
import com.vehiclerental.repository.UserRepository;
import jakarta.servlet.http.HttpSession;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestMapping;

import java.sql.SQLException;
import java.util.Collections;
import java.util.List;

@Controller
@RequestMapping("/admin")
public class AdminDashboardController {
    private final UserRepository users;
    private final MaintenanceRepository maintenance;

    public AdminDashboardController(UserRepository users, MaintenanceRepository maintenance) {
        this.users = users;
        this.maintenance = maintenance;
    }

    @GetMapping("/dashboard")
    public String dashboard(HttpSession session, Model model) {
        String guard = AdminController.requireAdmin(session);
        if (guard != null) return guard;

        int totalUsers = 0;
        int activeUsers = 0;
        int suspendedUsers = 0;
        try {
            List<User> all = users.findAll();
            totalUsers = all.size();
            for (User u : all) {
                if ("ACTIVE".equalsIgnoreCase(u.getStatus())) activeUsers++;
                if ("SUSPENDED".equalsIgnoreCase(u.getStatus())) suspendedUsers++;
            }
        } catch (SQLException ignored) { }

        List<VehicleOption> vehicles;
        List<MaintenanceRecord> records;
        try { vehicles = maintenance.findVehicleOptions(); }
        catch (SQLException e) { vehicles = Collections.emptyList(); }
        try { records = maintenance.findAll(); }
        catch (SQLException e) { records = Collections.emptyList(); }

        long available = vehicles.stream().filter(v -> "AVAILABLE".equalsIgnoreCase(v.getStatus())).count();
        long maintenanceVehicles = vehicles.stream().filter(v -> "MAINTENANCE".equalsIgnoreCase(v.getStatus())).count();
        long rented = vehicles.stream().filter(v -> "RENTED".equalsIgnoreCase(v.getStatus())).count();
        long scheduled = records.stream().filter(r -> "SCHEDULED".equalsIgnoreCase(r.getStatus())).count();
        long inProgress = records.stream().filter(r -> "IN_PROGRESS".equalsIgnoreCase(r.getStatus())).count();

        model.addAttribute("totalUsers", totalUsers);
        model.addAttribute("activeUsers", activeUsers);
        model.addAttribute("suspendedUsers", suspendedUsers);
        model.addAttribute("totalVehicles", vehicles.size());
        model.addAttribute("availableVehicles", available);
        model.addAttribute("maintenanceVehicles", maintenanceVehicles);
        model.addAttribute("rentedVehicles", rented);
        model.addAttribute("scheduledMaintenance", scheduled);
        model.addAttribute("inProgressMaintenance", inProgress);
        model.addAttribute("recentMaintenance", records.stream().limit(5).toList());
        return "adminDashboard";
    }
}
