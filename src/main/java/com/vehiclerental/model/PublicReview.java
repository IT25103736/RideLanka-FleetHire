package com.vehiclerental.model;


public class PublicReview extends Review {


    private String nickname;

    public PublicReview() {
        super();
        setReviewType("public");
    }

    public PublicReview(String reviewId, String vehicleId, String userId,
                        String username, int rating, String comment,
                        String reviewDate, String status, String nickname) {
        super(reviewId, vehicleId, userId, username, rating,
              comment, reviewDate, status, "public");
        this.nickname = nickname;
    }


    @Override
    public String getDisplayLabel() {
        return "Public Review";
    }


    public String getDisplayInfo() {
        return "[Community Review] by " + (nickname != null ? nickname : getUsername())
               + " | " + getStarString();
    }


    public String getNickname() { return nickname; }
    public void   setNickname(String nickname) { this.nickname = nickname; }


    @Override
    public String toFileString() {
        return super.toFileString() + "|" + (nickname != null ? nickname : "");
    }
}
