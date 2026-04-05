package com.campuspass.backend.controller;

import com.campuspass.backend.dto.MerchantRequest;
import com.campuspass.backend.dto.MerchantResponse;
import com.campuspass.backend.dto.MerchantStatsDto;
import com.campuspass.backend.dto.TransactionResponseDto;
import com.campuspass.backend.dto.MerchantStaffRequest;
import com.campuspass.backend.dto.UserResponseDto;
import com.campuspass.backend.security.SecurityUser;
import com.campuspass.backend.service.MerchantService;
import jakarta.validation.Valid;
import org.springframework.http.ResponseEntity;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@RestController
@RequestMapping("/api/merchants")
public class MerchantController {

    private final MerchantService merchantService;

    public MerchantController(MerchantService merchantService) {
        this.merchantService = merchantService;
    }

    @GetMapping
    public ResponseEntity<List<MerchantResponse>> getAll(@RequestParam(required = false) Long ownerId) {
        if (ownerId != null) {
            return ResponseEntity.ok(merchantService.findByOwnerId(ownerId));
        }
        return ResponseEntity.ok(merchantService.findAll());
    }

    @GetMapping("/{id}")
    public ResponseEntity<MerchantResponse> getById(@PathVariable Long id) {
        return ResponseEntity.ok(merchantService.getById(id));
    }

    @GetMapping("/{id}/transactions")
    public ResponseEntity<List<TransactionResponseDto>> getTransactions(
            @PathVariable Long id,
            @AuthenticationPrincipal SecurityUser user) {
        MerchantResponse merchant = merchantService.getById(id);
        if (!canAccessMerchant(merchant, user)) {
            return ResponseEntity.status(403).build();
        }
        return ResponseEntity.ok(merchantService.getTransactionsByMerchantId(id));
    }

    @GetMapping("/{id}/stats")
    public ResponseEntity<MerchantStatsDto> getStats(
            @PathVariable Long id,
            @AuthenticationPrincipal SecurityUser user) {
        MerchantResponse merchant = merchantService.getById(id);
        if (!canAccessMerchant(merchant, user)) {
            return ResponseEntity.status(403).build();
        }
        return ResponseEntity.ok(merchantService.getStatsByMerchantId(id));
    }

    /** Propriétaire du commerce ou membre d'équipe rattaché à ce {@code merchantId}. */
    private static boolean canAccessMerchant(MerchantResponse merchant, SecurityUser user) {
        if (merchant.getOwnerId() != null && merchant.getOwnerId().equals(user.getId())) {
            return true;
        }
        Long uidMerchantId = user.getMerchantId();
        return uidMerchantId != null && uidMerchantId.equals(merchant.getId());
    }

    @PostMapping
    public ResponseEntity<MerchantResponse> create(@AuthenticationPrincipal SecurityUser user,
                                                     @Valid @RequestBody MerchantRequest request) {
        return ResponseEntity.ok(merchantService.create(user.getId(), request));
    }

    @PutMapping("/{id}")
    public ResponseEntity<MerchantResponse> update(@PathVariable Long id, @Valid @RequestBody MerchantRequest request) {
        return ResponseEntity.ok(merchantService.update(id, request));
    }

    /** Liste les comptes employés rattachés à ce commerce (OWNER, MANAGER, STAFF). */
    @GetMapping("/{id}/team")
    public ResponseEntity<List<UserResponseDto>> getTeam(
            @PathVariable Long id,
            @AuthenticationPrincipal SecurityUser user) {
        return ResponseEntity.ok(merchantService.getTeamForMerchant(id, user.getId()));
    }

    /** Crée un sous-compte employé (MANAGER / STAFF) pour ce commerce. */
    @PostMapping("/{id}/team")
    public ResponseEntity<UserResponseDto> createStaff(
            @PathVariable Long id,
            @AuthenticationPrincipal SecurityUser user,
            @Valid @RequestBody MerchantStaffRequest request) {
        return ResponseEntity.ok(merchantService.createStaffForMerchant(id, user.getId(), request));
    }
}
