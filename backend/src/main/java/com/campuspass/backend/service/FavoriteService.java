package com.campuspass.backend.service;

import com.campuspass.backend.model.Favorite;
import com.campuspass.backend.repository.FavoriteRepository;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.time.LocalDateTime;
import java.util.List;

@Service
public class FavoriteService {

    private final FavoriteRepository favoriteRepository;

    public FavoriteService(FavoriteRepository favoriteRepository) {
        this.favoriteRepository = favoriteRepository;
    }

    public List<Long> getFavoriteOfferIds(Long userId) {
        return favoriteRepository.findByUserIdOrderByCreatedAtDesc(userId).stream()
                .map(Favorite::getOfferId)
                .toList();
    }

    @Transactional
    public void addFavorite(Long userId, Long offerId) {
        if (favoriteRepository.existsByUserIdAndOfferId(userId, offerId)) {
            return;
        }
        Favorite f = new Favorite();
        f.setUserId(userId);
        f.setOfferId(offerId);
        f.setCreatedAt(LocalDateTime.now());
        favoriteRepository.save(f);
    }

    @Transactional
    public void removeFavorite(Long userId, Long offerId) {
        favoriteRepository.findByUserIdAndOfferId(userId, offerId)
                .ifPresent(favoriteRepository::delete);
    }
}

