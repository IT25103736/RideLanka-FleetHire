package com.vehiclerental.payment;

public abstract class Payment
{

    private String paymentId;
    private String customerName;
    private double amount;
    private String date;
    private String status;
    private String bookingId;   // link back to the booking this payment settles

    // Constructor
    public Payment(String paymentId, String customerName, double amount, String date)
    {
        this.paymentId = paymentId;
        this.customerName = customerName;
        this.amount = amount;
        this.date = date;
        this.status = "Pending";
        this.bookingId = "";
    }

    // Getters and Setters
    public String getPaymentId()
    {
        return paymentId;
    }
    public String getCustomerName()
    {
        return customerName;
    }
    public double getAmount()
    {
        return amount;
    }
    public String getDate()
    {
        return date;
    }
    public String getStatus()
    {
        return status;
    }
    public void setStatus(String status)
    {
        this.status = status;
    }
    public String getBookingId()
    {
        return bookingId == null ? "" : bookingId;
    }
    public void setBookingId(String bookingId)
    {
        this.bookingId = bookingId == null ? "" : bookingId;
    }

    // Abstract method - every payment type must implement this
    public abstract String processPayment();}