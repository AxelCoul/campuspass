package com.campuspass.backend.controller;

import com.campuspass.backend.exception.ResourceNotFoundException;
import com.campuspass.backend.model.City;
import com.campuspass.backend.model.Country;
import com.campuspass.backend.repository.CityRepository;
import com.campuspass.backend.repository.CountryRepository;
import jakarta.validation.Valid;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.time.LocalDateTime;
import java.util.List;

@RestController
@RequestMapping("/api")
public class LocationController {

    private final CountryRepository countryRepository;
    private final CityRepository cityRepository;

    public LocationController(CountryRepository countryRepository, CityRepository cityRepository) {
        this.countryRepository = countryRepository;
        this.cityRepository = cityRepository;
    }

    @GetMapping("/countries")
    public ResponseEntity<List<Country>> getActiveCountries() {
        return ResponseEntity.ok(countryRepository.findByActiveTrueOrderByNameAsc());
    }

    @GetMapping("/cities")
    public ResponseEntity<List<City>> getActiveCities(
            @RequestParam(required = false) Long countryId) {
        if (countryId != null) {
            return ResponseEntity.ok(cityRepository.findByCountryIdAndActiveTrueOrderByNameAsc(countryId));
        }
        return ResponseEntity.ok(cityRepository.findByActiveTrueOrderByNameAsc());
    }

    @GetMapping("/admin/countries")
    public ResponseEntity<List<Country>> getAllCountries() {
        return ResponseEntity.ok(countryRepository.findAllByOrderByNameAsc());
    }

    @PostMapping("/admin/countries")
    public ResponseEntity<Country> createCountry(@Valid @RequestBody Country body) {
        body.setId(null);
        body.setCreatedAt(LocalDateTime.now());
        if (body.getActive() == null) body.setActive(true);
        if (body.getCode() != null) body.setCode(body.getCode().trim().toUpperCase());
        if (body.getName() != null) body.setName(body.getName().trim());
        return ResponseEntity.ok(countryRepository.save(body));
    }

    @PutMapping("/admin/countries/{id}")
    public ResponseEntity<Country> updateCountry(@PathVariable Long id, @Valid @RequestBody Country body) {
        Country c = countryRepository.findById(id)
                .orElseThrow(() -> new ResourceNotFoundException("Country", id));
        if (body.getName() != null) c.setName(body.getName().trim());
        if (body.getCode() != null) c.setCode(body.getCode().trim().toUpperCase());
        if (body.getActive() != null) c.setActive(body.getActive());
        return ResponseEntity.ok(countryRepository.save(c));
    }

    @DeleteMapping("/admin/countries/{id}")
    public ResponseEntity<Void> deleteCountry(@PathVariable Long id) {
        if (!countryRepository.existsById(id)) {
            throw new ResourceNotFoundException("Country", id);
        }
        countryRepository.deleteById(id);
        return ResponseEntity.noContent().build();
    }

    @GetMapping("/admin/cities")
    public ResponseEntity<List<City>> getAllCities() {
        return ResponseEntity.ok(cityRepository.findAllByOrderByNameAsc());
    }

    @PostMapping("/admin/cities")
    public ResponseEntity<City> createCity(@Valid @RequestBody City body) {
        if (body.getCountryId() == null || !countryRepository.existsById(body.getCountryId())) {
            throw new IllegalArgumentException("Pays invalide.");
        }
        body.setId(null);
        body.setCreatedAt(LocalDateTime.now());
        if (body.getActive() == null) body.setActive(true);
        if (body.getName() != null) body.setName(body.getName().trim());
        return ResponseEntity.ok(cityRepository.save(body));
    }

    @PutMapping("/admin/cities/{id}")
    public ResponseEntity<City> updateCity(@PathVariable Long id, @Valid @RequestBody City body) {
        City c = cityRepository.findById(id)
                .orElseThrow(() -> new ResourceNotFoundException("City", id));
        if (body.getCountryId() != null) {
            if (!countryRepository.existsById(body.getCountryId())) {
                throw new IllegalArgumentException("Pays invalide.");
            }
            c.setCountryId(body.getCountryId());
        }
        if (body.getName() != null) c.setName(body.getName().trim());
        if (body.getActive() != null) c.setActive(body.getActive());
        return ResponseEntity.ok(cityRepository.save(c));
    }

    @DeleteMapping("/admin/cities/{id}")
    public ResponseEntity<Void> deleteCity(@PathVariable Long id) {
        if (!cityRepository.existsById(id)) {
            throw new ResourceNotFoundException("City", id);
        }
        cityRepository.deleteById(id);
        return ResponseEntity.noContent().build();
    }
}
