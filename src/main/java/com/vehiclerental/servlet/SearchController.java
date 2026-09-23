package com.vehiclerental.servlet;

import com.vehiclerental.filter.CarFilter;
import com.vehiclerental.filter.VanFilter;
import com.vehiclerental.util.FileHelper;
import com.vehiclerental.util.VehicleSorter;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestParam;

import java.util.ArrayList;
import java.util.List;
import java.util.TreeSet;

/**
 * C01 — Vehicle Search & Filtering.
 * Reads vehicles.txt, applies a polymorphic VehicleFilter chain, then sorts
 * the surviving list via {@link VehicleSorter} (Selection Sort — C05).
 */
@Controller
public class SearchController {

    /** Fixed LKR→USD rate used for the approximate USD price on each card. */
    public static final double LKR_PER_USD = 300.0;

    @GetMapping("/search")
    public String search(
            @RequestParam(defaultValue = "") String vehicleType,
            @RequestParam(defaultValue = "") String transmission,
            @RequestParam(defaultValue = "") String minPrice,
            @RequestParam(defaultValue = "") String maxPrice,
            @RequestParam(defaultValue = "") String seats,
            @RequestParam(defaultValue = "") String capacity,
            @RequestParam(defaultValue = "") String keyword,
            @RequestParam(defaultValue = "") String location,
            @RequestParam(defaultValue = "") String withDriver,
            @RequestParam(defaultValue = "") String fuelType,
            @RequestParam(defaultValue = "") String sort,
            Model model) {

        boolean hasFilters = !(vehicleType.isEmpty() && keyword.isEmpty()
                && minPrice.isEmpty() && maxPrice.isEmpty()
                && seats.isEmpty()    && capacity.isEmpty()
                && location.isEmpty() && fuelType.isEmpty() && transmission.isEmpty()
                && withDriver.isEmpty() && sort.isEmpty());

        if (!hasFilters) {
            // Populate data-driven filter options so the form reflects real inventory
            model.addAttribute("availableCarSeats",      distinctCarSeats());
            model.addAttribute("availableVanCapacities", distinctVanCapacities());
            return "search";
        }

        double min = parseDouble(minPrice, 0);
        double max = parseDouble(maxPrice, 9_999_999);
        int    s   = parseInt(seats, 0);
        double cap = parseDouble(capacity, 0);

        List<String[]> source = keyword.isEmpty()
                ? FileHelper.readVehicles()
                : FileHelper.searchByKeyword(keyword);
        // Search supports RideLanka car and van inventory only.
        String effectiveType     = vehicleType;
        String effectiveFuelType = fuelType;
        switch (effectiveType.toLowerCase()) {
            case "sedan":     effectiveType = "car"; if (s == 0)                        s = 5; break;
            case "suv":       effectiveType = "car"; if (s == 0)                        s = 7; break;
            case "hatchback": effectiveType = "car"; if (s == 0)                        s = 4; break;
            case "hybrid":    effectiveType = "car"; if (effectiveFuelType.isEmpty()) effectiveFuelType = "Hybrid";   break;
            case "electric":  effectiveType = "car"; if (effectiveFuelType.isEmpty()) effectiveFuelType = "Electric"; break;
            default: break; // car / van /  / "" pass through
        }

        // If a tile link came in with just fuelType=Hybrid|Electric, default to car.
        if (effectiveType.isEmpty() && !effectiveFuelType.isEmpty()) {
            effectiveType = "car";
        }

        List<String[]> results;
        switch (effectiveType.toLowerCase()) {
            case "car":
                results = new CarFilter(min, max, transmission, s, effectiveFuelType).search(source);
                break;
            case "van":
                results = new VanFilter(min, max, cap).search(source);
                break;
            default:
                results = filterByPriceRange(source, min, max);
                break;
        }

        List<VehicleCard> cards = toCardViewModels(results);
        boolean wantsDriver = "true".equalsIgnoreCase(withDriver);

        // C05 — Selection Sort runs over the filtered list, not the whole catalogue.
        VehicleSorter.Mode mode = VehicleSorter.parseMode(sort);
        VehicleSorter.sort(cards, mode);

        model.addAttribute("results",     cards);
        model.addAttribute("count",       cards.size());
        model.addAttribute("vehicleType", vehicleType);
        model.addAttribute("location",    location);
        model.addAttribute("withDriver",  wantsDriver);
        model.addAttribute("sort",        sort);
        model.addAttribute("lkrPerUsd",   LKR_PER_USD);
        return "search-results";
    }

    /** Distinct seat counts across the current car inventory, sorted ascending. */
    private List<Integer> distinctCarSeats() {
        TreeSet<Integer> set = new TreeSet<>();
        for (String[] v : FileHelper.readVehicles()) {
            if (v.length < 8) continue;
            if (!"Car".equalsIgnoreCase(v[1])) continue;
            try { set.add(Integer.parseInt(v[7].trim())); } catch (NumberFormatException ignored) {}
        }
        return new ArrayList<>(set);
    }

    /** Distinct cargo/capacity values across the current van inventory, sorted ascending. */
    private List<Double> distinctVanCapacities() {
        TreeSet<Double> set = new TreeSet<>();
        for (String[] v : FileHelper.readVehicles()) {
            if (v.length < 8) continue;
            if (!"Van".equalsIgnoreCase(v[1])) continue;
            try { set.add(Double.parseDouble(v[7].trim())); } catch (NumberFormatException ignored) {}
        }
        return new ArrayList<>(set);
    }

    /** Filter generic results by price when no specific type was chosen. */
    private List<String[]> filterByPriceRange(List<String[]> list, double min, double max) {
        List<String[]> out = new ArrayList<>();
        for (String[] v : list) {
            try {
                double p = Double.parseDouble(v[5]);
                if (p >= min && p <= max) out.add(v);
            } catch (Exception ignored) {}
        }
        return out;
    }

    /** Convert raw pipe rows into POJOs the JSP can address by name. */
    private List<VehicleCard> toCardViewModels(List<String[]> rows) {
        List<VehicleCard> out = new ArrayList<>();
        for (String[] v : rows) {
            if (v.length < 8) continue;
            String img = v.length > 8 ? v[8] : "";
            out.add(new VehicleCard(
                    v[0], v[1], v[2], v[3],
                    safeInt(v[4]), safeDouble(v[5]),
                    Boolean.parseBoolean(v[6]), v[7], img
            ));
        }
        return out;
    }

    private static int    parseInt(String s, int def)    { try { return Integer.parseInt(s); } catch (Exception e) { return def; } }
    private static double parseDouble(String s, double d){ try { return Double.parseDouble(s); } catch (Exception e) { return d; } }
    private static int    safeInt(String s)              { try { return Integer.parseInt(s); } catch (Exception e) { return 0; } }
    private static double safeDouble(String s)           { try { return Double.parseDouble(s); } catch (Exception e) { return 0.0; } }

    /** Lightweight POJO the search-results.jsp iterates over. */
    public static class VehicleCard {
        private final String id, type, brand, model, extraField, imageUrl;
        private final int    year;
        private final double pricePerDay;
        private final boolean available;

        public VehicleCard(String id, String type, String brand, String model,
                           int year, double pricePerDay, boolean available,
                           String extraField, String imageUrl) {
            this.id = id; this.type = type; this.brand = brand; this.model = model;
            this.year = year; this.pricePerDay = pricePerDay;
            this.available = available; this.extraField = extraField;
            this.imageUrl = imageUrl == null ? "" : imageUrl;
        }

        public String  getId()           { return id; }
        public String  getType()         { return type; }
        public String  getBrand()        { return brand; }
        public String  getModel()        { return model; }
        public int     getYear()         { return year; }
        public double  getPricePerDay()  { return pricePerDay; }
        public boolean isAvailable()     { return available; }
        public String  getExtraField()   { return extraField; }
        public String  getImageUrl()     { return imageUrl; }
        public String  getName()         { return brand + " " + model; }
        public int     getPriceUsd()     { return (int) Math.round(pricePerDay / LKR_PER_USD); }
    }
}
