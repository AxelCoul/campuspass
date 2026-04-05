package com.campuspass.backend.util;

import java.nio.charset.StandardCharsets;
import java.util.Base64;
import java.util.UUID;

/**
 * Génère et valide des codes QR / coupon (stockage en base sous forme de chaîne).
 * Pour une vraie image QR, ajouter une lib (ex. ZXing) et renvoyer byte[] ou URL.
 */
public final class QrCodeGenerator {

    private QrCodeGenerator() {}

    /**
     * Génère un code unique pour le coupon (utilisable comme qrCodeData).
     */
    public static String generateCouponCode() {
        return "CP-" + UUID.randomUUID().toString().replace("-", "").substring(0, 12).toUpperCase();
    }

    /**
     * Encode une chaîne en Base64 (pour stockage qrCodeData si besoin).
     */
    public static String toBase64(String data) {
        return Base64.getEncoder().encodeToString(data.getBytes(StandardCharsets.UTF_8));
    }

    public static String fromBase64(String base64) {
        return new String(Base64.getDecoder().decode(base64), StandardCharsets.UTF_8);
    }
}
