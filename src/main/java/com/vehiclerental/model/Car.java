package com.vehiclerental.model;

import java.util.Set;

public class Car extends Vehicle {

    /** Powertrain inferred from model name — seed data has no fuel column.
     *  Canonical source for both CarFilter (search) and getDisplayCategory (booking-form label). */
    public static final Set<String> HYBRID_MODELS = Set.of(
            "Aqua", "Vezel", "Prius",
            "Camry Hybrid", "Insight", "Shuttle Hybrid",
            "CHR Hybrid", "Yaris Cross Hybrid"
    );
    public static final Set<String> ELECTRIC_MODELS = Set.of(
            "Leaf", "Model 3", "Model Y", "Atto 3",
            "Dolphin", "Kona Electric", "ZS EV", "ID.4"
    );

    private int numberOfSeats;

    // ---- Constructor ----
    public Car(String vehicleId, String brand, String model, int year,
               double rentalPricePerDay, boolean available, int numberOfSeats) {
        super(vehicleId, brand, model, year, rentalPricePerDay, available);
        this.numberOfSeats = numberOfSeats;
    }

    // Overridden methods (Polymorphism)
    @Override
    public String getVehicleType() {
        return "Car";
    }

    @Override
    public String getDisplayCategory() {
        if (HYBRID_MODELS.contains(getModel()))   return "Hybrid";
        if (ELECTRIC_MODELS.contains(getModel())) return "Electric";
        if (numberOfSeats >= 7)                   return "SUV";
        if (numberOfSeats <= 4)                   return "Hatchback";
        return "Sedan";
    }

    
    @Override
    public String toFileString() {
        return getVehicleId() + "|" + getVehicleType() + "|" + getBrand() + "|" + getModel()
                + "|" + getYear() + "|" + getRentalPricePerDay() + "|" + isAvailable()
                + "|" + numberOfSeats + "|" + getImageUrl();
    }

    // ---- Getter & Setter ----
    public int getNumberOfSeats()              { return numberOfSeats; }
    public void setNumberOfSeats(int seats)    { this.numberOfSeats = seats; }

    @Override
    public String getExtraField()              { return String.valueOf(numberOfSeats); }
}
