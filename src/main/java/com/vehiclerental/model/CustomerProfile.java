package com.vehiclerental.model;

import java.time.LocalDate;

/** Customer-only identity and verification details stored in dbo.customers. */
public class CustomerProfile {
    private String customerId;
    private String userId;
    private String drivingLicense;
    private String idDocumentNo;
    private String addressLine;
    private String city;
    private LocalDate dateOfBirth;
    private String verificationStatus;

    public String getCustomerId(){ return customerId; }
    public void setCustomerId(String customerId){ this.customerId=customerId; }
    public String getUserId(){ return userId; }
    public void setUserId(String userId){ this.userId=userId; }
    public String getDrivingLicense(){ return drivingLicense; }
    public void setDrivingLicense(String drivingLicense){ this.drivingLicense=drivingLicense; }
    public String getIdDocumentNo(){ return idDocumentNo; }
    public void setIdDocumentNo(String idDocumentNo){ this.idDocumentNo=idDocumentNo; }
    public String getAddressLine(){ return addressLine; }
    public void setAddressLine(String addressLine){ this.addressLine=addressLine; }
    public String getCity(){ return city; }
    public void setCity(String city){ this.city=city; }
    public LocalDate getDateOfBirth(){ return dateOfBirth; }
    public void setDateOfBirth(LocalDate dateOfBirth){ this.dateOfBirth=dateOfBirth; }
    public String getVerificationStatus(){ return verificationStatus; }
    public void setVerificationStatus(String verificationStatus){ this.verificationStatus=verificationStatus; }
}
