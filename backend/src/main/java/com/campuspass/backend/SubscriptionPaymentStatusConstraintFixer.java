package com.campuspass.backend;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.boot.CommandLineRunner;
import org.springframework.jdbc.core.JdbcTemplate;
import org.springframework.stereotype.Component;

@Component
public class SubscriptionPaymentStatusConstraintFixer implements CommandLineRunner {

    private static final Logger log = LoggerFactory.getLogger(SubscriptionPaymentStatusConstraintFixer.class);
    private final JdbcTemplate jdbcTemplate;

    public SubscriptionPaymentStatusConstraintFixer(JdbcTemplate jdbcTemplate) {
        this.jdbcTemplate = jdbcTemplate;
    }

    @Override
    public void run(String... args) {
        try {
            jdbcTemplate.execute("ALTER TABLE subscription_payments DROP CONSTRAINT IF EXISTS subscription_payments_status_check");
            jdbcTemplate.execute(
                    "ALTER TABLE subscription_payments " +
                    "ADD CONSTRAINT subscription_payments_status_check " +
                    "CHECK (status IN ('CREATED','PENDING','SUCCESS','FAILED','REFUNDED'))"
            );
        } catch (Exception e) {
            log.warn("Impossible de mettre a jour la contrainte subscription_payments_status_check: {}", e.getMessage());
        }
    }
}
