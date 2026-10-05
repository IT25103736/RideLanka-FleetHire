package com.vehiclerental.booking;

import com.vehiclerental.model.User;
import com.vehiclerental.model.Vehicle;
import com.vehiclerental.notification.NotificationService;
import com.vehiclerental.repository.BookingRepository;
import com.vehiclerental.repository.VehicleRepository;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpSession;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.*;

import java.net.URLEncoder;
import java.nio.charset.StandardCharsets;
import java.sql.SQLException;
import java.time.LocalDate;
import java.util.ArrayList;
import java.util.List;

/** Booking & Reservation Management controller. All persistence is MSSQL-backed. */
@Controller
@RequestMapping("/booking")
public class BookingServlet {
    public static final int ADVANCE_PAY_LEAD_DAYS = 7;
    public static final List<String> PICKUP_LOCATIONS = List.of("Colombo", "Kandy");
    public static final List<String> PICKUP_TIMES = List.of(
            "09:00","10:00","11:00","12:00","13:00","14:00","15:00","16:00","17:00","18:00","19:00","20:00","21:00");

    private final BookingRepository bookings;
    private final BookingService service;
    private final VehicleRepository vehicles;
    private final NotificationService notifications;

    public BookingServlet(BookingRepository bookings, BookingService service,
                          VehicleRepository vehicles, NotificationService notifications) {
        this.bookings=bookings; this.service=service; this.vehicles=vehicles; this.notifications=notifications;
    }

    @GetMapping
    public String get(@RequestParam(defaultValue="list") String action,
                      @RequestParam(required=false) String vehicleId,
                      @RequestParam(required=false) String bookingId,
                      HttpSession session, Model model) {
        User user = currentCustomer(session); if (user == null) return "redirect:/login";
        try {
            if ("form".equalsIgnoreCase(action)) { prepareForm(model, vehicleId, null); return "booking/bookingForm"; }
            if ("edit".equalsIgnoreCase(action)) {
                Booking b = bookings.findById(bookingId);
                if (b == null || !user.getId().equalsIgnoreCase(b.getUserId()) || !"PENDING".equalsIgnoreCase(b.getStatus()))
                    return "redirect:/booking?action=list&error=" + enc("Only your unpaid pending bookings can be edited.");
                prepareForm(model, b.getVehicleId(), b); model.addAttribute("editMode", true); model.addAttribute("editBooking", b);
                long duration = java.time.temporal.ChronoUnit.DAYS.between(LocalDate.parse(b.getStartDate()), LocalDate.parse(b.getEndDate()));
                model.addAttribute("editDuration", Math.max(1,duration)); return "booking/bookingForm";
            }
            renderList(user, model); return "booking/myBookings";
        } catch (Exception ex) {
            model.addAttribute("errorMsg", "Unable to load booking information from the database.");
            return "booking/myBookings";
        }
    }

    @PostMapping
    public String post(@RequestParam(defaultValue="create") String action,
                       @RequestParam(required=false) String bookingId,
                       @RequestParam(required=false) String vehicleId,
                       @RequestParam(required=false) String startDate,
                       @RequestParam(required=false) String duration,
                       @RequestParam(required=false) String pickupLocation,
                       @RequestParam(required=false) String pickupTime,
                       @RequestParam(required=false, defaultValue="") String phone,
                       @RequestParam(required=false) String withDriver,
                       @RequestParam(required=false) String acceptTerms,
                       @RequestParam(required=false, defaultValue="Customer cancellation") String reason,
                       HttpSession session, HttpServletRequest request, Model model) {
        User user = currentCustomer(session); if (user == null) return "redirect:/login";
        try {
            if ("cancel".equalsIgnoreCase(action)) {
                if (bookingId == null || bookingId.isBlank()) return "redirect:/booking?action=list";
                boolean ok = service.cancel(bookingId, user.getId(), reason);
                if (ok) notifications.bookingCancelled(bookingId,user);
                return "redirect:/booking?action=list&" + (ok?"msg=cancelled":"error="+enc("Booking cannot be cancelled in its current state."));
            }

            validateFormBasics(vehicleId,startDate,duration,pickupLocation,pickupTime,phone);
            boolean driver = "true".equalsIgnoreCase(withDriver) || "on".equalsIgnoreCase(withDriver);
            LocalDate start = LocalDate.parse(startDate);
            int days = Integer.parseInt(duration);

            if ("update".equalsIgnoreCase(action)) {
                BookingService.CreatedBooking updated = service.updatePending(bookingId,user.getId(),start,days,driver,pickupLocation,pickupTime,phone);
                return "redirect:/booking?action=list&msg=updated";
            }

            if (!("true".equalsIgnoreCase(acceptTerms) || "on".equalsIgnoreCase(acceptTerms)))
                throw new IllegalArgumentException("You must accept the rental policies before booking.");

            BookingService.CreatedBooking created = service.create(user.getId(),vehicleId,start,days,driver,pickupLocation,pickupTime,phone);
            Vehicle domainVehicle = vehicles.findDomainById(vehicleId);
            String baseUrl=request.getScheme()+"://"+request.getServerName()+((request.getServerPort()==80||request.getServerPort()==443)?"":":"+request.getServerPort());
            String waUrl = notifications.bookingCreated(created.booking(), user, domainVehicle, phone,
                    created.price().totalAmount(), request.getContextPath(), baseUrl);

            if (created.booking().requiresImmediatePayment())
                return "redirect:/payment/checkout?bookingId=" + enc(created.booking().getBookingId());

            populateConfirmation(model,created,user.getName(),waUrl,phone);
            return "booking/bookingConfirmation";
        } catch (IllegalArgumentException ex) {
            try { prepareForm(model, vehicleId, null); } catch (SQLException ignored) {}
            model.addAttribute("errorMsg", ex.getMessage());
            model.addAttribute("formStartDate",startDate); model.addAttribute("formDuration",duration);
            model.addAttribute("formPickupLocation",pickupLocation); model.addAttribute("formPickupTime",pickupTime); model.addAttribute("formPhone",phone); model.addAttribute("formWithDriver", "true".equalsIgnoreCase(withDriver) || "on".equalsIgnoreCase(withDriver));
            if ("update".equalsIgnoreCase(action)) { model.addAttribute("editMode",true); model.addAttribute("editBookingId",bookingId); }
            return "booking/bookingForm";
        } catch (Exception ex) {
            try { prepareForm(model, vehicleId, null); } catch (SQLException ignored) {}
            model.addAttribute("errorMsg", "Unable to save the booking. Please try again.");
            return "booking/bookingForm";
        }
    }

    private void renderList(User user, Model model) throws SQLException {
        List<Booking> all = bookings.findByUserId(user.getId());
        List<Booking> current=new ArrayList<>(), cancelled=new ArrayList<>();
        for(Booking b:all){if("CANCELLED".equalsIgnoreCase(b.getStatus()))cancelled.add(b);else current.add(b);}
        model.addAttribute("bookings",all); model.addAttribute("activeBookings",current); model.addAttribute("cancelledBookings",cancelled);
    }

    private void prepareForm(Model model,String selectedVehicleId,Booking existing)throws SQLException{
        model.addAttribute("vehicleList",vehicles.findAllDomain()); model.addAttribute("pickupLocations",PICKUP_LOCATIONS);
        model.addAttribute("pickupTimes",PICKUP_TIMES); model.addAttribute("advanceLeadDays",ADVANCE_PAY_LEAD_DAYS); model.addAttribute("vehicleId",selectedVehicleId);
        if(selectedVehicleId!=null){Vehicle v=vehicles.findDomainById(selectedVehicleId);if(v!=null){model.addAttribute("selectedVehicle",v);model.addAttribute("dailyRate",v.getRentalPricePerDay());}}
        if(existing!=null) model.addAttribute("editBooking",existing);
    }

    private static void validateFormBasics(String vehicleId,String startDate,String duration,String location,String time,String phone){
        if(vehicleId==null||vehicleId.isBlank())throw new IllegalArgumentException("Please select a vehicle.");
        try{LocalDate.parse(startDate);}catch(Exception e){throw new IllegalArgumentException("Please enter a valid pickup date.");}
        try{int d=Integer.parseInt(duration);if(d<1||d>90)throw new Exception();}catch(Exception e){throw new IllegalArgumentException("Rental duration must be between 1 and 90 days.");}
        if(!PICKUP_LOCATIONS.contains(location))throw new IllegalArgumentException("Please select a supported pickup location.");
        if(!PICKUP_TIMES.contains(time))throw new IllegalArgumentException("Please select a valid pickup time.");
        if(phone!=null&&!phone.isBlank()&&!phone.matches("^(?:\\+94|94|0)?7\\d{8}$"))throw new IllegalArgumentException("Enter a valid Sri Lankan mobile number.");
    }

    private static void populateConfirmation(Model m,BookingService.CreatedBooking c,String name,String wa,String phone){
        BookingService.Price p=c.price(); m.addAttribute("booking",c.booking());m.addAttribute("customerName",name);m.addAttribute("totalCost",p.totalAmount());
        m.addAttribute("baseCost",p.rentalCost());m.addAttribute("driverFee",p.driverCharge());m.addAttribute("insurance",p.insurance());m.addAttribute("delivery",p.delivery());
        m.addAttribute("deposit",BookingService.SECURITY_DEPOSIT);m.addAttribute("duration",c.duration());m.addAttribute("dailyRate",p.dailyRate());m.addAttribute("withDriver",c.booking().isWithDriver());
        m.addAttribute("appliedSurcharge",p.surchargeRate());m.addAttribute("whatsappUrl",wa);m.addAttribute("phone",phone);
    }

    private static User currentCustomer(HttpSession s){Object x=s==null?null:s.getAttribute("loggedUser");if(!(x instanceof User u))return null;return "CUSTOMER".equalsIgnoreCase(u.getRole())?u:null;}
    private static String enc(String s){return URLEncoder.encode(s==null?"":s, StandardCharsets.UTF_8);}
}
