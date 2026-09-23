package com.vehiclerental.repository;

import com.vehiclerental.db.MssqlConnection;
import com.vehiclerental.fleet.Inspection;
import com.vehiclerental.fleet.VehicleOption;
import com.vehiclerental.fleet.MaintenanceRecord;
import org.springframework.stereotype.Repository;

import java.sql.*;
import java.time.LocalDate;
//import java.util.*;

import java.sql.Date;  // explicit
import java.time.LocalDate;
import java.util.ArrayList;
import java.util.List;
@Repository
public class MaintenanceRepository {
    private final MssqlConnection db;
    public MaintenanceRepository(MssqlConnection db){this.db=db;}

    public List<MaintenanceRecord> findAll() throws SQLException{
        String sql="select maintenance_id,vehicle_id,maintenance_type,description,scheduled_date,service_date,cost,technician,status from maintenance_records order by scheduled_date desc, maintenance_id desc";
        List<MaintenanceRecord> out=new ArrayList<>();
        try(Connection c=db.getConnection();PreparedStatement ps=c.prepareStatement(sql);ResultSet rs=ps.executeQuery()){
            while(rs.next()) out.add(map(rs));
        } return out;
    }
    public MaintenanceRecord findById(String id)throws SQLException{
        String sql="select maintenance_id,vehicle_id,maintenance_type,description,scheduled_date,service_date,cost,technician,status from maintenance_records where maintenance_id=?";
        try(Connection c=db.getConnection();PreparedStatement ps=c.prepareStatement(sql)){ps.setString(1,id);try(ResultSet rs=ps.executeQuery()){return rs.next()?map(rs):null;}}
    }
    public String nextId()throws SQLException{
        try(Connection c=db.getConnection();PreparedStatement ps=c.prepareStatement("select isnull(max(try_cast(substring(maintenance_id,3,20) as int)),0)+1 from maintenance_records");ResultSet rs=ps.executeQuery()){rs.next();return String.format("MT%03d",rs.getInt(1));}
    }
    public boolean insert(MaintenanceRecord r)throws SQLException{
        String sql="insert into maintenance_records(maintenance_id,vehicle_id,maintenance_type,description,scheduled_date,service_date,cost,technician,status) values(?,?,?,?,?,?,?,?,?)";
        try(Connection c=db.getConnection();PreparedStatement ps=c.prepareStatement(sql)){
            ps.setString(1,r.getMaintenanceId());ps.setString(2,r.getVehicleId());ps.setString(3,r.getMaintenanceType());ps.setString(4,r.getDescription());
            ps.setDate(5,Date.valueOf(r.getScheduledDate())); if(r.getServiceDate()!=null) ps.setDate(6,Date.valueOf(r.getServiceDate())); else ps.setNull(6,Types.DATE);
            ps.setDouble(7,r.getCost());ps.setString(8,r.getTechnician());ps.setString(9,r.getStatus());return ps.executeUpdate()==1;
        }
    }
    public boolean updateStatus(String id,String status,LocalDate serviceDate)throws SQLException{
        String sql="update maintenance_records set status=?, service_date=? where maintenance_id=?";
        try(Connection c=db.getConnection();PreparedStatement ps=c.prepareStatement(sql)){ps.setString(1,status);if(serviceDate!=null)ps.setDate(2,Date.valueOf(serviceDate));else ps.setNull(2,Types.DATE);ps.setString(3,id);return ps.executeUpdate()==1;}
    }
    public boolean insertInspection(Inspection i)throws SQLException{
        String sql="insert into inspections(vehicle_id,maintenance_id,inspection_date,result,notes) values(?,?,?,?,?)";
        try(Connection c=db.getConnection();PreparedStatement ps=c.prepareStatement(sql)){ps.setString(1,i.getVehicleId());if(i.getMaintenanceId()==null||i.getMaintenanceId().isBlank())ps.setNull(2,Types.VARCHAR);else ps.setString(2,i.getMaintenanceId());ps.setDate(3,Date.valueOf(i.getInspectionDate()));ps.setString(4,i.getResult());ps.setString(5,i.getNotes());return ps.executeUpdate()==1;}
    }
    public List<Inspection> findInspections()throws SQLException{
        String sql="select inspection_id,vehicle_id,maintenance_id,inspection_date,result,notes from inspections order by inspection_date desc,inspection_id desc";
        List<Inspection> out=new ArrayList<>();
        try(Connection c=db.getConnection();PreparedStatement ps=c.prepareStatement(sql);ResultSet rs=ps.executeQuery()){while(rs.next())out.add(new Inspection(rs.getInt(1),rs.getString(2),rs.getString(3),rs.getDate(4).toLocalDate(),rs.getString(5),rs.getString(6)));}return out;
    }
    public boolean updateVehicleStatus(String vehicleId,String status) throws SQLException {
        try(Connection c=db.getConnection();PreparedStatement ps=c.prepareStatement("update vehicles set status=? where vehicle_id=?")){
            ps.setString(1,status);ps.setString(2,vehicleId);return ps.executeUpdate()==1;
        }
    }

    public List<VehicleOption> findVehicleOptions() throws SQLException {
        String sql="select v.vehicle_id,v.plate_no,v.make,v.model,b.branch_name,v.status from vehicles v join branches b on b.branch_id=v.branch_id order by v.vehicle_id";
        List<VehicleOption> out=new ArrayList<>();
        try(Connection c=db.getConnection();PreparedStatement ps=c.prepareStatement(sql);ResultSet rs=ps.executeQuery()){while(rs.next())out.add(new VehicleOption(rs.getString(1),rs.getString(2),rs.getString(3),rs.getString(4),rs.getString(5),rs.getString(6)));}
        return out;
    }

    private MaintenanceRecord map(ResultSet rs)throws SQLException{
        Date service=rs.getDate(6);return new MaintenanceRecord(rs.getString(1),rs.getString(2),rs.getString(3),rs.getString(4),rs.getDate(5).toLocalDate(),service==null?null:service.toLocalDate(),rs.getDouble(7),rs.getString(8),rs.getString(9));
    }
}
