package com.vehiclerental.model;

public abstract class Vehicle {

    private String vehicleId;
    private String brand;
    private String model;
    private int year;
    private double rentalPricePerDay;
    private boolean available;
    private String imageUrl;   // verified URL for this exact vehicle; blank means no photo is displayed

    // ---- Constructor ----
    public Vehicle(String vehicleId, String brand, String model, int year,
                   double rentalPricePerDay, boolean available) {
        this.vehicleId       = vehicleId;
        this.brand           = brand;
        this.model           = model;
        this.year            = year;
        this.rentalPricePerDay = rentalPricePerDay;
        this.available       = available;
        this.imageUrl        = "";
    }

    // ---- Abstract method — each subclass MUST override this (Polymorphism)
   
    public abstract String getVehicleType();

    /** Home-page-tile label (Sedan / Hybrid / SUV / Hatchback / Electric / Van).
     *   and Van return their type; Car narrows further by model name + seat count. */
    public abstract String getDisplayCategory();

    /** Convenience accessor used by the vehicle-form JSP to show whichever
     *  type-specific field this vehicle exposes (seats / cargo / cc). */
    public abstract String getExtraField();

    // ---- Getters ----
    public String getVehicleId()        { return vehicleId; }
    public String getBrand()            { return brand; }
    public String getModel()            { return model; }
    public int    getYear()             { return year; }
    public double getRentalPricePerDay(){ return rentalPricePerDay; }
    public boolean isAvailable()        { return available; }

    public String getImageUrl()                              { return imageUrl == null ? "" : imageUrl; }

    // ---- Setters ----
    public void setVehicleId(String vehicleId)               { this.vehicleId = vehicleId; }
    public void setBrand(String brand)                       { this.brand = brand; }
    public void setModel(String model)                       { this.model = model; }
    public void setYear(int year)                            { this.year = year; }
    public void setRentalPricePerDay(double rentalPricePerDay){ this.rentalPricePerDay = rentalPricePerDay; }
    public void setAvailable(boolean available)              { this.available = available; }
    public void setImageUrl(String imageUrl)                 { this.imageUrl = imageUrl == null ? "" : imageUrl; }

    // ---- toString for debugging ----
    @Override
    public String toString() {
        return getVehicleType() + " [" + vehicleId + "] " + brand + " " + model
                + " (" + year + ") - Rs." + rentalPricePerDay + "/day | Available: " + available;
    }
}
