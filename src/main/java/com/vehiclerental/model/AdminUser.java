package com.vehiclerental.model;

public class AdminUser extends User {
    public AdminUser(String id, String name, String email, String password, String createdDate) {
        this(id, name, email, password, "ADMIN", createdDate);
    }
    public AdminUser(String id, String name, String email, String password, String role, String createdDate) {
        super(id, name, email, password, role, createdDate);
    }
    @Override public String getDashboardUrl() { return "/admin/dashboard"; }
}
