package com.campuspass.backend;

import com.campuspass.backend.model.SubscriptionPlan;
import com.campuspass.backend.model.enums.SubscriptionPlanType;
import com.campuspass.backend.repository.SubscriptionPlanRepository;
import org.springframework.boot.CommandLineRunner;
import org.springframework.stereotype.Component;

import java.time.LocalDate;
import java.time.LocalDateTime;

@Component
public class DefaultPlansLoader implements CommandLineRunner {

    private final SubscriptionPlanRepository subscriptionPlanRepository;

    public DefaultPlansLoader(SubscriptionPlanRepository subscriptionPlanRepository) {
        this.subscriptionPlanRepository = subscriptionPlanRepository;
    }

    @Override
    public void run(String... args) {
        if (subscriptionPlanRepository.count() > 0) return;
        // Plan mensuel par défaut : 1 500 FCFA / mois
        SubscriptionPlan monthly = new SubscriptionPlan();
        monthly.setName("Abonnement mensuel");
        monthly.setType(SubscriptionPlanType.MONTHLY);
        monthly.setPrice(1500.0);
        monthly.setActive(true);
        monthly.setCreatedAt(LocalDateTime.now());
        subscriptionPlanRepository.save(monthly);

        // Plan annuel par défaut : 12 000 FCFA / an (≈ 2 mois offerts)
        SubscriptionPlan yearly = new SubscriptionPlan();
        yearly.setName("Abonnement annuel");
        yearly.setType(SubscriptionPlanType.YEARLY);
        yearly.setPrice(12000.0);
        yearly.setActive(true);
        yearly.setCreatedAt(LocalDateTime.now());
        subscriptionPlanRepository.save(yearly);
    }
}
