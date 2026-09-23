package com.vehiclerental.util;

import com.vehiclerental.model.Review;

import java.io.*;
import java.nio.file.*;
import java.util.ArrayList;
import java.util.List;

public class ReviewFileHandler {

    private static final String FILE_PATH = "data/reviews.txt";


    public static List<Review> readAllReviews() {
        List<Review> reviews = new ArrayList<>();
        try {
            File file = new File(FILE_PATH);
            if (!file.exists()) return reviews;

            List<String> lines = Files.readAllLines(file.toPath());
            for (String line : lines) {
                if (line.startsWith("#") || line.trim().isEmpty()) continue;
                String[] parts = line.split("\\|", -1);
                if (parts.length < 9) continue;
                try {
                    Review r = new Review(
                            parts[0], parts[1], parts[2], parts[3],
                            Integer.parseInt(parts[4].trim()),
                            parts[5], parts[6], parts[7], parts[8]
                    );
                    reviews.add(r);
                } catch (Exception e) {
                    // skip malformed lines
                }
            }
        } catch (IOException e) {
            e.printStackTrace();
        }
        return reviews;
    }


    public static boolean saveReview(Review review) {
        try {
            File file = new File(FILE_PATH);
            file.getParentFile().mkdirs();
            try (BufferedWriter bw = new BufferedWriter(new FileWriter(file, true))) {
                if (file.length() > 0) {
                    RandomAccessFile raf = new RandomAccessFile(file, "r");
                    raf.seek(file.length() - 1);
                    int lastByte = raf.read();
                    raf.close();
                    if (lastByte != '\n') bw.newLine();
                }
                bw.write(review.toFileString());
                bw.newLine();
            }
            return true;
        } catch (IOException e) {
            e.printStackTrace();
            return false;
        }
    }


    public static boolean updateStatus(String reviewId, String newStatus) {
        try {
            File file = new File(FILE_PATH);
            List<String> lines   = Files.readAllLines(file.toPath());
            List<String> updated = new ArrayList<>();
            boolean found = false;

            for (String line : lines) {
                if (line.startsWith("#") || line.trim().isEmpty()) {
                    updated.add(line);
                    continue;
                }
                String[] parts = line.split("\\|", -1);
                if (parts.length >= 9 && parts[0].equals(reviewId)) {
                    parts[7] = newStatus;
                    updated.add(String.join("|", parts));
                    found = true;
                } else {
                    updated.add(line);
                }
            }

            if (found) Files.write(file.toPath(), updated);
            return found;
        } catch (IOException e) {
            e.printStackTrace();
            return false;
        }
    }


    public static boolean updateReview(Review review) {
        try {
            File file = new File(FILE_PATH);
            List<String> lines   = Files.readAllLines(file.toPath());
            List<String> updated = new ArrayList<>();
            boolean found = false;

            for (String line : lines) {
                if (line.startsWith("#") || line.trim().isEmpty()) {
                    updated.add(line);
                    continue;
                }
                String[] parts = line.split("\\|", -1);
                if (parts.length >= 9 && parts[0].equals(review.getReviewId())) {
                    // rewrite the whole line from the updated review object
                    updated.add(review.toFileString());
                    found = true;
                } else {
                    updated.add(line);
                }
            }

            if (found) Files.write(file.toPath(), updated);
            return found;
        } catch (IOException e) {
            e.printStackTrace();
            return false;
        }
    }


    public static boolean deleteReview(String reviewId) {
        try {
            File file = new File(FILE_PATH);
            List<String> lines   = Files.readAllLines(file.toPath());
            List<String> updated = new ArrayList<>();
            boolean found = false;

            for (String line : lines) {
                if (line.startsWith("#") || line.trim().isEmpty()) {
                    updated.add(line);
                    continue;
                }
                String[] parts = line.split("\\|", -1);
                if (parts.length >= 1 && parts[0].equals(reviewId)) {
                    found = true; // skip = delete
                } else {
                    updated.add(line);
                }
            }

            if (found) Files.write(file.toPath(), updated);
            return found;
        } catch (IOException e) {
            e.printStackTrace();
            return false;
        }
    }


    public static Review findById(String reviewId) {
        return readAllReviews().stream()
                .filter(r -> r.getReviewId().equals(reviewId))
                .findFirst()
                .orElse(null);
    }


    public static String generateId() {
        List<Review> existing = readAllReviews();
        return "R" + String.format("%03d", existing.size() + 1);
    }


    public static List<Review> filterByStatus(List<Review> reviews, String status) {
        List<Review> result = new ArrayList<>();
        for (Review r : reviews) {
            if (status.equalsIgnoreCase(r.getStatus())) result.add(r);
        }
        return result;
    }
}