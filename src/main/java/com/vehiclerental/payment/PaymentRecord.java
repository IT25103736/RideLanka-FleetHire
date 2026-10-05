package com.vehiclerental.payment;

import java.time.LocalDateTime;

/** Read model for a persisted MSSQL payment. */
public class PaymentRecord {
    private final String paymentId, bookingId, customerId, customerName, paymentMethod,
            transactionReference, status, gatewayResponse;
    private final double amount;
    private final LocalDateTime paymentDate;

    public PaymentRecord(String paymentId, String bookingId, String customerId, String customerName,
                         double amount, String paymentMethod, String transactionReference,
                         String status, LocalDateTime paymentDate, String gatewayResponse) {
        this.paymentId=paymentId; this.bookingId=bookingId; this.customerId=customerId; this.customerName=customerName;
        this.amount=amount; this.paymentMethod=paymentMethod; this.transactionReference=transactionReference;
        this.status=status; this.paymentDate=paymentDate; this.gatewayResponse=gatewayResponse;
    }
    public String getPaymentId(){return paymentId;} public String getBookingId(){return bookingId;} public String getCustomerId(){return customerId;}
    public String getCustomerName(){return customerName;} public double getAmount(){return amount;} public String getPaymentMethod(){return paymentMethod;}
    public String getTransactionReference(){return transactionReference;} public String getStatus(){return status;} public LocalDateTime getPaymentDate(){return paymentDate;}
    public String getDate(){return paymentDate==null?"":paymentDate.toLocalDate().toString();} public String getGatewayResponse(){return gatewayResponse;}
}
