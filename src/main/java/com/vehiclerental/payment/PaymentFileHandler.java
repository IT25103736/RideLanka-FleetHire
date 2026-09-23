package com.vehiclerental.payment;

import java.io.*;
import java.time.LocalDate;
import java.util.ArrayList;
import java.util.List;

// This class handles all the file read and write operations for the Payment component.
// It acts as our database connection for payments.txt and invoices.txt.
public class PaymentFileHandler {

    private static final String PAYMENTS_FILE = "data/payments.txt";
    private static final String INVOICES_FILE = "data/invoices.txt";

    // Adds a new payment record to the bottom of the text file.
    public static boolean savePayment(Payment payment) {
        File file = new File(PAYMENTS_FILE);
        if (file.getParentFile() != null) file.getParentFile().mkdirs();

        // Using FileWriter with 'true' to append data instead of overwriting the file.
        try (BufferedWriter bw = new BufferedWriter(new FileWriter(file, true))) {
            bw.write(payment.toFileString());
            bw.newLine();
            return true;
        } catch (IOException e) {
            System.err.println("Error saving payment: " + e.getMessage());
            return false;
        }
    }

    // Reads every line from the text file so we can display it in the history table.
    public static List<String> readAllPayments() {
        List<String> payments = new ArrayList<>();
        File file = new File(PAYMENTS_FILE);
        if (!file.exists()) return payments;

        try (BufferedReader br = new BufferedReader(new FileReader(file))) {
            String line;
            while ((line = br.readLine()) != null) {
                String trimmed = line.trim();
                // Skip empty lines or commented lines
                if (trimmed.isEmpty() || trimmed.startsWith("#")) continue;
                payments.add(trimmed);
            }
        } catch (IOException e) {
            System.err.println("Error reading payments: " + e.getMessage());
        }
        return payments;
    }

    // Anchor date for trailing-window charts (weekly/monthly revenue). Returns the latest
    // payment date in the file, or today if the file has no parseable dates. Anchoring the
    // window to the data — instead of LocalDate.now() — keeps charts populated regardless
    // of the host clock, which matters because seeded payment rows can be forward-dated.
    public static LocalDate latestPaymentDate(List<String> payments) {
        LocalDate max = null;
        for (String line : payments) {
            String[] parts = line.split("\\|");
            if (parts.length < 5) continue;
            try {
                LocalDate d = LocalDate.parse(parts[4].trim());
                if (max == null || d.isAfter(max)) max = d;
            } catch (Exception ignored) {}
        }
        return max != null ? max : LocalDate.now();
    }

    // Saves the generated invoice details to the invoices text file.
    public static boolean saveInvoice(String invoiceContent) {
        File file = new File(INVOICES_FILE);
        if (file.getParentFile() != null) file.getParentFile().mkdirs();

        try (BufferedWriter bw = new BufferedWriter(new FileWriter(file, true))) {
            bw.write(invoiceContent);
            bw.newLine();
            bw.write("------------------------");
            bw.newLine();
            return true;
        } catch (IOException e) {
            System.err.println("Error saving invoice: " + e.getMessage());
            return false;
        }
    }

    public static List<String> readAllInvoices() {
        List<String> invoices = new ArrayList<>();
        File file = new File(INVOICES_FILE);
        if (!file.exists()) return invoices;

        try (BufferedReader br = new BufferedReader(new FileReader(file))) {
            String line;
            while ((line = br.readLine()) != null) invoices.add(line);
        } catch (IOException e) {
            System.err.println("Error reading invoices: " + e.getMessage());
        }
        return invoices;
    }

    // Deletes a specific payment by matching its ID.
    // It reads all payments, clears the file, and writes back everything except the deleted one.
    public static boolean deletePayment(String paymentId) {
        if (paymentId == null || paymentId.isBlank()) return false;
        List<String> allPayments = readAllPayments();
        boolean found = false;

        // Using FileWriter with 'false' to overwrite the file completely.
        try (BufferedWriter bw = new BufferedWriter(new FileWriter(PAYMENTS_FILE, false))) {
            for (String line : allPayments) {
                String[] parts = line.split("\\|");
                // If the ID matches, we skip writing this line to effectively "delete" it.
                if (parts.length > 0 && parts[0].trim().equals(paymentId)) {
                    found = true;
                    continue;
                }
                bw.write(line);
                bw.newLine();
            }
        } catch (IOException e) {
            System.err.println("Error deleting payment: " + e.getMessage());
            return false;
        }
        return found;
    }
}