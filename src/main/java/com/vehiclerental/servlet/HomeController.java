package com.vehiclerental.servlet;

import com.vehiclerental.model.Review;
import com.vehiclerental.model.Vehicle;
import com.vehiclerental.util.ReviewFileHandler;
import com.vehiclerental.util.VehicleFileHandler;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.GetMapping;

import java.util.ArrayList;
import java.util.LinkedHashMap;
import java.util.List;
import java.util.Map;

@Controller
public class HomeController {

    /** How many testimonials to surface on the homepage carousel. */
    private static final int FEATURED_REVIEW_LIMIT = 8;

    /** How many vehicles to surface on the "Currently on the floor" rail. */
    private static final int FEATURED_VEHICLE_LIMIT = 6;

    @GetMapping("/")
    public String home(Model model) {
        model.addAttribute("pageTitle", "Home");

        // ── Load approved reviews for the testimonials carousel ──
        List<Review> all = ReviewFileHandler.readAllReviews();
        List<Review> approved = new ArrayList<>();
        int   ratingSum = 0;
        for (Review r : all) {
            if (!"approved".equalsIgnoreCase(r.getStatus())) continue;
            approved.add(r);
            ratingSum += r.getRating();
        }
        // Prefer 5-star verified reviews at the top of the rail
        approved.sort((a, b) -> {
            int byRating = Integer.compare(b.getRating(), a.getRating());
            if (byRating != 0) return byRating;
            return b.getReviewDate().compareTo(a.getReviewDate());
        });
        List<Review> featured = approved.size() > FEATURED_REVIEW_LIMIT
                ? approved.subList(0, FEATURED_REVIEW_LIMIT)
                : approved;

        double avg = approved.isEmpty() ? 0.0 : (ratingSum / (double) approved.size());

        model.addAttribute("featuredReviews", featured);
        model.addAttribute("reviewCount",     approved.size());
        model.addAttribute("avgRating",       avg);

        // ── "Currently on the floor" — one available vehicle per category, real photos only ──
        model.addAttribute("featuredVehicles", pickFeaturedVehicles());

        return "index";
    }

    /**
     * Curates the home-page "on the floor" rail. Picks one vehicle per displayCategory
     * (Sedan, Hybrid, SUV, Hatchback, Electric, Van, ) so the rail showcases the
     * fleet's breadth rather than 6 hatchbacks. Polymorphism in action — the loop
     * calls Vehicle.getDisplayCategory() which dispatches to Car/Van.
     */
    private List<Vehicle> pickFeaturedVehicles() {
        List<Vehicle> all = new VehicleFileHandler().getAllVehicles();
        // Newest year first so cards feel fresh
        all.sort((a, b) -> Integer.compare(b.getYear(), a.getYear()));

        Map<String, Vehicle> oneOfEach = new LinkedHashMap<>();
        for (Vehicle v : all) {
            if (!v.isAvailable())              continue;   // hide grounded vehicles
            if (v.getImageUrl().isEmpty())     continue;   // skip rows without a real photo
            String cat = v.getDisplayCategory();
            if (oneOfEach.containsKey(cat))    continue;   // already covered this category
            oneOfEach.put(cat, v);
            if (oneOfEach.size() >= FEATURED_VEHICLE_LIMIT) break;
        }
        return new ArrayList<>(oneOfEach.values());
    }

    /**
     * Public-facing rental policies page — Sri Lanka context.
     * Linked from vehicle-detail, booking-form, marketing footer.
     */
    @GetMapping("/policies")
    public String policies(Model model) {
        model.addAttribute("pageTitle", "Rental Policies");
        return "policies";
    }
}
