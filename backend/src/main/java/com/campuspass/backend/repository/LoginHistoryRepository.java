package com.campuspass.backend.repository;

import com.campuspass.backend.model.LoginHistory;
import org.springframework.data.jpa.repository.JpaRepository;

import org.springframework.data.domain.Pageable;

import java.util.List;

public interface LoginHistoryRepository extends JpaRepository<LoginHistory, Long> {

    List<LoginHistory> findByUserIdOrderByLoginAtDesc(Long userId, Pageable pageable);

    List<LoginHistory> findAllByOrderByLoginAtDesc(Pageable pageable);
}
