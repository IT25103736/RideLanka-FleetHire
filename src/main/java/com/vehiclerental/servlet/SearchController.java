package com.vehiclerental.servlet;

import com.vehiclerental.fleet.ManagedVehicle;
import com.vehiclerental.repository.VehicleRepository;
import com.vehiclerental.util.VehicleSorter;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestParam;

import java.sql.SQLException;
import java.util.*;

@Controller
public class SearchController {
    public static final double LKR_PER_USD=300.0;
    private final VehicleRepository vehicles;
    public SearchController(VehicleRepository vehicles){this.vehicles=vehicles;}

    @GetMapping("/search")
    public String search(@RequestParam(defaultValue="")String vehicleType,@RequestParam(defaultValue="")String transmission,
                         @RequestParam(defaultValue="")String minPrice,@RequestParam(defaultValue="")String maxPrice,
                         @RequestParam(defaultValue="")String seats,@RequestParam(defaultValue="")String capacity,
                         @RequestParam(defaultValue="")String keyword,@RequestParam(defaultValue="")String location,
                         @RequestParam(defaultValue="")String withDriver,@RequestParam(defaultValue="")String fuelType,
                         @RequestParam(defaultValue="")String sort,Model model){
        List<ManagedVehicle> inventory;
        try{inventory=vehicles.findAll();}catch(SQLException e){inventory=Collections.emptyList();model.addAttribute("errorMessage","Vehicle catalogue is temporarily unavailable.");}
        model.addAttribute("availableCarSeats",distinctSeats(inventory,"Car"));
        model.addAttribute("availableVanCapacities",distinctSeats(inventory,"Van"));
        boolean hasFilters=!String.join("",vehicleType,transmission,minPrice,maxPrice,seats,capacity,keyword,location,withDriver,fuelType,sort).isBlank();
        if(!hasFilters)return "search";

        double min=parseDouble(minPrice,0),max=parseDouble(maxPrice,Double.MAX_VALUE);int seatFilter=parseInt(seats,0),vanSeats=parseInt(capacity,0);
        String type=vehicleType.trim();String fuel=fuelType.trim();
        if(type.matches("(?i)sedan|suv|hatchback|hybrid|electric")){if(type.equalsIgnoreCase("hybrid")||type.equalsIgnoreCase("electric"))fuel=type;type="Car";}
        if(type.isBlank()&&!fuel.isBlank())type="Car";
        List<VehicleCard> cards=new ArrayList<>();
        for(ManagedVehicle v:inventory){
            if(!type.isBlank()&&!type.equalsIgnoreCase(v.getVehicleType()))continue;
            if(!transmission.isBlank()&&!transmission.equalsIgnoreCase(v.getTransmission()))continue;
            if(!fuel.isBlank()&&!fuel.equalsIgnoreCase(v.getFuelType()))continue;
            if(!location.isBlank()&&!location.equalsIgnoreCase(v.getBranchName())&&!location.equalsIgnoreCase(branchCity(v.getBranchName())))continue;
            if(v.getDailyRate()<min||v.getDailyRate()>max)continue;
            if("Car".equalsIgnoreCase(v.getVehicleType())&&seatFilter>0&&v.getSeats()<seatFilter)continue;
            if("Van".equalsIgnoreCase(v.getVehicleType())&&vanSeats>0&&v.getSeats()<vanSeats)continue;
            if(!keyword.isBlank()){
                String hay=(v.getVehicleId()+" "+v.getPlateNo()+" "+v.getMake()+" "+v.getModel()+" "+v.getCategoryName()+" "+v.getBranchName()).toLowerCase();
                if(!hay.contains(keyword.trim().toLowerCase()))continue;
            }
            cards.add(new VehicleCard(v.getVehicleId(),v.getVehicleType(),v.getMake(),v.getModel(),v.getVehicleYear(),v.getDailyRate(),"AVAILABLE".equalsIgnoreCase(v.getStatus()),String.valueOf(v.getSeats()),v.getImageUrl(),v.getFuelType(),v.getTransmission()));
        }
        VehicleSorter.sort(cards,VehicleSorter.parseMode(sort));
        model.addAttribute("results",cards);model.addAttribute("count",cards.size());model.addAttribute("vehicleType",vehicleType);model.addAttribute("location",location);model.addAttribute("withDriver","true".equalsIgnoreCase(withDriver));model.addAttribute("sort",sort);model.addAttribute("lkrPerUsd",LKR_PER_USD);
        return "search-results";
    }
    private static String branchCity(String branch){return branch==null?"":branch.replaceAll("(?i)\\s*branch$","").trim();}
    private static List<Integer> distinctSeats(List<ManagedVehicle> list,String type){return list.stream().filter(v->type.equalsIgnoreCase(v.getVehicleType())).map(ManagedVehicle::getSeats).filter(x->x>0).distinct().sorted().toList();}
    private static int parseInt(String s,int d){try{return Integer.parseInt(s);}catch(Exception e){return d;}}
    private static double parseDouble(String s,double d){try{return Double.parseDouble(s);}catch(Exception e){return d;}}

    public static class VehicleCard{
        private final String id,type,brand,model,extraField,imageUrl,fuelType,transmission;private final int year;private final double pricePerDay;private final boolean available;
        public VehicleCard(String id,String type,String brand,String model,int year,double pricePerDay,boolean available,String extraField,String imageUrl,String fuelType,String transmission){this.id=id;this.type=type;this.brand=brand;this.model=model;this.year=year;this.pricePerDay=pricePerDay;this.available=available;this.extraField=extraField;this.imageUrl=imageUrl==null?"":imageUrl;this.fuelType=fuelType==null?"":fuelType;this.transmission=transmission==null?"":transmission;}
        public String getId(){return id;}public String getType(){return type;}public String getBrand(){return brand;}public String getModel(){return model;}public int getYear(){return year;}public double getPricePerDay(){return pricePerDay;}public boolean isAvailable(){return available;}public String getExtraField(){return extraField;}public String getImageUrl(){return imageUrl;}public String getFuelType(){return fuelType;}public String getTransmission(){return transmission;}public String getName(){return brand+" "+model;}public int getPriceUsd(){return (int)Math.round(pricePerDay/LKR_PER_USD);}
    }
}
