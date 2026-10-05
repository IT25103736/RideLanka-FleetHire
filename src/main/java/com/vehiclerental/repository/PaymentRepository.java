package com.vehiclerental.repository;

import com.vehiclerental.db.MssqlConnection;
import com.vehiclerental.payment.InvoiceRecord;
import com.vehiclerental.payment.PaymentRecord;
import org.springframework.stereotype.Repository;

import java.sql.*;
import java.time.LocalDate;
import java.time.LocalDateTime;
import java.util.ArrayList;
import java.util.List;

@Repository
public class PaymentRepository {
    private final MssqlConnection db;
    public PaymentRepository(MssqlConnection db){this.db=db;}

    public List<PaymentRecord> findAll() throws SQLException { return query(null,null); }
    public List<PaymentRecord> findByUserId(String userId) throws SQLException {
        return query(" where c.user_id=?",userId);
    }
    public PaymentRecord findById(String id) throws SQLException {
        List<PaymentRecord> x=query(" where p.payment_id=?",id); return x.isEmpty()?null:x.get(0);
    }
    public PaymentRecord findLatestForBooking(String bookingId) throws SQLException {
        String sql=baseSelect()+" where p.booking_id=? order by p.payment_date desc,p.payment_id desc";
        try(Connection c=db.getConnection();PreparedStatement ps=c.prepareStatement(sql)){ps.setString(1,bookingId);try(ResultSet rs=ps.executeQuery()){return rs.next()?map(rs):null;}}
    }
    public boolean hasSuccess(String bookingId)throws SQLException{
        return hasState(bookingId, "SUCCESS");
    }
    public boolean hasPending(String bookingId)throws SQLException{
        return hasState(bookingId, "PENDING");
    }
    private boolean hasState(String bookingId,String state)throws SQLException{
        try(Connection c=db.getConnection();PreparedStatement ps=c.prepareStatement("select 1 from dbo.payments where booking_id=? and status=?")){ps.setString(1,bookingId);ps.setString(2,state);try(ResultSet rs=ps.executeQuery()){return rs.next();}}
    }

    public List<Promotion> listActivePromotions() throws SQLException {
        List<Promotion> out=new ArrayList<>();
        String sql="select promotion_id,promo_code,description,discount_type,discount_value,start_date,end_date,max_uses,uses_count,status from dbo.promotions where status='ACTIVE' and cast(getdate() as date) between start_date and end_date order by end_date,promo_code";
        try(Connection c=db.getConnection();PreparedStatement ps=c.prepareStatement(sql);ResultSet rs=ps.executeQuery()){while(rs.next())out.add(new Promotion(rs.getString(1),rs.getString(2),rs.getString(3),rs.getString(4),rs.getDouble(5),rs.getDate(6).toLocalDate(),rs.getDate(7).toLocalDate(),(Integer)rs.getObject(8),rs.getInt(9)));}
        return out;
    }

    public Promotion findActivePromotion(String code) throws SQLException {
        if(code==null||code.isBlank())return null;
        String sql="select promotion_id,promo_code,description,discount_type,discount_value,start_date,end_date,max_uses,uses_count,status from dbo.promotions " +
                "where upper(promo_code)=upper(?) and status='ACTIVE' and cast(getdate() as date) between start_date and end_date and (max_uses is null or uses_count<max_uses)";
        try(Connection c=db.getConnection();PreparedStatement ps=c.prepareStatement(sql)){ps.setString(1,code.trim());try(ResultSet rs=ps.executeQuery()){if(!rs.next())return null;return new Promotion(rs.getString(1),rs.getString(2),rs.getString(3),rs.getString(4),rs.getDouble(5),rs.getDate(6).toLocalDate(),rs.getDate(7).toLocalDate(),(Integer)rs.getObject(8),rs.getInt(9));}}
    }

    /**
     * Records a successful demo card/wallet payment, updates the booking and invoice,
     * and increments the promotion usage in one transaction. Amount is calculated by
     * the service from the current booking row; no browser amount is trusted.
     */
    public PaymentResult recordImmediate(String bookingId,String userId,String method,String reference,String gatewayResponse,
                                         Promotion promo,double expectedOriginalAmount,double discountAmount,double finalAmount)throws SQLException{
        try(Connection c=db.getConnection()){
            c.setAutoCommit(false);c.setTransactionIsolation(Connection.TRANSACTION_SERIALIZABLE);
            try{
                LockedBooking b=lockPayableBooking(c,bookingId,userId);
                if(b==null)throw new IllegalStateException("Booking is not payable by this customer.");
                if(Math.abs(b.totalAmount-expectedOriginalAmount)>0.01)throw new IllegalStateException("Booking total changed. Reload checkout.");
                if(hasPaymentState(c,bookingId,"SUCCESS"))throw new IllegalStateException("This booking has already been paid.");
                if(hasPaymentState(c,bookingId,"PENDING"))throw new IllegalStateException("A payment for this booking is already awaiting verification.");
                String paymentId=nextId(c,"payments","payment_id","PAY");
                try(PreparedStatement ps=c.prepareStatement("insert into dbo.payments(payment_id,booking_id,customer_id,amount,payment_method,transaction_reference,status,gateway_response) values(?,?,?,?,?,?,'SUCCESS',?)")){
                    ps.setString(1,paymentId);ps.setString(2,bookingId);ps.setString(3,b.customerId);ps.setDouble(4,finalAmount);ps.setString(5,method);ps.setString(6,reference);ps.setString(7,gatewayResponse);ps.executeUpdate();
                }
                try(PreparedStatement ps=c.prepareStatement("update dbo.bookings set promotion_id=?,discount_amount=?,total_amount=?,status='CONFIRMED' where booking_id=?")){
                    if(promo==null)ps.setNull(1,Types.VARCHAR);else ps.setString(1,promo.id);ps.setDouble(2,discountAmount);ps.setDouble(3,finalAmount);ps.setString(4,bookingId);ps.executeUpdate();
                }
                if(promo!=null){try(PreparedStatement ps=c.prepareStatement("update dbo.promotions set uses_count=uses_count+1 where promotion_id=?")){ps.setString(1,promo.id);ps.executeUpdate();}}
                String invoiceId=upsertPaidInvoice(c,b,discountAmount,finalAmount);
                c.commit();
                return new PaymentResult(paymentId,invoiceId,bookingId,b.customerId,b.customerName,b.vehicleId,b.startDate,b.endDate,finalAmount,"SUCCESS",method,reference);
            }catch(SQLException|RuntimeException ex){c.rollback();throw ex;}finally{c.setAutoCommit(true);}
        }
    }

    /** Bank transfer submission stays PENDING until Finance approves it. */
    public PaymentResult submitBankTransfer(String bookingId,String userId,String reference)throws SQLException{
        try(Connection c=db.getConnection()){
            c.setAutoCommit(false);c.setTransactionIsolation(Connection.TRANSACTION_SERIALIZABLE);
            try{
                LockedBooking b=lockPayableBooking(c,bookingId,userId);if(b==null)throw new IllegalStateException("Booking is not payable by this customer.");
                if(hasPaymentState(c,bookingId,"SUCCESS")||hasPaymentState(c,bookingId,"PENDING"))throw new IllegalStateException("A successful or pending payment already exists for this booking.");
                String id=nextId(c,"payments","payment_id","PAY");
                try(PreparedStatement ps=c.prepareStatement("insert into dbo.payments(payment_id,booking_id,customer_id,amount,payment_method,transaction_reference,status,gateway_response) values(?,?,?,?,? ,?,'PENDING','Awaiting finance verification')")){
                    ps.setString(1,id);ps.setString(2,bookingId);ps.setString(3,b.customerId);ps.setDouble(4,b.totalAmount);ps.setString(5,"BANK_TRANSFER");ps.setString(6,reference);ps.executeUpdate();
                }
                c.commit();return new PaymentResult(id,null,bookingId,b.customerId,b.customerName,b.vehicleId,b.startDate,b.endDate,b.totalAmount,"PENDING","BANK_TRANSFER",reference);
            }catch(SQLException|RuntimeException ex){c.rollback();throw ex;}finally{c.setAutoCommit(true);}
        }
    }

    public boolean reviewBankTransfer(String paymentId,boolean approve,String actor)throws SQLException{
        try(Connection c=db.getConnection()){
            c.setAutoCommit(false);
            try{
                String bookingId,customerId;double amount;String method,status;
                try(PreparedStatement ps=c.prepareStatement("select booking_id,customer_id,amount,payment_method,status from dbo.payments with (updlock,holdlock) where payment_id=?")){
                    ps.setString(1,paymentId);try(ResultSet rs=ps.executeQuery()){if(!rs.next()){c.rollback();return false;}bookingId=rs.getString(1);customerId=rs.getString(2);amount=rs.getDouble(3);method=rs.getString(4);status=rs.getString(5);}
                }
                if(!"BANK_TRANSFER".equals(method)||!"PENDING".equals(status)){c.rollback();return false;}
                String newStatus=approve?"SUCCESS":"FAILED";
                try(PreparedStatement ps=c.prepareStatement("update dbo.payments set status=?,gateway_response=? where payment_id=?")){ps.setString(1,newStatus);ps.setString(2,approve?"Approved by "+actor:"Rejected by "+actor);ps.setString(3,paymentId);ps.executeUpdate();}
                if(approve){
                    int bookingChanged;
                    try(PreparedStatement ps=c.prepareStatement("update dbo.bookings set status='CONFIRMED' where booking_id=? and status='PENDING'")){ps.setString(1,bookingId);bookingChanged=ps.executeUpdate();}
                    if(bookingChanged!=1)throw new IllegalStateException("The linked booking is no longer pending, so this transfer cannot be approved.");
                    LockedBooking b=lockedBookingById(c,bookingId);
                    if(b==null)throw new IllegalStateException("The linked booking could not be loaded.");
                    upsertPaidInvoice(c,b,b.discountAmount,amount);
                }
                c.commit();return true;
            }catch(SQLException|RuntimeException ex){c.rollback();throw ex;}finally{c.setAutoCommit(true);}
        }
    }

    public boolean voidPayment(String paymentId,String actor)throws SQLException{
        try(Connection c=db.getConnection();PreparedStatement ps=c.prepareStatement("update dbo.payments set status='VOID',gateway_response=coalesce(gateway_response,'')+' | Voided by '+? where payment_id=? and status in ('PENDING','FAILED')")){
            ps.setString(1,actor);ps.setString(2,paymentId);return ps.executeUpdate()==1;
        }
    }

    public InvoiceRecord findInvoiceByBooking(String bookingId) throws SQLException {

        String sql =
                "SELECT TOP 1 " +
                        "i.invoice_id, " +
                        "i.booking_id, " +
                        "i.customer_id, " +
                        "i.invoice_date, " +
                        "i.subtotal, " +
                        "i.discount_amount, " +
                        "i.tax_amount, " +
                        "i.additional_charges, " +
                        "i.total_amount, " +
                        "i.status, " +
                        "p.promo_code " +
                        "FROM dbo.invoices i " +
                        "INNER JOIN dbo.bookings b " +
                        "ON b.booking_id = i.booking_id " +
                        "LEFT JOIN dbo.promotions p " +
                        "ON p.promotion_id = b.promotion_id " +
                        "WHERE i.booking_id = ? " +
                        "ORDER BY i.invoice_date DESC, i.invoice_id DESC";

        try (
                Connection c = db.getConnection();
                PreparedStatement ps = c.prepareStatement(sql)
        ) {

            ps.setString(1, bookingId);

            try (ResultSet rs = ps.executeQuery()) {

                if (!rs.next()) {
                    return null;
                }

                Date invoiceDate = rs.getDate("invoice_date");

                return new InvoiceRecord(
                        rs.getString("invoice_id"),
                        rs.getString("booking_id"),
                        rs.getString("customer_id"),
                        invoiceDate == null ? null : invoiceDate.toLocalDate(),
                        rs.getDouble("subtotal"),
                        rs.getDouble("discount_amount"),
                        rs.getDouble("tax_amount"),
                        rs.getDouble("additional_charges"),
                        rs.getDouble("total_amount"),
                        rs.getString("status"),
                        rs.getString("promo_code")
                );
            }
        }
    }

    private List<PaymentRecord> query(String where,String param)throws SQLException{
        List<PaymentRecord> out=new ArrayList<>();String sql=baseSelect()+(where==null?"":where)+" order by p.payment_date desc,p.payment_id desc";
        try(Connection c=db.getConnection();PreparedStatement ps=c.prepareStatement(sql)){if(param!=null)ps.setString(1,param);try(ResultSet rs=ps.executeQuery()){while(rs.next())out.add(map(rs));}}return out;
    }
    private String baseSelect(){return "select p.payment_id,p.booking_id,p.customer_id,u.name customer_name,p.amount,p.payment_method,p.transaction_reference,p.status,p.payment_date,p.gateway_response from dbo.payments p join dbo.customers c on c.customer_id=p.customer_id join dbo.users u on u.user_id=c.user_id";}
    private PaymentRecord map(ResultSet rs)throws SQLException{Timestamp t=rs.getTimestamp("payment_date");return new PaymentRecord(rs.getString("payment_id"),rs.getString("booking_id"),rs.getString("customer_id"),rs.getString("customer_name"),rs.getDouble("amount"),rs.getString("payment_method"),rs.getString("transaction_reference"),rs.getString("status"),t==null?null:t.toLocalDateTime(),rs.getString("gateway_response"));}

    private LockedBooking lockPayableBooking(Connection c,String bookingId,String userId)throws SQLException{
        String sql="select b.booking_id,b.customer_id,u.name,b.vehicle_id,b.start_date,b.end_date,b.base_amount,b.discount_amount,b.driver_charge,b.total_amount,b.status from dbo.bookings b join dbo.customers cu on cu.customer_id=b.customer_id join dbo.users u on u.user_id=cu.user_id where b.booking_id=? and cu.user_id=?";
        try(PreparedStatement ps=c.prepareStatement(sql)){ps.setString(1,bookingId);ps.setString(2,userId);try(ResultSet rs=ps.executeQuery()){if(!rs.next())return null;String s=rs.getString("status");if(!("PENDING".equals(s)||"CONFIRMED".equals(s)))return null;return locked(rs);}}
    }
    private LockedBooking lockedBookingById(Connection c,String bookingId)throws SQLException{
        String sql="select b.booking_id,b.customer_id,u.name,b.vehicle_id,b.start_date,b.end_date,b.base_amount,b.discount_amount,b.driver_charge,b.total_amount,b.status from dbo.bookings b join dbo.customers cu on cu.customer_id=b.customer_id join dbo.users u on u.user_id=cu.user_id where b.booking_id=?";
        try(PreparedStatement ps=c.prepareStatement(sql)){ps.setString(1,bookingId);try(ResultSet rs=ps.executeQuery()){return rs.next()?locked(rs):null;}}
    }
    private LockedBooking locked(ResultSet rs)throws SQLException{return new LockedBooking(rs.getString("booking_id"),rs.getString("customer_id"),rs.getString("name"),rs.getString("vehicle_id"),rs.getDate("start_date").toLocalDate(),rs.getDate("end_date").toLocalDate(),rs.getDouble("base_amount"),rs.getDouble("discount_amount"),rs.getDouble("driver_charge"),rs.getDouble("total_amount"),rs.getString("status"));}
    private boolean hasPaymentState(Connection c,String bookingId,String state)throws SQLException{try(PreparedStatement ps=c.prepareStatement("select top 1 1 from dbo.payments with (updlock,holdlock) where booking_id=? and status=?")){ps.setString(1,bookingId);ps.setString(2,state);try(ResultSet rs=ps.executeQuery()){return rs.next();}}}
    private String upsertPaidInvoice(Connection c,LockedBooking b,double discount,double total)throws SQLException{
        String existing=null;try(PreparedStatement ps=c.prepareStatement("select top 1 invoice_id from dbo.invoices where booking_id=?")){ps.setString(1,b.bookingId);try(ResultSet rs=ps.executeQuery()){if(rs.next())existing=rs.getString(1);}}
        if(existing!=null){try(PreparedStatement ps=c.prepareStatement("update dbo.invoices set subtotal=?,discount_amount=?,tax_amount=0,additional_charges=0,total_amount=?,status='PAID' where invoice_id=?")){ps.setDouble(1,b.baseAmount+b.driverCharge);ps.setDouble(2,discount);ps.setDouble(3,total);ps.setString(4,existing);ps.executeUpdate();}return existing;}
        String id=nextId(c,"invoices","invoice_id","INV");try(PreparedStatement ps=c.prepareStatement("insert into dbo.invoices(invoice_id,booking_id,customer_id,subtotal,discount_amount,tax_amount,additional_charges,total_amount,status) values(?,?,?,?,?,0,0,?,'PAID')")){ps.setString(1,id);ps.setString(2,b.bookingId);ps.setString(3,b.customerId);ps.setDouble(4,b.baseAmount+b.driverCharge);ps.setDouble(5,discount);ps.setDouble(6,total);ps.executeUpdate();}return id;
    }
    private String nextId(Connection c,String table,String col,String prefix)throws SQLException{String sql="select isnull(max(try_cast(substring("+col+","+(prefix.length()+1)+",20) as bigint)),0)+1 from dbo."+table+" with (updlock,holdlock)";try(PreparedStatement ps=c.prepareStatement(sql);ResultSet rs=ps.executeQuery()){rs.next();return String.format(prefix+"%05d",rs.getLong(1));}}

    private static class LockedBooking{String bookingId,customerId,customerName,vehicleId,status;LocalDate startDate,endDate;double baseAmount,discountAmount,driverCharge,totalAmount;LockedBooking(String bookingId,String customerId,String customerName,String vehicleId,LocalDate start,LocalDate end,double base,double discount,double driver,double total,String status){this.bookingId=bookingId;this.customerId=customerId;this.customerName=customerName;this.vehicleId=vehicleId;this.startDate=start;this.endDate=end;this.baseAmount=base;this.discountAmount=discount;this.driverCharge=driver;this.totalAmount=total;this.status=status;}}
    public static class Promotion{final String id,code,description,type;final double value;final LocalDate start,end;final Integer maxUses;final int uses;Promotion(String id,String code,String description,String type,double value,LocalDate start,LocalDate end,Integer maxUses,int uses){this.id=id;this.code=code;this.description=description;this.type=type;this.value=value;this.start=start;this.end=end;this.maxUses=maxUses;this.uses=uses;}public String getCode(){return code;}public String getDescription(){return description;}public String getType(){return type;}public double getValue(){return value;}public LocalDate getEnd(){return end;}public String getDiscount(){return ("PERCENT".equalsIgnoreCase(type)?String.format("%.0f%%",value):"LKR "+String.format("%.0f",value));}public LocalDate getExpiryDate(){return end;}}
    public static class PaymentResult{public final String paymentId,invoiceId,bookingId,customerId,customerName,vehicleId,status,method,reference;public final LocalDate startDate,endDate;public final double amount;PaymentResult(String paymentId,String invoiceId,String bookingId,String customerId,String customerName,String vehicleId,LocalDate startDate,LocalDate endDate,double amount,String status,String method,String reference){this.paymentId=paymentId;this.invoiceId=invoiceId;this.bookingId=bookingId;this.customerId=customerId;this.customerName=customerName;this.vehicleId=vehicleId;this.startDate=startDate;this.endDate=endDate;this.amount=amount;this.status=status;this.method=method;this.reference=reference;}}
}
