package com.campuspass.backend.repository;

import com.campuspass.backend.model.Payment;
import org.springframework.data.jpa.repository.JpaRepository;

import java.util.List;
import java.util.Optional;

public interface PaymentRepository extends JpaRepository<Payment, Long> {

    Optional<Payment> findByTransactionId(Long transactionId);

    List<Payment> findByPaymentReference(String paymentReference);
}
