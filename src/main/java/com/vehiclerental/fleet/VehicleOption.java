package com.vehiclerental.fleet;

public class VehicleOption {
    private final String vehicleId, plateNo, make, model, branchName, status;
    public VehicleOption(String vehicleId,String plateNo,String make,String model,String branchName,String status){this.vehicleId=vehicleId;this.plateNo=plateNo;this.make=make;this.model=model;this.branchName=branchName;this.status=status;}
    public String getVehicleId(){return vehicleId;} public String getPlateNo(){return plateNo;} public String getMake(){return make;} public String getModel(){return model;} public String getBranchName(){return branchName;} public String getStatus(){return status;}
}
