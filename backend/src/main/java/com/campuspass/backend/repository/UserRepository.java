package com.campuspass.backend.repository;

import com.campuspass.backend.model.User;
import com.campuspass.backend.model.enums.UserRole;
import org.springframework.data.jpa.repository.JpaRepository;

import java.util.Optional;
import java.util.List;

public interface UserRepository extends JpaRepository<User, Long> {

    Optional<User> findByEmailIgnoreCase(String email);

    Optional<User> findByPhoneNumber(String phoneNumber);
    Optional<User> findByReferralCodeIgnoreCase(String referralCode);
    List<User> findByReferredByCodeIgnoreCase(String referredByCode);

    boolean existsByEmailIgnoreCase(String email);
    long countByReferredByCodeIgnoreCase(String referredByCode);

    List<User> findByRole(UserRole role);

    List<User> findByMerchantId(Long merchantId);
}
