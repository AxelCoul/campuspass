package com.campuspass.backend.repository;

import com.campuspass.backend.model.Offer;
import com.campuspass.backend.model.enums.OfferStatus;
import org.springframework.data.jpa.repository.JpaRepository;

import java.util.List;

public interface OfferRepository extends JpaRepository<Offer, Long> {

    List<Offer> findByMerchantIdOrderByCreatedAtDesc(Long merchantId);

    List<Offer> findByStatus(OfferStatus status);

    List<Offer> findByCategoryIdAndStatus(Long categoryId, OfferStatus status);
}
