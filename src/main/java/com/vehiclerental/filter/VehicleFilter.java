package com.vehiclerental.filter;

import java.util.List;

/**
 * ABSTRACTION — defines the contract every filter must satisfy.
 * Demonstrates ENCAPSULATION (private fields + getters/setters)
 * and POLYMORPHISM (subclasses override search()).
 */
public abstract class VehicleFilter {

    private String vehicleType;
    private double minPrice;
    private double maxPrice;

    public VehicleFilter(String vehicleType, double minPrice, double maxPrice) {
        this.vehicleType = vehicleType;
        this.minPrice    = minPrice;
        this.maxPrice    = maxPrice;
    }

    public String getVehicleType()                  { return vehicleType; }
    public void   setVehicleType(String vehicleType){ this.vehicleType = vehicleType; }

    public double getMinPrice()                     { return minPrice; }
    public void   setMinPrice(double minPrice)      { this.minPrice = minPrice; }

    public double getMaxPrice()                     { return maxPrice; }
    public void   setMaxPrice(double maxPrice)      { this.maxPrice = maxPrice; }

    /**
     * POLYMORPHISM — each subclass implements its own search logic.
     * Input rows from vehicles.txt:
     *   [0]=id  [1]=type  [2]=brand  [3]=model
     *   [4]=year  [5]=pricePerDay  [6]=available  [7]=extraField
     */
    public abstract List<String[]> search(List<String[]> vehicles);

    /* ── shared helpers ── */

    protected boolean isType(String[] row, String type) {
        return row.length > 1 && row[1].equalsIgnoreCase(type);
    }

    protected boolean priceInRange(String[] row) {
        if (row.length < 6) return false;
        try {
            double price = Double.parseDouble(row[5]);
            return price >= getMinPrice() && price <= getMaxPrice();
        } catch (NumberFormatException e) {
            return false;
        }
    }

    protected boolean isAvailable(String[] row) {
        return row.length > 6 && Boolean.parseBoolean(row[6]);
    }
}
