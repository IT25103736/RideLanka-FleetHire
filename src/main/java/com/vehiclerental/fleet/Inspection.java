package com.vehiclerental.fleet;

import java.time.LocalDate;

public class Inspection {
    private final int id; private final String vehicleId; private final String maintenanceId; private final LocalDate inspectionDate; private final String result; private final String notes;
    public Inspection(int id,String vehicleId,String maintenanceId,LocalDate inspectionDate,String result,String notes){this.id=id;this.vehicleId=vehicleId;this.maintenanceId=maintenanceId;this.inspectionDate=inspectionDate;this.result=result;this.notes=notes;}
    public int getId(){return id;} public String getVehicleId(){return vehicleId;} public String getMaintenanceId(){return maintenanceId;} public LocalDate getInspectionDate(){return inspectionDate;} public String getResult(){return result;} public String getNotes(){return notes;}
}
