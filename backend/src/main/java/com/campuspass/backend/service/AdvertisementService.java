package com.campuspass.backend.service;

import com.campuspass.backend.dto.AdvertisementRequest;
import com.campuspass.backend.dto.AdvertisementResponse;
import com.campuspass.backend.exception.ResourceNotFoundException;
import com.campuspass.backend.model.Advertisement;
import com.campuspass.backend.model.enums.AdPosition;
import com.campuspass.backend.model.enums.AdStatus;
import com.campuspass.backend.repository.AdvertisementRepository;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.time.LocalDateTime;
import java.util.List;
import java.util.stream.Collectors;

@Service
public class AdvertisementService {

    private final AdvertisementRepository advertisementRepository;

    public AdvertisementService(AdvertisementRepository advertisementRepository) {
        this.advertisementRepository = advertisementRepository;
    }

    public List<AdvertisementResponse> findAll() {
        return advertisementRepository.findAll().stream().map(this::toResponse).collect(Collectors.toList());
    }

    public List<AdvertisementResponse> findByMerchantId(Long merchantId) {
        return advertisementRepository.findByMerchantId(merchantId).stream()
                .map(this::toResponse).collect(Collectors.toList());
    }

    public List<AdvertisementResponse> findByPosition(AdPosition position) {
        return findByPosition(position, null, null, null, null);
    }

    /**
     * Ciblage simple par ville / pays / université / segment.
     * Si les paramètres de ciblage sont null, on renvoie toutes les pubs actives pour la position.
     */
    public List<AdvertisementResponse> findByPosition(AdPosition position, String city, String country, String university, String segment) {
        return advertisementRepository.findByPositionAndStatus(position, AdStatus.ACTIVE).stream()
                .filter(a -> matchesTarget(a, city, country, university, segment))
                .filter(this::matchesDateWindow)
                .map(this::toResponse)
                .collect(Collectors.toList());
    }

    public AdvertisementResponse getById(Long id) {
        Advertisement a = advertisementRepository.findById(id)
                .orElseThrow(() -> new ResourceNotFoundException("Advertisement", id));
        return toResponse(a);
    }

    @Transactional
    public AdvertisementResponse create(AdvertisementRequest req) {
        Advertisement a = new Advertisement();
        a.setMerchantId(req.getMerchantId());
        a.setTitle(req.getTitle());
        a.setDescription(req.getDescription());
        a.setCtaLabel(req.getCtaLabel());
        a.setImageUrl(req.getImageUrl());
        a.setVideoUrl(req.getVideoUrl());
        a.setTargetUrl(req.getTargetUrl());
        a.setTargetCity(req.getTargetCity());
        a.setTargetCountry(req.getTargetCountry());
        a.setTargetUniversity(req.getTargetUniversity());
        a.setTargetSegment(req.getTargetSegment());
        a.setPosition(req.getPosition() != null ? req.getPosition() : AdPosition.HOME_BANNER);
        a.setStartDate(req.getStartDate());
        a.setEndDate(req.getEndDate());
        a.setBudget(req.getBudget());
        a.setOfferId(req.getOfferId());
        a.setStatus(AdStatus.ACTIVE);
        a.setCreatedAt(LocalDateTime.now());
        a = advertisementRepository.save(a);
        return toResponse(a);
    }

    @Transactional
    public AdvertisementResponse update(Long id, AdvertisementRequest req) {
        Advertisement a = advertisementRepository.findById(id)
                .orElseThrow(() -> new ResourceNotFoundException("Advertisement", id));
        if (req.getTitle() != null) a.setTitle(req.getTitle());
        if (req.getDescription() != null) a.setDescription(req.getDescription());
        if (req.getImageUrl() != null) a.setImageUrl(req.getImageUrl());
        if (req.getVideoUrl() != null) a.setVideoUrl(req.getVideoUrl());
        if (req.getTargetUrl() != null) a.setTargetUrl(req.getTargetUrl());
        if (req.getTargetCity() != null) a.setTargetCity(req.getTargetCity());
        if (req.getTargetCountry() != null) a.setTargetCountry(req.getTargetCountry());
        if (req.getTargetUniversity() != null) a.setTargetUniversity(req.getTargetUniversity());
        if (req.getTargetSegment() != null) a.setTargetSegment(req.getTargetSegment());
        if (req.getPosition() != null) a.setPosition(req.getPosition());
        if (req.getStartDate() != null) a.setStartDate(req.getStartDate());
        if (req.getEndDate() != null) a.setEndDate(req.getEndDate());
        if (req.getBudget() != null) a.setBudget(req.getBudget());
        if (req.getOfferId() != null) a.setOfferId(req.getOfferId());
        a = advertisementRepository.save(a);
        return toResponse(a);
    }

    @Transactional
    public void delete(Long id) {
        if (!advertisementRepository.existsById(id)) {
            throw new ResourceNotFoundException("Advertisement", id);
        }
        advertisementRepository.deleteById(id);
    }

    private AdvertisementResponse toResponse(Advertisement a) {
        AdvertisementResponse r = new AdvertisementResponse();
        r.setId(a.getId());
        r.setMerchantId(a.getMerchantId());
        r.setTitle(a.getTitle());
        r.setDescription(a.getDescription());
        r.setCtaLabel(a.getCtaLabel());
        r.setImageUrl(a.getImageUrl());
        r.setVideoUrl(a.getVideoUrl());
        r.setTargetUrl(a.getTargetUrl());
        r.setTargetCity(a.getTargetCity());
        r.setTargetCountry(a.getTargetCountry());
        r.setTargetUniversity(a.getTargetUniversity());
        r.setTargetSegment(a.getTargetSegment());
        r.setPosition(a.getPosition());
        r.setStartDate(a.getStartDate());
        r.setEndDate(a.getEndDate());
        r.setBudget(a.getBudget());
        r.setOfferId(a.getOfferId());
        r.setStatus(a.getStatus());
        r.setCreatedAt(a.getCreatedAt());
        return r;
    }

    private boolean matchesTarget(Advertisement a, String city, String country, String university, String segment) {
        // Ville
        if (a.getTargetCity() != null && !a.getTargetCity().isBlank()) {
            if (city == null || city.isBlank()
                    || !a.getTargetCity().equalsIgnoreCase(city.trim())) {
                return false;
            }
        }
        // Pays
        if (a.getTargetCountry() != null && !a.getTargetCountry().isBlank()) {
            if (country == null || country.isBlank()
                    || !a.getTargetCountry().equalsIgnoreCase(country.trim())) {
                return false;
            }
        }
        // Université
        if (a.getTargetUniversity() != null && !a.getTargetUniversity().isBlank()) {
            if (university == null || university.isBlank()
                    || !a.getTargetUniversity().equalsIgnoreCase(university.trim())) {
                return false;
            }
        }
        // Segment
        if (a.getTargetSegment() != null && !a.getTargetSegment().isBlank()) {
            if (segment == null || segment.isBlank()) {
                // Si le backend ne reçoit pas le segment côté mobile, on autorise quand même "ALL".
                // Sinon, on ne peut pas savoir si l'utilisateur correspond.
                return "ALL".equalsIgnoreCase(a.getTargetSegment());
            }
            if (!"ALL".equalsIgnoreCase(a.getTargetSegment())
                    && !a.getTargetSegment().equalsIgnoreCase(segment.trim())) {
                return false;
            }
        }
        return true;
    }

    private boolean matchesDateWindow(Advertisement a) {
        // Inclusive window: startDate <= today <= endDate
        java.time.LocalDate today = java.time.LocalDate.now();

        if (a.getStartDate() != null && today.isBefore(a.getStartDate())) {
            return false;
        }
        if (a.getEndDate() != null && today.isAfter(a.getEndDate())) {
            return false;
        }
        return true;
    }
}
