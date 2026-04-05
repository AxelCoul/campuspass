package com.campuspass.backend.repository;

import com.campuspass.backend.model.RewardCatalogItem;
import org.springframework.data.jpa.repository.JpaRepository;

import java.util.List;

public interface RewardCatalogItemRepository extends JpaRepository<RewardCatalogItem, Long> {
    List<RewardCatalogItem> findByActiveTrueOrderByPointsCostAsc();
}
