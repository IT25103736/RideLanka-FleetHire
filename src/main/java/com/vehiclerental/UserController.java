package com.vehiclerental;

import com.vehiclerental.model.User;
import com.vehiclerental.repository.AuditRepository;
import com.vehiclerental.repository.UserRepository;
import com.vehiclerental.security.PasswordUtil;
import jakarta.servlet.http.HttpSession;
import org.springframework.stereotype.Controller;
import org.springframework.web.bind.annotation.*;

import java.sql.SQLException;

@Controller
public class UserController {
    private final UserRepository users;
    private final AuditRepository audit;
    public UserController(UserRepository users,AuditRepository audit){this.users=users;this.audit=audit;}

    @GetMapping("/register") public String register(){return "register";}
    @GetMapping("/login") public String login(){return "login";}

    @GetMapping("/profile") public String profile(HttpSession session){
        if(session.getAttribute("loggedUser")==null)return "redirect:/login";return "profile";
    }
    @GetMapping("/logout") public String logout(HttpSession session){
        User u=(User)session.getAttribute("loggedUser");if(u!=null) audit.log(u.getId(),"LOGOUT",u.getId(),"User signed out");session.invalidate();return "redirect:/login?msg=loggedout";
    }

    @PostMapping("/user/register")
    public String handleRegister(@RequestParam String name,@RequestParam String email,@RequestParam String password,
                                 @RequestParam(defaultValue="") String phone,@RequestParam(defaultValue="") String licenseNo){
        try{
            if(password.length()<6)return "redirect:/register?error=shortPassword";
            boolean ok=users.insert(name,email,password,"CUSTOMER",phone,licenseNo);
            return ok?"redirect:/login?msg=registered":"redirect:/register?error=emailExists";
        }catch(SQLException e){System.err.println("[UserController] register: "+e.getMessage());return "redirect:/register?error=db";}
    }

    @PostMapping("/user/login")
    public String handleLogin(@RequestParam String email,@RequestParam String password,HttpSession session){
        try{
            User u=users.findByEmail(email);
            if(u!=null && "ACTIVE".equalsIgnoreCase(u.getStatus()) && PasswordUtil.matches(password,u.getPassword())){
                session.setAttribute("loggedUser",u);audit.log(u.getId(),"LOGIN",u.getId(),"Successful login");return "redirect:"+u.getDashboardUrl();
            }
            return "redirect:/login?error=invalid";
        }catch(SQLException e){System.err.println("[UserController] login: "+e.getMessage());return "redirect:/login?error=db";}
    }

    @PostMapping("/user/update")
    public String handleUpdate(@RequestParam String name,@RequestParam String email,@RequestParam(defaultValue="") String phone,
                               @RequestParam(defaultValue="") String licenseNo,HttpSession session){
        User logged=(User)session.getAttribute("loggedUser");if(logged==null)return "redirect:/login";
        try{users.updateProfile(logged.getId(),name,email,phone,licenseNo);logged.setName(name);logged.setEmail(email);logged.setPhone(phone);logged.setLicenseNo(licenseNo);session.setAttribute("loggedUser",logged);audit.log(logged.getId(),"UPDATE_PROFILE",logged.getId(),"Profile updated");return "redirect:/profile?msg=updated";}
        catch(SQLException e){return "redirect:/profile?error=db";}
    }

    @PostMapping("/user/delete")
    public String handleDelete(HttpSession session){
        User logged=(User)session.getAttribute("loggedUser");if(logged==null)return "redirect:/login";
        try{users.softDelete(logged.getId());audit.log(logged.getId(),"DEACTIVATE_ACCOUNT",logged.getId(),"Customer deactivated own account");session.invalidate();return "redirect:/login?msg=deleted";}catch(SQLException e){return "redirect:/profile?error=db";}
    }
}
