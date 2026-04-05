package com.campuspass.backend.dto;

import lombok.Getter;
import lombok.Setter;
import jakarta.validation.constraints.*;
import java.util.List;
import java.time.LocalDate;

@Getter
@Setter
public class OfferRequest {

    @NotNull
    private Long merchantId;
    private Long categoryId;
    @NotBlank
    @Size(max = 200)
    private String title;
    @Size(max = 2000)
    private String description;
    @Size(max = 1000)
    private String termsConditions;
    @DecimalMin("0")
    private Double originalPrice;
    @DecimalMin("0") @DecimalMax("100")
    private Double discountPercentage;
    @DecimalMin("0")
    private Double discountAmount;
    @DecimalMin("0")
    private Double finalPrice;
    @Size(max = 500)
    private String imageUrl;
    /**
     * Galerie d'images de l'offre (urls déjà uploadées) pour affichage.
     * Optionnel. Si vide/null, on retombe sur `imageUrl`.
     */
    @Size(max = 3)
    private List<String> imageUrls;
    @Min(0)
    private Integer maxCoupons = 0;
    /** Nombre maximum de passages par jour pour un étudiant (null = illimité). */
    @Min(0)
    private Integer maxPassesPerDayPerUser;
    /** Nombre maximum de plats / unités par passage (null = illimité). */
    @Min(0)
    private Integer maxQuantityPerPass;
    /** Liste d'universités ciblées (CSV). Vide/null => tout le monde. */
    @Size(max = 1000)
    private String targetUniversities;
    private LocalDate startDate;
    private LocalDate endDate;
}
