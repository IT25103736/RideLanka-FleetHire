package com.vehiclerental.servlet;

import com.vehiclerental.model.Review;
import com.vehiclerental.model.Vehicle;
import com.vehiclerental.repository.FeedbackRepository;
import com.vehiclerental.repository.VehicleRepository;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.GetMapping;

import java.sql.SQLException;
import java.util.*;

@Controller
public class HomeController {
    private static final int FEATURED_REVIEW_LIMIT=8;
    private static final int FEATURED_VEHICLE_LIMIT=6;
    private final FeedbackRepository feedback;
    private final VehicleRepository vehicles;
    public HomeController(FeedbackRepository feedback,VehicleRepository vehicles){this.feedback=feedback;this.vehicles=vehicles;}

    @GetMapping("/")
    public String home(Model model){
        model.addAttribute("pageTitle","Home");
        try{
            List<Review> visible=new ArrayList<>(feedback.findVisible());
            visible.sort(Comparator.comparingInt(Review::getRating).reversed().thenComparing(Review::getReviewDate,Comparator.reverseOrder()));
            double avg=visible.stream().mapToInt(Review::getRating).average().orElse(0.0);
            model.addAttribute("featuredReviews",visible.stream().limit(FEATURED_REVIEW_LIMIT).toList());
            model.addAttribute("reviewCount",visible.size());model.addAttribute("avgRating",avg);
        }catch(SQLException e){model.addAttribute("featuredReviews",Collections.emptyList());model.addAttribute("reviewCount",0);model.addAttribute("avgRating",0.0);}
        try{model.addAttribute("featuredVehicles",pickFeaturedVehicles(vehicles.findAllDomain()));}
        catch(SQLException e){model.addAttribute("featuredVehicles",Collections.emptyList());}
        return "index";
    }
    private List<Vehicle> pickFeaturedVehicles(List<Vehicle> all){
        all.sort(Comparator.comparingInt(Vehicle::getYear).reversed());Map<String,Vehicle> oneOfEach=new LinkedHashMap<>();
        for(Vehicle v:all){if(!v.isAvailable()||v.getImageUrl().isBlank())continue;oneOfEach.putIfAbsent(v.getDisplayCategory(),v);if(oneOfEach.size()>=FEATURED_VEHICLE_LIMIT)break;}return new ArrayList<>(oneOfEach.values());
    }
    @GetMapping("/policies") public String policies(Model model){model.addAttribute("pageTitle","Rental Policies");return "policies";}
}
