package com.campuspass.backend.repository;

import com.campuspass.backend.model.City;
import org.springframework.data.jpa.repository.JpaRepository;

import java.util.List;

public interface CityRepository extends JpaRepository<City, Long> {
    List<City> findByActiveTrueOrderByNameAsc();
    List<City> findByCountryIdAndActiveTrueOrderByNameAsc(Long countryId);
    List<City> findAllByOrderByNameAsc();
}
