package com.vehiclerental.servlet;

import com.vehiclerental.fleet.ManagedVehicle;
import com.vehiclerental.model.User;
import com.vehiclerental.model.Vehicle;
import com.vehiclerental.repository.AuditRepository;
import com.vehiclerental.repository.VehicleRepository;
import jakarta.servlet.http.HttpSession;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.*;

import java.net.URI;
import java.sql.SQLException;
import java.time.LocalDate;
import java.util.Collections;
import java.util.List;
import java.util.Set;

/** Vehicle Management: master vehicle CRUD only. Operational state remains Fleet Management. */
@Controller
@RequestMapping("/vehicle")
public class VehicleController {
    private static final Set<String> TRANSMISSIONS=Set.of("MANUAL","AUTOMATIC");
    private static final Set<String> FUELS=Set.of("PETROL","DIESEL","HYBRID","ELECTRIC");
    private final VehicleRepository repository;private final AuditRepository audit;
    public VehicleController(VehicleRepository repository,AuditRepository audit){this.repository=repository;this.audit=audit;}

    @GetMapping
    public String get(@RequestParam(defaultValue="list")String action,@RequestParam(required=false)String id,HttpSession session,Model model){
        try{
            if("view".equalsIgnoreCase(action))return publicView(id,model);
            if(requireManager(session)!=null)return requireManager(session);
            if("add".equalsIgnoreCase(action)){prepareForm(model,null);return"vehicle-form";}
            if("edit".equalsIgnoreCase(action)){ManagedVehicle v=repository.findById(id);if(v==null){model.addAttribute("errorMessage","Vehicle not found.");renderList(model);return"vehicle-list";}prepareForm(model,v);return"vehicle-form";}
            renderList(model);return"vehicle-list";
        }catch(SQLException ex){model.addAttribute("errorMessage","Vehicle database is unavailable.");model.addAttribute("vehicles",Collections.emptyList());return"vehicle-list";}
    }
    @GetMapping("/list")public String list(HttpSession s,Model m){return get("list",null,s,m);}

    @PostMapping
    public String save(@RequestParam(defaultValue="add")String action,@RequestParam String vehicleId,@RequestParam String vehicleType,
                       @RequestParam String plateNo,@RequestParam String make,@RequestParam String model,@RequestParam String vehicleYear,
                       @RequestParam String transmission,@RequestParam String fuelType,@RequestParam String seats,@RequestParam(defaultValue="0")String mileage,
                       @RequestParam String dailyRate,@RequestParam String categoryId,@RequestParam String branchId,@RequestParam(defaultValue="")String imageUrl,
                       @RequestParam(defaultValue="")String registrationExpiry,@RequestParam(defaultValue="")String insuranceExpiry,@RequestParam(defaultValue="")String permitExpiry,
                       HttpSession session,Model out){
        User actor=current(session);if(requireManager(session)!=null)return requireManager(session);
        try{
            String id=vehicleId.trim().toUpperCase(),plate=plateNo.trim().toUpperCase(),type=normalizeType(vehicleType);
            int year=Integer.parseInt(vehicleYear.trim()),seatCount=Integer.parseInt(seats.trim()),km=Integer.parseInt(mileage.trim());double rate=Double.parseDouble(dailyRate.trim());
            validate(id,plate,make,model,year,transmission,fuelType,seatCount,km,rate,imageUrl,registrationExpiry,insuranceExpiry,permitExpiry);
            if(repository.plateExists(plate,"edit".equalsIgnoreCase(action)?id:null))throw new IllegalArgumentException("The vehicle registration number already exists.");
            if("edit".equalsIgnoreCase(action)){
                if(repository.findById(id)==null)throw new IllegalArgumentException("Vehicle was not found.");
                if(!repository.updateWithBranchHistory(id,plate,make.trim(),model.trim(),year,transmission,fuelType,seatCount,km,rate,categoryId,branchId,imageUrl.trim(),registrationExpiry,insuranceExpiry,permitExpiry,type,actor.getId()))throw new IllegalArgumentException("Vehicle could not be updated.");
                audit.log(actor.getId(),"UPDATE_VEHICLE",id,"Vehicle master record updated");
            }else{
                if(repository.exists(id))throw new IllegalArgumentException("Vehicle ID already exists.");
                repository.insert(id,plate,make.trim(),model.trim(),year,transmission,fuelType,seatCount,km,rate,categoryId,branchId,imageUrl.trim(),registrationExpiry,insuranceExpiry,permitExpiry,type);
                audit.log(actor.getId(),"CREATE_VEHICLE",id,"Vehicle master record created");
            }
            return"redirect:/vehicle?action=list&msg=saved";
        }catch(IllegalArgumentException ex){return formError(out,ex.getMessage(),action,vehicleId,vehicleType,plateNo,make,model,vehicleYear,transmission,fuelType,seats,mileage,dailyRate,categoryId,branchId,imageUrl,registrationExpiry,insuranceExpiry,permitExpiry);}
        catch(SQLException ex){String msg=isUnique(ex)?"A vehicle with the same ID or registration number already exists.":"Unable to save the vehicle. Check the database connection and selected category/branch.";return formError(out,msg,action,vehicleId,vehicleType,plateNo,make,model,vehicleYear,transmission,fuelType,seats,mileage,dailyRate,categoryId,branchId,imageUrl,registrationExpiry,insuranceExpiry,permitExpiry);}
    }

    @PostMapping("/delete")
    public String delete(@RequestParam String id,HttpSession session){User u=current(session);if(requireManager(session)!=null)return requireManager(session);try{if(repository.delete(id)){audit.log(u.getId(),"DELETE_VEHICLE",id,"Vehicle master record deleted");return"redirect:/vehicle?action=list&msg=deleted";}return"redirect:/vehicle?action=list&error=Vehicle%20not%20found";}catch(SQLException ex){return"redirect:/vehicle?action=list&error=Vehicle%20cannot%20be%20deleted%20because%20it%20is%20referenced%20by%20bookings%20or%20fleet%20records";}}

    private String publicView(String id,Model model)throws SQLException{ManagedVehicle record=repository.findById(id);Vehicle v=record==null?null:repository.findDomainById(id);if(v==null){model.addAttribute("errorMessage","Vehicle not found.");model.addAttribute("vehicles",repository.findAll());return"vehicle-list";}model.addAttribute("vehicle",v);model.addAttribute("vehicleRecord",record);model.addAttribute("driverFeeLkr",4500.0);model.addAttribute("lkrPerUsd",SearchController.LKR_PER_USD);return"vehicle-detail";}
    private void renderList(Model m)throws SQLException{List<ManagedVehicle>list=repository.findAll();m.addAttribute("vehicles",list);m.addAttribute("totalVehicles",list.size());m.addAttribute("availableVehicles",list.stream().filter(v->"AVAILABLE".equalsIgnoreCase(v.getStatus())).count());m.addAttribute("rentedVehicles",list.stream().filter(v->"RENTED".equalsIgnoreCase(v.getStatus())).count());m.addAttribute("maintenanceVehicles",list.stream().filter(v->"MAINTENANCE".equalsIgnoreCase(v.getStatus())).count());m.addAttribute("outVehicles",list.stream().filter(v->"OUT_OF_SERVICE".equalsIgnoreCase(v.getStatus())).count());}
    private void prepareForm(Model m,ManagedVehicle v)throws SQLException{if(v!=null)m.addAttribute("vehicle",v);m.addAttribute("branches",repository.branches());m.addAttribute("categories",repository.categories());}

    private static void validate(String id,String plate,String make,String model,int year,String trans,String fuel,int seats,int mileage,double rate,String image,String reg,String ins,String permit){
        if(!id.matches("[A-Z0-9-]{2,20}"))throw new IllegalArgumentException("Vehicle ID must use 2-20 letters, numbers or hyphens.");if(!plate.matches("[A-Z0-9-]{3,30}"))throw new IllegalArgumentException("Enter a valid registration/plate number.");if(make==null||make.isBlank()||make.length()>60||model==null||model.isBlank()||model.length()>80)throw new IllegalArgumentException("Make and model are required.");int maxYear=LocalDate.now().getYear()+1;if(year<1980||year>maxYear)throw new IllegalArgumentException("Vehicle year must be between 1980 and "+maxYear+".");if(!TRANSMISSIONS.contains(trans.toUpperCase()))throw new IllegalArgumentException("Invalid transmission.");if(!FUELS.contains(fuel.toUpperCase()))throw new IllegalArgumentException("Invalid fuel type.");if(seats<1||seats>20)throw new IllegalArgumentException("Seats must be between 1 and 20.");if(mileage<0)throw new IllegalArgumentException("Mileage cannot be negative.");if(rate<=0||rate>1_000_000)throw new IllegalArgumentException("Daily rental rate must be greater than zero.");validateUrl(image);validateDate(reg,"Registration expiry");validateDate(ins,"Insurance expiry");validateDate(permit,"Permit expiry");}
    private static void validateUrl(String url){if(url==null||url.isBlank())throw new IllegalArgumentException("Vehicle image path or URL is required.");String v=url.trim();if(v.length()>500)throw new IllegalArgumentException("Vehicle image path or URL must not exceed 500 characters.");if(v.startsWith("/images/vehicles/")&&v.matches("/images/vehicles/[A-Za-z0-9._-]+"))return;try{URI u=URI.create(v);if(!("http".equalsIgnoreCase(u.getScheme())||"https".equalsIgnoreCase(u.getScheme())))throw new Exception();}catch(Exception e){throw new IllegalArgumentException("Use a packaged /images/vehicles/... path or an http:// / https:// image URL.");}}
    private static void validateDate(String s,String label){if(s==null||s.isBlank())return;try{LocalDate.parse(s);}catch(Exception e){throw new IllegalArgumentException(label+" is not a valid date.");}}
    private static String normalizeType(String s){if("Van".equalsIgnoreCase(s))return"Van";if("Car".equalsIgnoreCase(s))return"Car";throw new IllegalArgumentException("Vehicle type must be Car or Van.");}
    private String formError(Model m,String error,String action,String id,String type,String plate,String make,String model,String year,String transmission,String fuel,String seats,String mileage,String rate,String category,String branch,String image,String reg,String ins,String permit){m.addAttribute("errorMessage",error);m.addAttribute("formAction",action);m.addAttribute("formVehicleId",id);m.addAttribute("formVehicleType",type);m.addAttribute("formPlateNo",plate);m.addAttribute("formMake",make);m.addAttribute("formModel",model);m.addAttribute("formYear",year);m.addAttribute("formTransmission",transmission);m.addAttribute("formFuel",fuel);m.addAttribute("formSeats",seats);m.addAttribute("formMileage",mileage);m.addAttribute("formRate",rate);m.addAttribute("formCategory",category);m.addAttribute("formBranch",branch);m.addAttribute("formImage",image);m.addAttribute("formReg",reg);m.addAttribute("formIns",ins);m.addAttribute("formPermit",permit);try{prepareForm(m,null);}catch(SQLException ignored){}return"vehicle-form";}
    static String requireManager(HttpSession s){User u=current(s);return u!=null&&("ADMIN".equalsIgnoreCase(u.getRole())||"VEHICLE".equalsIgnoreCase(u.getRole()))?null:"redirect:/dashboard";}private static User current(HttpSession s){Object x=s==null?null:s.getAttribute("loggedUser");return x instanceof User?(User)x:null;}private static boolean isUnique(SQLException e){return"23000".equals(e.getSQLState())||e.getErrorCode()==2627||e.getErrorCode()==2601;}
}
