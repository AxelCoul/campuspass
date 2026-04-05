import 'package:dio/dio.dart';
import 'api_client.dart';

class StudentMe {
  final bool hasActiveSubscription;
  final String? subscriptionPlanName;
  final String? subscriptionEndDate;
  final bool studentVerified;
  final String? email;
  final String? phoneNumber;
  final String? city;
  final String? country;
  final String? university;
  final double totalSavings;
  final int points;
  final int referralBalance;
  final String? firstName;
  final String? lastName;
  final String? referralCode;
  final int? referralsCount;
  final String studentVerificationStatus;
  final String? studentVerificationRejectionReason;

  StudentMe({
    required this.hasActiveSubscription,
    this.subscriptionPlanName,
    this.subscriptionEndDate,
    required this.studentVerified,
    this.email,
    this.phoneNumber,
    this.city,
    this.country,
    this.university,
    this.totalSavings = 0,
    this.points = 0,
    this.referralBalance = 0,
    this.firstName,
    this.lastName,
    this.referralCode,
    this.referralsCount,
    this.studentVerificationStatus = 'NONE',
    this.studentVerificationRejectionReason,
  });

  factory StudentMe.fromJson(Map<String, dynamic> json) {
    return StudentMe(
      hasActiveSubscription: json['hasActiveSubscription'] as bool? ?? false,
      subscriptionPlanName: json['subscriptionPlanName'] as String?,
      subscriptionEndDate: json['subscriptionEndDate']?.toString(),
      studentVerified: json['studentVerified'] as bool? ?? false,
      email: json['email'] as String?,
      phoneNumber: json['phoneNumber'] as String?,
      city: json['city'] as String?,
      country: json['country'] as String?,
      university: json['university'] as String?,
      totalSavings: (json['totalSavings'] as num?)?.toDouble() ?? 0,
      points: ((json['loyaltyPoints'] ?? json['points']) as num?)?.toInt() ?? 0,
      referralBalance: (json['referralBalance'] as num?)?.toInt() ?? 0,
      firstName: json['firstName'] as String?,
      lastName: json['lastName'] as String?,
      referralCode: json['referralCode'] as String?,
      referralsCount: (json['referralsCount'] as num?)?.toInt(),
      studentVerificationStatus: json['studentVerificationStatus']?.toString() ?? 'NONE',
      studentVerificationRejectionReason: json['studentVerificationRejectionReason'] as String?,
    );
  }
}

class StudentService {
  StudentService._();
  static final StudentService instance = StudentService._();

  Future<StudentMeAndSavings> getMeWithSavings() async {
    final meFuture = getMe();
    final savingsFuture = _getSavings();
    final me = await meFuture;
    final savings = await savingsFuture;
    return StudentMeAndSavings(me: me, savings: savings);
  }

  Future<StudentMe> getMe() async {
    final Response<Map<String, dynamic>> res = await ApiClient.instance.dio.get('/student/me');
    final data = res.data ?? const {};
    return StudentMe.fromJson(data);
  }

  Future<void> updateArea({
    String? city,
    String? country,
  }) async {
    await ApiClient.instance.dio.patch(
      '/student/area',
      data: {
        'city': city,
        'country': country,
      },
    );
  }

  Future<void> updateProfile({
    required String firstName,
    required String email,
    String? phoneNumber,
    String? city,
  }) async {
    await ApiClient.instance.dio.patch(
      '/student/profile',
      data: {
        'firstName': firstName,
        'email': email,
        'phoneNumber': phoneNumber,
        'city': city,
      },
    );
  }

  Future<void> updatePassword({
    required String currentPassword,
    required String newPassword,
  }) async {
    await ApiClient.instance.dio.patch(
      '/student/password',
      data: {
        'currentPassword': currentPassword,
        'newPassword': newPassword,
      },
    );
  }

  Future<void> linkReferralCode(String referralCode) async {
    await ApiClient.instance.dio.patch(
      '/student/referral-code',
      data: {
        'referralCode': referralCode,
      },
    );
  }

  Future<void> requestReferralPayout() async {
    await ApiClient.instance.dio.post('/student/referral/payout-request');
  }

  Future<void> submitVerification({
    required String verificationDocumentType,
    required String studentCardNumber,
    required String studentCardImage,
    String? university,
    String? city,
    String? country,
  }) async {
    await ApiClient.instance.dio.post(
      '/student/verification',
      data: {
        'verificationDocumentType': verificationDocumentType,
        'studentCardNumber': studentCardNumber,
        'studentCardImage': studentCardImage,
        'university': university,
        'city': city,
        'country': country,
      },
    );
  }

  Future<StudentSavings> _getSavings() async {
    final Response<Map<String, dynamic>> res = await ApiClient.instance.dio.get('/student/savings');
    final data = res.data ?? const {};
    return StudentSavings.fromJson(data);
  }
}

class StudentSavings {
  final double totalSaved;
  final int offersUsedCount;
  final int merchantsVisitedCount;
  final List<SavingsEntry> history;

  StudentSavings({
    required this.totalSaved,
    required this.offersUsedCount,
    required this.merchantsVisitedCount,
    required this.history,
  });

  factory StudentSavings.fromJson(Map<String, dynamic> json) {
    final List<dynamic> rawHistory = json['history'] as List<dynamic>? ?? const [];
    return StudentSavings(
      totalSaved: (json['totalSaved'] as num?)?.toDouble() ?? 0,
      offersUsedCount: (json['offersUsedCount'] as num?)?.toInt() ?? 0,
      merchantsVisitedCount: (json['merchantsVisitedCount'] as num?)?.toInt() ?? 0,
      history: rawHistory
          .map(
            (e) => SavingsEntry.fromJson(e as Map<String, dynamic>),
          )
          .toList(),
    );
  }
}

class SavingsEntry {
  final int transactionId;
  final String merchantName;
  final String offerTitle;
  final double originalAmount;
  final double discountAmount;
  final double savedAmount;
  final String date;

  SavingsEntry({
    required this.transactionId,
    required this.merchantName,
    required this.offerTitle,
    required this.originalAmount,
    required this.discountAmount,
    required this.savedAmount,
    required this.date,
  });

  factory SavingsEntry.fromJson(Map<String, dynamic> json) {
    return SavingsEntry(
      transactionId: (json['transactionId'] as num?)?.toInt() ?? 0,
      merchantName: json['merchantName'] as String? ?? '',
      offerTitle: json['offerTitle'] as String? ?? '',
      originalAmount: (json['originalAmount'] as num?)?.toDouble() ?? 0,
      discountAmount: (json['discountAmount'] as num?)?.toDouble() ?? 0,
      savedAmount: (json['savedAmount'] as num?)?.toDouble() ?? 0,
      date: json['date']?.toString() ?? '',
    );
  }
}

class StudentMeAndSavings {
  final StudentMe me;
  final StudentSavings savings;

  StudentMeAndSavings({
    required this.me,
    required this.savings,
  });
}

