import 'package:dio/dio.dart';

import 'api_client.dart';
import 'student_service.dart';

class RewardsSummary {
  final int totalPoints;
  final int spentPoints;
  final int availablePoints;
  final int fcfaPerPoint;
  final int referralsCount;
  final int pointsPerReferral;
  final int referralBonusPoints;
  final List<RewardCatalogItem> catalog;

  RewardsSummary({
    required this.totalPoints,
    required this.spentPoints,
    required this.availablePoints,
    required this.fcfaPerPoint,
    required this.referralsCount,
    required this.pointsPerReferral,
    required this.referralBonusPoints,
    required this.catalog,
  });

  factory RewardsSummary.fromJson(Map<String, dynamic> json) {
    final rawCatalog = json['catalog'] as List<dynamic>? ?? const [];
    return RewardsSummary(
      totalPoints: (json['totalPoints'] as num?)?.toInt() ?? 0,
      spentPoints: (json['spentPoints'] as num?)?.toInt() ?? 0,
      availablePoints: (json['availablePoints'] as num?)?.toInt() ?? 0,
      fcfaPerPoint: (json['fcfaPerPoint'] as num?)?.toInt() ?? 500,
      referralsCount: (json['referralsCount'] as num?)?.toInt() ?? 0,
      pointsPerReferral: (json['pointsPerReferral'] as num?)?.toInt() ?? 5,
      referralBonusPoints: (json['referralBonusPoints'] as num?)?.toInt() ?? 0,
      catalog: rawCatalog
          .map((e) => RewardCatalogItem.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }
}

class RewardCatalogItem {
  final int id;
  final String title;
  final String description;
  final int pointsCost;
  final bool active;

  RewardCatalogItem({
    required this.id,
    required this.title,
    required this.description,
    required this.pointsCost,
    required this.active,
  });

  factory RewardCatalogItem.fromJson(Map<String, dynamic> json) {
    return RewardCatalogItem(
      id: (json['id'] as num?)?.toInt() ?? 0,
      title: json['title'] as String? ?? '',
      description: json['description'] as String? ?? '',
      pointsCost: (json['pointsCost'] as num?)?.toInt() ?? 0,
      active: json['active'] as bool? ?? true,
    );
  }
}

class RewardRedemption {
  final int id;
  final int rewardId;
  final String rewardTitle;
  final int pointsCost;
  final String redeemedAt;

  RewardRedemption({
    required this.id,
    required this.rewardId,
    required this.rewardTitle,
    required this.pointsCost,
    required this.redeemedAt,
  });

  factory RewardRedemption.fromJson(Map<String, dynamic> json) {
    return RewardRedemption(
      id: (json['id'] as num?)?.toInt() ?? 0,
      rewardId: (json['rewardId'] as num?)?.toInt() ?? 0,
      rewardTitle: json['rewardTitle'] as String? ?? '',
      pointsCost: (json['pointsCost'] as num?)?.toInt() ?? 0,
      redeemedAt: json['redeemedAt']?.toString() ?? '',
    );
  }
}

class RewardsService {
  RewardsService._();
  static final RewardsService instance = RewardsService._();

  static final List<RewardCatalogItem> _fallbackCatalog = [
    RewardCatalogItem(
      id: 1,
      title: 'Boisson offerte',
      description: '1 boisson gratuite chez les partenaires participants.',
      pointsCost: 120,
      active: true,
    ),
    RewardCatalogItem(
      id: 2,
      title: 'Dessert offert',
      description: 'Un dessert offert sur une commande eligibile.',
      pointsCost: 200,
      active: true,
    ),
    RewardCatalogItem(
      id: 3,
      title: 'Reduction 2 000 FCFA',
      description: 'Bon de reduction valable sur une prochaine commande.',
      pointsCost: 300,
      active: true,
    ),
    RewardCatalogItem(
      id: 4,
      title: 'Reduction 5 000 FCFA',
      description: 'Bon de reduction premium valable chez nos partenaires.',
      pointsCost: 650,
      active: true,
    ),
  ];

  Future<RewardsSummary> getSummary() async {
    try {
      final Response<Map<String, dynamic>> res =
          await ApiClient.instance.dio.get('/student/rewards');
      final data = res.data ?? const {};
      return RewardsSummary.fromJson(data);
    } on DioException catch (e) {
      // Compatibilité : si le backend n'a pas encore les endpoints rewards,
      // on affiche quand même les points dynamiques depuis /student/me.
      final status = e.response?.statusCode ?? 0;
      if (status == 404 || status == 405 || status >= 500) {
        final me = await StudentService.instance.getMe();
        return RewardsSummary(
          totalPoints: me.points,
          spentPoints: 0,
          availablePoints: me.points,
          fcfaPerPoint: 500,
          referralsCount: 0,
          pointsPerReferral: 5,
          referralBonusPoints: 0,
          catalog: _fallbackCatalog,
        );
      }
      rethrow;
    }
  }

  Future<List<RewardRedemption>> getHistory() async {
    try {
      final Response<List<dynamic>> res =
          await ApiClient.instance.dio.get('/student/rewards/history');
      final raw = res.data ?? const [];
      return raw
          .map((e) => RewardRedemption.fromJson(e as Map<String, dynamic>))
          .toList();
    } on DioException catch (e) {
      final status = e.response?.statusCode ?? 0;
      if (status == 404 || status == 405 || status >= 500) {
        return const [];
      }
      rethrow;
    }
  }

  Future<RewardRedemption> redeem(int rewardId) async {
    final Response<Map<String, dynamic>> res =
        await ApiClient.instance.dio.post(
      '/student/rewards/redeem',
      data: {'rewardId': rewardId},
    );
    final data = res.data ?? const {};
    return RewardRedemption.fromJson(data);
  }
}
