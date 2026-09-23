package com.vehiclerental.filter;

import java.util.ArrayList;
import java.util.List;

public class VanFilter extends VehicleFilter {

    private final double minCargoKg;

    public VanFilter(double minPrice, double maxPrice, double minCargoKg) {
        super("Van", minPrice, maxPrice);
        this.minCargoKg = minCargoKg;
    }

    public double getMinCargoKg() { return minCargoKg; }

    @Override
    public List<String[]> search(List<String[]> vehicles) {
        List<String[]> results = new ArrayList<>();
        for (String[] v : vehicles) {
            if (!isType(v, "Van"))   continue;
            if (!priceInRange(v))     continue;
            if (minCargoKg > 0) {
                try {
                    double cargo = Double.parseDouble(v[7]);
                    if (cargo < minCargoKg) continue;
                } catch (NumberFormatException e) { continue; }
            }
            results.add(v);
        }
        return results;
    }
}
