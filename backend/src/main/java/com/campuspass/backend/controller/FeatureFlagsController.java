package com.campuspass.backend.controller;

import org.springframework.beans.factory.annotation.Value;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

import java.util.Map;

/**
 * Drapeaux de fonctionnalités côté client (lecture seule).
 * Permet d'activer plus tard la gestion des offres par commerce sans refactor.
 */
@RestController
@RequestMapping("/api/features")
public class FeatureFlagsController {

    @Value("${feature.merchant-offer-management.enabled:false}")
    private boolean merchantOfferManagementEnabled;

    @GetMapping("/merchant-capabilities")
    public ResponseEntity<Map<String, Object>> merchantCapabilities() {
        // Si merchantOfferManagementEnabled : création commerçant → PROPOSED, validation admin pour ACTIVE.
        return ResponseEntity.ok(Map.of(
                "canManageOffers", merchantOfferManagementEnabled,
                "merchantOfferManagementEnabled", merchantOfferManagementEnabled,
                "proposalRequiresAdminApproval", merchantOfferManagementEnabled
        ));
    }
}
