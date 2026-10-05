package com.vehiclerental.repository;

import com.vehiclerental.db.MssqlConnection;
import com.vehiclerental.model.Review;
import org.springframework.stereotype.Repository;

import java.sql.*;
import java.util.ArrayList;
import java.util.List;

@Repository
public class FeedbackRepository {
    private final MssqlConnection db;
    public FeedbackRepository(MssqlConnection db){this.db=db;}

    public List<Review> findVisible() throws SQLException {return query(" where f.status='VISIBLE'",null);}
    public List<Review> findAllForModeration() throws SQLException {return query(" where f.status<>'REMOVED'",null);}
    public Review findById(String id)throws SQLException{List<Review>x=query(" where f.feedback_id=?",id);return x.isEmpty()?null:x.get(0);}

    public String create(String userId,String vehicleId,String bookingId,int rating,String comment,String reviewType)throws SQLException{
        try(Connection c=db.getConnection()){
            c.setAutoCommit(false);c.setTransactionIsolation(Connection.TRANSACTION_SERIALIZABLE);
            try{
                String customerId=customerId(c,userId);if(customerId==null)throw new IllegalStateException("Customer profile not found.");
                if(!vehicleExists(c,vehicleId))throw new IllegalArgumentException("Vehicle not found.");
                String type="verified".equalsIgnoreCase(reviewType)?"VERIFIED":"PUBLIC";
                if("VERIFIED".equals(type)){
                    if(bookingId==null||bookingId.isBlank())throw new IllegalArgumentException("Verified renter feedback requires a booking ID.");
                    if(!completedOwnedBooking(c,userId,bookingId,vehicleId))throw new IllegalArgumentException("Verified feedback is allowed only for your completed booking for this vehicle.");
                    if(existingBookingFeedback(c,bookingId))throw new IllegalArgumentException("Feedback has already been submitted for this booking.");
                }else if(bookingId!=null&&!bookingId.isBlank()&&!ownedBooking(c,userId,bookingId,vehicleId)){
                    throw new IllegalArgumentException("The booking does not belong to this customer and vehicle.");
                }
                String id=nextId(c);
                try(PreparedStatement ps=c.prepareStatement("insert into dbo.feedback(feedback_id,customer_id,booking_id,vehicle_id,rating,comment,review_type,status) values(?,?,?,?,?,?,?,'VISIBLE')")){
                    ps.setString(1,id);ps.setString(2,customerId);if(bookingId==null||bookingId.isBlank())ps.setNull(3,Types.VARCHAR);else ps.setString(3,bookingId.trim());ps.setString(4,vehicleId.trim());ps.setInt(5,rating);ps.setString(6,comment.trim());ps.setString(7,type);ps.executeUpdate();
                }
                c.commit();return id;
            }catch(SQLException|RuntimeException ex){c.rollback();throw ex;}finally{c.setAutoCommit(true);}
        }
    }

    public boolean updateOwned(String feedbackId,String userId,int rating,String comment,String reviewType)throws SQLException{
        String type="verified".equalsIgnoreCase(reviewType)?"VERIFIED":"PUBLIC";
        String sql="update f set rating=?,comment=?,review_type=?,updated_at=sysdatetime() from dbo.feedback f join dbo.customers c on c.customer_id=f.customer_id where f.feedback_id=? and c.user_id=? and f.status<>'REMOVED'";
        try(Connection c=db.getConnection();PreparedStatement ps=c.prepareStatement(sql)){ps.setInt(1,rating);ps.setString(2,comment.trim());ps.setString(3,type);ps.setString(4,feedbackId);ps.setString(5,userId);return ps.executeUpdate()==1;}
    }

    public boolean setStatus(String feedbackId,String status)throws SQLException{
        String dbStatus=switch(status.toLowerCase()){case"flagged"->"FLAGGED";case"approved","visible"->"VISIBLE";case"hidden"->"HIDDEN";default->"REMOVED";};
        try(Connection c=db.getConnection();PreparedStatement ps=c.prepareStatement("update dbo.feedback set status=?,updated_at=sysdatetime() where feedback_id=?")){ps.setString(1,dbStatus);ps.setString(2,feedbackId);return ps.executeUpdate()==1;}
    }
    public boolean removeOwnedOrAdmin(String id,String userId,boolean admin)throws SQLException{
        String sql=admin?"update dbo.feedback set status='REMOVED',updated_at=sysdatetime() where feedback_id=?":"update f set status='REMOVED',updated_at=sysdatetime() from dbo.feedback f join dbo.customers c on c.customer_id=f.customer_id where f.feedback_id=? and c.user_id=?";
        try(Connection c=db.getConnection();PreparedStatement ps=c.prepareStatement(sql)){ps.setString(1,id);if(!admin)ps.setString(2,userId);return ps.executeUpdate()==1;}
    }

    public long countVisible()throws SQLException{try(Connection c=db.getConnection();PreparedStatement ps=c.prepareStatement("select count(*) from dbo.feedback where status='VISIBLE'");ResultSet rs=ps.executeQuery()){rs.next();return rs.getLong(1);}}

    private List<Review> query(String where,String param)throws SQLException{
        String sql="select f.feedback_id,f.vehicle_id,c.user_id,u.name,f.rating,f.comment,cast(f.created_at as date) review_date,f.status,f.review_type from dbo.feedback f join dbo.customers c on c.customer_id=f.customer_id join dbo.users u on u.user_id=c.user_id"+where+" order by f.created_at desc";
        List<Review> out=new ArrayList<>();try(Connection c=db.getConnection();PreparedStatement ps=c.prepareStatement(sql)){if(param!=null)ps.setString(1,param);try(ResultSet rs=ps.executeQuery()){while(rs.next()){String st=switch(rs.getString("status")){case"VISIBLE"->"approved";case"FLAGGED"->"flagged";case"HIDDEN"->"hidden";default->"removed";};out.add(new Review(rs.getString("feedback_id"),rs.getString("vehicle_id"),rs.getString("user_id"),rs.getString("name"),rs.getInt("rating"),rs.getString("comment"),rs.getDate("review_date").toLocalDate().toString(),st,rs.getString("review_type").toLowerCase()));}}}return out;
    }
    private String customerId(Connection c,String userId)throws SQLException{try(PreparedStatement ps=c.prepareStatement("select customer_id from dbo.customers where user_id=?")){ps.setString(1,userId);try(ResultSet rs=ps.executeQuery()){return rs.next()?rs.getString(1):null;}}}
    private boolean vehicleExists(Connection c,String id)throws SQLException{try(PreparedStatement ps=c.prepareStatement("select 1 from dbo.vehicles where vehicle_id=?")){ps.setString(1,id);try(ResultSet rs=ps.executeQuery()){return rs.next();}}}
    private boolean completedOwnedBooking(Connection c,String userId,String bid,String vid)throws SQLException{try(PreparedStatement ps=c.prepareStatement("select 1 from dbo.bookings b join dbo.customers cu on cu.customer_id=b.customer_id where cu.user_id=? and b.booking_id=? and b.vehicle_id=? and b.status='COMPLETED'")){ps.setString(1,userId);ps.setString(2,bid);ps.setString(3,vid);try(ResultSet rs=ps.executeQuery()){return rs.next();}}}
    private boolean ownedBooking(Connection c,String userId,String bid,String vid)throws SQLException{try(PreparedStatement ps=c.prepareStatement("select 1 from dbo.bookings b join dbo.customers cu on cu.customer_id=b.customer_id where cu.user_id=? and b.booking_id=? and b.vehicle_id=?")){ps.setString(1,userId);ps.setString(2,bid);ps.setString(3,vid);try(ResultSet rs=ps.executeQuery()){return rs.next();}}}
    private boolean existingBookingFeedback(Connection c,String bid)throws SQLException{try(PreparedStatement ps=c.prepareStatement("select 1 from dbo.feedback where booking_id=? and status<>'REMOVED'")){ps.setString(1,bid);try(ResultSet rs=ps.executeQuery()){return rs.next();}}}
    private String nextId(Connection c)throws SQLException{try(PreparedStatement ps=c.prepareStatement("select isnull(max(try_cast(substring(feedback_id,2,20) as bigint)),0)+1 from dbo.feedback with (updlock,holdlock)");ResultSet rs=ps.executeQuery()){rs.next();return String.format("F%05d",rs.getLong(1));}}
}
