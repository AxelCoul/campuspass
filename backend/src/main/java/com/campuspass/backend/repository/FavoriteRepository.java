package com.campuspass.backend.repository;

import com.campuspass.backend.model.Favorite;
import org.springframework.data.jpa.repository.JpaRepository;

import java.util.List;
import java.util.Optional;

public interface FavoriteRepository extends JpaRepository<Favorite, Long> {

    List<Favorite> findByUserIdOrderByCreatedAtDesc(Long userId);

    Optional<Favorite> findByUserIdAndOfferId(Long userId, Long offerId);

    boolean existsByUserIdAndOfferId(Long userId, Long offerId);
}
