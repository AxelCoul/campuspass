package com.campuspass.backend.repository;

import com.campuspass.backend.model.Transaction;
import org.springframework.data.jpa.repository.JpaRepository;

import java.util.List;

public interface TransactionRepository extends JpaRepository<Transaction, Long> {

    List<Transaction> findByUserIdOrderByTransactionDateDesc(Long userId);

    List<Transaction> findByMerchantIdOrderByTransactionDateDesc(Long merchantId);
}
