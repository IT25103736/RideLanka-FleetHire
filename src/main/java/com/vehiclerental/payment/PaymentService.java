package com.vehiclerental.payment;

import com.vehiclerental.booking.BookingServlet;
import com.vehiclerental.model.User;
import com.vehiclerental.repository.AuditRepository;
import com.vehiclerental.repository.BookingRepository;
import com.vehiclerental.repository.PaymentRepository;
import org.springframework.stereotype.Service;

import java.sql.SQLException;
import java.time.LocalDate;
import java.time.YearMonth;
import java.time.format.DateTimeFormatter;
import java.time.format.DateTimeParseException;
import java.time.temporal.ChronoUnit;
import java.util.List;
import java.util.UUID;

@Service
public class PaymentService {
    private final BookingRepository bookings;
    private final PaymentRepository payments;
    private final AuditRepository audit;

    public PaymentService(BookingRepository bookings, PaymentRepository payments, AuditRepository audit){
        this.bookings=bookings;this.payments=payments;this.audit=audit;
    }

    public Checkout checkout(String bookingId, User user) throws SQLException {
        if(user==null||!"CUSTOMER".equalsIgnoreCase(user.getRole()))throw new IllegalArgumentException("Please sign in as the booking customer.");
        BookingRepository.BookingInfo b=bookings.findInfo(bookingId);
        if(b==null||!user.getId().equals(b.getUserId()))throw new IllegalArgumentException("Booking not found.");
        if(!("PENDING".equalsIgnoreCase(b.getStatus())||"CONFIRMED".equalsIgnoreCase(b.getStatus())))throw new IllegalArgumentException("This booking is not payable in its current state.");
        if(payments.hasSuccess(bookingId))throw new IllegalArgumentException("This booking has already been paid.");
        if(payments.hasPending(bookingId))throw new IllegalArgumentException("A bank transfer for this booking is already awaiting Finance verification.");
        if("ADVANCE".equalsIgnoreCase(b.getBookingType())){
            long days=ChronoUnit.DAYS.between(LocalDate.now(),b.getStartDate());
            if(days<BookingServlet.ADVANCE_PAY_LEAD_DAYS)throw new IllegalArgumentException("The advance-payment deadline has passed. Please contact support.");
        }
        return new Checkout(b,b.getTotalAmount());
    }

    public Processed processImmediate(String bookingId, User user, String method, String promoCode,
                                      String cardNumber,String cardHolder,String expiry,String cvv,
                                      String walletType,String walletNumber) throws SQLException {
        Checkout ck=checkout(bookingId,user);
        String normalized=method==null?"":method.trim().toUpperCase();
        if(!List.of("CARD","WALLET").contains(normalized))throw new IllegalArgumentException("Choose card, wallet, or bank transfer.");
        String ref,gateway;
        if("CARD".equals(normalized)){
            validateCard(cardNumber,cardHolder,expiry,cvv);
            String digits=cardNumber.replaceAll("\\D","");
            ref="SIM-CARD-"+digits.substring(digits.length()-4)+"-"+UUID.randomUUID().toString().substring(0,8).toUpperCase();
            gateway="Demo card validation accepted; full card number and CVV were not stored";
        }else{
            validateWallet(walletType,walletNumber);
            ref="SIM-WALLET-"+UUID.randomUUID().toString().substring(0,12).toUpperCase();
            gateway="Demo wallet validation accepted; no external wallet gateway is connected";
        }
        Discount d=discount(ck.originalAmount,promoCode);
        PaymentRepository.PaymentResult result=payments.recordImmediate(bookingId,user.getId(),normalized,ref,gateway,d.promotion,ck.originalAmount,d.amount,d.finalAmount);
        audit.log(user.getId(),"PAYMENT_SUCCESS",result.paymentId,"Booking "+bookingId+" via "+normalized);
        return new Processed(result,d.message);
    }

    public Processed submitBankTransfer(String bookingId,User user,String transferReference)throws SQLException{
        checkout(bookingId,user);
        if(transferReference==null||!transferReference.trim().matches("[A-Za-z0-9._/-]{4,100}"))throw new IllegalArgumentException("Enter a valid bank transfer reference (4-100 letters/numbers). ");
        PaymentRepository.PaymentResult result=payments.submitBankTransfer(bookingId,user.getId(),transferReference.trim());
        audit.log(user.getId(),"BANK_TRANSFER_SUBMITTED",result.paymentId,"Booking "+bookingId+" awaiting Finance approval");
        return new Processed(result,"Bank transfer submitted for Finance verification.");
    }

    public boolean reviewBankTransfer(String paymentId,boolean approve,User actor)throws SQLException{
        if(actor==null||!("ADMIN".equalsIgnoreCase(actor.getRole())||"FINANCE".equalsIgnoreCase(actor.getRole())))throw new IllegalArgumentException("Finance access required.");
        boolean ok=payments.reviewBankTransfer(paymentId,approve,actor.getId());
        if(ok)audit.log(actor.getId(),approve?"APPROVE_BANK_TRANSFER":"REJECT_BANK_TRANSFER",paymentId,"Finance verification");
        return ok;
    }

    private Discount discount(double original,String code)throws SQLException{
        if(code==null||code.isBlank())return new Discount(null,0,original,"");
        PaymentRepository.Promotion p=payments.findActivePromotion(code);
        if(p==null)return new Discount(null,0,original,"Promo code is invalid or inactive; the original booking total was charged.");
        double amount="PERCENT".equalsIgnoreCase(p.getType())?original*(p.getValue()/100.0):p.getValue();
        amount=Math.max(0,Math.min(original,amount));
        return new Discount(p,amount,Math.max(0,original-amount),"Promotion "+p.getCode()+" applied: LKR "+String.format("%.2f",amount)+" off.");
    }

    private static void validateCard(String number,String holder,String expiry,String cvv){
        String digits=number==null?"":number.replaceAll("\\D","");
        if(digits.length()<13||digits.length()>19)throw new IllegalArgumentException("Enter a valid card number.");
        if(holder==null||!holder.trim().matches("[A-Za-z .'-]{2,80}"))throw new IllegalArgumentException("Enter the cardholder name.");
        if(cvv==null||!cvv.trim().matches("\\d{3,4}"))throw new IllegalArgumentException("Enter a valid CVV.");
        YearMonth ym=parseCardExpiry(expiry);
        YearMonth now=YearMonth.now();
        if(ym.isBefore(now))throw new IllegalArgumentException("The card has expired.");
        if(ym.isAfter(now.plusYears(20)))throw new IllegalArgumentException("Enter a realistic card expiry date.");
    }

    private static YearMonth parseCardExpiry(String expiry){
        String value=expiry==null?"":expiry.trim();
        if(value.isBlank())throw new IllegalArgumentException("Select the card expiry month.");
        try{
            // HTML <input type="month"> submits yyyy-MM.
            if(value.matches("\\d{4}-(0[1-9]|1[0-2])")) return YearMonth.parse(value);
            // Keep backwards compatibility with the former MM/YY field.
            DateTimeFormatter legacy=DateTimeFormatter.ofPattern("MM/yy");
            return YearMonth.parse(value,legacy);
        }catch(DateTimeParseException e){
            throw new IllegalArgumentException("Select a valid card expiry month.");
        }
    }
    private static void validateWallet(String type,String number){
        if(type==null||type.isBlank())throw new IllegalArgumentException("Select a wallet type.");
        if(number==null||!number.matches("^(?:\\+94|94|0)?7\\d{8}$"))throw new IllegalArgumentException("Enter a valid wallet mobile number.");
    }

    public record Checkout(BookingRepository.BookingInfo booking,double originalAmount){}
    private record Discount(PaymentRepository.Promotion promotion,double amount,double finalAmount,String message){}
    public record Processed(PaymentRepository.PaymentResult result,String message){}
}
