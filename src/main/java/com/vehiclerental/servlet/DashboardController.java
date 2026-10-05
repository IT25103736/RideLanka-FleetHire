package com.vehiclerental.servlet;

import com.vehiclerental.booking.Booking;
import com.vehiclerental.model.User;
import com.vehiclerental.model.Vehicle;
import com.vehiclerental.payment.PaymentRecord;
import com.vehiclerental.repository.BookingRepository;
import com.vehiclerental.repository.PaymentRepository;
import com.vehiclerental.repository.VehicleRepository;
import jakarta.servlet.http.HttpSession;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.GetMapping;

import java.sql.SQLException;
import java.time.LocalDate;
import java.util.*;

@Controller
public class DashboardController {
    private final BookingRepository bookings;
    private final PaymentRepository payments;
    private final VehicleRepository vehicles;
    public DashboardController(BookingRepository bookings,PaymentRepository payments,VehicleRepository vehicles){this.bookings=bookings;this.payments=payments;this.vehicles=vehicles;}

    @GetMapping("/dashboard")
    public String dashboard(HttpSession session,Model model){
        Object logged=session.getAttribute("loggedUser");if(!(logged instanceof User u))return "redirect:/login";
        if("ADMIN".equalsIgnoreCase(u.getRole()))return "redirect:/admin/dashboard";
        return renderUser(u,model);
    }
    private String renderUser(User u,Model model){
        try{
            List<Booking> mine=bookings.findByUserId(u.getId());List<PaymentRecord> minePayments=payments.findByUserId(u.getId());
            Set<String> paidIds=new HashSet<>();double totalSpent=0;
            for(PaymentRecord p:minePayments)if("SUCCESS".equalsIgnoreCase(p.getStatus())){paidIds.add(p.getBookingId());totalSpent+=p.getAmount();}
            List<Booking> pending=new ArrayList<>(),paid=new ArrayList<>();
            for(Booking b:mine){if("CANCELLED".equalsIgnoreCase(b.getStatus()))continue;if(paidIds.contains(b.getBookingId()))paid.add(b);else pending.add(b);}
            List<Vehicle> recommended=new ArrayList<>();for(Vehicle v:vehicles.findAllDomain()){if(v.isAvailable()){recommended.add(v);if(recommended.size()==4)break;}}
            LinkedHashMap<String,Double> spendByMonth=new LinkedHashMap<>();LocalDate anchor=minePayments.stream().map(PaymentRecord::getPaymentDate).filter(Objects::nonNull).map(x->x.toLocalDate()).max(LocalDate::compareTo).orElse(LocalDate.now());
            for(int i=5;i>=0;i--){LocalDate d=anchor.minusMonths(i);spendByMonth.put(String.format("%04d-%02d",d.getYear(),d.getMonthValue()),0.0);}
            for(PaymentRecord p:minePayments){if(!"SUCCESS".equalsIgnoreCase(p.getStatus())||p.getPaymentDate()==null)continue;LocalDate d=p.getPaymentDate().toLocalDate();String key=String.format("%04d-%02d",d.getYear(),d.getMonthValue());if(spendByMonth.containsKey(key))spendByMonth.merge(key,p.getAmount(),Double::sum);}
            long cancelled=mine.stream().filter(b->"CANCELLED".equalsIgnoreCase(b.getStatus())).count();
            model.addAttribute("pendingBookings",pending);model.addAttribute("paidBookings",paid);model.addAttribute("recommendedVehicles",recommended);model.addAttribute("pendingCount",pending.size());model.addAttribute("paidCount",paid.size());model.addAttribute("cancelledCount",cancelled);model.addAttribute("spendByMonth",spendByMonth);model.addAttribute("totalSpent",totalSpent);
        }catch(SQLException e){model.addAttribute("errorMessage","Dashboard data is temporarily unavailable.");model.addAttribute("pendingBookings",Collections.emptyList());model.addAttribute("paidBookings",Collections.emptyList());model.addAttribute("recommendedVehicles",Collections.emptyList());model.addAttribute("pendingCount",0);model.addAttribute("paidCount",0);model.addAttribute("cancelledCount",0);model.addAttribute("spendByMonth",Collections.emptyMap());model.addAttribute("totalSpent",0.0);}
        return "userDashboard";
    }
}
