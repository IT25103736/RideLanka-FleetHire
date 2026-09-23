package com.vehiclerental.model;

public abstract class User {
    private String id;
    private String name;
    private String email;
    private String password;
    private String role;
    private String createdDate;
    private String status;
    private String phone;
    private String licenseNo;

    public User(String id, String name, String email, String password, String role, String createdDate) {
        this.id = id;
        this.name = name;
        this.email = email;
        this.password = password;
        this.role = role;
        this.createdDate = createdDate;
        this.status = "ACTIVE";
        this.phone = "";
        this.licenseNo = "";
    }

    public String getId() { return id; }
    public String getName() { return name; }
    public void setName(String name) { this.name = name; }
    public String getEmail() { return email; }
    public void setEmail(String email) { this.email = email; }
    public String getPassword() { return password; }
    public void setPassword(String password) { this.password = password; }
    public String getRole() { return role; }
    public void setRole(String role) { this.role = role; }
    public String getCreatedDate() { return createdDate; }
    public String getStatus() { return status; }
    public void setStatus(String status) { this.status = status; }
    public String getPhone() { return phone; }
    public void setPhone(String phone) { this.phone = phone == null ? "" : phone; }
    public String getLicenseNo() { return licenseNo; }
    public void setLicenseNo(String licenseNo) { this.licenseNo = licenseNo == null ? "" : licenseNo; }

    public abstract String getDashboardUrl();

    public String toFileString() {
        return id + "|" + name + "|" + email + "|" + password + "|" + role + "|" + createdDate;
    }
}
