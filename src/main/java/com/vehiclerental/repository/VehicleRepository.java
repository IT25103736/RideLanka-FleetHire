package com.vehiclerental.repository;

import com.vehiclerental.db.MssqlConnection;
import com.vehiclerental.fleet.ManagedVehicle;
import org.springframework.stereotype.Repository;

import java.sql.*;
import java.time.LocalDate;
//import java.util.*;

import java.sql.Date;  // explicit
import java.time.LocalDate;
import java.util.ArrayList;
import java.util.List;
@Repository
public class VehicleRepository {
    private final MssqlConnection db;
    public VehicleRepository(MssqlConnection db){this.db=db;}

    public List<ManagedVehicle> findAll() throws SQLException {
        String sql = "select v.vehicle_id,v.plate_no,v.make,v.model,v.vehicle_year,v.transmission,v.fuel_type,"
                + "v.seats,v.mileage,v.daily_rate,v.status,v.category_id,c.category_name,v.branch_id,b.branch_name,"
                + "v.image_url,v.registration_expiry,v.insurance_expiry,v.permit_expiry,coalesce(v.vehicle_type,'Car') "
                + "from vehicles v join vehicle_categories c on c.category_id=v.category_id "
                + "join branches b on b.branch_id=v.branch_id order by v.vehicle_id";
        List<ManagedVehicle> out=new ArrayList<>();
        try(Connection c=db.getConnection();PreparedStatement ps=c.prepareStatement(sql);ResultSet rs=ps.executeQuery()){
            while(rs.next()) out.add(map(rs));
        }
        return out;
    }

    public ManagedVehicle findById(String id) throws SQLException {
        String sql = "select v.vehicle_id,v.plate_no,v.make,v.model,v.vehicle_year,v.transmission,v.fuel_type,"
                + "v.seats,v.mileage,v.daily_rate,v.status,v.category_id,c.category_name,v.branch_id,b.branch_name,"
                + "v.image_url,v.registration_expiry,v.insurance_expiry,v.permit_expiry,coalesce(v.vehicle_type,'Car') "
                + "from vehicles v join vehicle_categories c on c.category_id=v.category_id "
                + "join branches b on b.branch_id=v.branch_id where v.vehicle_id=?";
        try(Connection c=db.getConnection();PreparedStatement ps=c.prepareStatement(sql)){
            ps.setString(1,id); try(ResultSet rs=ps.executeQuery()){return rs.next()?map(rs):null;}
        }
    }

    public List<String[]> branches() throws SQLException {
        List<String[]> out=new ArrayList<>();
        try(Connection c=db.getConnection();PreparedStatement ps=c.prepareStatement("select branch_id,branch_name from branches where status='ACTIVE' order by branch_name");ResultSet rs=ps.executeQuery()){
            while(rs.next()) out.add(new String[]{rs.getString(1),rs.getString(2)});
        }
        return out;
    }
    public List<String[]> categories() throws SQLException {
        List<String[]> out=new ArrayList<>();
        try(Connection c=db.getConnection();PreparedStatement ps=c.prepareStatement("select category_id,category_name from vehicle_categories order by category_name");ResultSet rs=ps.executeQuery()){
            while(rs.next()) out.add(new String[]{rs.getString(1),rs.getString(2)});
        }
        return out;
    }

    public boolean exists(String id) throws SQLException {
        try(Connection c=db.getConnection();PreparedStatement ps=c.prepareStatement("select 1 from vehicles where vehicle_id=?")){
            ps.setString(1,id); try(ResultSet rs=ps.executeQuery()){return rs.next();}
        }
    }

    public boolean insert(String id,String plate,String make,String model,int year,String transmission,String fuel,int seats,int mileage,double rate,
                          String categoryId,String branchId,String imageUrl,String regExp,String insExp,String permitExp,String type) throws SQLException {
        String sql="insert into vehicles(vehicle_id,plate_no,make,model,vehicle_year,transmission,fuel_type,seats,mileage,daily_rate,status,category_id,branch_id,image_url,registration_expiry,insurance_expiry,permit_expiry,vehicle_type) values(?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?)";
        try(Connection c=db.getConnection();PreparedStatement ps=c.prepareStatement(sql)){
            bind(ps,id,plate,make,model,year,transmission,fuel,seats,mileage,rate,"AVAILABLE",categoryId,branchId,imageUrl,regExp,insExp,permitExp,type);
            return ps.executeUpdate()==1;
        }
    }

    public boolean update(String id,String plate,String make,String model,int year,String transmission,String fuel,int seats,int mileage,double rate,
                          String categoryId,String branchId,String imageUrl,String regExp,String insExp,String permitExp,String type) throws SQLException {
        String sql="update vehicles set plate_no=?,make=?,model=?,vehicle_year=?,transmission=?,fuel_type=?,seats=?,mileage=?,daily_rate=?,category_id=?,branch_id=?,image_url=?,registration_expiry=?,insurance_expiry=?,permit_expiry=?,vehicle_type=? where vehicle_id=?";
        try(Connection c=db.getConnection();PreparedStatement ps=c.prepareStatement(sql)){
            ps.setString(1,plate);ps.setString(2,make);ps.setString(3,model);ps.setInt(4,year);ps.setString(5,transmission);ps.setString(6,fuel);
            ps.setInt(7,seats);ps.setInt(8,mileage);ps.setDouble(9,rate);ps.setString(10,categoryId);ps.setString(11,branchId);ps.setString(12,imageUrl);
            dateOrNull(ps,13,regExp);dateOrNull(ps,14,insExp);dateOrNull(ps,15,permitExp);ps.setString(16,type);ps.setString(17,id);
            return ps.executeUpdate()==1;
        }
    }

    public boolean delete(String id) throws SQLException {
        try(Connection c=db.getConnection();PreparedStatement ps=c.prepareStatement("delete from vehicles where vehicle_id=?")){
            ps.setString(1,id); return ps.executeUpdate()==1;
        }
    }

    public boolean updateStatus(String id,String status) throws SQLException {
        try(Connection c=db.getConnection();PreparedStatement ps=c.prepareStatement("update vehicles set status=? where vehicle_id=?")){
            ps.setString(1,status);ps.setString(2,id);return ps.executeUpdate()==1;
        }
    }

    private static void bind(PreparedStatement ps,String id,String plate,String make,String model,int year,String transmission,String fuel,int seats,int mileage,double rate,
                             String status,String categoryId,String branchId,String imageUrl,String regExp,String insExp,String permitExp,String type)throws SQLException{
        ps.setString(1,id);ps.setString(2,plate);ps.setString(3,make);ps.setString(4,model);ps.setInt(5,year);ps.setString(6,transmission);ps.setString(7,fuel);
        ps.setInt(8,seats);ps.setInt(9,mileage);ps.setDouble(10,rate);ps.setString(11,status);ps.setString(12,categoryId);ps.setString(13,branchId);ps.setString(14,imageUrl);
        dateOrNull(ps,15,regExp);dateOrNull(ps,16,insExp);dateOrNull(ps,17,permitExp);ps.setString(18,type);
    }
    private static void dateOrNull(PreparedStatement ps,int i,String value)throws SQLException{
        if(value==null||value.isBlank())ps.setNull(i,Types.DATE);else ps.setDate(i,Date.valueOf(LocalDate.parse(value)));
    }
    private ManagedVehicle map(ResultSet rs)throws SQLException{
        Date reg=rs.getDate(17), ins=rs.getDate(18), permit=rs.getDate(19);
        return new ManagedVehicle(rs.getString(1),rs.getString(2),rs.getString(3),rs.getString(4),rs.getInt(5),rs.getString(6),rs.getString(7),
                rs.getInt(8),rs.getInt(9),rs.getDouble(10),rs.getString(11),rs.getString(12),rs.getString(13),rs.getString(14),rs.getString(15),
                rs.getString(16),reg==null?null:reg.toLocalDate(),ins==null?null:ins.toLocalDate(),permit==null?null:permit.toLocalDate(),rs.getString(20));
    }
}
