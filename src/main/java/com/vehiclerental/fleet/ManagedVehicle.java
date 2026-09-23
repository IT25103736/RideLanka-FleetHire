package com.vehiclerental.fleet;

import java.time.LocalDate;

/** MSSQL vehicle master record used only by Vehicle Management. */
public class ManagedVehicle {
    private String vehicleId, plateNo, make, model, transmission, fuelType;
    private int vehicleYear, seats, mileage;
    private double dailyRate;
    private String status, categoryId, categoryName, branchId, branchName, imageUrl, vehicleType;
    private LocalDate registrationExpiry, insuranceExpiry, permitExpiry;

    public ManagedVehicle(String vehicleId, String plateNo, String make, String model, int vehicleYear,
                          String transmission, String fuelType, int seats, int mileage, double dailyRate,
                          String status, String categoryId, String categoryName, String branchId, String branchName,
                          String imageUrl, LocalDate registrationExpiry, LocalDate insuranceExpiry,
                          LocalDate permitExpiry, String vehicleType) {
        this.vehicleId=vehicleId; this.plateNo=plateNo; this.make=make; this.model=model;
        this.vehicleYear=vehicleYear; this.transmission=transmission; this.fuelType=fuelType;
        this.seats=seats; this.mileage=mileage; this.dailyRate=dailyRate; this.status=status;
        this.categoryId=categoryId; this.categoryName=categoryName; this.branchId=branchId; this.branchName=branchName;
        this.imageUrl=imageUrl==null?"":imageUrl; this.registrationExpiry=registrationExpiry;
        this.insuranceExpiry=insuranceExpiry; this.permitExpiry=permitExpiry; this.vehicleType=vehicleType;
    }
    public String getVehicleId(){return vehicleId;} public String getPlateNo(){return plateNo;}
    public String getMake(){return make;} public String getModel(){return model;} public int getVehicleYear(){return vehicleYear;}
    public String getTransmission(){return transmission;} public String getFuelType(){return fuelType;}
    public int getSeats(){return seats;} public int getMileage(){return mileage;} public double getDailyRate(){return dailyRate;}
    public String getStatus(){return status;} public String getCategoryId(){return categoryId;} public String getCategoryName(){return categoryName;}
    public String getBranchId(){return branchId;} public String getBranchName(){return branchName;} public String getImageUrl(){return imageUrl;}
    public LocalDate getRegistrationExpiry(){return registrationExpiry;} public LocalDate getInsuranceExpiry(){return insuranceExpiry;}
    public LocalDate getPermitExpiry(){return permitExpiry;} public String getVehicleType(){return vehicleType;}
}
