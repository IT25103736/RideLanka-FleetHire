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
import java.time.temporal.ChronoUnit;
import java.time.temporal.WeekFields;
import java.util.*;

@Controller
public class AdminRevenueController {
    private final BookingRepository bookingRepo;private final PaymentRepository paymentRepo;private final VehicleRepository vehicleRepo;
    public AdminRevenueController(BookingRepository bookingRepo,PaymentRepository paymentRepo,VehicleRepository vehicleRepo){this.bookingRepo=bookingRepo;this.paymentRepo=paymentRepo;this.vehicleRepo=vehicleRepo;}

    @GetMapping("/admin/revenue")
    public String revenue(HttpSession session,Model model){if(AdminController.requireAdmin(session)!=null)return "redirect:/dashboard";
        try{
            List<Booking> bookings=bookingRepo.findAll();List<PaymentRecord> payments=paymentRepo.findAll();List<Vehicle> vehicles=vehicleRepo.findAllDomain();
            List<PaymentRecord> success=payments.stream().filter(p->"SUCCESS".equalsIgnoreCase(p.getStatus())).toList();double totalRevenue=success.stream().mapToDouble(PaymentRecord::getAmount).sum();
            double avgDuration=bookings.stream().filter(b->!"CANCELLED".equalsIgnoreCase(b.getStatus())).mapToLong(this::durationDays).average().orElse(0.0);Map<String,Integer> rentalCount=rentalCount(bookings);String most=rentalCount.entrySet().stream().max(Map.Entry.comparingByValue()).map(Map.Entry::getKey).orElse("—");
            model.addAttribute("totalRevenue",totalRevenue);model.addAttribute("totalBookings",bookings.size());model.addAttribute("avgDuration",avgDuration);model.addAttribute("mostRentedId",most);model.addAttribute("fleetSize",vehicles.size());model.addAttribute("monthly",monthly(success));model.addAttribute("rentalCount",rentalCount);model.addAttribute("weekly",weekly(success));model.addAttribute("revenueByType",revenueByType(success,bookings,vehicles));model.addAttribute("topN",rentalCount.entrySet().stream().sorted((a,b)->Integer.compare(b.getValue(),a.getValue())).limit(5).toList());
        }catch(SQLException e){model.addAttribute("errorMessage","Revenue data is temporarily unavailable.");model.addAttribute("totalRevenue",0.0);model.addAttribute("totalBookings",0);model.addAttribute("avgDuration",0.0);model.addAttribute("mostRentedId","—");model.addAttribute("fleetSize",0);model.addAttribute("monthly",Collections.emptyMap());model.addAttribute("rentalCount",Collections.emptyMap());model.addAttribute("weekly",Collections.emptyMap());model.addAttribute("revenueByType",Collections.emptyMap());model.addAttribute("topN",Collections.emptyList());}
        return "admin-revenue";
    }

    @GetMapping("/admin/top-vehicles")
    public String topVehicles(HttpSession session,Model model){Object logged=session.getAttribute("loggedUser");if(!(logged instanceof User u))return "redirect:/login";if(!"ADMIN".equalsIgnoreCase(u.getRole()))return "redirect:/dashboard";
        try{
            List<Booking> bookings=bookingRepo.findAll();List<PaymentRecord> payments=paymentRepo.findAll();Map<String,Vehicle> vehicleById=new HashMap<>();for(Vehicle v:vehicleRepo.findAllDomain())vehicleById.put(v.getVehicleId(),v);Map<String,String> vehicleByBooking=new HashMap<>();Map<String,Integer> rentals=new HashMap<>();Map<String,Long> days=new HashMap<>();
            for(Booking b:bookings){vehicleByBooking.put(b.getBookingId(),b.getVehicleId());if("CANCELLED".equalsIgnoreCase(b.getStatus()))continue;rentals.merge(b.getVehicleId(),1,Integer::sum);days.merge(b.getVehicleId(),durationDays(b),Long::sum);}Map<String,Double> revenue=new HashMap<>();for(PaymentRecord p:payments){if(!"SUCCESS".equalsIgnoreCase(p.getStatus()))continue;String vid=vehicleByBooking.get(p.getBookingId());if(vid!=null)revenue.merge(vid,p.getAmount(),Double::sum);}
            List<TopVehicleRow> rows=new ArrayList<>();for(var e:rentals.entrySet()){Vehicle v=vehicleById.get(e.getKey());if(v==null)continue;int count=e.getValue();rows.add(new TopVehicleRow(v,count,revenue.getOrDefault(e.getKey(),0.0),days.getOrDefault(e.getKey(),0L)/(double)count));}rows.sort((a,b)->Integer.compare(b.rentals,a.rentals));model.addAttribute("rows",rows);
        }catch(SQLException e){model.addAttribute("rows",Collections.emptyList());model.addAttribute("errorMessage","Vehicle analytics are temporarily unavailable.");}
        return "adminTopVehicles";
    }
    private Map<String,Integer> rentalCount(List<Booking> bookings){Map<String,Integer> m=new HashMap<>();for(Booking b:bookings)if(!"CANCELLED".equalsIgnoreCase(b.getStatus()))m.merge(b.getVehicleId(),1,Integer::sum);return m;}
    private Map<String,Double> monthly(List<PaymentRecord> payments){LinkedHashMap<String,Double> m=new LinkedHashMap<>();LocalDate a=anchor(payments);for(int i=3;i>=0;i--){LocalDate d=a.minusMonths(i);m.put(String.format("%04d-%02d",d.getYear(),d.getMonthValue()),0.0);}for(PaymentRecord p:payments){if(p.getPaymentDate()==null)continue;LocalDate d=p.getPaymentDate().toLocalDate();String k=String.format("%04d-%02d",d.getYear(),d.getMonthValue());if(m.containsKey(k))m.merge(k,p.getAmount(),Double::sum);}return m;}
    private Map<String,Double> weekly(List<PaymentRecord> payments){LinkedHashMap<String,Double> m=new LinkedHashMap<>();WeekFields wf=WeekFields.ISO;LocalDate a=anchor(payments);for(int i=7;i>=0;i--){LocalDate d=a.minusWeeks(i);m.put(d.getYear()+"-W"+String.format("%02d",d.get(wf.weekOfWeekBasedYear())),0.0);}for(PaymentRecord p:payments){if(p.getPaymentDate()==null)continue;LocalDate d=p.getPaymentDate().toLocalDate();String k=d.getYear()+"-W"+String.format("%02d",d.get(wf.weekOfWeekBasedYear()));if(m.containsKey(k))m.merge(k,p.getAmount(),Double::sum);}return m;}
    private Map<String,Double> revenueByType(List<PaymentRecord> payments,List<Booking> bookings,List<Vehicle> vehicles){Map<String,String> categoryByVehicle=new HashMap<>();for(Vehicle v:vehicles)categoryByVehicle.put(v.getVehicleId(),v.getDisplayCategory());Map<String,String> categoryByBooking=new HashMap<>();for(Booking b:bookings)categoryByBooking.put(b.getBookingId(),categoryByVehicle.get(b.getVehicleId()));LinkedHashMap<String,Double> m=new LinkedHashMap<>();for(String c:List.of("Sedan","Hybrid","SUV","Hatchback","Electric","Van"))m.put(c,0.0);for(PaymentRecord p:payments){String c=categoryByBooking.get(p.getBookingId());if(c!=null&&m.containsKey(c))m.merge(c,p.getAmount(),Double::sum);}return m;}
    private LocalDate anchor(List<PaymentRecord> p){return p.stream().map(PaymentRecord::getPaymentDate).filter(Objects::nonNull).map(x->x.toLocalDate()).max(LocalDate::compareTo).orElse(LocalDate.now());}
    private long durationDays(Booking b){try{return Math.max(1,ChronoUnit.DAYS.between(LocalDate.parse(b.getStartDate()),LocalDate.parse(b.getEndDate())));}catch(Exception e){return 1;}}
    public static class TopVehicleRow{private final Vehicle vehicle;public final int rentals;public final double revenue,avgTripDays;public TopVehicleRow(Vehicle v,int r,double rev,double avg){vehicle=v;rentals=r;revenue=rev;avgTripDays=avg;}public Vehicle getVehicle(){return vehicle;}public int getRentals(){return rentals;}public double getRevenue(){return revenue;}public double getAvgTripDays(){return avgTripDays;}}
}
