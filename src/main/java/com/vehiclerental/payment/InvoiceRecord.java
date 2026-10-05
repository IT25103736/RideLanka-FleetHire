package com.vehiclerental.payment;

import java.time.LocalDate;

public class InvoiceRecord {

    private final String invoiceId;
    private final String bookingId;
    private final String customerId;
    private final String status;
    private final String promoCode;

    private final LocalDate invoiceDate;

    private final double subtotal;
    private final double discountAmount;
    private final double taxAmount;
    private final double additionalCharges;
    private final double totalAmount;

    public InvoiceRecord(
            String invoiceId,
            String bookingId,
            String customerId,
            LocalDate invoiceDate,
            double subtotal,
            double discountAmount,
            double taxAmount,
            double additionalCharges,
            double totalAmount,
            String status,
            String promoCode
    ) {
        this.invoiceId = invoiceId;
        this.bookingId = bookingId;
        this.customerId = customerId;
        this.invoiceDate = invoiceDate;
        this.subtotal = subtotal;
        this.discountAmount = discountAmount;
        this.taxAmount = taxAmount;
        this.additionalCharges = additionalCharges;
        this.totalAmount = totalAmount;
        this.status = status;
        this.promoCode = promoCode;
    }

    public String getInvoiceId() {
        return invoiceId;
    }

    public String getBookingId() {
        return bookingId;
    }

    public String getCustomerId() {
        return customerId;
    }

    public LocalDate getInvoiceDate() {
        return invoiceDate;
    }

    public double getSubtotal() {
        return subtotal;
    }

    public double getDiscountAmount() {
        return discountAmount;
    }

    public double getTaxAmount() {
        return taxAmount;
    }

    public double getAdditionalCharges() {
        return additionalCharges;
    }

    public double getTotalAmount() {
        return totalAmount;
    }

    public String getStatus() {
        return status;
    }

    public String getPromoCode() {
        return promoCode;
    }
}