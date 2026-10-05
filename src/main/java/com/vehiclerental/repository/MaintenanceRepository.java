package com.vehiclerental.repository;

import com.vehiclerental.db.MssqlConnection;
import com.vehiclerental.fleet.Inspection;
import com.vehiclerental.fleet.MaintenanceRecord;
import com.vehiclerental.fleet.VehicleOption;
import org.springframework.stereotype.Repository;

import java.sql.*;
import java.time.LocalDate;
import java.util.ArrayList;
import java.util.List;

@Repository
public class MaintenanceRepository {
    private final MssqlConnection db;
    public MaintenanceRepository(MssqlConnection db){ this.db=db; }

    public List<MaintenanceRecord> findAll() throws SQLException {
        String sql="select maintenance_id,vehicle_id,maintenance_type,description,scheduled_date,service_date,cost,technician,status from dbo.maintenance_records order by scheduled_date desc,maintenance_id desc";
        List<MaintenanceRecord> out=new ArrayList<>();
        try(Connection c=db.getConnection();PreparedStatement ps=c.prepareStatement(sql);ResultSet rs=ps.executeQuery()){
            while(rs.next()) out.add(map(rs));
        }
        return out;
    }

    public MaintenanceRecord findById(String id)throws SQLException{
        String sql="select maintenance_id,vehicle_id,maintenance_type,description,scheduled_date,service_date,cost,technician,status from dbo.maintenance_records where maintenance_id=?";
        try(Connection c=db.getConnection();PreparedStatement ps=c.prepareStatement(sql)){
            ps.setString(1,id);try(ResultSet rs=ps.executeQuery()){return rs.next()?map(rs):null;}
        }
    }

    public String nextId()throws SQLException{try(Connection c=db.getConnection()){return nextId(c);}}

    public String schedule(String vehicleId,String type,String description,LocalDate scheduledDate,String technician,double cost)throws SQLException{
        try(Connection c=db.getConnection()){
            c.setAutoCommit(false);c.setTransactionIsolation(Connection.TRANSACTION_SERIALIZABLE);
            try{
                String currentStatus;
                try(PreparedStatement ps=c.prepareStatement("select status from dbo.vehicles with (updlock,holdlock) where vehicle_id=?")){
                    ps.setString(1,vehicleId);try(ResultSet rs=ps.executeQuery()){if(!rs.next())throw new SQLException("Vehicle not found.");currentStatus=rs.getString(1);}
                }
                if("OUT_OF_SERVICE".equalsIgnoreCase(currentStatus)) throw new IllegalStateException("Out-of-service vehicles cannot be scheduled until their operational status is reviewed.");
                try(PreparedStatement ps=c.prepareStatement("select top 1 1 from dbo.maintenance_records with (updlock,holdlock) where vehicle_id=? and status in ('SCHEDULED','IN_PROGRESS')")){
                    ps.setString(1,vehicleId);try(ResultSet rs=ps.executeQuery()){if(rs.next())throw new IllegalStateException("This vehicle already has an open maintenance record.");}
                }
                String id=nextId(c);
                try(PreparedStatement ps=c.prepareStatement("insert into dbo.maintenance_records(maintenance_id,vehicle_id,maintenance_type,description,scheduled_date,service_date,cost,technician,status) values(?,?,?,?,?,null,?,?, 'SCHEDULED')")){
                    ps.setString(1,id);ps.setString(2,vehicleId);ps.setString(3,type);ps.setString(4,description);ps.setDate(5,Date.valueOf(scheduledDate));ps.setDouble(6,cost);ps.setString(7,technician);ps.executeUpdate();
                }
                try(PreparedStatement ps=c.prepareStatement("update dbo.vehicles set status='MAINTENANCE' where vehicle_id=?")){ps.setString(1,vehicleId);ps.executeUpdate();}
                c.commit();return id;
            }catch(SQLException|RuntimeException ex){c.rollback();throw ex;}finally{c.setAutoCommit(true);}
        }
    }

    public void changeMaintenanceStatus(String maintenanceId,String newStatus,LocalDate serviceDate)throws SQLException{
        try(Connection c=db.getConnection()){
            c.setAutoCommit(false);c.setTransactionIsolation(Connection.TRANSACTION_SERIALIZABLE);
            try{
                String vehicleId,oldStatus;
                try(PreparedStatement ps=c.prepareStatement("select vehicle_id,status from dbo.maintenance_records with (updlock,holdlock) where maintenance_id=?")){
                    ps.setString(1,maintenanceId);try(ResultSet rs=ps.executeQuery()){if(!rs.next())throw new SQLException("Maintenance record not found.");vehicleId=rs.getString(1);oldStatus=rs.getString(2);}
                }
                if(!validTransition(oldStatus,newStatus)) throw new IllegalStateException("Invalid maintenance status transition: "+oldStatus+" -> "+newStatus);
                try(PreparedStatement ps=c.prepareStatement("update dbo.maintenance_records set status=?,service_date=? where maintenance_id=?")){
                    ps.setString(1,newStatus);if(serviceDate==null)ps.setNull(2,Types.DATE);else ps.setDate(2,Date.valueOf(serviceDate));ps.setString(3,maintenanceId);ps.executeUpdate();
                }
                boolean hasOtherOpen;
                try(PreparedStatement ps=c.prepareStatement("select top 1 1 from dbo.maintenance_records where vehicle_id=? and maintenance_id<>? and status in ('SCHEDULED','IN_PROGRESS')")){
                    ps.setString(1,vehicleId);ps.setString(2,maintenanceId);try(ResultSet rs=ps.executeQuery()){hasOtherOpen=rs.next();}
                }
                String vehicleStatus=("COMPLETED".equals(newStatus)||"CANCELLED".equals(newStatus))&&!hasOtherOpen?"AVAILABLE":"MAINTENANCE";
                try(PreparedStatement ps=c.prepareStatement("update dbo.vehicles set status=? where vehicle_id=? and status<>'OUT_OF_SERVICE'")){ps.setString(1,vehicleStatus);ps.setString(2,vehicleId);ps.executeUpdate();}
                c.commit();
            }catch(SQLException|RuntimeException ex){c.rollback();throw ex;}finally{c.setAutoCommit(true);}
        }
    }

    public void recordInspection(Inspection i)throws SQLException{
        try(Connection c=db.getConnection()){
            c.setAutoCommit(false);c.setTransactionIsolation(Connection.TRANSACTION_SERIALIZABLE);
            try{
                try(PreparedStatement exists=c.prepareStatement("select status from dbo.vehicles with (updlock,holdlock) where vehicle_id=?")){
                    exists.setString(1,i.getVehicleId());try(ResultSet rs=exists.executeQuery()){if(!rs.next())throw new SQLException("Vehicle not found.");}
                }
                if(i.getMaintenanceId()!=null&&!i.getMaintenanceId().isBlank()){
                    try(PreparedStatement ps=c.prepareStatement("select 1 from dbo.maintenance_records where maintenance_id=? and vehicle_id=?")){
                        ps.setString(1,i.getMaintenanceId());ps.setString(2,i.getVehicleId());try(ResultSet rs=ps.executeQuery()){if(!rs.next())throw new IllegalArgumentException("Maintenance record does not belong to this vehicle.");}
                    }
                }
                try(PreparedStatement ps=c.prepareStatement("insert into dbo.inspections(vehicle_id,maintenance_id,inspection_date,result,notes) values(?,?,?,?,?)")){
                    ps.setString(1,i.getVehicleId());if(i.getMaintenanceId()==null||i.getMaintenanceId().isBlank())ps.setNull(2,Types.VARCHAR);else ps.setString(2,i.getMaintenanceId());ps.setDate(3,Date.valueOf(i.getInspectionDate()));ps.setString(4,i.getResult());ps.setString(5,i.getNotes());ps.executeUpdate();
                }
                if("FAIL".equalsIgnoreCase(i.getResult())){
                    try(PreparedStatement ps=c.prepareStatement("update dbo.vehicles set status='OUT_OF_SERVICE' where vehicle_id=?")){ps.setString(1,i.getVehicleId());ps.executeUpdate();}
                }else{
                    boolean open;
                    try(PreparedStatement ps=c.prepareStatement("select top 1 1 from dbo.maintenance_records where vehicle_id=? and status in ('SCHEDULED','IN_PROGRESS')")){
                        ps.setString(1,i.getVehicleId());try(ResultSet rs=ps.executeQuery()){open=rs.next();}
                    }
                    if(!open){try(PreparedStatement ps=c.prepareStatement("update dbo.vehicles set status='AVAILABLE' where vehicle_id=? and status<>'OUT_OF_SERVICE'")){ps.setString(1,i.getVehicleId());ps.executeUpdate();}}
                }
                c.commit();
            }catch(SQLException|RuntimeException ex){c.rollback();throw ex;}finally{c.setAutoCommit(true);}
        }
    }

    public List<Inspection> findInspections()throws SQLException{
        List<Inspection> out=new ArrayList<>();
        try(Connection c=db.getConnection();PreparedStatement ps=c.prepareStatement("select inspection_id,vehicle_id,maintenance_id,inspection_date,result,notes from dbo.inspections order by inspection_date desc,inspection_id desc");ResultSet rs=ps.executeQuery()){
            while(rs.next())out.add(new Inspection(rs.getInt(1),rs.getString(2),rs.getString(3),rs.getDate(4).toLocalDate(),rs.getString(5),rs.getString(6)));
        }return out;
    }

    public boolean updateVehicleStatus(String vehicleId,String status)throws SQLException{
        try(Connection c=db.getConnection()){
            c.setAutoCommit(false);c.setTransactionIsolation(Connection.TRANSACTION_SERIALIZABLE);
            try{
                if("AVAILABLE".equals(status)){
                    try(PreparedStatement ps=c.prepareStatement("select top 1 1 from dbo.maintenance_records where vehicle_id=? and status in ('SCHEDULED','IN_PROGRESS')")){ps.setString(1,vehicleId);try(ResultSet rs=ps.executeQuery()){if(rs.next())throw new IllegalStateException("Vehicle has open maintenance and cannot be marked AVAILABLE.");}}
                }
                try(PreparedStatement ps=c.prepareStatement("update dbo.vehicles set status=? where vehicle_id=?")){ps.setString(1,status);ps.setString(2,vehicleId);boolean ok=ps.executeUpdate()==1;if(ok)c.commit();else c.rollback();return ok;}
            }catch(SQLException|RuntimeException ex){c.rollback();throw ex;}finally{c.setAutoCommit(true);}
        }
    }

    /**
     * Permanently deletes a cancelled maintenance record.
     * Historical IN_PROGRESS/COMPLETED work is never removed. If an inspection
     * still references the maintenance row, deletion is blocked so inspection
     * history is not silently detached or lost.
     */
    public boolean deleteMaintenance(String maintenanceId) throws SQLException {
        try (Connection c = db.getConnection()) {
            c.setAutoCommit(false);
            c.setTransactionIsolation(Connection.TRANSACTION_SERIALIZABLE);
            try {
                String status;
                try (PreparedStatement ps = c.prepareStatement(
                        "select status from dbo.maintenance_records with (updlock,holdlock) where maintenance_id=?")) {
                    ps.setString(1, maintenanceId);
                    try (ResultSet rs = ps.executeQuery()) {
                        if (!rs.next()) {
                            c.rollback();
                            return false;
                        }
                        status = rs.getString(1);
                    }
                }

                if (!"CANCELLED".equalsIgnoreCase(status)) {
                    throw new IllegalStateException("Only CANCELLED maintenance records can be deleted.");
                }

                try (PreparedStatement ps = c.prepareStatement(
                        "select top 1 1 from dbo.inspections with (holdlock) where maintenance_id=?")) {
                    ps.setString(1, maintenanceId);
                    try (ResultSet rs = ps.executeQuery()) {
                        if (rs.next()) {
                            throw new IllegalStateException("This cancelled maintenance record has linked inspections and cannot be deleted. Delete the linked inspection first.");
                        }
                    }
                }

                try (PreparedStatement ps = c.prepareStatement(
                        "delete from dbo.maintenance_records where maintenance_id=? and status='CANCELLED'")) {
                    ps.setString(1, maintenanceId);
                    boolean deleted = ps.executeUpdate() == 1;
                    if (deleted) c.commit(); else c.rollback();
                    return deleted;
                }
            } catch (SQLException | RuntimeException ex) {
                c.rollback();
                throw ex;
            } finally {
                c.setAutoCommit(true);
            }
        }
    }

    /** Permanently deletes an inspection record by its identity key. */
    public boolean deleteInspection(int inspectionId) throws SQLException {
        try (Connection c = db.getConnection();
             PreparedStatement ps = c.prepareStatement("delete from dbo.inspections where inspection_id=?")) {
            ps.setInt(1, inspectionId);
            return ps.executeUpdate() == 1;
        }
    }

    public List<VehicleOption> findVehicleOptions()throws SQLException{
        List<VehicleOption> out=new ArrayList<>();
        try(Connection c=db.getConnection();PreparedStatement ps=c.prepareStatement("select v.vehicle_id,v.plate_no,v.make,v.model,b.branch_name,v.status from dbo.vehicles v join dbo.branches b on b.branch_id=v.branch_id order by v.vehicle_id");ResultSet rs=ps.executeQuery()){
            while(rs.next())out.add(new VehicleOption(rs.getString(1),rs.getString(2),rs.getString(3),rs.getString(4),rs.getString(5),rs.getString(6)));
        }return out;
    }

    private String nextId(Connection c)throws SQLException{
        try(PreparedStatement ps=c.prepareStatement("select isnull(max(try_cast(substring(maintenance_id,3,20) as int)),0)+1 from dbo.maintenance_records with (updlock,holdlock)");ResultSet rs=ps.executeQuery()){rs.next();return String.format("MT%03d",rs.getInt(1));}
    }
    private boolean validTransition(String oldStatus,String newStatus){
        if(oldStatus==null||newStatus==null)return false;if(oldStatus.equals(newStatus))return true;
        return switch(oldStatus.toUpperCase()){
            case "SCHEDULED" -> newStatus.equals("IN_PROGRESS")||newStatus.equals("CANCELLED");
            case "IN_PROGRESS" -> newStatus.equals("COMPLETED")||newStatus.equals("CANCELLED");
            default -> false;
        };
    }
    private MaintenanceRecord map(ResultSet rs)throws SQLException{
        Date service=rs.getDate(6);return new MaintenanceRecord(rs.getString(1),rs.getString(2),rs.getString(3),rs.getString(4),rs.getDate(5).toLocalDate(),service==null?null:service.toLocalDate(),rs.getDouble(7),rs.getString(8),rs.getString(9));
    }
}
