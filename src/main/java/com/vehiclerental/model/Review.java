package com.vehiclerental.model;


public class Review {


    private String reviewId;
    private String vehicleId;
    private String userId;
    private String username;
    private int rating;
    private String comment;
    private String reviewDate;
    private String status;
    private String reviewType;


    public Review() {}

    protected Review(String reviewType) {
        this.reviewType = reviewType;
    }

    public Review(String reviewId, String vehicleId, String userId,
                  String username, int rating, String comment,
                  String reviewDate, String status, String reviewType) {
        this.reviewId   = reviewId;
        this.vehicleId  = vehicleId;
        this.userId     = userId;
        this.username   = username;
        this.rating     = rating;
        this.comment    = comment;
        this.reviewDate = reviewDate;
        this.status     = status;
        this.reviewType = reviewType;
    }


    public String getDisplayLabel() {
        return "Review";
    }


    public String getStarString() {
        StringBuilder sb = new StringBuilder();
        for (int i = 0; i < rating; i++)   sb.append("★");
        for (int i = rating; i < 5; i++)   sb.append("☆");
        return sb.toString();
    }

    public String getReviewId()   { return reviewId; }
    public void   setReviewId(String reviewId)   { this.reviewId = reviewId; }

    public String getVehicleId()  { return vehicleId; }
    public void   setVehicleId(String vehicleId)  { this.vehicleId = vehicleId; }

    public String getUserId()     { return userId; }
    public void   setUserId(String userId)     { this.userId = userId; }

    public String getUsername()   { return username; }
    public void   setUsername(String username)   { this.username = username; }

    public int    getRating()     { return rating; }
    public void   setRating(int rating) {
        if (rating < 1 || rating > 5) throw new IllegalArgumentException("Rating must be 1–5");
        this.rating = rating;
    }

    public String getComment()    { return comment; }
    public void   setComment(String comment)    { this.comment = comment; }

    public String getReviewDate() { return reviewDate; }
    public void   setReviewDate(String reviewDate) { this.reviewDate = reviewDate; }

    public String getStatus()     { return status; }
    public void   setStatus(String status)     { this.status = status; }

    public String getReviewType() { return reviewType; }
    public void   setReviewType(String reviewType) { this.reviewType = reviewType; }

    @Override
    public String toString() {
        return "Review{id=" + reviewId + ", vehicle=" + vehicleId +
               ", user=" + username + ", rating=" + rating + ", status=" + status + "}";
    }
}
