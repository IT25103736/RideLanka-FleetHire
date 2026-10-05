package com.vehiclerental.notification;

import com.vehiclerental.booking.Booking;
import com.vehiclerental.model.User;
import com.vehiclerental.model.Vehicle;

import java.text.NumberFormat;
import java.time.LocalDate;
import java.time.format.DateTimeFormatter;
import java.time.temporal.ChronoUnit;
import java.util.Locale;

/** Formats RideLanka FleetHire booking text; delivery remains optional click-to-chat. */
public final class WhatsAppMessages {
    private static final DateTimeFormatter PRETTY=DateTimeFormatter.ofPattern("d MMM yyyy");
    private static final NumberFormat LKR=NumberFormat.getNumberInstance(Locale.US);
    private WhatsAppMessages(){}

    public static String buildConfirmation(Booking booking,User user,Vehicle vehicle,double totalCost,String contextPath,String baseUrl){
        String name=user==null?"Customer":user.getName();String vehicleName=vehicle==null?booking.getVehicleId():vehicle.getBrand()+" "+vehicle.getModel();
        StringBuilder sb=new StringBuilder();sb.append("*RideLanka FleetHire — Reservation Created*\n\n");sb.append("Hello ").append(name).append(",\n\n");sb.append("Your reservation has been recorded in RideLanka FleetHire.\n\n");
        sb.append("*Booking Ref:* ").append(booking.getBookingId()).append('\n');sb.append("*Vehicle:* ").append(vehicleName).append('\n');sb.append("*Pickup:* ").append(pretty(booking.getStartDate())).append(" ").append(booking.getPickupTime().isBlank()?"TBC":booking.getPickupTime()).append('\n');sb.append("*Return:* ").append(pretty(booking.getEndDate())).append('\n');sb.append("*Duration:* ").append(duration(booking)).append(" day(s)\n");
        if(totalCost>0)sb.append("*Total:* LKR ").append(LKR.format(totalCost)).append('\n');
        sb.append("*Status:* ").append(booking.getStatus()).append("\n\n");sb.append("Payment and invoice status are available after signing in to your RideLanka FleetHire account.");return sb.toString();
    }
    private static String pretty(String iso){try{return LocalDate.parse(iso).format(PRETTY);}catch(Exception e){return iso;}}
    private static long duration(Booking b){try{return Math.max(1,ChronoUnit.DAYS.between(LocalDate.parse(b.getStartDate()),LocalDate.parse(b.getEndDate())));}catch(Exception e){return 1;}}
}
