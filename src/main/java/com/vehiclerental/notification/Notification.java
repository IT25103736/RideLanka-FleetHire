package com.vehiclerental.notification;

import java.time.LocalDateTime;

/**
 * In-app notification record persisted through NotificationRepository to MSSQL.
 * The type field classifies notifications for UI rendering and filtering.
 */
public class Notification {

    public static final String RECIPIENT_ADMIN_BROADCAST = "ADMIN";

    private String        id;
    private String        recipientId;       // user id, or "ADMIN" for broadcast
    private String        type;              // BOOKING_CONFIRMED, BOOKING_CANCELLED, NEW_BOOKING, NEW_REVIEW, NEW_USER, BOOKING_STATUS
    private String        title;
    private String        message;
    private boolean       read;
    private String        relatedBookingId;  // optional, "" when not applicable
    private LocalDateTime createdAt;

    public Notification(String id, String recipientId, String type, String title,
                        String message, boolean read, String relatedBookingId,
                        LocalDateTime createdAt) {
        this.id               = id;
        this.recipientId      = recipientId;
        this.type             = type;
        this.title            = title;
        this.message          = message;
        this.read             = read;
        this.relatedBookingId = relatedBookingId == null ? "" : relatedBookingId;
        this.createdAt        = createdAt == null ? LocalDateTime.now() : createdAt;
    }

    public String        getId()               { return id; }
    public String        getRecipientId()      { return recipientId; }
    public String        getType()             { return type; }
    public String        getTitle()            { return title; }
    public String        getMessage()          { return message; }
    public boolean       isRead()              { return read; }
    public String        getRelatedBookingId() { return relatedBookingId; }
    public LocalDateTime getCreatedAt()        { return createdAt; }

    public void setRead(boolean read) { this.read = read; }

}
