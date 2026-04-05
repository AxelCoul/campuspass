package com.campuspass.backend;

import com.campuspass.backend.model.AdminProfile;
import com.campuspass.backend.model.User;
import com.campuspass.backend.model.enums.UserRole;
import com.campuspass.backend.repository.AdminProfileRepository;
import com.campuspass.backend.repository.UserRepository;
import org.springframework.boot.CommandLineRunner;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.stereotype.Component;

@Component
public class DefaultAdminLoader implements CommandLineRunner {

    private final UserRepository userRepository;
    private final AdminProfileRepository adminProfileRepository;
    private final PasswordEncoder passwordEncoder;

    public DefaultAdminLoader(UserRepository userRepository, AdminProfileRepository adminProfileRepository, PasswordEncoder passwordEncoder) {
        this.userRepository = userRepository;
        this.adminProfileRepository = adminProfileRepository;
        this.passwordEncoder = passwordEncoder;
    }

    @Override
    public void run(String... args) {
        String email = "admin@passcampus.com";
        userRepository.findByEmailIgnoreCase(email).ifPresentOrElse(
                u -> {
                    u.setPassword(passwordEncoder.encode("admin123"));
                    u.setRole(UserRole.ADMIN);
                    userRepository.save(u);
                    adminProfileRepository.findByUserId(u.getId()).ifPresentOrElse(
                            ap -> { ap.setPermissions("SUPER_ADMIN"); adminProfileRepository.save(ap); },
                            () -> {
                                AdminProfile ap = new AdminProfile();
                                ap.setUserId(u.getId());
                                ap.setPermissions("SUPER_ADMIN");
                                adminProfileRepository.save(ap);
                            }
                    );
                },
                () -> {
                    User admin = new User();
                    admin.setEmail(email);
                    admin.setFirstName("Admin");
                    admin.setLastName("Pass Campus");
                    admin.setPassword(passwordEncoder.encode("admin123"));
                    admin.setRole(UserRole.ADMIN);
                    admin.setCreatedAt(java.time.LocalDateTime.now());
                    admin.setUpdatedAt(java.time.LocalDateTime.now());
                    userRepository.save(admin);
                    AdminProfile ap = new AdminProfile();
                    ap.setUserId(admin.getId());
                    ap.setPermissions("SUPER_ADMIN");
                    adminProfileRepository.save(ap);
                }
        );
    }
}
