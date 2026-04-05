package com.campuspass.backend.repository;

import com.campuspass.backend.model.Report;
import org.springframework.data.jpa.repository.JpaRepository;

import java.util.List;

public interface ReportRepository extends JpaRepository<Report, Long> {

    List<Report> findByUserIdOrderByCreatedAtDesc(Long userId);
}
