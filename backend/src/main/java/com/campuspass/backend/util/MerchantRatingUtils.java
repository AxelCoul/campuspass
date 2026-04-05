package com.campuspass.backend.util;

import com.campuspass.backend.dto.MerchantResponse;
import com.campuspass.backend.model.Review;
import com.campuspass.backend.model.enums.ReviewStatus;

import java.util.List;

/**
 * Moyenne des notes : {@code somme des notes / nombre d'avis visibles}.
 * Si aucun avis : {@code rating = null} et {@code reviewCount = 0}.
 */
public final class MerchantRatingUtils {

    private MerchantRatingUtils() {}

    public static void applyAggregatedRating(MerchantResponse response, List<Review> reviews) {
        int sum = 0;
        int count = 0;
        if (reviews != null) {
            for (Review rv : reviews) {
                if (rv.getStatus() == ReviewStatus.VISIBLE && rv.getRating() != null) {
                    sum += rv.getRating();
                    count++;
                }
            }
        }
        response.setReviewCount(count);
        response.setRating(count > 0 ? (sum / (double) count) : null);
    }
}
