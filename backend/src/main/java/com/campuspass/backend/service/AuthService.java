package com.campuspass.backend.service;

import com.campuspass.backend.dto.AuthResponse;
import com.campuspass.backend.dto.LoginRequest;
import com.campuspass.backend.dto.RegisterRequest;
import com.campuspass.backend.model.Merchant;
import com.campuspass.backend.model.User;
import com.campuspass.backend.model.enums.MerchantStatus;
import com.campuspass.backend.model.enums.UserRole;
import com.campuspass.backend.model.StudentProfile;
import com.campuspass.backend.repository.MerchantRepository;
import com.campuspass.backend.repository.UserRepository;
import com.campuspass.backend.repository.AdminProfileRepository;
import com.campuspass.backend.repository.StudentProfileRepository;
import com.campuspass.backend.security.JwtService;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.time.LocalDateTime;

@Service
public class AuthService {

    private final UserRepository userRepository;
    private final MerchantRepository merchantRepository;
    private final AdminProfileRepository adminProfileRepository;
    private final StudentProfileRepository studentProfileRepository;
    private final PasswordEncoder passwordEncoder;
    private final JwtService jwtService;

    public AuthService(UserRepository userRepository, MerchantRepository merchantRepository,
                       AdminProfileRepository adminProfileRepository,
                       StudentProfileRepository studentProfileRepository,
                       PasswordEncoder passwordEncoder, JwtService jwtService) {
        this.userRepository = userRepository;
        this.merchantRepository = merchantRepository;
        this.adminProfileRepository = adminProfileRepository;
        this.studentProfileRepository = studentProfileRepository;
        this.passwordEncoder = passwordEncoder;
        this.jwtService = jwtService;
    }

    @Transactional
    public AuthResponse register(RegisterRequest req) {
        if (req.getEmail() != null && !req.getEmail().isBlank()) {
            if (userRepository.existsByEmailIgnoreCase(req.getEmail().trim().toLowerCase())) {
                throw new IllegalArgumentException("Un compte existe déjà avec cet email.");
            }
        }
        User user = new User();
        user.setFirstName(req.getFirstName());
        user.setLastName(req.getLastName());
        if (req.getEmail() != null && !req.getEmail().isBlank()) {
            user.setEmail(req.getEmail().trim().toLowerCase());
        }
        user.setPassword(passwordEncoder.encode(req.getPassword()));
        user.setPhoneNumber(req.getPhoneNumber());
        user.setRole(req.getRole());
        if (req.getRole() == UserRole.STUDENT && req.getReferralCode() != null && !req.getReferralCode().isBlank()) {
            String referralInput = req.getReferralCode().trim().toUpperCase();
            User inviter = userRepository.findByReferralCodeIgnoreCase(referralInput)
                    .orElseThrow(() -> new IllegalArgumentException("Code de parrainage invalide."));
            user.setReferredByCode(inviter.getReferralCode());
            user.setReferredByLinkedAt(LocalDateTime.now());
        }
        if (req.getRole() == UserRole.MERCHANT) {
            // Par défaut, le compte créé est propriétaire du commerce.
            user.setMerchantRole(com.campuspass.backend.model.enums.MerchantRole.OWNER);
        }
        user.setCreatedAt(LocalDateTime.now());
        user.setUpdatedAt(LocalDateTime.now());
        user = userRepository.save(user);
        if (user.getReferralCode() == null || user.getReferralCode().isBlank()) {
            user.setReferralCode(("PASS" + user.getId()).toUpperCase());
            user = userRepository.save(user);
        }

        if (req.getRole() == UserRole.MERCHANT && req.getMerchantName() != null && !req.getMerchantName().isBlank()) {
            Merchant merchant = new Merchant();
            merchant.setOwnerId(user.getId());
            merchant.setName(req.getMerchantName());
            merchant.setEmail(user.getEmail());
            merchant.setCity(req.getCity());
            merchant.setCountry(req.getCountry());
            merchant.setCategoryId(req.getCategoryId());
            merchant.setStatus(MerchantStatus.PENDING);
            merchant.setCreatedAt(LocalDateTime.now());
            merchant.setUpdatedAt(LocalDateTime.now());
            merchant = merchantRepository.save(merchant);
            // Lier aussi le propriétaire à ce commerce
            user.setMerchantId(merchant.getId());
            user = userRepository.save(user);
        }
        if (req.getRole() == UserRole.STUDENT) {
            StudentProfile sp = new StudentProfile();
            sp.setUserId(user.getId());
            sp.setUniversity(req.getUniversity());
            sp.setStudentCardNumber(req.getMatricule());
            studentProfileRepository.save(sp);
        }

        String token = jwtService.generateToken(user.getId(), user.getEmail(), user.getRole().name());
        return new AuthResponse(
                token,
                user.getId(),
                user.getEmail(),
                user.getFirstName(),
                user.getLastName(),
                user.getRole(),
                null,
                user.getMerchantId(),
                user.getMerchantRole()
        );
    }

    public AuthResponse login(LoginRequest req) {
        // Permettre la connexion via email OU numéro de téléphone
        User user = userRepository.findByEmailIgnoreCase(req.getEmail())
                .orElseGet(() -> userRepository.findByPhoneNumber(req.getEmail())
                        .orElseThrow(() -> new IllegalArgumentException("Email ou mot de passe incorrect.")));
        if (!passwordEncoder.matches(req.getPassword(), user.getPassword())) {
            throw new IllegalArgumentException("Email ou mot de passe incorrect.");
        }
        user.setLastLogin(LocalDateTime.now());
        userRepository.save(user);

        String token = jwtService.generateToken(user.getId(), user.getEmail(), user.getRole().name());
        return new AuthResponse(
                token,
                user.getId(),
                user.getEmail(),
                user.getFirstName(),
                user.getLastName(),
                user.getRole(),
                null,
                user.getMerchantId(),
                user.getMerchantRole()
        );
    }

    /** Connexion réservée aux utilisateurs avec rôle ADMIN (panneau admin). */
    public AuthResponse loginAdmin(LoginRequest req) {
        User user = userRepository.findByEmailIgnoreCase(req.getEmail())
                .orElseThrow(() -> new IllegalArgumentException("Email ou mot de passe incorrect."));
        if (!passwordEncoder.matches(req.getPassword(), user.getPassword())) {
            throw new IllegalArgumentException("Email ou mot de passe incorrect.");
        }
        if (user.getRole() != UserRole.ADMIN) {
            throw new IllegalArgumentException("Accès réservé aux administrateurs.");
        }
        user.setLastLogin(LocalDateTime.now());
        userRepository.save(user);
        String token = jwtService.generateToken(user.getId(), user.getEmail(), user.getRole().name());
        String adminLevel = adminProfileRepository.findByUserId(user.getId())
                .map(ap -> ap.getPermissions() != null ? ap.getPermissions() : "ADMIN")
                .orElse("ADMIN");
        return new AuthResponse(
                token,
                user.getId(),
                user.getEmail(),
                user.getFirstName(),
                user.getLastName(),
                user.getRole(),
                adminLevel,
                null,
                null
        );
    }
}
