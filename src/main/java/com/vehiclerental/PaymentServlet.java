package com.vehiclerental;

import com.vehiclerental.booking.Booking;
import com.vehiclerental.model.User;
import com.vehiclerental.payment.InvoiceRecord;
import com.vehiclerental.payment.PaymentRecord;
import com.vehiclerental.payment.PaymentService;
import com.vehiclerental.repository.BookingRepository;
import com.vehiclerental.repository.PaymentRepository;
import jakarta.servlet.http.HttpSession;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.*;

import java.sql.SQLException;
import java.time.LocalDate;
import java.time.LocalDateTime;
import java.time.temporal.ChronoUnit;
import java.util.*;

/** Payment Management. Browser-supplied amounts are ignored; MSSQL booking totals are authoritative. */
@Controller
@RequestMapping("/payment")
public class PaymentServlet {
    private final PaymentService service;
    private final PaymentRepository payments;
    private final BookingRepository bookings;

    public PaymentServlet(PaymentService service, PaymentRepository payments, BookingRepository bookings){
        this.service=service;this.payments=payments;this.bookings=bookings;
    }

    @GetMapping("/checkout")
    public String checkout(@RequestParam(required=false) String bookingId,HttpSession session,Model model){
        User user=currentCustomer(session);if(user==null)return"redirect:/login";
        try{
            PaymentService.Checkout ck=service.checkout(bookingId,user);
            BookingRepository.BookingInfo b=ck.booking();
            model.addAttribute("bookingId",b.getBookingId());model.addAttribute("amount",ck.originalAmount());model.addAttribute("customerName",b.getCustomerName());
            model.addAttribute("vehicleId",b.getVehicleId());model.addAttribute("startDate",b.getStartDate());model.addAttribute("endDate",b.getEndDate());
            model.addAttribute("duration",Math.max(1,ChronoUnit.DAYS.between(b.getStartDate(),b.getEndDate())));
            return"checkout";
        }catch(Exception ex){return"redirect:/booking?action=list&error="+url(userMessage(ex));}
    }

    @PostMapping("/process")
    public String process(@RequestParam String paymentMethod,@RequestParam String bookingId,
                          @RequestParam(required=false) String cardNumber,@RequestParam(required=false) String cardHolderName,
                          @RequestParam(required=false) String expiryDate,@RequestParam(required=false) String cvv,
                          @RequestParam(required=false) String walletType,@RequestParam(required=false) String walletNumber,
                          @RequestParam(required=false) String promoCode,@RequestParam(required=false) String transferReference,
                          HttpSession session,Model model){
        User user=currentCustomer(session);if(user==null)return"redirect:/login";
        try{
            PaymentService.Processed p;
            if("bank_transfer".equalsIgnoreCase(paymentMethod)||"BANK_TRANSFER".equalsIgnoreCase(paymentMethod)){
                p=service.submitBankTransfer(bookingId,user,transferReference);
                model.addAttribute("successMsg",p.message());
                return"redirect:/payment/history?msg=transferSubmitted";
            }
            String normalized="wallet".equalsIgnoreCase(paymentMethod)?"WALLET":"CARD";
            p=service.processImmediate(bookingId,user,normalized,promoCode,cardNumber,cardHolderName,expiryDate,cvv,walletType,walletNumber);
            PaymentRepository.PaymentResult r=p.result();
            PaymentRecord record=new PaymentRecord(r.paymentId,r.bookingId,r.customerId,r.customerName,r.amount,r.method,r.reference,r.status,LocalDateTime.now(),"Recorded in MSSQL");
            InvoiceRecord inv=payments.findInvoiceByBooking(bookingId);
            model.addAttribute("payment",record);model.addAttribute("invoiceRecord",inv);model.addAttribute("bookingId",bookingId);
            model.addAttribute("vehicleId",r.vehicleId);model.addAttribute("startDate",r.startDate);model.addAttribute("endDate",r.endDate);
            model.addAttribute("duration",Math.max(1,ChronoUnit.DAYS.between(r.startDate,r.endDate)));model.addAttribute("promoMessage",p.message());
            model.addAttribute("result","Payment recorded successfully.");model.addAttribute("paymentMethod",normalized);
            return"invoice";
        }catch(Exception ex){
            try{PaymentService.Checkout ck=service.checkout(bookingId,user);model.addAttribute("bookingId",bookingId);model.addAttribute("amount",ck.originalAmount());model.addAttribute("customerName",ck.booking().getCustomerName());}catch(Exception ignored){}
            model.addAttribute("errorMsg",userMessage(ex));return"checkout";
        }
    }

    @GetMapping("/history")
    public String history(HttpSession session,Model model){
        User user=currentCustomer(session);if(user==null)return"redirect:/login";
        try{
            List<PaymentRecord> mine=payments.findByUserId(user.getId());Map<String,PaymentRecord> latest=new HashMap<>();double total=0;
            for(PaymentRecord p:mine){latest.putIfAbsent(p.getBookingId(),p);if("SUCCESS".equalsIgnoreCase(p.getStatus()))total+=p.getAmount();}
            List<BookingPayView> rows=new ArrayList<>();int pending=0,paid=0,cancelled=0;
            for(Booking b:bookings.findByUserId(user.getId())){
                BookingRepository.BookingInfo info=bookings.findInfo(b.getBookingId());PaymentRecord p=latest.get(b.getBookingId());
                BookingPayView row=new BookingPayView(b,info==null?0:info.getTotalAmount());
                if("CANCELLED".equalsIgnoreCase(b.getStatus())){row.setPayStatus("CANCELLED");cancelled++;}
                else if(p!=null&&"SUCCESS".equalsIgnoreCase(p.getStatus())){row.fromPayment(p);row.setPayStatus("COMPLETED".equalsIgnoreCase(b.getStatus())?"COMPLETED":"PAID");paid++;}
                else if(p!=null&&"PENDING".equalsIgnoreCase(p.getStatus())){row.fromPayment(p);row.setPayStatus("PENDING_VERIFICATION");pending++;}
                else if("COMPLETED".equalsIgnoreCase(b.getStatus()))row.setPayStatus("COMPLETED_UNPAID");
                else{row.setPayStatus("PENDING");pending++;}
                rows.add(row);
            }
            model.addAttribute("rows",rows);model.addAttribute("unlinkedPayments",List.of());model.addAttribute("totalSpent",total);
            model.addAttribute("pendingCount",pending);model.addAttribute("paidCount",paid);model.addAttribute("cancelledCount",cancelled);
            return"myPayments";
        }catch(SQLException ex){model.addAttribute("errorMsg","Unable to load payment history.");model.addAttribute("rows",List.of());return"myPayments";}
    }

    @GetMapping("/list")
    public String list(HttpSession session,Model model){
        User u=currentUser(session);if(!finance(u))return"redirect:/dashboard";
        try{
            List<PaymentRecord> all=payments.findAll();model.addAttribute("paymentRecords",all);model.addAttribute("payments",List.of());
            model.addAttribute("pendingTransfers",all.stream().filter(p->"BANK_TRANSFER".equalsIgnoreCase(p.getPaymentMethod())&&"PENDING".equalsIgnoreCase(p.getStatus())).toList());
            model.addAttribute("pendingAdvances",pendingAdvances());model.addAttribute("message","");return"paymentList";
        }catch(SQLException ex){model.addAttribute("errorMsg","Unable to load payments from MSSQL.");model.addAttribute("paymentRecords",List.of());model.addAttribute("pendingTransfers",List.of());model.addAttribute("pendingAdvances",List.of());return"paymentList";}
    }

    @PostMapping("/bank-review")
    public String bankReview(@RequestParam String paymentId,@RequestParam String decision,HttpSession session){
        User u=currentUser(session);if(!finance(u))return"redirect:/dashboard";
        try{boolean ok=service.reviewBankTransfer(paymentId,"approve".equalsIgnoreCase(decision),u);return"redirect:/payment/list?msg="+(ok?"reviewed":"unchanged");}
        catch(Exception ex){return"redirect:/payment/list?error="+url(userMessage(ex));}
    }

    @PostMapping("/void")
    public String voidPayment(@RequestParam String paymentId,HttpSession session){
        User u=currentUser(session);if(!finance(u))return"redirect:/dashboard";
        try{payments.voidPayment(paymentId,u.getId());}catch(SQLException ignored){}return"redirect:/payment/list";
    }

    @GetMapping("/promotions")
    public String promotions(@RequestParam(required=false) String promoCode,Model model){
        try{model.addAttribute("promotions",payments.listActivePromotions());if(promoCode!=null&&!promoCode.isBlank()){var p=payments.findActivePromotion(promoCode);model.addAttribute("promoValid",p!=null);model.addAttribute("promoResult",p==null?"Code is invalid or inactive.":"Valid promotion: "+p.getDescription());}}catch(SQLException ex){model.addAttribute("promotions",List.of());}
        return"promotions";
    }

    private List<PendingAdvanceRow> pendingAdvances() throws SQLException {
        List<PendingAdvanceRow> out=new ArrayList<>();Set<String> paid=new HashSet<>(),pending=new HashSet<>();
        for(PaymentRecord p:payments.findAll()){if("SUCCESS".equalsIgnoreCase(p.getStatus()))paid.add(p.getBookingId());if("PENDING".equalsIgnoreCase(p.getStatus()))pending.add(p.getBookingId());}
        for(Booking b:bookings.findAll()){
            if(!"ADVANCE".equalsIgnoreCase(b.getBookingType())||"CANCELLED".equalsIgnoreCase(b.getStatus())||paid.contains(b.getBookingId())||pending.contains(b.getBookingId()))continue;
            BookingRepository.BookingInfo i=bookings.findInfo(b.getBookingId());if(i==null)continue;LocalDate due=i.getStartDate().minusDays(com.vehiclerental.booking.BookingServlet.ADVANCE_PAY_LEAD_DAYS);
            out.add(new PendingAdvanceRow(i.getBookingId(),i.getCustomerName(),i.getVehicleLabel(),i.getStartDate(),due,ChronoUnit.DAYS.between(LocalDate.now(),due),
                    Math.max(1,ChronoUnit.DAYS.between(i.getStartDate(),i.getEndDate())),i.getTotalAmount(),i.isWithDriver(),""));
        }return out;
    }

    public static class PendingAdvanceRow{
        private final String bookingId,customerName,vehicleLabel,pickupLocation;private final LocalDate startDate,dueDate;private final long daysUntilDue,duration;private final double estimatedTotal;private final boolean withDriver;
        public PendingAdvanceRow(String b,String c,String v,LocalDate s,LocalDate d,long du,long duration,double total,boolean driver,String loc){bookingId=b;customerName=c;vehicleLabel=v;startDate=s;dueDate=d;daysUntilDue=du;this.duration=duration;estimatedTotal=total;withDriver=driver;pickupLocation=loc;}
        public String getBookingId(){return bookingId;}public String getCustomerName(){return customerName;}public String getVehicleLabel(){return vehicleLabel;}public LocalDate getStartDate(){return startDate;}public LocalDate getDueDate(){return dueDate;}public long getDaysUntilDue(){return daysUntilDue;}public long getDuration(){return duration;}public double getEstimatedTotal(){return estimatedTotal;}public boolean isWithDriver(){return withDriver;}public String getPickupLocation(){return pickupLocation;}
    }

    public static class BookingPayView{
        private final Booking booking;private final double computedTotal;private String payStatus="PENDING",paymentId,paymentDate,paymentMethod;private double paymentAmount;
        BookingPayView(Booking b,double total){booking=b;computedTotal=total;}void fromPayment(PaymentRecord p){paymentId=p.getPaymentId();paymentDate=p.getDate();paymentMethod=p.getPaymentMethod();paymentAmount=p.getAmount();}
        public Booking getBooking(){return booking;}public double getComputedTotal(){return computedTotal;}public String getPayStatus(){return payStatus;}public String getPaymentId(){return paymentId;}public String getPaymentDate(){return paymentDate;}public String getPaymentMethod(){return paymentMethod;}public double getPaymentAmount(){return paymentAmount;}public int getDurationDays(){try{return(int)Math.max(1,ChronoUnit.DAYS.between(LocalDate.parse(booking.getStartDate()),LocalDate.parse(booking.getEndDate())));}catch(Exception e){return 1;}}public boolean isPending(){return"PENDING".equals(payStatus)||"PENDING_VERIFICATION".equals(payStatus);}public boolean isPaid(){return"PAID".equals(payStatus)||"COMPLETED".equals(payStatus);}public boolean isCancelled(){return"CANCELLED".equals(payStatus);}public void setPayStatus(String s){payStatus=s;}
    }

    private static User currentUser(HttpSession s){Object x=s==null?null:s.getAttribute("loggedUser");return x instanceof User?(User)x:null;}
    private static User currentCustomer(HttpSession s){User u=currentUser(s);return u!=null&&"CUSTOMER".equalsIgnoreCase(u.getRole())?u:null;}
    private static boolean finance(User u){return u!=null&&("ADMIN".equalsIgnoreCase(u.getRole())||"FINANCE".equalsIgnoreCase(u.getRole()));}
    private static String url(String s){return java.net.URLEncoder.encode(clean(s),java.nio.charset.StandardCharsets.UTF_8);}
    private static String userMessage(Exception ex){if(ex instanceof IllegalArgumentException||ex instanceof IllegalStateException)return clean(ex.getMessage());if(ex instanceof SQLException)System.err.println("[PaymentServlet] database operation failed: "+ex.getMessage());return "Payment operation failed. Please try again.";}
    private static String clean(String s){return s==null?"Payment operation failed.":s.replace('\n',' ').replace('\r',' ');}
}
