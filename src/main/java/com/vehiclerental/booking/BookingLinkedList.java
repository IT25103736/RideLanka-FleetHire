package com.vehiclerental.booking;

public class BookingLinkedList {
    private BookingNode head;

    public BookingLinkedList() {
        this.head = null;
    }

    public void addBooking(Booking booking) {
        BookingNode newNode = new BookingNode(booking);
        newNode.next = head;
        head = newNode;
    }

    public Booking findById(String bookingId) {
        BookingNode current = head;
        while (current != null) {
            if (current.booking.getBookingId().equals(bookingId)) {
                return current.booking;
            }
            current = current.next;
        }
        return null; // not found
    }

    public void printActiveBookings() {
        BookingNode current = head;
        boolean found = false;
        while (current != null) {
            if (current.booking.getStatus().equals("ACTIVE")) {
                System.out.println(current.booking.getBookingId()
                        + " | " + current.booking.getBookingType()
                        + " | " + current.booking.getStatus());
                found = true;
            }
            current = current.next;
        }
        if (!found) System.out.println("No active bookings found.");
    }

    public void printAllBookings() {
        BookingNode current = head;
        while (current != null) {
            System.out.println(current.booking.getBookingId()
                    + " | " + current.booking.getBookingType()
                    + " | " + current.booking.getStatus());
            current = current.next;
        }
    }
}
