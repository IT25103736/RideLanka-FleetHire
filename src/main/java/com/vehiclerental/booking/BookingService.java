package com.vehiclerental.booking;

import com.vehiclerental.fleet.ManagedVehicle;
import com.vehiclerental.repository.AuditRepository;
import com.vehiclerental.repository.BookingRepository;
import com.vehiclerental.repository.VehicleRepository;
import org.springframework.stereotype.Service;

import java.sql.SQLException;
import java.time.LocalDate;
import java.time.LocalDateTime;
import java.time.temporal.ChronoUnit;

@Service
public class BookingService {
    public static final double DRIVER_FEE_PER_DAY = 4500.0;
    public static final double INSURANCE_PER_DAY = 1200.0;
    public static final double DELIVERY_FEE = 1500.0;
    public static final double SECURITY_DEPOSIT = 25_000.0;

    private final BookingRepository bookings;
    private final VehicleRepository vehicles;
    private final AuditRepository audit;

    public BookingService(BookingRepository bookings, VehicleRepository vehicles, AuditRepository audit) {
        this.bookings = bookings; this.vehicles = vehicles; this.audit = audit;
    }

    public CreatedBooking create(String userId, String vehicleId, LocalDate start, int duration,
                                 boolean withDriver, String pickupLocation, String pickupTime,
                                 String phone) throws SQLException {
        if (duration < 1 || duration > 90) throw new IllegalArgumentException("Rental duration must be between 1 and 90 days.");
        if (start.isBefore(LocalDate.now())) throw new IllegalArgumentException("Pickup date cannot be in the past.");
        LocalDate end = start.plusDays(duration);
        ManagedVehicle vehicle = vehicles.findById(vehicleId);
        if (vehicle == null) throw new IllegalArgumentException("The selected vehicle does not exist.");
        if ("MAINTENANCE".equalsIgnoreCase(vehicle.getStatus()) || "OUT_OF_SERVICE".equalsIgnoreCase(vehicle.getStatus()))
            throw new IllegalArgumentException("The selected vehicle is not operationally available.");

        String customerId = bookings.customerIdForUser(userId);
        if (customerId == null) throw new IllegalArgumentException("This account is not registered as a customer.");
        String branchId = bookings.branchIdForLocation(pickupLocation, vehicleId);
        if (branchId == null) throw new IllegalArgumentException("The selected pickup location is not available.");

        String bookingId = bookings.nextId();
        Booking booking = Booking.classify(bookingId, userId, vehicleId, start, end, LocalDate.now());
        booking.setWithDriver(withDriver); booking.setPickupLocation(pickupLocation); booking.setPickupTime(pickupTime); booking.setCustomerPhone(phone);
        String ruleError = booking.validateBookingRules(LocalDateTime.now());
        if (ruleError != null) throw new IllegalArgumentException(ruleError);

        Price price = price(booking, vehicle.getDailyRate(), duration);
        if (!bookings.createIfAvailable(booking, customerId, branchId, price.baseAmount, price.driverCharge, price.totalAmount))
            throw new IllegalArgumentException("This vehicle is not available for the selected dates.");
        audit.log(userId, "CREATE_BOOKING", bookingId, "Vehicle " + vehicleId + " from " + start + " to " + end);
        return new CreatedBooking(booking, vehicle, price, duration);
    }

    public CreatedBooking updatePending(String bookingId, String userId, LocalDate start, int duration,
                                        boolean withDriver, String pickupLocation, String pickupTime,
                                        String phone) throws SQLException {
        BookingRepository.BookingInfo info = bookings.findInfo(bookingId);
        if (info == null || !userId.equals(info.getUserId())) throw new IllegalArgumentException("Booking not found.");
        if (!"PENDING".equalsIgnoreCase(info.getStatus())) throw new IllegalArgumentException("Only unpaid pending bookings can be modified.");
        if (start.isBefore(LocalDate.now())) throw new IllegalArgumentException("Pickup date cannot be in the past.");
        if (duration < 1 || duration > 90) throw new IllegalArgumentException("Rental duration must be between 1 and 90 days.");

        LocalDate end = start.plusDays(duration);
        Booking candidate = Booking.classify(bookingId, userId, info.getVehicleId(), start, end, LocalDate.now());
        candidate.setWithDriver(withDriver); candidate.setPickupLocation(pickupLocation); candidate.setPickupTime(pickupTime); candidate.setCustomerPhone(phone);
        String ruleError = candidate.validateBookingRules(LocalDateTime.now());
        if (ruleError != null) throw new IllegalArgumentException(ruleError);
        ManagedVehicle vehicle = vehicles.findById(info.getVehicleId());
        if (vehicle == null) throw new IllegalArgumentException("Vehicle not found.");
        String branchId = bookings.branchIdForLocation(pickupLocation, info.getVehicleId());
        Price price = price(candidate, vehicle.getDailyRate(), duration);
        Integer days = candidate instanceof AdvanceBooking a ? a.getDaysInAdvance() : null;
        boolean ok = bookings.updatePending(bookingId, userId, start, end, branchId, pickupTime, phone,
                withDriver, candidate.getBookingType(), days, price.baseAmount, price.driverCharge, price.totalAmount);
        if (!ok) throw new IllegalArgumentException("Booking could not be modified. It may now be paid or the vehicle may be unavailable.");
        audit.log(userId, "UPDATE_BOOKING", bookingId, "Dates or pickup details changed");
        return new CreatedBooking(candidate, vehicle, price, duration);
    }

    public boolean cancel(String bookingId, String userId, String reason) throws SQLException {
        boolean ok = bookings.cancelOwned(bookingId, userId, reason);
        if (ok) audit.log(userId, "CANCEL_BOOKING", bookingId, reason == null ? "Customer cancellation" : reason);
        return ok;
    }

    private static Price price(Booking booking, double dailyRate, int duration) {
        double rental = booking.calculateBaseCost(dailyRate, duration, LocalDate.now());
        double insurance = INSURANCE_PER_DAY * duration;
        double delivery = DELIVERY_FEE;
        double driver = booking.isWithDriver() ? DRIVER_FEE_PER_DAY * duration : 0;
        double base = rental + insurance + delivery;
        return new Price(dailyRate, rental, insurance, delivery, driver, base, base + driver, booking.getAppliedSurcharge(LocalDate.now()));
    }

    public record Price(double dailyRate, double rentalCost, double insurance, double delivery,
                        double driverCharge, double baseAmount, double totalAmount, double surchargeRate) {}
    public record CreatedBooking(Booking booking, ManagedVehicle vehicle, Price price, int duration) {}
}
