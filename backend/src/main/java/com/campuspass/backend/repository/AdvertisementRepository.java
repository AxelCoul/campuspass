package com.campuspass.backend.repository;

import com.campuspass.backend.model.Advertisement;
import com.campuspass.backend.model.enums.AdPosition;
import com.campuspass.backend.model.enums.AdStatus;
import org.springframework.data.jpa.repository.JpaRepository;

import java.util.List;

public interface AdvertisementRepository extends JpaRepository<Advertisement, Long> {

    List<Advertisement> findByMerchantId(Long merchantId);

    List<Advertisement> findByPositionAndStatus(AdPosition position, AdStatus status);
}
