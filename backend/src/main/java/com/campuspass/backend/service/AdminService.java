package com.campuspass.backend.service;

import com.campuspass.backend.dto.*;
import com.campuspass.backend.model.Coupon;
import com.campuspass.backend.model.Payment;
import com.campuspass.backend.model.Transaction;
import com.campuspass.backend.model.User;
import com.campuspass.backend.model.StudentProfile;
import com.campuspass.backend.model.AdminProfile;
import com.campuspass.backend.model.Offer;
import com.campuspass.backend.model.Review;
import com.campuspass.backend.model.Merchant;
import com.campuspass.backend.model.enums.CouponStatus;
import com.campuspass.backend.model.enums.OfferStatus;
import com.campuspass.backend.model.enums.PaymentStatus;
import com.campuspass.backend.model.enums.UserRole;
import com.campuspass.backend.model.enums.UserStatus;
import com.campuspass.backend.model.enums.ReviewStatus;
import com.campuspass.backend.model.enums.MerchantStatus;
import com.campuspass.backend.model.enums.StudentVerificationStatus;
import com.campuspass.backend.model.LoginHistory;
import com.campuspass.backend.util.MerchantRatingUtils;
import com.campuspass.backend.repository.*;
import org.springframework.data.domain.PageRequest;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.time.LocalDate;
import java.time.LocalDateTime;
import java.util.*;
import java.util.stream.Collectors;

@Service
public class AdminService {

    private final UserRepository userRepository;
    private final MerchantRepository merchantRepository;
    private final OfferRepository offerRepository;
    private final CouponRepository couponRepository;
    private final TransactionRepository transactionRepository;
    private final PaymentRepository paymentRepository;
    private final StudentProfileRepository studentProfileRepository;
    private final AdminProfileRepository adminProfileRepository;
    private final LoginHistoryRepository loginHistoryRepository;
    private final PasswordEncoder passwordEncoder;
    private final ReviewRepository reviewRepository;

    public AdminService(UserRepository userRepository, MerchantRepository merchantRepository,
                        OfferRepository offerRepository, CouponRepository couponRepository,
                        TransactionRepository transactionRepository, PaymentRepository paymentRepository,
                        StudentProfileRepository studentProfileRepository, AdminProfileRepository adminProfileRepository,
                        LoginHistoryRepository loginHistoryRepository, PasswordEncoder passwordEncoder,
                        ReviewRepository reviewRepository) {
        this.userRepository = userRepository;
        this.merchantRepository = merchantRepository;
        this.offerRepository = offerRepository;
        this.couponRepository = couponRepository;
        this.transactionRepository = transactionRepository;
        this.paymentRepository = paymentRepository;
        this.studentProfileRepository = studentProfileRepository;
        this.adminProfileRepository = adminProfileRepository;
        this.loginHistoryRepository = loginHistoryRepository;
        this.passwordEncoder = passwordEncoder;
        this.reviewRepository = reviewRepository;
    }

    public DashboardStatsDto getDashboardStats() {
        DashboardStatsDto dto = new DashboardStatsDto();
        dto.setTotalStudents(userRepository.findAll().stream().filter(u -> u.getRole() == UserRole.STUDENT).count());
        dto.setTotalMerchants(merchantRepository.count());
        dto.setActiveOffers(offerRepository.findAll().stream().filter(o -> o.getStatus() == OfferStatus.ACTIVE).count());
        LocalDate today = LocalDate.now();
        dto.setCouponsUsedToday(couponRepository.findAll().stream()
                .filter(c -> c.getStatus() == CouponStatus.USED && c.getUsedAt() != null && c.getUsedAt().toLocalDate().equals(today))
                .count());
        dto.setTotalTransactions(transactionRepository.count());
        List<Payment> successPayments = paymentRepository.findAll().stream()
                .filter(p -> p.getStatus() == PaymentStatus.SUCCESS).toList();
        double revenue = successPayments.stream().mapToDouble(p -> p.getAmount() != null ? p.getAmount() : 0.0).sum();
        dto.setRevenue(revenue);
        dto.setTotalSubscriptions(successPayments.size());
        double totalDiscounts = transactionRepository.findAll().stream()
                .mapToDouble(t -> t.getDiscountAmount() != null ? t.getDiscountAmount() : 0.0).sum();
        dto.setTotalDiscountsGenerated(totalDiscounts);
        return dto;
    }

    /** Statistiques paiements pour le dashboard admin (revenus, paiements aujourd'hui, mensuels). */
    public PaymentDashboardDto getPaymentDashboardStats() {
        PaymentDashboardDto dto = new PaymentDashboardDto();
        LocalDate today = LocalDate.now();
        LocalDateTime startOfMonth = today.atStartOfDay().withDayOfMonth(1);
        List<Payment> all = paymentRepository.findAll().stream()
                .filter(p -> p.getStatus() == PaymentStatus.SUCCESS).toList();
        dto.setTotalRevenue(all.stream().mapToDouble(p -> p.getAmount() != null ? p.getAmount() : 0.0).sum());
        dto.setPaymentsToday(all.stream().filter(p -> p.getPaidAt() != null && p.getPaidAt().toLocalDate().equals(today)).count());
        dto.setPaymentsThisMonth(all.stream().filter(p -> p.getPaidAt() != null && !p.getPaidAt().isBefore(startOfMonth)).count());
        return dto;
    }

    public List<UserResponseDto> getAllUsers() {
        return userRepository.findAll().stream().map(this::toUserDto).collect(Collectors.toList());
    }

    public UserResponseDto getUserById(Long id) {
        User u = userRepository.findById(id).orElseThrow(() -> new com.campuspass.backend.exception.ResourceNotFoundException("User", id));
        return toUserDto(u);
    }

    public List<CouponResponse> getAllCoupons() {
        return couponRepository.findAll().stream().map(this::toCouponResponse).collect(Collectors.toList());
    }

    public List<TransactionResponseDto> getAllTransactions() {
        return transactionRepository.findAll().stream().map(this::toTransactionDto).collect(Collectors.toList());
    }

    public List<PaymentResponseDto> getAllPayments() {
        return paymentRepository.findAll().stream().map(this::toPaymentDto).collect(Collectors.toList());
    }

    public List<StudentResponseDto> getStudents() {
        List<User> students = userRepository.findByRole(UserRole.STUDENT);
        return students.stream().map(u -> {
            StudentResponseDto dto = new StudentResponseDto();
            dto.setId(u.getId());
            dto.setFirstName(u.getFirstName());
            dto.setLastName(u.getLastName());
            dto.setEmail(u.getEmail());
            dto.setStatus(u.getStatus());
            dto.setCreatedAt(u.getCreatedAt());
            studentProfileRepository.findByUserId(u.getId()).ifPresent(sp -> {
                dto.setUniversity(sp.getUniversity());
                dto.setCity(sp.getCity());
                dto.setCountry(sp.getCountry());
                dto.setCardVerified(Boolean.TRUE.equals(sp.getVerified()));
                dto.setStudentCardNumber(sp.getStudentCardNumber());
                dto.setVerificationDocumentType(sp.getVerificationDocumentType());
                dto.setStudentCardImage(sp.getStudentCardImage());
                dto.setVerificationDate(sp.getVerificationDate());
                dto.setVerificationStatus(sp.getVerificationStatus() != null ? sp.getVerificationStatus().name() : StudentVerificationStatus.NONE.name());
                dto.setVerificationRejectionReason(sp.getVerificationRejectionReason());
            });
            long used = couponRepository.findByUserIdOrderByGeneratedAtDesc(u.getId()).stream()
                    .filter(c -> c.getStatus() == CouponStatus.USED).count();
            dto.setCouponsUsed((int) used);
            return dto;
        }).collect(Collectors.toList());
    }

    public void updateUserStatus(Long id, UserStatus status) {
        User u = userRepository.findById(id).orElseThrow(() -> new com.campuspass.backend.exception.ResourceNotFoundException("User", id));
        u.setStatus(status);
        u.setUpdatedAt(LocalDateTime.now());
        userRepository.save(u);
    }

    public void validateStudentCard(Long userId) {
        StudentProfile sp = studentProfileRepository.findByUserId(userId)
                .orElseGet(() -> {
                    StudentProfile p = new StudentProfile();
                    p.setUserId(userId);
                    p.setVerified(false);
                    return p;
                });
        sp.setVerified(true);
        sp.setVerificationStatus(StudentVerificationStatus.APPROVED);
        sp.setVerificationRejectionReason(null);
        sp.setVerificationDate(LocalDateTime.now());
        if (sp.getId() == null) studentProfileRepository.save(sp);
        else studentProfileRepository.save(sp);
    }

    public void rejectStudentCard(Long userId, String reason) {
        if (reason == null || reason.isBlank()) {
            throw new IllegalArgumentException("Motif de rejet requis.");
        }
        StudentProfile sp = studentProfileRepository.findByUserId(userId)
                .orElseGet(() -> {
                    StudentProfile p = new StudentProfile();
                    p.setUserId(userId);
                    p.setVerified(false);
                    p.setVerificationStatus(StudentVerificationStatus.NONE);
                    return p;
                });
        sp.setVerified(false);
        sp.setVerificationStatus(StudentVerificationStatus.REJECTED);
        sp.setVerificationRejectionReason(reason.trim());
        sp.setVerificationDate(LocalDateTime.now());
        studentProfileRepository.save(sp);
    }

    public List<AdminResponseDto> getAdmins() {
        return userRepository.findByRole(UserRole.ADMIN).stream().map(u -> {
            AdminResponseDto dto = new AdminResponseDto();
            dto.setId(u.getId());
            dto.setFirstName(u.getFirstName());
            dto.setLastName(u.getLastName());
            dto.setEmail(u.getEmail());
            dto.setStatus(u.getStatus());
            dto.setCreatedAt(u.getCreatedAt());
            adminProfileRepository.findByUserId(u.getId()).ifPresent(ap -> dto.setAdminLevel(ap.getPermissions() != null ? ap.getPermissions() : "ADMIN"));
            if (dto.getAdminLevel() == null) dto.setAdminLevel("ADMIN");
            return dto;
        }).collect(Collectors.toList());
    }

    @Transactional
    public AdminResponseDto createAdmin(CreateAdminRequest req) {
        if (userRepository.existsByEmailIgnoreCase(req.getEmail())) {
            throw new IllegalArgumentException("Un administrateur existe déjà avec cet email.");
        }
        User user = new User();
        user.setFirstName(req.getFirstName());
        user.setLastName(req.getLastName());
        user.setEmail(req.getEmail().trim().toLowerCase());
        user.setPassword(passwordEncoder.encode(req.getPassword()));
        user.setRole(UserRole.ADMIN);
        user.setStatus(UserStatus.ACTIVE);
        user.setCreatedAt(LocalDateTime.now());
        user.setUpdatedAt(LocalDateTime.now());
        user = userRepository.save(user);
        AdminProfile ap = new AdminProfile();
        ap.setUserId(user.getId());
        ap.setPermissions(req.getAdminLevel() != null && !req.getAdminLevel().isBlank() ? req.getAdminLevel() : "ADMIN");
        adminProfileRepository.save(ap);
        AdminResponseDto dto = new AdminResponseDto();
        dto.setId(user.getId());
        dto.setFirstName(user.getFirstName());
        dto.setLastName(user.getLastName());
        dto.setEmail(user.getEmail());
        dto.setAdminLevel(ap.getPermissions());
        dto.setStatus(user.getStatus());
        dto.setCreatedAt(user.getCreatedAt());
        return dto;
    }

    public void updateAdminLevel(Long id, String adminLevel) {
        User u = userRepository.findById(id).orElseThrow(() -> new com.campuspass.backend.exception.ResourceNotFoundException("User", id));
        if (u.getRole() != UserRole.ADMIN) throw new IllegalArgumentException("L'utilisateur n'est pas un administrateur.");
        AdminProfile ap = adminProfileRepository.findByUserId(id).orElseGet(() -> {
            AdminProfile p = new AdminProfile();
            p.setUserId(id);
            return p;
        });
        ap.setPermissions(adminLevel != null && !adminLevel.isBlank() ? adminLevel : "ADMIN");
        adminProfileRepository.save(ap);
    }

    public void disableAdmin(Long id) {
        updateUserStatus(id, UserStatus.SUSPENDED);
    }

    public boolean isSuperAdmin(Long userId) {
        if (userId == null) return false;
        return adminProfileRepository.findByUserId(userId)
                .map(ap -> ap.getPermissions() != null && "SUPER_ADMIN".equalsIgnoreCase(ap.getPermissions().trim()))
                .orElse(false);
    }

    public void requireSuperAdmin(Long userId) {
        if (!isSuperAdmin(userId)) {
            throw new IllegalArgumentException("Action reservee au SUPER_ADMIN.");
        }
    }

    public DashboardChartsDto getDashboardCharts() {
        DashboardChartsDto dto = new DashboardChartsDto();
        LocalDate end = LocalDate.now();
        LocalDate start = end.minusDays(6);
        List<PointDto> perDay = new ArrayList<>();
        for (LocalDate d = start; !d.isAfter(end); d = d.plusDays(1)) {
            LocalDate day = d;
            long count = transactionRepository.findAll().stream()
                    .filter(t -> t.getTransactionDate() != null && t.getTransactionDate().toLocalDate().equals(day))
                    .count();
            perDay.add(new PointDto(d, count));
        }
        dto.setTransactionsPerDay(perDay);

        List<PointDto> usersPerDay = new ArrayList<>();
        for (LocalDate d = start; !d.isAfter(end); d = d.plusDays(1)) {
            LocalDate day = d;
            long count = userRepository.findAll().stream()
                    .filter(u -> u.getCreatedAt() != null && u.getCreatedAt().toLocalDate().equals(day))
                    .count();
            usersPerDay.add(new PointDto(d, count));
        }
        dto.setNewUsersPerDay(usersPerDay);

        Map<Long, Long> offerCounts = new HashMap<>();
        for (Transaction t : transactionRepository.findAll()) {
            if (t.getOfferId() != null) {
                offerCounts.merge(t.getOfferId(), 1L, Long::sum);
            }
        }
        List<TopOfferDto> topOffers = offerCounts.entrySet().stream()
                .sorted((a, b) -> Long.compare(b.getValue(), a.getValue()))
                .limit(5)
                .map(e -> {
                    TopOfferDto to = new TopOfferDto();
                    to.setOfferId(e.getKey());
                    to.setUsageCount(e.getValue());
                    offerRepository.findById(e.getKey()).ifPresent(o -> to.setTitle(o.getTitle()));
                    return to;
                })
                .collect(Collectors.toList());
        dto.setTopOffers(topOffers);
        return dto;
    }

    public List<LogEntryDto> getLogs(int limit) {
        return loginHistoryRepository.findAllByOrderByLoginAtDesc(PageRequest.of(0, limit)).stream()
                .map(lh -> {
                    LogEntryDto e = new LogEntryDto();
                    e.setId(lh.getId());
                    e.setUserId(lh.getUserId());
                    e.setLoginAt(lh.getLoginAt());
                    e.setIpAddress(lh.getIpAddress());
                    e.setDevice(lh.getDevice());
                    userRepository.findById(lh.getUserId()).ifPresent(u -> e.setEmail(u.getEmail()));
                    return e;
                })
                .collect(Collectors.toList());
    }

    public List<ReviewResponse> getAllReviews(Long merchantId) {
        List<Review> list = merchantId != null
                ? reviewRepository.findByMerchantIdOrderByCreatedAtDesc(merchantId)
                : reviewRepository.findAll().stream().sorted((a, b) -> {
                    if (a.getCreatedAt() == null) return 1;
                    if (b.getCreatedAt() == null) return -1;
                    return b.getCreatedAt().compareTo(a.getCreatedAt());
                }).collect(Collectors.toList());
        return list.stream().map(this::toReviewResponse).collect(Collectors.toList());
    }

    public void updateReviewStatus(Long id, ReviewStatus status) {
        Review r = reviewRepository.findById(id).orElseThrow(() -> new com.campuspass.backend.exception.ResourceNotFoundException("Review", id));
        r.setStatus(status);
        reviewRepository.save(r);
    }

    /** Validation ou rejet d'un commerce par l'admin. */
    public MerchantResponse approveMerchant(Long id) {
        Merchant m = merchantRepository.findById(id)
                .orElseThrow(() -> new com.campuspass.backend.exception.ResourceNotFoundException("Merchant", id));
        m.setStatus(MerchantStatus.APPROVED);
        m.setVerified(true);
        m.setVerificationDate(LocalDateTime.now());
        m.setUpdatedAt(LocalDateTime.now());
        merchantRepository.save(m);
        return toMerchantResponse(m);
    }

    public void rejectMerchant(Long id) {
        Merchant m = merchantRepository.findById(id)
                .orElseThrow(() -> new com.campuspass.backend.exception.ResourceNotFoundException("Merchant", id));
        m.setStatus(MerchantStatus.REJECTED);
        m.setUpdatedAt(LocalDateTime.now());
        merchantRepository.save(m);
    }

    /** Mise à jour du statut d'une offre (validation / désactivation par l'admin). */
    public void updateOfferStatus(Long id, OfferStatus status) {
        Offer o = offerRepository.findById(id).orElseThrow(() -> new com.campuspass.backend.exception.ResourceNotFoundException("Offer", id));
        o.setStatus(status);
        o.setUpdatedAt(LocalDateTime.now());
        offerRepository.save(o);
    }

    private ReviewResponse toReviewResponse(Review r) {
        ReviewResponse res = new ReviewResponse();
        res.setId(r.getId());
        res.setUserId(r.getUserId());
        res.setMerchantId(r.getMerchantId());
        res.setRating(r.getRating());
        res.setComment(r.getComment());
        res.setStatus(r.getStatus());
        res.setCreatedAt(r.getCreatedAt());
        return res;
    }

    private CouponResponse toCouponResponse(Coupon c) {
        CouponResponse r = new CouponResponse();
        r.setId(c.getId());
        r.setUserId(c.getUserId());
        r.setOfferId(c.getOfferId());
        r.setCouponCode(c.getCouponCode());
        r.setQrCodeData(c.getQrCodeData());
        r.setStatus(c.getStatus());
        r.setGeneratedAt(c.getGeneratedAt());
        r.setExpiresAt(c.getExpiresAt());
        r.setUsedAt(c.getUsedAt());
        return r;
    }

    private TransactionResponseDto toTransactionDto(Transaction t) {
        TransactionResponseDto dto = new TransactionResponseDto();
        dto.setId(t.getId());
        dto.setCouponId(t.getCouponId());
        dto.setUserId(t.getUserId());
        dto.setMerchantId(t.getMerchantId());
        dto.setOfferId(t.getOfferId());
        dto.setOriginalAmount(t.getOriginalAmount());
        dto.setDiscountAmount(t.getDiscountAmount());
        dto.setFinalAmount(t.getFinalAmount());
        dto.setStatus(t.getStatus());
        dto.setTransactionDate(t.getTransactionDate());
        return dto;
    }

    private PaymentResponseDto toPaymentDto(Payment p) {
        PaymentResponseDto dto = new PaymentResponseDto();
        dto.setId(p.getId());
        dto.setTransactionId(p.getTransactionId());
        dto.setAmount(p.getAmount());
        dto.setCurrency(p.getCurrency());
        dto.setStatus(p.getStatus());
        dto.setPaidAt(p.getPaidAt());
        dto.setCreatedAt(p.getCreatedAt());
        return dto;
    }

    private UserResponseDto toUserDto(User u) {
        UserResponseDto dto = new UserResponseDto();
        dto.setId(u.getId());
        dto.setFirstName(u.getFirstName());
        dto.setLastName(u.getLastName());
        dto.setEmail(u.getEmail());
        dto.setPhoneNumber(u.getPhoneNumber());
        dto.setRole(u.getRole());
        dto.setMerchantRole(u.getMerchantRole());
        dto.setStatus(u.getStatus());
        dto.setCreatedAt(u.getCreatedAt());
        return dto;
    }

    private MerchantResponse toMerchantResponse(Merchant m) {
        MerchantResponse r = new MerchantResponse();
        r.setId(m.getId());
        r.setOwnerId(m.getOwnerId());
        r.setName(m.getName());
        r.setDescription(m.getDescription());
        r.setEmail(m.getEmail());
        r.setPhone(m.getPhone());
        r.setWebsite(m.getWebsite());
        r.setLogoUrl(m.getLogoUrl());
        r.setCoverImage(m.getCoverImage());
        r.setCategoryId(m.getCategoryId());
        r.setAddress(m.getAddress());
        r.setCity(m.getCity());
        r.setCountry(m.getCountry());
        r.setLatitude(m.getLatitude());
        r.setLongitude(m.getLongitude());
        r.setVerified(m.getVerified());
        r.setStatus(m.getStatus());
        r.setCreatedAt(m.getCreatedAt());
        var reviews = reviewRepository.findByMerchantIdOrderByCreatedAtDesc(m.getId());
        MerchantRatingUtils.applyAggregatedRating(r, reviews);
        return r;
    }
}
