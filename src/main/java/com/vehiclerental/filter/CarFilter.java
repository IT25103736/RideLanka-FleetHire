package com.vehiclerental.filter;

import com.vehiclerental.model.Car;

import java.util.ArrayList;
import java.util.List;

public class CarFilter extends VehicleFilter {

    private final String transmission;   // empty = any
    private final int    minSeats;       // 0     = any
    private final String fuelType;       // empty = any; "Hybrid" / "Electric" trigger model whitelist

    public CarFilter(double minPrice, double maxPrice, String transmission, int minSeats, String fuelType) {
        super("Car", minPrice, maxPrice);
        this.transmission = transmission == null ? "" : transmission;
        this.minSeats     = minSeats;
        this.fuelType     = fuelType == null ? "" : fuelType;
    }

    public String getTransmission() { return transmission; }
    public int    getMinSeats()     { return minSeats; }
    public String getFuelType()     { return fuelType; }

    @Override
    public List<String[]> search(List<String[]> vehicles) {
        List<String[]> results = new ArrayList<>();
        for (String[] v : vehicles) {
            if (!isType(v, "Car"))    continue;
            if (!priceInRange(v))      continue;

            if (minSeats > 0) {
                try {
                    int seats = Integer.parseInt(v[7]);
                    if (seats < minSeats) continue;
                } catch (NumberFormatException e) { continue; }
            }

            if (!fuelType.isEmpty()) {
                String model = v.length > 3 ? v[3] : "";
                if ("Hybrid".equalsIgnoreCase(fuelType)   && !Car.HYBRID_MODELS.contains(model))   continue;
                if ("Electric".equalsIgnoreCase(fuelType) && !Car.ELECTRIC_MODELS.contains(model)) continue;
            }

            results.add(v);
        }
        return results;
    }
}
