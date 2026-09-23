package com.vehiclerental.util;

import com.vehiclerental.model.AdminUser;
import com.vehiclerental.model.RegularUser;
import com.vehiclerental.model.User;

import java.io.*;
import java.util.ArrayList;
import java.util.List;

public class UserFileHandler {

    private static final String FILE_PATH = "data/users.txt";

    // CREATE — Register
    public static boolean registerUser(User user) throws IOException {
        if (findByEmail(user.getEmail()) != null) return false;

        try (BufferedWriter bw =
                     new BufferedWriter(new FileWriter(FILE_PATH, true))) {
            bw.write(user.toFileString());
            bw.newLine();
        }
        return true;
    }

    // READ — Get all users
    public static List<User> getAllUsers() throws IOException {
        List<User> users = new ArrayList<>();
        File f = new File(FILE_PATH);
        if (!f.exists()) return users;

        try (BufferedReader br =
                     new BufferedReader(new FileReader(FILE_PATH))) {
            String line;
            while ((line = br.readLine()) != null) {
                String trimmed = line.trim();
                if (trimmed.isEmpty() || trimmed.startsWith("#")) continue;
                User parsed = parseUser(trimmed);
                if (parsed != null) users.add(parsed);
            }
        }
        return users;
    }

    // READ — Find by Email
    public static User findByEmail(String email) throws IOException {
        for (User u : getAllUsers()) {
            if (u.getEmail().equalsIgnoreCase(email)) return u;
        }
        return null;
    }

    // READ — Find by ID
    public static User findById(String id) throws IOException {
        for (User u : getAllUsers()) {
            if (u.getId().equals(id)) return u;
        }
        return null;
    }

    // UPDATE — Update user
    public static boolean updateUser(User updatedUser) throws IOException {
        List<User> users = getAllUsers();
        boolean found = false;

        try (BufferedWriter bw =
                     new BufferedWriter(new FileWriter(FILE_PATH, false))) {
            for (User u : users) {
                if (u.getId().equals(updatedUser.getId())) {
                    bw.write(updatedUser.toFileString());
                    found = true;
                } else {
                    bw.write(u.toFileString());
                }
                bw.newLine();
            }
        }
        return found;
    }

    // DELETE — Delete by ID
    public static boolean deleteUser(String id) throws IOException {
        List<User> users = getAllUsers();
        boolean found = false;

        try (BufferedWriter bw =
                     new BufferedWriter(new FileWriter(FILE_PATH, false))) {
            for (User u : users) {
                if (u.getId().equals(id)) {
                    found = true;
                } else {
                    bw.write(u.toFileString());
                    bw.newLine();
                }
            }
        }
        return found;
    }

    // Generate new ID
    public static String generateId() throws IOException {
        List<User> users = getAllUsers();
        return "U" + String.format("%03d", users.size() + 1);
    }

    // Password Encoding
    public static String encodePassword(String raw) {
        return java.util.Base64.getEncoder()
                .encodeToString(raw.getBytes());
    }

    public static boolean checkPassword(String raw, String encoded) {
        return encodePassword(raw).equals(encoded);
    }

    // Parse line to User object — returns null on malformed rows rather than
    // throwing an IndexOutOfBoundsException that would crash the whole read.
    private static User parseUser(String line) {
        String[] parts = line.split("\\|");
        if (parts.length < 6) {
            System.err.println("[UserFileHandler] skipping malformed row (need 6 fields, got "
                    + parts.length + "): " + line);
            return null;
        }
        if ("ADMIN".equalsIgnoreCase(parts[4].trim())) {
            return new AdminUser(
                    parts[0], parts[1], parts[2], parts[3], parts[5]);
        } else {
            return new RegularUser(
                    parts[0], parts[1], parts[2], parts[3], parts[5]);
        }
    }
}