package com.campuspass.backend.repository;

import com.campuspass.backend.model.Country;
import org.springframework.data.jpa.repository.JpaRepository;

import java.util.List;

public interface CountryRepository extends JpaRepository<Country, Long> {
    List<Country> findByActiveTrueOrderByNameAsc();
    List<Country> findAllByOrderByNameAsc();
}
