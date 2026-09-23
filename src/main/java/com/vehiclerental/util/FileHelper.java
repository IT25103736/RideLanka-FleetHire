package com.vehiclerental.util;

import com.vehiclerental.model.PublicReview;
import com.vehiclerental.model.Review;
import com.vehiclerental.model.VerifiedRenterReview;
import java.io.*;
import java.util.ArrayList;
import java.util.List;

/**
 * Shared file I/O for vehicles + reviews.
 * All data files live in repo-root /data and use pipe '|' delimiter.
 */
public class FileHelper {

    private static final String VEHICLES_FILE = "data/vehicles.txt";
    private static final String REVIEWS_FILE  = "data/reviews.txt";

    // ════════════════════════════════════════════════════════════════════════
    //  VEHICLE METHODS  (C01 / C05)
    //  Line format: vehicleId|type|brand|model|year|pricePerDay|available|extraField
    // ════════════════════════════════════════════════════════════════════════

    public static List<String[]> readVehicles() {
        List<String[]> vehicles = new ArrayList<>();
        File f = new File(VEHICLES_FILE);
        if (!f.exists()) return vehicles;

        try (BufferedReader reader = new BufferedReader(new FileReader(f))) {
            String line;
            while ((line = reader.readLine()) != null) {
                String trimmed = line.trim();
                if (trimmed.isEmpty() || trimmed.startsWith("#")) continue;
                vehicles.add(trimmed.split("\\|"));
            }
        } catch (IOException e) {
            System.err.println("Error reading vehicles.txt: " + e.getMessage());
        }
        return vehicles;
    }

    public static String[] getVehicleById(String id) {
        for (String[] v : readVehicles()) {
            if (v.length > 0 && v[0].equalsIgnoreCase(id)) return v;
        }
        return null;
    }

    /** Search vehicles whose brand or model contains the given keyword. */
    public static List<String[]> searchByKeyword(String keyword) {
        String needle = keyword.toLowerCase();
        List<String[]> results = new ArrayList<>();
        for (String[] v : readVehicles()) {
            if (v.length < 4) continue;
            String label = (v[2] + " " + v[3]).toLowerCase();
            if (label.contains(needle)) results.add(v);
        }
        return results;
    }

    // ════════════════════════════════════════════════════════════════════════
    //  REVIEW METHODS  (C06)
    // ════════════════════════════════════════════════════════════════════════

    public static List<Review> readAllReviews() {
        List<Review> reviews = new ArrayList<>();
        File file = new File(REVIEWS_FILE);
        if (!file.exists()) return reviews;

        try (BufferedReader br = new BufferedReader(new FileReader(file))) {
            String line;
            while ((line = br.readLine()) != null) {
                line = line.trim();
                if (line.isEmpty() || line.startsWith("#")) continue;

                String[] p = line.split("\\|", -1);
                if (p.length < 9) continue;

                String type = p[8];

                if ("public".equalsIgnoreCase(type)) {
                    PublicReview pr = new PublicReview();
                    fillCommon(pr, p);
                    if (p.length > 9) pr.setNickname(p[9]);
                    reviews.add(pr);

                } else if ("verified".equalsIgnoreCase(type)) {
                    VerifiedRenterReview vr = new VerifiedRenterReview();
                    fillCommon(vr, p);
                    if (p.length > 9)  vr.setBookingId(p[9]);
                    if (p.length > 10) vr.setRentalDate(p[10]);
                    reviews.add(vr);
                }
            }
        } catch (IOException e) {
            e.printStackTrace();
        }
        return reviews;
    }

    private static void fillCommon(Review r, String[] p) {
        r.setReviewId(p[0]);
        r.setVehicleId(p[1]);
        r.setUserId(p[2]);
        r.setUsername(p[3]);
        try { r.setRating(Integer.parseInt(p[4].trim())); } catch (Exception e) { r.setRating(5); }
        r.setComment(p[5]);
        r.setReviewDate(p[6]);
        r.setStatus(p[7]);
        r.setReviewType(p[8]);
    }

    public static boolean writeReview(Review review) {
        try {
            File file = new File(REVIEWS_FILE);
            if (file.getParentFile() != null) file.getParentFile().mkdirs();
            try (BufferedWriter bw = new BufferedWriter(new FileWriter(file, true))) {
                bw.write(review.toFileString());
                bw.newLine();
            }
            return true;
        } catch (IOException e) {
            e.printStackTrace();
            return false;
        }
    }

    public static boolean updateAllReviews(List<Review> reviews) {
        try {
            File file = new File(REVIEWS_FILE);
            if (file.getParentFile() != null) file.getParentFile().mkdirs();
            try (BufferedWriter bw = new BufferedWriter(new FileWriter(file, false))) {
                for (Review r : reviews) {
                    bw.write(r.toFileString());
                    bw.newLine();
                }
            }
            return true;
        } catch (IOException e) {
            e.printStackTrace();
            return false;
        }
    }

    public static boolean deleteReview(String reviewId) {
        List<Review> all = readAllReviews();
        boolean removed = all.removeIf(r -> r.getReviewId().equals(reviewId));
        if (removed) updateAllReviews(all);
        return removed;
    }

    public static Review getReviewById(String reviewId) {
        return readAllReviews().stream()
                .filter(r -> r.getReviewId().equals(reviewId))
                .findFirst()
                .orElse(null);
    }

    public static List<Review> getReviewsByVehicle(String vehicleId) {
        List<Review> result = new ArrayList<>();
        for (Review r : readAllReviews()) {
            if (r.getVehicleId().equals(vehicleId) && "approved".equalsIgnoreCase(r.getStatus())) {
                result.add(r);
            }
        }
        return result;
    }

    public static String generateReviewId() {
        return "R" + String.format("%03d", readAllReviews().size() + 1);
    }

    public static boolean updateReviewStatus(String reviewId, String newStatus) {
        List<Review> all = readAllReviews();
        for (Review r : all) {
            if (r.getReviewId().equals(reviewId)) {
                r.setStatus(newStatus);
                return updateAllReviews(all);
            }
        }
        return false;
    }

    public static double getAverageRating(String vehicleId) {
        List<Review> reviews = getReviewsByVehicle(vehicleId);
        if (reviews.isEmpty()) return 0.0;
        int total = 0;
        for (Review r : reviews) total += r.getRating();
        return (double) total / reviews.size();
    }
}
