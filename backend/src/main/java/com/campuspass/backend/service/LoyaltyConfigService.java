package com.campuspass.backend.service;

import com.campuspass.backend.model.AppSetting;
import com.campuspass.backend.repository.AppSettingRepository;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.time.LocalDateTime;

@Service
public class LoyaltyConfigService {
    public static final String FCFA_PER_POINT_KEY = "LOYALTY_FCFA_PER_POINT";
    private static final int DEFAULT_FCFA_PER_POINT = 500;

    private final AppSettingRepository appSettingRepository;

    public LoyaltyConfigService(AppSettingRepository appSettingRepository) {
        this.appSettingRepository = appSettingRepository;
    }

    @Transactional(readOnly = true)
    public int getFcfaPerPoint() {
        return appSettingRepository.findById(FCFA_PER_POINT_KEY)
                .map(AppSetting::getSettingValue)
                .map(this::parsePositiveOrDefault)
                .orElse(DEFAULT_FCFA_PER_POINT);
    }

    @Transactional
    public int setFcfaPerPoint(int fcfaPerPoint) {
        if (fcfaPerPoint <= 0) {
            throw new IllegalArgumentException("fcfaPerPoint doit être > 0");
        }
        AppSetting setting = appSettingRepository.findById(FCFA_PER_POINT_KEY)
                .orElseGet(AppSetting::new);
        setting.setSettingKey(FCFA_PER_POINT_KEY);
        setting.setSettingValue(String.valueOf(fcfaPerPoint));
        setting.setUpdatedAt(LocalDateTime.now());
        appSettingRepository.save(setting);
        return fcfaPerPoint;
    }

    private int parsePositiveOrDefault(String value) {
        try {
            int parsed = Integer.parseInt(value);
            return parsed > 0 ? parsed : DEFAULT_FCFA_PER_POINT;
        } catch (Exception e) {
            return DEFAULT_FCFA_PER_POINT;
        }
    }
}
