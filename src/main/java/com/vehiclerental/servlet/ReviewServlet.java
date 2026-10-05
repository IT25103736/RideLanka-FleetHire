package com.vehiclerental.servlet;

import com.vehiclerental.model.Review;
import com.vehiclerental.model.User;
import com.vehiclerental.notification.NotificationService;
import com.vehiclerental.repository.AuditRepository;
import com.vehiclerental.repository.FeedbackRepository;
import jakarta.servlet.http.HttpSession;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.*;

import java.sql.SQLException;
import java.util.ArrayList;
import java.util.List;

@Controller
@RequestMapping("/review")
public class ReviewServlet {
    private final FeedbackRepository feedback;
    private final NotificationService notifications;
    private final AuditRepository audit;
    public ReviewServlet(FeedbackRepository feedback,NotificationService notifications,AuditRepository audit){this.feedback=feedback;this.notifications=notifications;this.audit=audit;}

    @GetMapping("/submit")
    public String form(HttpSession session,Model model){User u=customer(session);if(u==null)return"redirect:/login";return"submitReview";}

    @PostMapping("/submit")
    public String submit(@RequestParam String vehicleId,@RequestParam String reviewType,@RequestParam int rating,
                         @RequestParam(required=false,defaultValue="") String title,@RequestParam String comment,
                         @RequestParam(required=false) String bookingId,HttpSession session,Model model){
        User u=customer(session);if(u==null)return"redirect:/login";
        try{
            validate(rating,comment,title);
            vehicleId=vehicleId==null?"":vehicleId.trim();
            bookingId=bookingId==null?null:bookingId.trim();
            if(vehicleId.isBlank()||vehicleId.length()>20)throw new IllegalArgumentException("Enter a valid vehicle ID.");
            if(bookingId!=null&&!bookingId.isBlank()&&bookingId.length()>20)throw new IllegalArgumentException("Enter a valid booking ID.");
            String full=(title==null||title.isBlank())?comment.trim():title.trim()+" - "+comment.trim();
            if(full.length()>1000)throw new IllegalArgumentException("Review text is too long.");
            String id=feedback.create(u.getId(),vehicleId,bookingId,rating,full,reviewType);audit.log(u.getId(),"CREATE_FEEDBACK",id,"Vehicle "+vehicleId);
            notifications.reviewSubmitted(u.getName(),rating,vehicleId);model.addAttribute("successMsg","Review submitted successfully.");
        }catch(Exception ex){model.addAttribute("errorMsg",userMessage(ex));}
        return"submitReview";
    }

    @GetMapping("/view")
    public String view(@RequestParam(required=false)String vehicleId,@RequestParam(required=false)String rating,@RequestParam(required=false)String search,Model model,HttpSession session){
        try{
            List<Review> rows=new ArrayList<>(feedback.findVisible());
            if(vehicleId!=null&&!vehicleId.isBlank())rows.removeIf(r->!vehicleId.equalsIgnoreCase(r.getVehicleId()));
            if(rating!=null&&!rating.isBlank()){try{int min=Integer.parseInt(rating);rows.removeIf(r->r.getRating()<min);}catch(NumberFormatException ignored){}}
            if(search!=null&&!search.isBlank()){String q=search.toLowerCase();rows.removeIf(r->!(r.getComment().toLowerCase().contains(q)||r.getUsername().toLowerCase().contains(q)));}
            User u=current(session);model.addAttribute("reviews",rows);model.addAttribute("sessionUserId",u==null?"":u.getId());model.addAttribute("sessionRole",u==null?"":u.getRole().toLowerCase());
        }catch(SQLException ex){model.addAttribute("reviews",List.of());model.addAttribute("errorMsg","Unable to load feedback.");}
        return"viewReviews";
    }

    @GetMapping("/edit")
    public String edit(@RequestParam String reviewId,HttpSession session,Model model){User u=current(session);if(u==null)return"redirect:/login";try{Review r=feedback.findById(reviewId);if(r==null||!(u.getId().equals(r.getUserId())||"ADMIN".equalsIgnoreCase(u.getRole())))return"redirect:/review/view";model.addAttribute("review",r);return"editReview";}catch(SQLException e){return"redirect:/review/view";}}

    @PostMapping("/edit")
    public String saveEdit(@RequestParam String reviewId,@RequestParam int rating,@RequestParam String comment,@RequestParam String reviewType,HttpSession session,Model model){
        User u=current(session);if(u==null)return"redirect:/login";try{validate(rating,comment,"");Review r=feedback.findById(reviewId);if(r==null)return"redirect:/review/view";boolean admin="ADMIN".equalsIgnoreCase(u.getRole());if(!admin&&!u.getId().equals(r.getUserId()))return"redirect:/review/view";
            boolean ok;if(admin){ // admin moderation should not silently rewrite customer text; only owner edits content
                ok=false;model.addAttribute("errorMsg","Administrators can moderate feedback status but cannot rewrite customer feedback.");
            }else ok=feedback.updateOwned(reviewId,u.getId(),rating,comment,reviewType);
            if(ok){audit.log(u.getId(),"UPDATE_FEEDBACK",reviewId,"Customer edited feedback");model.addAttribute("successMsg","Review updated successfully.");r=feedback.findById(reviewId);}model.addAttribute("review",r);return"editReview";
        }catch(Exception ex){model.addAttribute("errorMsg",userMessage(ex));return"editReview";}
    }

    @GetMapping("/moderate")
    public String moderate(@RequestParam(defaultValue="approved")String tab,HttpSession session,Model model){User u=current(session);if(u==null||!"ADMIN".equalsIgnoreCase(u.getRole()))return"redirect:/dashboard";try{List<Review>all=feedback.findAllForModeration();List<Review>approved=all.stream().filter(r->"approved".equalsIgnoreCase(r.getStatus())).toList();List<Review>flagged=all.stream().filter(r->"flagged".equalsIgnoreCase(r.getStatus())).toList();model.addAttribute("reviews","flagged".equals(tab)?flagged:approved);model.addAttribute("approvedCount",approved.size());model.addAttribute("flaggedCount",flagged.size());model.addAttribute("tab",tab);}catch(SQLException e){model.addAttribute("reviews",List.of());}return"moderationPanel";}
    @PostMapping("/flag") public String flag(@RequestParam String reviewId,HttpSession s){return moderateStatus(reviewId,"flagged",s,"approved");}
    @PostMapping("/unflag") public String unflag(@RequestParam String reviewId,HttpSession s){return moderateStatus(reviewId,"approved",s,"flagged");}
    @PostMapping("/delete") public String delete(@RequestParam String reviewId,@RequestParam(defaultValue="approved")String tab,HttpSession s){User u=current(s);if(u==null)return"redirect:/login";try{boolean admin="ADMIN".equalsIgnoreCase(u.getRole());if(feedback.removeOwnedOrAdmin(reviewId,u.getId(),admin))audit.log(u.getId(),"REMOVE_FEEDBACK",reviewId,"Feedback removed");return admin?"redirect:/review/moderate?tab="+tab:"redirect:/review/view";}catch(SQLException e){return"redirect:/review/view";}}
    private String moderateStatus(String id,String status,HttpSession s,String tab){User u=current(s);if(u==null||!"ADMIN".equalsIgnoreCase(u.getRole()))return"redirect:/dashboard";try{feedback.setStatus(id,status);audit.log(u.getId(),"MODERATE_FEEDBACK",id,status);}catch(SQLException ignored){}return"redirect:/review/moderate?tab="+tab;}

    private static void validate(int rating,String comment,String title){if(rating<1||rating>5)throw new IllegalArgumentException("Rating must be between 1 and 5.");if(comment==null||comment.trim().length()<5||comment.length()>1000)throw new IllegalArgumentException("Comment must be between 5 and 1000 characters.");if(title!=null&&title.trim().length()>120)throw new IllegalArgumentException("Review title is too long.");if(containsMarkup(comment)||containsMarkup(title))throw new IllegalArgumentException("HTML markup is not allowed in feedback.");}
    private static boolean containsMarkup(String s){return s!=null&&(s.contains("<")||s.contains(">"));}
    private static User current(HttpSession s){Object x=s==null?null:s.getAttribute("loggedUser");return x instanceof User?(User)x:null;}private static User customer(HttpSession s){User u=current(s);return u!=null&&"CUSTOMER".equalsIgnoreCase(u.getRole())?u:null;}
    private static String userMessage(Exception ex){if(ex instanceof IllegalArgumentException||ex instanceof IllegalStateException)return safe(ex.getMessage());if(ex instanceof SQLException)System.err.println("[ReviewServlet] database operation failed: "+ex.getMessage());return "Unable to save feedback.";}
    private static String safe(String s){return s==null?"Unable to save feedback.":s.replace('\n',' ');}
}
