package com.vehiclerental.fleet;

import java.time.LocalDate;

public class MaintenanceRecord {
    private String maintenanceId, vehicleId, maintenanceType, description, technician, status;
    private LocalDate scheduledDate, serviceDate;
    private double cost;

    public MaintenanceRecord(String maintenanceId,String vehicleId,String maintenanceType,String description,
                             LocalDate scheduledDate,LocalDate serviceDate,double cost,String technician,String status){
        this.maintenanceId=maintenanceId;this.vehicleId=vehicleId;this.maintenanceType=maintenanceType;this.description=description;
        this.scheduledDate=scheduledDate;this.serviceDate=serviceDate;this.cost=cost;this.technician=technician;this.status=status;
    }
    public String getMaintenanceId(){return maintenanceId;} public String getVehicleId(){return vehicleId;}
    public String getMaintenanceType(){return maintenanceType;} public String getDescription(){return description;}
    public LocalDate getScheduledDate(){return scheduledDate;} public LocalDate getServiceDate(){return serviceDate;}
    public double getCost(){return cost;} public String getTechnician(){return technician;} public String getStatus(){return status;}
    public void setStatus(String status){this.status=status;}
}
