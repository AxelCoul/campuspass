package com.campuspass.backend.controller;

import com.campuspass.backend.model.University;
import com.campuspass.backend.repository.UniversityRepository;
import jakarta.validation.Valid;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.time.LocalDateTime;
import java.util.List;

@RestController
@RequestMapping("/api")
public class UniversityController {

    private final UniversityRepository universityRepository;

    public UniversityController(UniversityRepository universityRepository) {
        this.universityRepository = universityRepository;
    }

    /** Liste publique des universités actives (utilisée par l'app étudiant pour le formulaire d'inscription). */
    @GetMapping("/universities")
    public ResponseEntity<List<University>> getActiveUniversities() {
        return ResponseEntity.ok(universityRepository.findByActiveTrueOrderByNameAsc());
    }

    /** Gestion des universités côté admin. */
    @GetMapping("/admin/universities")
    public ResponseEntity<List<University>> getAllUniversities() {
        return ResponseEntity.ok(universityRepository.findAll());
    }

    @PostMapping("/admin/universities")
    public ResponseEntity<University> createUniversity(@Valid @RequestBody University body) {
        body.setId(null);
        body.setCreatedAt(LocalDateTime.now());
        if (body.getActive() == null) body.setActive(true);
        return ResponseEntity.ok(universityRepository.save(body));
    }

    @PutMapping("/admin/universities/{id}")
    public ResponseEntity<University> updateUniversity(@PathVariable Long id, @Valid @RequestBody University body) {
        University u = universityRepository.findById(id)
                .orElseThrow(() -> new com.campuspass.backend.exception.ResourceNotFoundException("University", id));
        if (body.getName() != null) u.setName(body.getName());
        if (body.getCode() != null) u.setCode(body.getCode());
        if (body.getCity() != null) u.setCity(body.getCity());
        if (body.getCountry() != null) u.setCountry(body.getCountry());
        if (body.getActive() != null) u.setActive(body.getActive());
        return ResponseEntity.ok(universityRepository.save(u));
    }

    @DeleteMapping("/admin/universities/{id}")
    public ResponseEntity<Void> deleteUniversity(@PathVariable Long id) {
        if (!universityRepository.existsById(id)) {
            throw new com.campuspass.backend.exception.ResourceNotFoundException("University", id);
        }
        universityRepository.deleteById(id);
        return ResponseEntity.noContent().build();
    }
}

