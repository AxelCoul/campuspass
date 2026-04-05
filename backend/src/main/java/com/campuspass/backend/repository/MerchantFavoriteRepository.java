package com.campuspass.backend.repository;

import com.campuspass.backend.model.MerchantFavorite;
import org.springframework.data.jpa.repository.JpaRepository;

import java.util.List;
import java.util.Optional;

public interface MerchantFavoriteRepository extends JpaRepository<MerchantFavorite, Long> {

    List<MerchantFavorite> findByUserIdOrderByCreatedAtDesc(Long userId);

    Optional<MerchantFavorite> findByUserIdAndMerchantId(Long userId, Long merchantId);

    boolean existsByUserIdAndMerchantId(Long userId, Long merchantId);
}

