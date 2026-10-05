package com.vehiclerental.servlet;

import com.vehiclerental.fleet.FleetMaintenanceService;
import com.vehiclerental.fleet.MaintenanceRecord;
import com.vehiclerental.fleet.Inspection;
import com.vehiclerental.model.User;
import com.vehiclerental.repository.MaintenanceRepository;
import jakarta.servlet.http.HttpSession;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.*;

import java.sql.SQLException;
import java.util.Collections;
import java.util.List;

/** Fleet Management / Maintenance = operational state, maintenance and inspections. */
@Controller
@RequestMapping("/fleet")
public class FleetMaintenanceController {
    private final MaintenanceRepository repository; private final FleetMaintenanceService service;
    public FleetMaintenanceController(MaintenanceRepository repository,FleetMaintenanceService service){this.repository=repository;this.service=service;}

    @GetMapping
    public String page(HttpSession session,Model model){
        String guard=requireFleetStaff(session);if(guard!=null)return guard;
        try{
            List<MaintenanceRecord> records=repository.findAll(); List<Inspection> inspections=repository.findInspections();
            var vehicles=repository.findVehicleOptions();
            model.addAttribute("maintenanceRecords",records);model.addAttribute("inspections",inspections);model.addAttribute("vehicles",vehicles);
            model.addAttribute("availableCount",vehicles.stream().filter(v->"AVAILABLE".equalsIgnoreCase(v.getStatus())).count());
            model.addAttribute("maintenanceCount",vehicles.stream().filter(v->"MAINTENANCE".equalsIgnoreCase(v.getStatus())).count());
            model.addAttribute("outCount",vehicles.stream().filter(v->"OUT_OF_SERVICE".equalsIgnoreCase(v.getStatus())).count());
            model.addAttribute("scheduledCount",records.stream().filter(m->"SCHEDULED".equalsIgnoreCase(m.getStatus())).count());
        }catch(SQLException e){
            System.err.println("[FleetMaintenanceController] load failed: "+e.getMessage());
            model.addAttribute("errorMessage","Unable to load fleet data from the database.");model.addAttribute("maintenanceRecords",Collections.emptyList());model.addAttribute("inspections",Collections.emptyList());
            model.addAttribute("vehicles",Collections.emptyList());model.addAttribute("availableCount",0);model.addAttribute("maintenanceCount",0);model.addAttribute("outCount",0);model.addAttribute("scheduledCount",0);
        }
        return "fleet-maintenance";
    }

    @PostMapping("/operational-status")
    public String operationalStatus(@RequestParam String vehicleId,@RequestParam String status,HttpSession session){
        User u=(User)session.getAttribute("loggedUser");if(u==null)return "redirect:/login";
        if(!isFleetOrMaintenance(u))return "redirect:/dashboard";
        try{service.setOperationalStatus(vehicleId,status,u.getId());return "redirect:/fleet?msg=status";}catch(Exception e){return "redirect:/fleet?error="+url(userMessage(e));}
    }
    @PostMapping("/schedule") public String schedule(@RequestParam String vehicleId,@RequestParam String maintenanceType,@RequestParam String description,@RequestParam String scheduledDate,@RequestParam String technician,@RequestParam(defaultValue="0") double cost,HttpSession session){
        User u=(User)session.getAttribute("loggedUser");if(u==null||!isFleetOrMaintenance(u))return "redirect:/login";
        try{service.schedule(vehicleId,maintenanceType,description,scheduledDate,technician,cost,u.getId());return "redirect:/fleet?msg=scheduled";}catch(Exception e){return "redirect:/fleet?error="+url(userMessage(e));}
    }
    @PostMapping("/status") public String status(@RequestParam String maintenanceId,@RequestParam String status,HttpSession session){
        User u=(User)session.getAttribute("loggedUser");if(u==null||!isFleetOrMaintenance(u))return "redirect:/login";
        try{service.setStatus(maintenanceId,status,u.getId());return "redirect:/fleet?msg=status";}catch(Exception e){return "redirect:/fleet?error="+url(userMessage(e));}
    }
    @PostMapping("/inspection") public String inspection(@RequestParam String vehicleId,@RequestParam(required=false,defaultValue="") String maintenanceId,@RequestParam String result,@RequestParam(defaultValue="") String notes,HttpSession session){
        User u=(User)session.getAttribute("loggedUser");if(u==null||!isFleetOrMaintenance(u))return "redirect:/login";
        try{service.recordInspection(vehicleId,maintenanceId.isBlank()?null:maintenanceId,result,notes,u.getId());return "redirect:/fleet?msg=inspection";}catch(Exception e){return "redirect:/fleet?error="+url(userMessage(e));}
    }
    @PostMapping("/maintenance/delete")
    public String deleteMaintenance(@RequestParam String maintenanceId,HttpSession session){
        User u=(User)session.getAttribute("loggedUser");if(u==null)return "redirect:/login";
        if(!isFleetOrMaintenance(u))return "redirect:/dashboard";
        try{service.deleteMaintenance(maintenanceId,u.getId());return "redirect:/fleet?msg=maintenanceDeleted";}catch(Exception e){return "redirect:/fleet?error="+url(userMessage(e));}
    }

    @PostMapping("/inspection/delete")
    public String deleteInspection(@RequestParam int inspectionId,HttpSession session){
        User u=(User)session.getAttribute("loggedUser");if(u==null)return "redirect:/login";
        if(!isFleetOrMaintenance(u))return "redirect:/dashboard";
        try{service.deleteInspection(inspectionId,u.getId());return "redirect:/fleet?msg=inspectionDeleted";}catch(Exception e){return "redirect:/fleet?error="+url(userMessage(e));}
    }
    private String requireFleetStaff(HttpSession session){Object x=session.getAttribute("loggedUser");if(!(x instanceof User u))return "redirect:/login";return isFleetOrMaintenance(u)?null:"redirect:/dashboard";}
    private boolean isFleetOrMaintenance(User u){String r=u.getRole();return "ADMIN".equalsIgnoreCase(r)||"MAINTENANCE".equalsIgnoreCase(r)||"FLEET".equalsIgnoreCase(r);}
    private static String userMessage(Exception e){
        if(e instanceof IllegalArgumentException || e instanceof IllegalStateException) return e.getMessage();
        System.err.println("[FleetMaintenanceController] operation failed: "+e.getMessage());
        return "Unable to complete the fleet operation.";
    }
    private static String url(String s){return s==null?"error":s.replace(" ","%20").replace("\n","%20");}
}
