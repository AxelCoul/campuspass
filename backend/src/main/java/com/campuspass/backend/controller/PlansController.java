package com.campuspass.backend.controller;

import com.campuspass.backend.dto.SubscriptionPlanResponse;
import com.campuspass.backend.service.SubscriptionPlanService;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;
import java.util.List;

@RestController
@RequestMapping("/api/plans")
public class PlansController {
    private final SubscriptionPlanService subscriptionPlanService;

    public PlansController(SubscriptionPlanService subscriptionPlanService) {
        this.subscriptionPlanService = subscriptionPlanService;
    }

    @GetMapping
    public ResponseEntity<List<SubscriptionPlanResponse>> getActivePlans() {
        return ResponseEntity.ok(subscriptionPlanService.findActiveForStudent());
    }

    @GetMapping("/{id}")
    public ResponseEntity<SubscriptionPlanResponse> getById(@PathVariable Long id) {
        return ResponseEntity.ok(subscriptionPlanService.getById(id));
    }
}
