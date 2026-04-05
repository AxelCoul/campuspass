package com.campuspass.backend.repository;

import com.campuspass.backend.model.StudentSubscription;
import com.campuspass.backend.model.enums.SubscriptionStatus;
import org.springframework.data.jpa.repository.JpaRepository;
import java.util.List;
import java.util.Optional;

public interface StudentSubscriptionRepository extends JpaRepository<StudentSubscription, Long> {
    List<StudentSubscription> findByStudentIdOrderByEndDateDesc(Long studentId);
    List<StudentSubscription> findByStudentIdOrderByStartDateAsc(Long studentId);
    Optional<StudentSubscription> findFirstByStudentIdAndStatusOrderByEndDateDesc(Long studentId, SubscriptionStatus status);
    Optional<StudentSubscription> findFirstByStudentIdOrderByStartDateAsc(Long studentId);
}
