package com.vehiclerental.fleet;

import com.vehiclerental.repository.AuditRepository;
import com.vehiclerental.repository.MaintenanceRepository;
import org.springframework.stereotype.Service;

import java.sql.SQLException;
import java.time.LocalDate;
import java.util.Set;

@Service
public class FleetMaintenanceService {
    private static final Set<String> MAINTENANCE_TYPES = Set.of("SERVICE", "REPAIR", "INSPECTION", "OTHER");
    private static final Set<String> MAINTENANCE_STATUSES = Set.of("SCHEDULED", "IN_PROGRESS", "COMPLETED", "CANCELLED");
    private static final Set<String> VEHICLE_STATUSES = Set.of("AVAILABLE", "RESERVED", "RENTED", "MAINTENANCE", "OUT_OF_SERVICE");

    private final MaintenanceRepository maintenanceRepository;
    private final AuditRepository auditRepository;

    public FleetMaintenanceService(MaintenanceRepository maintenanceRepository, AuditRepository auditRepository) {
        this.maintenanceRepository = maintenanceRepository;
        this.auditRepository = auditRepository;
    }

    public String schedule(String vehicleId, String type, String description, String scheduledDate,
                           String technician, double cost, String actor) throws SQLException {
        vehicleId = requireText(vehicleId, "Vehicle", 20);
        type = requireText(type, "Maintenance type", 30).toUpperCase();
        description = requireText(description, "Description", 500);
        technician = requireText(technician, "Technician", 120);
        if (!MAINTENANCE_TYPES.contains(type)) throw new IllegalArgumentException("Invalid maintenance type.");
        if (cost < 0 || cost > 99_999_999.99) throw new IllegalArgumentException("Maintenance cost is invalid.");
        LocalDate date = parseDate(scheduledDate);
        if (date.isBefore(LocalDate.now())) throw new IllegalArgumentException("Maintenance date cannot be in the past.");

        String id = maintenanceRepository.schedule(vehicleId, type, description, date, technician, cost);
        auditRepository.log(actor, "CREATE_MAINTENANCE", id, "Vehicle " + vehicleId + " scheduled");
        return id;
    }

    public void setStatus(String maintenanceId, String status, String actor) throws SQLException {
        maintenanceId = requireText(maintenanceId, "Maintenance record", 20);
        String normalized = status == null ? "" : status.trim().toUpperCase();
        if (!MAINTENANCE_STATUSES.contains(normalized)) throw new IllegalArgumentException("Invalid maintenance status.");
        MaintenanceRecord r = maintenanceRepository.findById(maintenanceId);
        if (r == null) throw new IllegalArgumentException("Maintenance record not found.");
        LocalDate serviceDate = "COMPLETED".equals(normalized) ? LocalDate.now() : r.getServiceDate();
        maintenanceRepository.changeMaintenanceStatus(maintenanceId, normalized, serviceDate);
        auditRepository.log(actor, "UPDATE_MAINTENANCE_STATUS", maintenanceId, normalized);
    }

    public void recordInspection(String vehicleId, String maintenanceId, String result, String notes, String actor) throws SQLException {
        vehicleId = requireText(vehicleId, "Vehicle", 20);
        maintenanceId = maintenanceId == null ? null : maintenanceId.trim();
        if (maintenanceId != null && maintenanceId.length() > 20) throw new IllegalArgumentException("Maintenance ID is too long.");
        if (maintenanceId != null && maintenanceId.isBlank()) maintenanceId = null;
        String normalized = result == null ? "" : result.trim().toUpperCase();
        if (!Set.of("PASS", "FAIL").contains(normalized)) throw new IllegalArgumentException("Inspection result must be PASS or FAIL.");
        notes = notes == null ? "" : notes.trim();
        if (notes.length() > 500) throw new IllegalArgumentException("Inspection notes must not exceed 500 characters.");
        maintenanceRepository.recordInspection(new Inspection(0, vehicleId, maintenanceId, LocalDate.now(), normalized, notes));
        auditRepository.log(actor, "RECORD_INSPECTION", maintenanceId == null ? vehicleId : maintenanceId, vehicleId + " -> " + normalized);
    }

    public void deleteMaintenance(String maintenanceId, String actor) throws SQLException {
        maintenanceId = requireText(maintenanceId, "Maintenance record", 20);
        MaintenanceRecord r = maintenanceRepository.findById(maintenanceId);
        if (r == null) throw new IllegalArgumentException("Maintenance record not found.");
        if (!"CANCELLED".equalsIgnoreCase(r.getStatus())) {
            throw new IllegalStateException("Only CANCELLED maintenance records can be deleted. Cancel the job first.");
        }
        if (!maintenanceRepository.deleteMaintenance(maintenanceId)) {
            throw new IllegalArgumentException("Maintenance record not found or was already deleted.");
        }
        auditRepository.log(actor, "DELETE_MAINTENANCE", maintenanceId,
                "Permanently deleted cancelled maintenance for vehicle " + r.getVehicleId());
    }

    public void deleteInspection(int inspectionId, String actor) throws SQLException {
        if (inspectionId <= 0) throw new IllegalArgumentException("Invalid inspection record.");
        if (!maintenanceRepository.deleteInspection(inspectionId)) {
            throw new IllegalArgumentException("Inspection record not found or was already deleted.");
        }
        auditRepository.log(actor, "DELETE_INSPECTION", String.valueOf(inspectionId),
                "Inspection record permanently deleted");
    }

    public void setOperationalStatus(String vehicleId, String status, String actor) throws SQLException {
        vehicleId = requireText(vehicleId, "Vehicle", 20);
        String normalized = status == null ? "" : status.trim().toUpperCase();
        if (!VEHICLE_STATUSES.contains(normalized)) throw new IllegalArgumentException("Invalid operational status.");
        if (!maintenanceRepository.updateVehicleStatus(vehicleId, normalized)) throw new IllegalArgumentException("Vehicle not found.");
        auditRepository.log(actor, "UPDATE_VEHICLE_OPERATIONAL_STATUS", vehicleId, normalized);
    }

    private static LocalDate parseDate(String value) {
        try {
            return LocalDate.parse(value);
        } catch (Exception e) {
            throw new IllegalArgumentException("Invalid maintenance date.");
        }
    }

    private static String requireText(String value, String label, int maxLength) {
        if (value == null || value.isBlank()) throw new IllegalArgumentException(label + " is required.");
        String trimmed = value.trim();
        if (trimmed.length() > maxLength) throw new IllegalArgumentException(label + " is too long.");
        return trimmed;
    }
}
