package com.campuspass.backend.repository;

import com.campuspass.backend.model.OfferImage;
import org.springframework.data.jpa.repository.JpaRepository;

import java.util.List;

public interface OfferImageRepository extends JpaRepository<OfferImage, Long> {

    List<OfferImage> findByOfferIdOrderByPositionAsc(Long offerId);

    void deleteByOfferId(Long offerId);
}
