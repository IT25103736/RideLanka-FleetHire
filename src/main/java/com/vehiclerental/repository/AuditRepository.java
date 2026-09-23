package com.vehiclerental.repository;

import com.vehiclerental.db.MssqlConnection;
import org.springframework.stereotype.Repository;

import java.sql.*;

@Repository
public class AuditRepository {
    private final MssqlConnection db;
    public AuditRepository(MssqlConnection db) { this.db=db; }
    public void log(String userId,String action,String targetId,String details) {
        String sql="insert into audit_logs(user_id,action,target_id,details,event_time) values(?,?,?,?,getdate())";
        try(Connection c=db.getConnection();PreparedStatement ps=c.prepareStatement(sql)){
            ps.setString(1,userId);ps.setString(2,action);ps.setString(3,targetId);ps.setString(4,details);ps.executeUpdate();
        }catch(SQLException ex){ System.err.println("[AuditRepository] "+ex.getMessage()); }
    }
}
