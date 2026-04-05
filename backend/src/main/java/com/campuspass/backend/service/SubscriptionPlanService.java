package com.campuspass.backend.service;

import com.campuspass.backend.dto.SubscriptionPlanRequest;
import com.campuspass.backend.dto.SubscriptionPlanResponse;
import com.campuspass.backend.exception.ResourceNotFoundException;
import com.campuspass.backend.model.SubscriptionPlan;
import com.campuspass.backend.repository.SubscriptionPlanRepository;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.time.LocalDate;
import java.time.LocalDateTime;
import java.util.List;
import java.util.stream.Collectors;

@Service
public class SubscriptionPlanService {

    private final SubscriptionPlanRepository subscriptionPlanRepository;

    public SubscriptionPlanService(SubscriptionPlanRepository subscriptionPlanRepository) {
        this.subscriptionPlanRepository = subscriptionPlanRepository;
    }

    public List<SubscriptionPlanResponse> findActiveForStudent() {
        LocalDate today = LocalDate.now();
        return subscriptionPlanRepository.findByActiveTrueOrderByNameAsc().stream()
                .map(p -> toResponse(p, today))
                .collect(Collectors.toList());
    }

    public List<SubscriptionPlanResponse> findAll() {
        LocalDate today = LocalDate.now();
        return subscriptionPlanRepository.findAll().stream()
                .map(p -> toResponse(p, today))
                .collect(Collectors.toList());
    }

    public SubscriptionPlanResponse getById(Long id) {
        SubscriptionPlan p = subscriptionPlanRepository.findById(id)
                .orElseThrow(() -> new ResourceNotFoundException("SubscriptionPlan", id));
        return toResponse(p, LocalDate.now());
    }

    @Transactional
    public SubscriptionPlanResponse create(SubscriptionPlanRequest req) {
        SubscriptionPlan p = new SubscriptionPlan();
        p.setName(req.getName());
        p.setType(req.getType());
        p.setPrice(req.getPrice());
        p.setPromoPrice(req.getPromoPrice());
        p.setStartPromoDate(req.getStartPromoDate());
        p.setEndPromoDate(req.getEndPromoDate());
        p.setActive(req.getActive() != null ? req.getActive() : true);
        p.setCreatedAt(LocalDateTime.now());
        p = subscriptionPlanRepository.save(p);
        return toResponse(p, LocalDate.now());
    }

    @Transactional
    public SubscriptionPlanResponse update(Long id, SubscriptionPlanRequest req) {
        SubscriptionPlan p = subscriptionPlanRepository.findById(id)
                .orElseThrow(() -> new ResourceNotFoundException("SubscriptionPlan", id));
        p.setName(req.getName());
        p.setType(req.getType());
        p.setPrice(req.getPrice());
        p.setPromoPrice(req.getPromoPrice());
        p.setStartPromoDate(req.getStartPromoDate());
        p.setEndPromoDate(req.getEndPromoDate());
        if (req.getActive() != null) p.setActive(req.getActive());
        p = subscriptionPlanRepository.save(p);
        return toResponse(p, LocalDate.now());
    }

    @Transactional
    public void delete(Long id) {
        if (!subscriptionPlanRepository.existsById(id))
            throw new ResourceNotFoundException("SubscriptionPlan", id);
        subscriptionPlanRepository.deleteById(id);
    }

    private SubscriptionPlanResponse toResponse(SubscriptionPlan p, LocalDate today) {
        SubscriptionPlanResponse r = new SubscriptionPlanResponse();
        r.setId(p.getId());
        r.setName(p.getName());
        r.setType(p.getType());
        r.setPrice(p.getPrice());
        r.setPromoPrice(p.getPromoPrice());
        r.setStartPromoDate(p.getStartPromoDate());
        r.setEndPromoDate(p.getEndPromoDate());
        r.setActive(p.getActive());
        r.setCreatedAt(p.getCreatedAt());
        r.setEffectivePrice(p.getEffectivePrice(today));
        r.setPromoActive(p.isPromoActive(today));
        return r;
    }
}
