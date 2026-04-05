import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../services/rewards_service.dart';

class RewardsScreen extends StatefulWidget {
  const RewardsScreen({super.key});

  @override
  State<RewardsScreen> createState() => _RewardsScreenState();
}

class _RewardsScreenState extends State<RewardsScreen> {
  late Future<_RewardsData> _future;

  @override
  void initState() {
    super.initState();
    _future = _load();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Points & cadeaux'),
      ),
      body: FutureBuilder<_RewardsData>(
        future: _future,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError || !snapshot.hasData) {
            return Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text('Impossible de charger tes points.'),
                  const SizedBox(height: 8),
                  TextButton(
                    onPressed: () {
                      setState(() {
                        _future = _load();
                      });
                    },
                    child: const Text('Reessayer'),
                  ),
                ],
              ),
            );
          }

          final data = snapshot.data!;
          final summary = data.summary;
          final history = data.history;

          return SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _PointsCard(
                  currentPoints: summary.totalPoints,
                  spentPoints: summary.spentPoints,
                  availablePoints: summary.availablePoints,
                ),
                const SizedBox(height: 16),
                _HowToEarnPoints(fcfaPerPoint: summary.fcfaPerPoint),
                const SizedBox(height: 8),
                _ReferralBonusInfo(
                  referralsCount: summary.referralsCount,
                  pointsPerReferral: summary.pointsPerReferral,
                  referralBonusPoints: summary.referralBonusPoints,
                ),
                const SizedBox(height: 16),
                Text(
                  'Catalogue cadeaux',
                  style: AppTextStyles.h2(context),
                ),
                const SizedBox(height: 8),
                ...summary.catalog.map(
                  (reward) => Padding(
                    padding: const EdgeInsets.only(bottom: 10),
                    child: _RewardTile(
                      reward: reward,
                      canRedeem: summary.availablePoints >= reward.pointsCost,
                      onRedeem: () => _redeemReward(
                        reward: reward,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  'Historique des echanges',
                  style: AppTextStyles.h2(context),
                ),
                const SizedBox(height: 8),
                if (history.isEmpty)
                  Text(
                    "Tu n'as pas encore echange de points.",
                    style: AppTextStyles.bodySecondary(context),
                  )
                else
                  ...history.map(
                    (entry) => ListTile(
                      contentPadding: EdgeInsets.zero,
                      leading: const Icon(Icons.card_giftcard_outlined),
                      title: Text(entry.rewardTitle),
                      subtitle: Text(_formatApiDate(entry.redeemedAt)),
                      trailing: Text(
                        '-${entry.pointsCost} pts',
                        style: AppTextStyles.body(context).copyWith(
                          color: AppColors.primary,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          );
        },
      ),
    );
  }

  Future<_RewardsData> _load() async {
    final summaryFuture = RewardsService.instance.getSummary();
    final historyFuture = RewardsService.instance.getHistory();
    final summary = await summaryFuture;
    final history = await historyFuture;
    return _RewardsData(summary: summary, history: history);
  }

  Future<void> _redeemReward({
    required RewardCatalogItem reward,
  }) async {
    try {
      await RewardsService.instance.redeem(reward.id);
      if (!mounted) return;
      setState(() {
        _future = _load();
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Cadeau obtenu : ${reward.title}')),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Echange impossible pour le moment.")),
      );
    }
  }

  String _formatApiDate(String raw) {
    final dt = DateTime.tryParse(raw);
    if (dt == null) return raw;
    final now = dt.toLocal();
    final d = now.day.toString().padLeft(2, '0');
    final m = now.month.toString().padLeft(2, '0');
    final y = now.year.toString();
    final h = now.hour.toString().padLeft(2, '0');
    final min = now.minute.toString().padLeft(2, '0');
    return '$d/$m/$y a $h:$min';
  }
}

class _RewardsData {
  _RewardsData({
    required this.summary,
    required this.history,
  });

  final RewardsSummary summary;
  final List<RewardRedemption> history;
}

class _PointsCard extends StatelessWidget {
  const _PointsCard({
    required this.currentPoints,
    required this.spentPoints,
    required this.availablePoints,
  });

  final int currentPoints;
  final int spentPoints;
  final int availablePoints;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(14),
        color: Colors.white,
        border: Border.all(color: const Color(0xFFE8EAF0)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Ton solde de points',
            style: AppTextStyles.body(context).copyWith(
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            '$availablePoints pts',
            style: AppTextStyles.h1(context).copyWith(
              color: AppColors.primary,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Total recu: $currentPoints pts  |  Utilises: $spentPoints pts',
            style: AppTextStyles.caption(context),
          ),
        ],
      ),
    );
  }
}

class _HowToEarnPoints extends StatelessWidget {
  const _HowToEarnPoints({required this.fcfaPerPoint});

  final int fcfaPerPoint;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(14),
        color: AppColors.primary.withValues(alpha: 0.06),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Comment obtenir des points ?',
            style: AppTextStyles.body(context).copyWith(
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '- Utiliser des offres PASS chez les marchands\n'
            '- Economiser de l\'argent avec ces offres\n'
            '- Chaque filleul avec abonnement actif te donne 5 points',
            style: AppTextStyles.body(context),
          ),
          const SizedBox(height: 6),
          Text(
            'Regle actuelle: 1 point pour $fcfaPerPoint FCFA economises.',
            style: AppTextStyles.caption(context),
          ),
        ],
      ),
    );
  }
}

class _ReferralBonusInfo extends StatelessWidget {
  const _ReferralBonusInfo({
    required this.referralsCount,
    required this.pointsPerReferral,
    required this.referralBonusPoints,
  });

  final int referralsCount;
  final int pointsPerReferral;
  final int referralBonusPoints;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        color: Colors.white,
        border: Border.all(color: const Color(0xFFE8EAF0)),
      ),
      child: Text(
        'Bonus parrainage: $referralsCount x $pointsPerReferral = $referralBonusPoints points',
        style: AppTextStyles.body(context).copyWith(fontWeight: FontWeight.w600),
      ),
    );
  }
}

class _RewardTile extends StatelessWidget {
  const _RewardTile({
    required this.reward,
    required this.canRedeem,
    required this.onRedeem,
  });

  final RewardCatalogItem reward;
  final bool canRedeem;
  final VoidCallback onRedeem;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE8EAF0)),
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: AppColors.background,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(
              _iconForReward(reward.title),
              color: AppColors.secondary,
              size: 22,
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  reward.title,
                  style: AppTextStyles.body(context).copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  reward.description,
                  style: AppTextStyles.caption(context),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '${reward.pointsCost} pts',
                style: AppTextStyles.body(context).copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 6),
              SizedBox(
                height: 30,
                child: ElevatedButton(
                  onPressed: canRedeem ? onRedeem : null,
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(horizontal: 10),
                  ),
                  child: const Text('Echanger'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  IconData _iconForReward(String title) {
    final t = title.toLowerCase();
    if (t.contains('boisson')) return Icons.local_drink_outlined;
    if (t.contains('dessert')) return Icons.icecream_outlined;
    if (t.contains('premium')) return Icons.workspace_premium_outlined;
    if (t.contains('reduction')) return Icons.sell_outlined;
    return Icons.card_giftcard_outlined;
  }
}
