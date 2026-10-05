package com.vehiclerental.model;


public class VerifiedRenterReview extends Review {


    private String bookingId;
    private String rentalDate;


    public VerifiedRenterReview() {
        super("verified");
    }

    public VerifiedRenterReview(String reviewId, String vehicleId, String userId,
                                String username, int rating, String comment,
                                String reviewDate, String status,
                                String bookingId, String rentalDate) {
        super(reviewId, vehicleId, userId, username, rating,
              comment, reviewDate, status, "verified");
        this.bookingId  = bookingId;
        this.rentalDate = rentalDate;
    }


    @Override
    public String getDisplayLabel() {
        return "Verified Renter Review";
    }



    public String getDisplayInfo() {
        return "[✔ Verified Renter] " + getUsername()
               + " (rented on " + rentalDate + ") | " + getStarString();
    }


    public String getBookingId()  { return bookingId; }
    public void   setBookingId(String bookingId)  { this.bookingId = bookingId; }

    public String getRentalDate() { return rentalDate; }
    public void   setRentalDate(String rentalDate) { this.rentalDate = rentalDate; }}
