package com.campuspass.backend.repository;

import com.campuspass.backend.model.SubscriptionPayment;
import com.campuspass.backend.model.enums.PaymentStatus;
import org.springframework.data.jpa.repository.JpaRepository;

import java.time.LocalDateTime;
import java.util.List;

public interface SubscriptionPaymentRepository extends JpaRepository<SubscriptionPayment, Long> {
    List<SubscriptionPayment> findByStudentIdOrderByCreatedAtDesc(Long studentId);
    List<SubscriptionPayment> findAllByOrderByCreatedAtDesc();
    List<SubscriptionPayment> findByStatusInAndCreatedAtAfterOrderByCreatedAtDesc(List<PaymentStatus> statuses, LocalDateTime createdAfter);
    List<SubscriptionPayment> findByStatusInAndCreatedAtBeforeOrderByCreatedAtDesc(List<PaymentStatus> statuses, LocalDateTime createdBefore);
    java.util.Optional<SubscriptionPayment> findByPaymentReference(String paymentReference);
}
