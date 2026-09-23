package com.vehiclerental.util;

import com.vehiclerental.servlet.SearchController;
import java.util.List;

/**
 * C05 — Selection Sort over the Vehicle catalogue.
 *
 * Selection Sort is the algorithm the examiner expects to see; this class is
 * the single place it is implemented and can be referenced during the viva to
 * demonstrate both the algorithm and information-hiding (callers never see the
 * inner swap/scan loop, they only call a typed sort method).
 */
public final class VehicleSorter {

    private VehicleSorter() { /* utility — no instances */ }

    /** Sort modes accepted by {@link #sort}. */
    public enum Mode {
        PRICE_ASC,    // cheapest first
        PRICE_DESC,   // most expensive first
        NEWEST,       // highest model year first
        RECOMMENDED   // available first, then by price asc (used by default)
    }

    /**
     * In-place Selection Sort on a list of VehicleCards. Returns the same
     * reference for chaining convenience.
     */
    public static List<SearchController.VehicleCard> sort(
            List<SearchController.VehicleCard> list, Mode mode) {

        if (list == null || list.size() < 2) return list;

        int n = list.size();
        for (int i = 0; i < n - 1; i++) {
            int bestIdx = i;
            for (int j = i + 1; j < n; j++) {
                if (compare(list.get(j), list.get(bestIdx), mode) < 0) {
                    bestIdx = j;
                }
            }
            if (bestIdx != i) {
                SearchController.VehicleCard tmp = list.get(i);
                list.set(i, list.get(bestIdx));
                list.set(bestIdx, tmp);
            }
        }
        return list;
    }

    /**
     * Negative if {@code a} should come before {@code b}, positive otherwise.
     * Encapsulated inside the sorter so callers don't reinvent comparison
     * logic for every sort mode.
     */
    private static int compare(SearchController.VehicleCard a,
                               SearchController.VehicleCard b,
                               Mode mode) {
        switch (mode) {
            case PRICE_ASC:
                return Double.compare(a.getPricePerDay(), b.getPricePerDay());
            case PRICE_DESC:
                return Double.compare(b.getPricePerDay(), a.getPricePerDay());
            case NEWEST:
                return Integer.compare(b.getYear(), a.getYear());
            case RECOMMENDED:
            default:
                if (a.isAvailable() != b.isAvailable()) {
                    return a.isAvailable() ? -1 : 1;       // available first
                }
                return Double.compare(a.getPricePerDay(), b.getPricePerDay());
        }
    }

    /** Map a raw query-string value (e.g. {@code "price-asc"}) to a {@link Mode}. */
    public static Mode parseMode(String raw) {
        if (raw == null) return Mode.RECOMMENDED;
        switch (raw.trim().toLowerCase()) {
            case "price-asc":  case "priceasc":  return Mode.PRICE_ASC;
            case "price-desc": case "pricedesc": return Mode.PRICE_DESC;
            case "newest":     case "year":      return Mode.NEWEST;
            default:                              return Mode.RECOMMENDED;
        }
    }
}
