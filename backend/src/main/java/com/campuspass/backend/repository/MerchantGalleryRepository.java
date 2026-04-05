package com.campuspass.backend.repository;

import com.campuspass.backend.model.MerchantGallery;
import org.springframework.data.jpa.repository.JpaRepository;

import java.util.List;

public interface MerchantGalleryRepository extends JpaRepository<MerchantGallery, Long> {

    List<MerchantGallery> findByMerchantIdOrderByIdAsc(Long merchantId);
}
