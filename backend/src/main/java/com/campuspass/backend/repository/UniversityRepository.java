package com.campuspass.backend.repository;

import com.campuspass.backend.model.University;
import org.springframework.data.jpa.repository.JpaRepository;

import java.util.List;

public interface UniversityRepository extends JpaRepository<University, Long> {

    List<University> findByActiveTrueOrderByNameAsc();
}

