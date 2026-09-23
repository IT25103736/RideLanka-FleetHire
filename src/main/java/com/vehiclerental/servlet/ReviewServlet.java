package com.vehiclerental.servlet;

import com.vehiclerental.model.Review;
import com.vehiclerental.notification.NotificationService;
import com.vehiclerental.util.ReviewFileHandler;
import jakarta.servlet.http.HttpSession;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.*;

import java.time.LocalDate;
import java.util.List;

@Controller
@RequestMapping("/review")
public class ReviewServlet {

    //  show submission form
    @GetMapping("/submit")
    public String showSubmitForm(Model model) {
        return "submitReview";
    }

    //  save a new review
    @PostMapping("/submit")
    public String handleSubmit(
            @RequestParam String vehicleId,
            @RequestParam String reviewType,
            @RequestParam int    rating,
            @RequestParam(required = false, defaultValue = "") String title,
            @RequestParam String comment,
            @RequestParam(required = false) String bookingId,
            HttpSession session,
            Model model) {

        Object loggedUser = session.getAttribute("loggedUser");
        String userId   = "GUEST";
        String username = "Anonymous";

        if (loggedUser != null) {
            try {
                userId   = (String) loggedUser.getClass().getMethod("getId").invoke(loggedUser);
                username = (String) loggedUser.getClass().getMethod("getName").invoke(loggedUser);
            } catch (Exception e) {

            }
        }

        String reviewId   = ReviewFileHandler.generateId();
        String reviewDate = LocalDate.now().toString();
        String status     = "approved"; // ← auto-approve, no admin needed

        Review review = new Review(
                reviewId, vehicleId, userId, username,
                rating, comment, reviewDate, status, reviewType
        );

        boolean saved = ReviewFileHandler.saveReview(review);

        if (saved) {
            model.addAttribute("successMsg", "Review submitted successfully!");
            // Notify admins so the moderation panel surfaces fresh activity.
            try {
                NotificationService.get().reviewSubmitted(username, rating,
                        vehicleId == null ? "a vehicle" : vehicleId);
            } catch (RuntimeException ex) {
                System.err.println("[ReviewServlet] notification failed: " + ex.getMessage());
            }
        } else {
            model.addAttribute("errorMsg", "Failed to save review. Please try again.");
        }
        return "submitReview";
    }


    @GetMapping("/view")
    public String viewReviews(
            @RequestParam(required = false) String vehicleId,
            @RequestParam(required = false) String rating,
            @RequestParam(required = false) String search,
            Model model,
            HttpSession session) {

        List<Review> all     = ReviewFileHandler.readAllReviews();
        List<Review> approved = ReviewFileHandler.filterByStatus(all, "approved");

        if (vehicleId != null && !vehicleId.isEmpty()) {
            approved.removeIf(r -> !r.getVehicleId().equals(vehicleId));
        }
        if (rating != null && !rating.isEmpty()) {
            try {
                int minRating = Integer.parseInt(rating);
                approved.removeIf(r -> r.getRating() < minRating);
            } catch (NumberFormatException ignored) {}
        }
        if (search != null && !search.isEmpty()) {
            String lower = search.toLowerCase();
            approved.removeIf(r ->
                    !r.getComment().toLowerCase().contains(lower) &&
                            !r.getUsername().toLowerCase().contains(lower));
        }

        Object loggedUser = session.getAttribute("loggedUser");
        String sessionUserId = "";
        String sessionRole   = "";
        if (loggedUser != null) {
            try {
                sessionUserId = (String) loggedUser.getClass().getMethod("getId").invoke(loggedUser);
                sessionRole   = (String) loggedUser.getClass().getMethod("getRole").invoke(loggedUser);
            } catch (Exception e) { /* fallback */ }
        }

        model.addAttribute("reviews",       approved);
        model.addAttribute("sessionUserId", sessionUserId);
        model.addAttribute("sessionRole",   sessionRole);
        return "viewReviews";
    }

    // edit
    @GetMapping("/edit")
    public String showEditForm(
            @RequestParam String reviewId,
            HttpSession session,
            Model model) {

        Object loggedUser = session.getAttribute("loggedUser");
        String sessionUserId = "";
        String sessionRole   = "";
        if (loggedUser != null) {
            try {
                sessionUserId = (String) loggedUser.getClass().getMethod("getId").invoke(loggedUser);
                sessionRole   = (String) loggedUser.getClass().getMethod("getRole").invoke(loggedUser);
            } catch (Exception e) { /* fallback */ }
        }

        Review review = ReviewFileHandler.findById(reviewId);

        if (review == null) {
            return "redirect:/review/view";
        }


        if (!sessionUserId.equals(review.getUserId()) && !"admin".equals(sessionRole)) {
            return "redirect:/review/view";
        }

        model.addAttribute("review", review);
        return "editReview";
    }

    // save edited review
    @PostMapping("/edit")
    public String handleEdit(
            @RequestParam String reviewId,
            @RequestParam int    rating,
            @RequestParam String comment,
            @RequestParam String reviewType,
            HttpSession session,
            Model model) {

        Object loggedUser = session.getAttribute("loggedUser");
        String sessionUserId = "";
        String sessionRole   = "";
        if (loggedUser != null) {
            try {
                sessionUserId = (String) loggedUser.getClass().getMethod("getId").invoke(loggedUser);
                sessionRole   = (String) loggedUser.getClass().getMethod("getRole").invoke(loggedUser);
            } catch (Exception e) { /* fallback */ }
        }

        Review review = ReviewFileHandler.findById(reviewId);

        if (review == null) {
            return "redirect:/review/view";
        }


        if (!sessionUserId.equals(review.getUserId()) && !"admin".equals(sessionRole)) {
            return "redirect:/review/view";
        }

        review.setRating(rating);
        review.setComment(comment);
        review.setReviewType(reviewType);

        boolean updated = ReviewFileHandler.updateReview(review);

        if (updated) {
            model.addAttribute("successMsg", "Review updated successfully!");
        } else {
            model.addAttribute("errorMsg", "Failed to update review.");
        }
        model.addAttribute("review", review);
        return "editReview";
    }


    @GetMapping("/moderate")
    public String showModeration(
            @RequestParam(defaultValue = "approved") String tab,
            Model model) {

        List<Review> all      = ReviewFileHandler.readAllReviews();
        List<Review> approved = ReviewFileHandler.filterByStatus(all, "approved");
        List<Review> flagged  = ReviewFileHandler.filterByStatus(all, "flagged");

        List<Review> displayed = "flagged".equals(tab) ? flagged : approved;

        model.addAttribute("reviews",       displayed);
        model.addAttribute("approvedCount", approved.size());
        model.addAttribute("flaggedCount",  flagged.size());
        model.addAttribute("tab",           tab);
        return "moderationPanel";
    }


    @PostMapping("/flag")
    public String flagReview(@RequestParam String reviewId) {
        ReviewFileHandler.updateStatus(reviewId, "flagged");
        return "redirect:/review/moderate?tab=approved";
    }


    @PostMapping("/unflag")
    public String unflagReview(@RequestParam String reviewId) {
        ReviewFileHandler.updateStatus(reviewId, "approved");
        return "redirect:/review/moderate?tab=flagged";
    }

    // delete ─
    @PostMapping("/delete")
    public String deleteReview(
            @RequestParam String reviewId,
            @RequestParam(defaultValue = "approved") String tab,
            HttpSession session) {

        Object loggedUser = session.getAttribute("loggedUser");
        String sessionRole   = "";
        String sessionUserId = "";

        if (loggedUser != null) {
            try {
                sessionRole   = (String) loggedUser.getClass().getMethod("getRole").invoke(loggedUser);
                sessionUserId = (String) loggedUser.getClass().getMethod("getId").invoke(loggedUser);
            } catch (Exception e) { /* fallback */ }
        }

        Review review = ReviewFileHandler.findById(reviewId);

        if (review != null &&
                ("admin".equals(sessionRole) || sessionUserId.equals(review.getUserId()))) {
            ReviewFileHandler.deleteReview(reviewId);
        }

        if ("admin".equals(sessionRole)) {
            return "redirect:/review/moderate?tab=" + tab;
        }
        return "redirect:/review/view";
    }
}