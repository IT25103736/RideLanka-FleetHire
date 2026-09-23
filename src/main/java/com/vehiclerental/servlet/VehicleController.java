package com.vehiclerental.servlet;

import com.vehiclerental.fleet.ManagedVehicle;
import com.vehiclerental.model.Car;
import com.vehiclerental.model.User;
import com.vehiclerental.model.Vehicle;
import com.vehiclerental.repository.AuditRepository;
import com.vehiclerental.repository.VehicleRepository;
import com.vehiclerental.util.VehicleFileHandler;
import jakarta.servlet.http.HttpSession;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.*;

import java.sql.SQLException;
import java.util.*;

/** Vehicle Management = master vehicle records only. Operational status belongs to /fleet. */
@Controller
@RequestMapping("/vehicle")
public class VehicleController {
    private final VehicleRepository repository;
    private final AuditRepository audit;
    private final VehicleFileHandler legacy;
    public VehicleController(VehicleRepository repository, AuditRepository audit){
        this.repository=repository; this.audit=audit; this.legacy=new VehicleFileHandler();
    }

    @GetMapping
    public String handleGet(@RequestParam(defaultValue="list") String action,
                            @RequestParam(required=false) String id,
                            HttpSession session, Model model){
        if("view".equals(action)) return publicView(id,model);
        String guard=requireVehicleManager(session); if(guard!=null)return guard;
        try{
            if("add".equals(action)) { prepareForm(model,null); return "vehicle-form"; }
            if("edit".equals(action)) {
                ManagedVehicle v=repository.findById(id);
                if(v==null){model.addAttribute("errorMessage","Vehicle not found: "+id);renderList(model);return "vehicle-list";}
                prepareForm(model,v); return "vehicle-form";
            }
            if("delete".equals(action)) {
                try {
                    repository.delete(id);
                    audit.log(((User)session.getAttribute("loggedUser")).getId(),"DELETE_VEHICLE",id,"Vehicle master record deleted");
                    return "redirect:/vehicle?action=list&msg=deleted";
                } catch(SQLException e){
                    return "redirect:/vehicle?action=list&error="+enc("Vehicle "+id+" cannot be deleted because it is referenced by another module.");
                }
            }
            renderList(model); return "vehicle-list";
        }catch(SQLException e){
            model.addAttribute("errorMessage","Vehicle database is unavailable: "+safe(e.getMessage()));
            model.addAttribute("vehicles",Collections.emptyList());return "vehicle-list";
        }
    }

    @GetMapping("/list")
    public String list(HttpSession session,Model model){
        if(requireVehicleManager(session)!=null)return requireVehicleManager(session);
        try{renderList(model);return "vehicle-list";}catch(SQLException e){model.addAttribute("errorMessage","Vehicle database is unavailable: "+safe(e.getMessage()));return "vehicle-list";}
    }

    @PostMapping
    public String save(@RequestParam(defaultValue="add") String action,
                       @RequestParam String vehicleId,@RequestParam String vehicleType,@RequestParam String plateNo,
                       @RequestParam String make,@RequestParam String model,@RequestParam String vehicleYear,
                       @RequestParam String transmission,@RequestParam String fuelType,@RequestParam String seats,
                       @RequestParam(defaultValue="0") String mileage,@RequestParam String dailyRate,
                       @RequestParam String categoryId,@RequestParam String branchId,
                       @RequestParam(defaultValue="") String imageUrl,@RequestParam(defaultValue="") String registrationExpiry,
                       @RequestParam(defaultValue="") String insuranceExpiry,@RequestParam(defaultValue="") String permitExpiry,
                       HttpSession session, Model modelMap){
        String guard=requireVehicleManager(session); if(guard!=null)return guard;
        try{
            int y=Integer.parseInt(vehicleYear.trim()), s=Integer.parseInt(seats.trim()), m=Integer.parseInt(mileage.trim());
            double rate=Double.parseDouble(dailyRate.trim());
            if(vehicleId.isBlank()||plateNo.isBlank()||make.isBlank()||model.isBlank()) throw new IllegalArgumentException("Required vehicle master fields are missing.");
            if(y<1980||y>2100) throw new IllegalArgumentException("Vehicle year must be between 1980 and 2100.");
            if(s<1||s>20||m<0||rate<0) throw new IllegalArgumentException("Seats, mileage or daily rate is outside the allowed range.");
            if(!"Car".equalsIgnoreCase(vehicleType)) throw new IllegalArgumentException("Use Car for the current RideLanka fleet demo.");
            if("edit".equalsIgnoreCase(action)){
                ManagedVehicle existing=repository.findById(vehicleId);
                if(existing==null) throw new IllegalArgumentException("Vehicle was not found.");
                if(!repository.update(vehicleId,plateNo.trim(),make.trim(),model.trim(),y,transmission,fuelType,s,m,rate,categoryId,branchId,imageUrl.trim(),registrationExpiry,insuranceExpiry,permitExpiry,"Car"))
                    throw new IllegalArgumentException("Vehicle could not be updated.");
                mirrorToLegacy(vehicleId,make,model,y,rate,"AVAILABLE".equalsIgnoreCase(existing.getStatus()),s,imageUrl);
                audit.log(((User)session.getAttribute("loggedUser")).getId(),"UPDATE_VEHICLE",vehicleId,"Vehicle master record updated");
            }else{
                if(repository.exists(vehicleId.trim())) throw new IllegalArgumentException("Vehicle ID already exists.");
                repository.insert(vehicleId.trim(),plateNo.trim(),make.trim(),model.trim(),y,transmission,fuelType,s,m,rate,categoryId,branchId,imageUrl.trim(),registrationExpiry,insuranceExpiry,permitExpiry,"Car");
                mirrorToLegacy(vehicleId,make,model,y,rate,true,s,imageUrl);
                audit.log(((User)session.getAttribute("loggedUser")).getId(),"CREATE_VEHICLE",vehicleId,"Vehicle master record created");
            }
            return "redirect:/vehicle?action=list&msg=saved";
        }catch(IllegalArgumentException e){
            return formError(modelMap,e.getMessage(),action,vehicleId,vehicleType,plateNo,make,model,vehicleYear,transmission,fuelType,seats,mileage,dailyRate,categoryId,branchId,imageUrl,registrationExpiry,insuranceExpiry,permitExpiry);
        }catch(SQLException e){
            return formError(modelMap,"Could not save vehicle. Check the SQL Server connection and that the plate number is unique.",action,vehicleId,vehicleType,plateNo,make,model,vehicleYear,transmission,fuelType,seats,mileage,dailyRate,categoryId,branchId,imageUrl,registrationExpiry,insuranceExpiry,permitExpiry);
        }
    }

    private void renderList(Model model)throws SQLException{
        List<ManagedVehicle> list=repository.findAll();
        long available=list.stream().filter(v->"AVAILABLE".equalsIgnoreCase(v.getStatus())).count();
        long rented=list.stream().filter(v->"RENTED".equalsIgnoreCase(v.getStatus())).count();
        long maintenance=list.stream().filter(v->"MAINTENANCE".equalsIgnoreCase(v.getStatus())).count();
        long out=list.stream().filter(v->"OUT_OF_SERVICE".equalsIgnoreCase(v.getStatus())).count();
        model.addAttribute("vehicles",list);model.addAttribute("totalVehicles",list.size());model.addAttribute("availableVehicles",available);
        model.addAttribute("rentedVehicles",rented);model.addAttribute("maintenanceVehicles",maintenance);model.addAttribute("outVehicles",out);
    }

    private void prepareForm(Model model,ManagedVehicle v)throws SQLException{
        if(v!=null)model.addAttribute("vehicle",v);
        model.addAttribute("branches",repository.branches());model.addAttribute("categories",repository.categories());
    }

    private String formError(Model m,String error,String action,String id,String type,String plate,String make,String model,String year,String transmission,
                             String fuel,String seats,String mileage,String rate,String category,String branch,String image,String reg,String ins,String permit){
        m.addAttribute("errorMessage",error);m.addAttribute("formAction",action);m.addAttribute("formVehicleId",id);m.addAttribute("formVehicleType",type);
        m.addAttribute("formPlateNo",plate);m.addAttribute("formMake",make);m.addAttribute("formModel",model);m.addAttribute("formYear",year);
        m.addAttribute("formTransmission",transmission);m.addAttribute("formFuel",fuel);m.addAttribute("formSeats",seats);m.addAttribute("formMileage",mileage);
        m.addAttribute("formRate",rate);m.addAttribute("formCategory",category);m.addAttribute("formBranch",branch);m.addAttribute("formImage",image);
        m.addAttribute("formReg",reg);m.addAttribute("formIns",ins);m.addAttribute("formPermit",permit);
        try{m.addAttribute("branches",repository.branches());m.addAttribute("categories",repository.categories());}catch(SQLException ignored){}
        return "vehicle-form";
    }

    private String publicView(String id,Model model){
        Vehicle v=legacy.getVehicleById(id);
        if(v==null){model.addAttribute("errorMessage","Vehicle not found: "+id);return "vehicle-list";}
        model.addAttribute("vehicle",v);model.addAttribute("driverFeeLkr",4500.0);model.addAttribute("lkrPerUsd",SearchController.LKR_PER_USD);return "vehicle-detail";
    }
    private void mirrorToLegacy(String id,String make,String model,int year,double rate,boolean available,int seats,String image){
        try{
            Car c=new Car(id,make.trim(),model.trim(),year,rate,available,seats);c.setImageUrl(image==null?"":image.trim());
            Vehicle existing=legacy.getVehicleById(id); if(existing==null)legacy.addVehicle(c); else legacy.updateVehicle(c);
        }catch(Exception ex){System.err.println("[VehicleController] legacy compatibility mirror failed: "+ex.getMessage());}
    }
    static String requireVehicleManager(HttpSession session){Object x=session.getAttribute("loggedUser");if(!(x instanceof User u))return "redirect:/login";String r=u.getRole();return ("ADMIN".equalsIgnoreCase(r)||"VEHICLE".equalsIgnoreCase(r))?null:"redirect:/dashboard";}
    private static String enc(String s){return s.replace(" ","%20");}
    private static String safe(String s){return s==null?"unknown database error":s.replace("\n"," ");}
}
