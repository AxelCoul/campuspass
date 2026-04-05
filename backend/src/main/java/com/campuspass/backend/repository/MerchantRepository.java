package com.campuspass.backend.repository;

import com.campuspass.backend.model.Merchant;
import com.campuspass.backend.model.enums.MerchantStatus;
import org.springframework.data.jpa.repository.JpaRepository;

import java.util.List;

public interface MerchantRepository extends JpaRepository<Merchant, Long> {

    List<Merchant> findByOwnerId(Long ownerId);

    List<Merchant> findByStatus(MerchantStatus status);
}
