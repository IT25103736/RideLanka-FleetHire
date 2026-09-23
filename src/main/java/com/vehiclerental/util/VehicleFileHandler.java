package com.vehiclerental.util;

import com.vehiclerental.model.Car;
import com.vehiclerental.model.Van;
import com.vehiclerental.model.Vehicle;

import java.io.*;
import java.util.ArrayList;
import java.util.List;

public class VehicleFileHandler {

    private static final String FILE_PATH = "data/vehicles.txt";

    public List<Vehicle> getAllVehicles() {
        List<Vehicle> vehicles = new ArrayList<>();

        File file = new File(FILE_PATH);
        if (!file.exists()) {
            return vehicles; // return empty list if file doesn't exist yet
        }

        try (BufferedReader reader = new BufferedReader(new FileReader(file))) {
            String line;
            while ((line = reader.readLine()) != null) {
                line = line.trim();
                if (line.isEmpty() || line.startsWith("#")) continue; // skip blank/comment lines
                Vehicle vehicle = parseLine(line);
                if (vehicle != null) {
                    vehicles.add(vehicle);
                }
            }
        } catch (IOException e) {
            System.err.println("Error reading vehicles.txt: " + e.getMessage());
        }

        return vehicles;
    }

   
    public Vehicle getVehicleById(String vehicleId) {
        for (Vehicle v : getAllVehicles()) {
            if (v.getVehicleId().equalsIgnoreCase(vehicleId)) {
                return v;
            }
        }
        return null; // not found
    }

    
    public boolean addVehicle(Vehicle vehicle) {
        try (BufferedWriter writer = new BufferedWriter(new FileWriter(FILE_PATH, true))) {
            writer.write(vehicle.toFileString());
            writer.newLine();
            return true;
        } catch (IOException e) {
            System.err.println("Error writing to vehicles.txt: " + e.getMessage());
            return false;
        }
    }

   
    public boolean updateVehicle(Vehicle updatedVehicle) {
        List<Vehicle> allVehicles = getAllVehicles();
        boolean found = false;

        for (int i = 0; i < allVehicles.size(); i++) {
            if (allVehicles.get(i).getVehicleId().equalsIgnoreCase(updatedVehicle.getVehicleId())) {
                allVehicles.set(i, updatedVehicle); // replace old with new
                found = true;
                break;
            }
        }

        if (!found) return false;

        return writeAllToFile(allVehicles);
    }

   
    public boolean deleteVehicle(String vehicleId) {
        List<Vehicle> allVehicles = getAllVehicles();
        boolean removed = allVehicles.removeIf(v -> v.getVehicleId().equalsIgnoreCase(vehicleId));

        if (!removed) return false;

        return writeAllToFile(allVehicles);
    }

    
    public List<Vehicle> sortByAvailability(List<Vehicle> vehicles) {
        int n = vehicles.size();

        for (int i = 0; i < n - 1; i++) {
            int selectedIndex = i;

            for (int j = i + 1; j < n; j++) {
                // available=true should come before available=false
                // true > false when converted to int (1 > 0), so we want true first
                boolean jAvailable = vehicles.get(j).isAvailable();
                boolean selectedAvailable = vehicles.get(selectedIndex).isAvailable();

                if (jAvailable && !selectedAvailable) {
                    selectedIndex = j;
                }
            }

            // Swap positions i and selectedIndex
            Vehicle temp = vehicles.get(selectedIndex);
            vehicles.set(selectedIndex, vehicles.get(i));
            vehicles.set(i, temp);
        }

        return vehicles;
    }

   
    private Vehicle parseLine(String line) {
        String[] parts = line.split("\\|");
        if (parts.length < 8) return null; // invalid line

        try {
            String vehicleId   = parts[0].trim();
            String type        = parts[1].trim();
            String brand       = parts[2].trim();
            String model       = parts[3].trim();
            int    year        = Integer.parseInt(parts[4].trim());
            double price       = Double.parseDouble(parts[5].trim());
            boolean available  = Boolean.parseBoolean(parts[6].trim());
            String extraField  = parts[7].trim();
            String imageUrl    = parts.length > 8 ? parts[8].trim() : "";

            Vehicle built;
            switch (type) {
                case "Car":
                    built = new Car(vehicleId, brand, model, year, price, available,
                            Integer.parseInt(extraField));
                    break;
                case "Van":
                    built = new Van(vehicleId, brand, model, year, price, available,
                            Double.parseDouble(extraField));
                    break;
                default:
                    System.err.println("[VehicleFileHandler] unknown vehicle type: " + type);
                    return null;
            }
            built.setImageUrl(imageUrl);
            return built;
        } catch (RuntimeException e) {
            // Catches NumberFormatException AND ArrayIndexOutOfBoundsException for
            // rows that pass the length>=8 check but still have bad data.
            System.err.println("[VehicleFileHandler] skipping malformed row: " + line
                    + " (" + e.getClass().getSimpleName() + ")");
            return null;
        }
    }

    /**
     * Overwrites the entire file with the given list (used by update and delete).
     */
    private boolean writeAllToFile(List<Vehicle> vehicles) {
        try (BufferedWriter writer = new BufferedWriter(new FileWriter(FILE_PATH, false))) {
            for (Vehicle v : vehicles) {
                writer.write(v.toFileString());
                writer.newLine();
            }
            return true;
        } catch (IOException e) {
            System.err.println("Error rewriting vehicles.txt: " + e.getMessage());
            return false;
        }
    }
}
