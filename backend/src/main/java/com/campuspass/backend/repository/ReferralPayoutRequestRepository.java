package com.campuspass.backend.repository;

import com.campuspass.backend.model.ReferralPayoutRequest;
import com.campuspass.backend.model.enums.ReferralPayoutStatus;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;

public interface ReferralPayoutRequestRepository extends JpaRepository<ReferralPayoutRequest, Long> {
    long countByReferrerIdAndRequestYearAndRequestMonth(Long referrerId, int year, int month);
    java.util.List<ReferralPayoutRequest> findAllByOrderByRequestedAtDesc();

    @Query("select coalesce(sum(r.amountFcfa), 0) from ReferralPayoutRequest r where r.referrerId = :referrerId and r.status <> :rejected")
    Integer sumRequestedNonRejectedByReferrerId(Long referrerId, ReferralPayoutStatus rejected);
}
