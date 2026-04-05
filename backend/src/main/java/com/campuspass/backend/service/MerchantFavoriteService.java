package com.campuspass.backend.service;

import com.campuspass.backend.model.MerchantFavorite;
import com.campuspass.backend.repository.MerchantFavoriteRepository;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.time.LocalDateTime;
import java.util.List;

@Service
public class MerchantFavoriteService {

    private final MerchantFavoriteRepository repository;

    public MerchantFavoriteService(MerchantFavoriteRepository repository) {
        this.repository = repository;
    }

    public List<Long> getFavoriteMerchantIds(Long userId) {
        return repository.findByUserIdOrderByCreatedAtDesc(userId).stream()
                .map(MerchantFavorite::getMerchantId)
                .toList();
    }

    @Transactional
    public void addFavorite(Long userId, Long merchantId) {
        if (repository.existsByUserIdAndMerchantId(userId, merchantId)) {
            return;
        }
        MerchantFavorite f = new MerchantFavorite();
        f.setUserId(userId);
        f.setMerchantId(merchantId);
        f.setCreatedAt(LocalDateTime.now());
        repository.save(f);
    }

    @Transactional
    public void removeFavorite(Long userId, Long merchantId) {
        repository.findByUserIdAndMerchantId(userId, merchantId)
                .ifPresent(repository::delete);
    }
}

