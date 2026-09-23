package com.vehiclerental.model;

public class RegularUser extends User {
    public RegularUser(String id, String name, String email, String password, String createdDate) {
        this(id, name, email, password, "CUSTOMER", createdDate);
    }
    public RegularUser(String id, String name, String email, String password, String role, String createdDate) {
        super(id, name, email, password, role, createdDate);
    }
    @Override public String getDashboardUrl() {
        if ("MAINTENANCE".equalsIgnoreCase(getRole()) || "FLEET".equalsIgnoreCase(getRole())) {
            return "/fleet";
        }
        if ("VEHICLE".equalsIgnoreCase(getRole())) return "/vehicle?action=list";
        if ("FINANCE".equalsIgnoreCase(getRole()) || "BRANCH_STAFF".equalsIgnoreCase(getRole())) {
            return "/dashboard";
        }
        return "/search";
    }
}
