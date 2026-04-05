package com.campuspass.backend.controller;

import com.campuspass.backend.security.SecurityUser;
import com.campuspass.backend.service.MerchantFavoriteService;
import org.springframework.http.ResponseEntity;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.web.bind.annotation.DeleteMapping;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

import java.util.List;

@RestController
@RequestMapping("/api/merchant-favorites")
public class MerchantFavoriteController {

    private final MerchantFavoriteService service;

    public MerchantFavoriteController(MerchantFavoriteService service) {
        this.service = service;
    }

    @GetMapping
    public ResponseEntity<List<Long>> getFavoriteMerchantIds(@AuthenticationPrincipal SecurityUser user) {
        if (user == null || user.getId() == null) {
            return ResponseEntity.status(401).build();
        }
        return ResponseEntity.ok(service.getFavoriteMerchantIds(user.getId()));
    }

    @PostMapping("/{merchantId}")
    public ResponseEntity<Void> addFavorite(@AuthenticationPrincipal SecurityUser user,
                                            @PathVariable Long merchantId) {
        if (user == null || user.getId() == null) {
            return ResponseEntity.status(401).build();
        }
        service.addFavorite(user.getId(), merchantId);
        return ResponseEntity.ok().build();
    }

    @DeleteMapping("/{merchantId}")
    public ResponseEntity<Void> removeFavorite(@AuthenticationPrincipal SecurityUser user,
                                               @PathVariable Long merchantId) {
        if (user == null || user.getId() == null) {
            return ResponseEntity.status(401).build();
        }
        service.removeFavorite(user.getId(), merchantId);
        return ResponseEntity.ok().build();
    }
}

