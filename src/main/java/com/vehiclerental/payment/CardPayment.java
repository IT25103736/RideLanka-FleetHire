package com.vehiclerental.payment;

public class CardPayment extends Payment
{

    private String cardNumber;
    private String cardHolderName;
    private String expiryDate;

    // Constructor
    public CardPayment(String paymentId, String customerName, double amount,
                       String date, String cardNumber, String cardHolderName, String expiryDate)
    {
        super(paymentId, customerName, amount, date);
        this.cardNumber = cardNumber;
        this.cardHolderName = cardHolderName;
        this.expiryDate = expiryDate;
    }

    // Getters
    public String getCardNumber()
    {
        return cardNumber;
    }
    public String getCardHolderName()
    {
        return cardHolderName;
    }
    public String getExpiryDate()
    {
        return expiryDate;
    }

    // Process the card payment
    @Override
    public String processPayment()
    {
        setStatus("Success");
        return "Card Payment processed successfully for " + getCustomerName();
    }

    // Save to file — bookingId is appended last for backward-compat with legacy 9-field rows.
    @Override //this is like providing own implementation of that abstract method
    public String toFileString()
    {
        return "CARD|" + super.toFileString() + "|" + cardNumber + "|" + cardHolderName + "|" + expiryDate
                + "|" + getBookingId();
    }
}