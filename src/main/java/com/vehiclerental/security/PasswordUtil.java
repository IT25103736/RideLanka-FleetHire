package com.vehiclerental.security;

import java.nio.charset.StandardCharsets;
import java.security.MessageDigest;
import java.security.NoSuchAlgorithmException;
import java.security.SecureRandom;
import java.util.Base64;

/** Small JDK-only password hashing utility for the progress demo. */
public final class PasswordUtil {
    private static final int ITERATIONS = 120_000;
    private static final int SALT_BYTES = 16;

    private PasswordUtil() {}

    public static String hash(String raw) {
        if (raw == null) throw new IllegalArgumentException("Password is required");
        byte[] salt = new byte[SALT_BYTES];
        new SecureRandom().nextBytes(salt);
        return "PBKDF2$" + ITERATIONS + "$" + Base64.getEncoder().encodeToString(salt) + "$"
                + Base64.getEncoder().encodeToString(derive(raw.toCharArray(), salt, ITERATIONS));
    }

    public static boolean matches(String raw, String stored) {
        try {
            String[] p = stored.split("\\$", -1);
            if (p.length != 4 || !"PBKDF2".equals(p[0])) return false;
            int iterations = Integer.parseInt(p[1]);
            byte[] salt = Base64.getDecoder().decode(p[2]);
            byte[] expected = Base64.getDecoder().decode(p[3]);
            byte[] actual = derive(raw.toCharArray(), salt, iterations);
            return MessageDigest.isEqual(expected, actual);
        } catch (Exception ex) {
            return false;
        }
    }

    private static byte[] derive(char[] password, byte[] salt, int iterations) {
        try {
            var spec = new javax.crypto.spec.PBEKeySpec(password, salt, iterations, 256);
            byte[] out = javax.crypto.SecretKeyFactory.getInstance("PBKDF2WithHmacSHA256").generateSecret(spec).getEncoded();
            spec.clearPassword();
            return out;
        } catch (Exception e) {
            throw new IllegalStateException("Password hashing unavailable", e);
        }
    }
}
