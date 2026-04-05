package com.campuspass.backend.schedule;

import com.campuspass.backend.service.SubscriptionService;
import org.springframework.scheduling.annotation.Scheduled;
import org.springframework.stereotype.Component;

@Component
public class SubscriptionPaymentSyncScheduler {

    private final SubscriptionService subscriptionService;

    public SubscriptionPaymentSyncScheduler(SubscriptionService subscriptionService) {
        this.subscriptionService = subscriptionService;
    }

    @Scheduled(
            fixedDelayString = "${subscription.payment.hot-sync.fixed-delay-ms:25000}",
            initialDelayString = "${subscription.payment.hot-sync.initial-delay-ms:15000}"
    )
    public void syncHotWindowSubscriptionPayments() {
        subscriptionService.autoSyncHotWindowPayments();
    }

    @Scheduled(fixedDelayString = "${subscription.payment.sync.fixed-delay-ms:120000}")
    public void syncRecentSubscriptionPayments() {
        subscriptionService.autoSyncRecentPayments();
    }
}
