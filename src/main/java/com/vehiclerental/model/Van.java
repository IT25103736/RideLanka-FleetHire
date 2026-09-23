package com.vehiclerental.model;

public class Van extends Vehicle {

    private double cargoCapacityKg;

    public Van(String vehicleId, String brand, String model, int year,
               double rentalPricePerDay, boolean available, double cargoCapacityKg) {
        super(vehicleId, brand, model, year, rentalPricePerDay, available);
        this.cargoCapacityKg = cargoCapacityKg;
    }

    @Override
    public String getVehicleType() {
        return "Van";
    }

    @Override
    public String getDisplayCategory() {
        return "Van";
    }

    /**
     * Saves as: vehicleId|Van|brand|model|year|price|available|cargoCapacityKg|imageUrl
     */
    @Override
    public String toFileString() {
        return getVehicleId() + "|" + getVehicleType() + "|" + getBrand() + "|" + getModel()
                + "|" + getYear() + "|" + getRentalPricePerDay() + "|" + isAvailable()
                + "|" + cargoCapacityKg + "|" + getImageUrl();
    }

    public double getCargoCapacityKg()                { return cargoCapacityKg; }
    public void setCargoCapacityKg(double capacity)   { this.cargoCapacityKg = capacity; }

    @Override
    public String getExtraField()                     { return String.valueOf(cargoCapacityKg); }
}
