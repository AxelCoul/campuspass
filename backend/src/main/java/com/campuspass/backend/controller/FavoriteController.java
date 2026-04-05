package com.campuspass.backend.controller;

import com.campuspass.backend.security.SecurityUser;
import com.campuspass.backend.service.FavoriteService;
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
@RequestMapping("/api/favorites")
public class FavoriteController {

    private final FavoriteService favoriteService;

    public FavoriteController(FavoriteService favoriteService) {
        this.favoriteService = favoriteService;
    }

    @GetMapping
    public ResponseEntity<List<Long>> getFavoriteOfferIds(@AuthenticationPrincipal SecurityUser user) {
        if (user == null || user.getId() == null) {
            return ResponseEntity.status(401).build();
        }
        return ResponseEntity.ok(favoriteService.getFavoriteOfferIds(user.getId()));
    }

    @PostMapping("/{offerId}")
    public ResponseEntity<Void> addFavorite(@AuthenticationPrincipal SecurityUser user,
                                            @PathVariable Long offerId) {
        if (user == null || user.getId() == null) {
            return ResponseEntity.status(401).build();
        }
        favoriteService.addFavorite(user.getId(), offerId);
        return ResponseEntity.ok().build();
    }

    @DeleteMapping("/{offerId}")
    public ResponseEntity<Void> removeFavorite(@AuthenticationPrincipal SecurityUser user,
                                               @PathVariable Long offerId) {
        if (user == null || user.getId() == null) {
            return ResponseEntity.status(401).build();
        }
        favoriteService.removeFavorite(user.getId(), offerId);
        return ResponseEntity.ok().build();
    }
}

