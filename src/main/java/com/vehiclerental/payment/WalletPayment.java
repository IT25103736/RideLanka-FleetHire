package com.vehiclerental.payment;

public class WalletPayment extends Payment {

    private String walletType;
    private String walletNumber;
    private double walletBalance;

    // Constructor
    public WalletPayment(String paymentId, String customerName, double amount,
                         String date, String walletType, String walletNumber, double walletBalance) {
        super(paymentId, customerName, amount, date);
        this.walletType = walletType;
        this.walletNumber = walletNumber;
        this.walletBalance = walletBalance;
    }

    // Getters
    public String getWalletType() { return walletType; }
    public String getWalletNumber() { return walletNumber; }
    public double getWalletBalance() { return walletBalance; }

    // Process the wallet payment
    @Override
    public String processPayment() {
        if (walletBalance >= getAmount()) {
            walletBalance -= getAmount();
            setStatus("Success");
            return "Wallet Payment processed successfully for " + getCustomerName();
        } else {
            setStatus("Failed");
            return "Wallet Payment failed! Insufficient balance!";
        }
    }

    // Save to file — bookingId is appended last for backward-compat with legacy 9-field rows.
    @Override
    public String toFileString() {
        return "WALLET|" + super.toFileString() + "|" + walletType + "|" + walletNumber + "|" + walletBalance
                + "|" + getBookingId();
    }
}