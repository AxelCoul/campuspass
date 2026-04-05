package com.campuspass.backend.controller;

import com.campuspass.backend.dto.AdvertisementRequest;
import com.campuspass.backend.dto.AdvertisementResponse;
import com.campuspass.backend.model.enums.AdPosition;
import com.campuspass.backend.service.AdvertisementService;
import jakarta.validation.Valid;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@RestController
@RequestMapping("/api/advertisements")
public class AdvertisementController {

    private final AdvertisementService advertisementService;

    public AdvertisementController(AdvertisementService advertisementService) {
        this.advertisementService = advertisementService;
    }

    @GetMapping
    public ResponseEntity<List<AdvertisementResponse>> getAll(
            @RequestParam(required = false) AdPosition position,
            @RequestParam(required = false) Long merchantId,
            @RequestParam(required = false) String city,
            @RequestParam(required = false) String country,
            @RequestParam(required = false) String university,
            @RequestParam(required = false) String segment) {
        if (position != null) {
            return ResponseEntity.ok(advertisementService.findByPosition(position, city, country, university, segment));
        }
        if (merchantId != null) {
            return ResponseEntity.ok(advertisementService.findByMerchantId(merchantId));
        }
        return ResponseEntity.ok(advertisementService.findAll());
    }

    @GetMapping("/{id}")
    public ResponseEntity<AdvertisementResponse> getById(@PathVariable Long id) {
        return ResponseEntity.ok(advertisementService.getById(id));
    }

    @PostMapping
    public ResponseEntity<AdvertisementResponse> create(@Valid @RequestBody AdvertisementRequest request) {
        return ResponseEntity.ok(advertisementService.create(request));
    }

    @PutMapping("/{id}")
    public ResponseEntity<AdvertisementResponse> update(
            @PathVariable Long id,
            @Valid @RequestBody AdvertisementRequest request) {
        return ResponseEntity.ok(advertisementService.update(id, request));
    }

    @DeleteMapping("/{id}")
    public ResponseEntity<Void> delete(@PathVariable Long id) {
        advertisementService.delete(id);
        return ResponseEntity.noContent().build();
    }
}
