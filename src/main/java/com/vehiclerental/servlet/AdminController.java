package com.vehiclerental.servlet;

import com.vehiclerental.booking.Booking;
import com.vehiclerental.booking.BookingFileHandler;
import com.vehiclerental.model.User;
import com.vehiclerental.model.Vehicle;
import com.vehiclerental.notification.WhatsAppMessages;
import com.vehiclerental.payment.PaymentFileHandler;
import com.vehiclerental.repository.AuditRepository;
import com.vehiclerental.repository.UserRepository;
import com.vehiclerental.util.VehicleFileHandler;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpSession;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.*;

import java.sql.SQLException;
import java.util.*;

@Controller
@RequestMapping("/admin")
public class AdminController {
    private final UserRepository users;
    private final AuditRepository audit;
    public AdminController(UserRepository users,AuditRepository audit){this.users=users;this.audit=audit;}

    @GetMapping("/members")
    public String members(HttpSession session,Model model){
        String guard=requireAdmin(session);if(guard!=null)return guard;
        List<User> userList;
        try{userList=users.findAll();}catch(SQLException e){userList=new ArrayList<>();model.addAttribute("errorMessage","Database unavailable: "+e.getMessage());}
        Map<String,Integer> bookingCount=new HashMap<>();
        try{for(Booking b:BookingFileHandler.readAllBookings()){if(!"CANCELLED".equalsIgnoreCase(b.getStatus()))bookingCount.merge(b.getUserId(),1,Integer::sum);}}catch(Exception ignored){}
        Map<String,Double> spendByName=new HashMap<>();
        for(String line:PaymentFileHandler.readAllPayments()){String[] p=line.split("\\|");if(p.length<6)continue;if(!"Success".equalsIgnoreCase(p[5].trim()))continue;try{spendByName.merge(p[2].trim(),Double.parseDouble(p[3].trim()),Double::sum);}catch(NumberFormatException ignored){}}
        model.addAttribute("users",userList);model.addAttribute("bookingCount",bookingCount);model.addAttribute("spendByName",spendByName);return "adminMembers";
    }

    @PostMapping("/users/create")
    public String createUser(@RequestParam String name,@RequestParam String email,@RequestParam String password,@RequestParam String role,
                             @RequestParam(defaultValue="") String phone,@RequestParam(defaultValue="") String licenseNo,HttpSession session){
        String guard=requireAdmin(session);if(guard!=null)return guard;
        User admin=(User)session.getAttribute("loggedUser");
        try{boolean ok=users.insert(name,email,password,role,phone,licenseNo);if(ok)audit.log(admin.getId(),"CREATE_USER",email,role);return ok?"redirect:/admin/members?msg=created":"redirect:/admin/members?error=emailExists";}catch(SQLException e){return "redirect:/admin/members?error=db";}
    }

    @PostMapping("/users/status")
    public String status(@RequestParam String id,@RequestParam String status,HttpSession session){
        String guard=requireAdmin(session);if(guard!=null)return guard;User admin=(User)session.getAttribute("loggedUser");
        try{users.updateStatus(id,status);audit.log(admin.getId(),"UPDATE_USER_STATUS",id,status);return "redirect:/admin/members?msg=status";}catch(SQLException e){return "redirect:/admin/members?error=db";}
    }

    @PostMapping("/users/update")
    public String update(@RequestParam String id,@RequestParam String name,@RequestParam String email,@RequestParam String role,@RequestParam String status,
                         @RequestParam(defaultValue="") String phone,@RequestParam(defaultValue="") String licenseNo,HttpSession session){
        String guard=requireAdmin(session);if(guard!=null)return guard;User admin=(User)session.getAttribute("loggedUser");
        try{users.updateAdminFields(id,name,email,role,status,phone,licenseNo);audit.log(admin.getId(),"UPDATE_USER",id,role+"/"+status);return "redirect:/admin/members?msg=updated";}catch(SQLException e){return "redirect:/admin/members?error=db";}
    }

    @GetMapping("/bookings")
    public String bookings(HttpServletRequest request,HttpSession session,Model model){
        String guard=requireAdmin(session);if(guard!=null)return guard;
        List<Booking> all;try{all=BookingFileHandler.readAllBookings();}catch(Exception e){all=new ArrayList<>();}
        Map<String,User> userById=new HashMap<>();Map<String,String> nameById=new HashMap<>();
        try{for(User u:users.findAll()){userById.put(u.getId(),u);nameById.put(u.getId(),u.getName());}}catch(Exception ignored){}
        Map<String,String> vehicleById=new HashMap<>();
        Map<String,Vehicle> vehicleObj=new HashMap<>();for(Vehicle v:new VehicleFileHandler().getAllVehicles()){vehicleById.put(v.getVehicleId(),v.getBrand()+" "+v.getModel());vehicleObj.put(v.getVehicleId(),v);}
        String baseUrl=request.getScheme()+"://"+request.getServerName()+(request.getServerPort()==80||request.getServerPort()==443?"":":"+request.getServerPort());
        Map<String,String> wa=new HashMap<>();for(Booking b:all){if(b.getCustomerPhone().isEmpty())continue;String u=WhatsAppMessages.buildWaUrl(b,userById.get(b.getUserId()),vehicleObj.get(b.getVehicleId()),0.0,request.getContextPath(),baseUrl);if(!u.isEmpty())wa.put(b.getBookingId(),u);}
        model.addAttribute("bookings",all);model.addAttribute("nameById",nameById);model.addAttribute("waUrlByBooking",wa);model.addAttribute("vehicleById",vehicleById);return "adminBookings";
    }

    static String requireAdmin(HttpSession session){Object logged=session.getAttribute("loggedUser");if(!(logged instanceof User u))return "redirect:/login";if(!"ADMIN".equalsIgnoreCase(u.getRole()))return "redirect:/dashboard";return null;}
}
