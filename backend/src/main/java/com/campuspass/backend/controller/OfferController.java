package com.campuspass.backend.controller;

import com.campuspass.backend.dto.OfferRequest;
import com.campuspass.backend.dto.OfferResponse;
import com.campuspass.backend.service.OfferService;
import jakarta.validation.Valid;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@RestController
@RequestMapping("/api/offers")
public class OfferController {

    private final OfferService offerService;

    public OfferController(OfferService offerService) {
        this.offerService = offerService;
    }

    @GetMapping
    public ResponseEntity<List<OfferResponse>> getAll(
            @RequestParam(required = false) Long merchantId,
            @RequestParam(required = false) String filter,
            @RequestParam(required = false) String university) {
        if (merchantId != null && filter != null && !filter.isBlank()) {
            return ResponseEntity.ok(offerService.findByMerchantIdAndFilter(merchantId, filter));
        }
        if (merchantId != null) {
            return ResponseEntity.ok(offerService.findByMerchantId(merchantId));
        }
        return ResponseEntity.ok(offerService.findActive(university));
    }

    /** Offres actives à proximité de la position fournie (latitude, longitude, rayon en km). */
    @GetMapping("/nearby")
    public ResponseEntity<List<OfferResponse>> getNearby(
            @RequestParam double lat,
            @RequestParam double lng,
            @RequestParam(defaultValue = "2.0") double radiusKm) {
        return ResponseEntity.ok(offerService.findNearby(lat, lng, radiusKm));
    }

    @GetMapping("/{id}")
    public ResponseEntity<OfferResponse> getById(@PathVariable Long id) {
        return ResponseEntity.ok(offerService.getById(id));
    }

    @PostMapping
    public ResponseEntity<OfferResponse> create(@Valid @RequestBody OfferRequest request) {
        return ResponseEntity.ok(offerService.create(request));
    }

    @PutMapping("/{id}")
    public ResponseEntity<OfferResponse> update(@PathVariable Long id, @Valid @RequestBody OfferRequest request) {
        return ResponseEntity.ok(offerService.update(id, request));
    }

    @DeleteMapping("/{id}")
    public ResponseEntity<Void> delete(@PathVariable Long id) {
        offerService.delete(id);
        return ResponseEntity.noContent().build();
    }
}
