package com.vehiclerental.fleet;

import com.vehiclerental.repository.AuditRepository;
import com.vehiclerental.repository.MaintenanceRepository;
import com.vehiclerental.model.Vehicle;
import com.vehiclerental.util.VehicleFileHandler;
import org.springframework.stereotype.Service;

import java.sql.SQLException;
import java.time.LocalDate;

@Service
public class FleetMaintenanceService {
    private final MaintenanceRepository maintenanceRepository;
    private final AuditRepository auditRepository;
    private final VehicleFileHandler legacyVehicles = new VehicleFileHandler();
    public FleetMaintenanceService(MaintenanceRepository maintenanceRepository,AuditRepository auditRepository){this.maintenanceRepository=maintenanceRepository;this.auditRepository=auditRepository;}

    public String schedule(String vehicleId,String type,String description,String scheduledDate,String technician,double cost,String actor)throws SQLException{
        String id=maintenanceRepository.nextId();
        MaintenanceRecord r=new MaintenanceRecord(id,vehicleId,type,description,LocalDate.parse(scheduledDate),null,cost,technician,"SCHEDULED");
        if(!maintenanceRepository.insert(r))throw new SQLException("Could not create maintenance record");
        maintenanceRepository.updateVehicleStatus(vehicleId,"MAINTENANCE");
        syncLegacyAvailability(vehicleId,false);
        auditRepository.log(actor,"CREATE_MAINTENANCE",id,"Vehicle "+vehicleId+" scheduled");
        return id;
    }
    public void setStatus(String maintenanceId,String status,String actor)throws SQLException{
        MaintenanceRecord r=maintenanceRepository.findById(maintenanceId);if(r==null)throw new SQLException("Maintenance record not found");
        LocalDate serviceDate="COMPLETED".equalsIgnoreCase(status)?LocalDate.now():r.getServiceDate();
        maintenanceRepository.updateStatus(maintenanceId,status,serviceDate);
        if("COMPLETED".equalsIgnoreCase(status)||"CANCELLED".equalsIgnoreCase(status)){maintenanceRepository.updateVehicleStatus(r.getVehicleId(),"AVAILABLE");syncLegacyAvailability(r.getVehicleId(),true);}
        else {maintenanceRepository.updateVehicleStatus(r.getVehicleId(),"MAINTENANCE");syncLegacyAvailability(r.getVehicleId(),false);}
        auditRepository.log(actor,"UPDATE_MAINTENANCE_STATUS",maintenanceId,status);
    }
    public void recordInspection(String vehicleId,String maintenanceId,String result,String notes,String actor)throws SQLException{
        maintenanceRepository.insertInspection(new Inspection(0,vehicleId,maintenanceId,LocalDate.now(),result,notes));
        boolean available="PASS".equalsIgnoreCase(result);
        maintenanceRepository.updateVehicleStatus(vehicleId,available?"AVAILABLE":"MAINTENANCE");
        syncLegacyAvailability(vehicleId,available);
        auditRepository.log(actor,"RECORD_INSPECTION",maintenanceId,vehicleId+" -> "+result);
    }
    public void setOperationalStatus(String vehicleId,String status,String actor)throws SQLException{
        String normalized=status.toUpperCase();
        if(!normalized.matches("AVAILABLE|RESERVED|RENTED|MAINTENANCE|OUT_OF_SERVICE"))throw new IllegalArgumentException("Invalid operational status.");
        if(!maintenanceRepository.updateVehicleStatus(vehicleId,normalized))throw new SQLException("Vehicle not found: "+vehicleId);
        syncLegacyAvailability(vehicleId,"AVAILABLE".equals(normalized));
        auditRepository.log(actor,"UPDATE_VEHICLE_OPERATIONAL_STATUS",vehicleId,normalized);
    }
    private void syncLegacyAvailability(String vehicleId,boolean available){
        try{Vehicle v=legacyVehicles.getVehicleById(vehicleId);if(v!=null){v.setAvailable(available);legacyVehicles.updateVehicle(v);}}catch(Exception ex){System.err.println("[FleetMaintenanceService] availability mirror failed: "+ex.getMessage());}
    }
}
