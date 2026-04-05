import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../core/constants/api_constants.dart';
import '../core/theme/app_colors.dart';
import '../models/offer.dart';
import '../services/auth_service.dart';
import '../services/feature_flags_service.dart';
import '../services/merchant_stats_service.dart';
import '../services/offer_service.dart';
import '../widgets/error_view.dart';

/// Index des onglets [MainShell] : 0 Dashboard, 1 Scanner, 2 Offres, 3 Transactions, 4 Profil.
typedef OnMainTabSelected = void Function(int index);

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key, this.onSwitchTab});

  final OnMainTabSelected? onSwitchTab;

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  List<Offer> _offers = [];
  int _couponsToday = 0;
  double _revenueToday = 0.0;
  double _totalSalesViaApp = 0.0;
  double _totalDiscountsGiven = 0.0;
  int _uniqueClientsCount = 0;
  String? _topOfferTitle;
  int _topOfferUsageCount = 0;
  bool _loading = true;
  String? _error;

  static final _numberFr = NumberFormat.decimalPattern('fr_FR');

  @override
  void initState() {
    super.initState();
    _load();
  }

  void load() => _load();

  bool get _isStaff =>
      AuthService.instance.user?.merchantRole?.toUpperCase() == 'STAFF';

  bool get _showPerformance => !_isStaff;

  bool get _canManageOffers =>
      !_isStaff && FeatureFlagsService.instance.merchantOfferManagementEnabled;

  String _formatMoney(double value) =>
      '${_numberFr.format(value.round())} $kCurrencySymbol';

  Future<void> _load() async {
    final merchantId = AuthService.instance.merchantId;
    if (merchantId == null) return;
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final results = await Future.wait([
        OfferService.instance.getByMerchantId(merchantId),
        MerchantStatsService.instance.getByMerchantId(merchantId),
      ]);
      if (mounted) {
        setState(() {
          _offers = results[0] as List<Offer>;
          final stats = results[1] as MerchantStats;
          _couponsToday = stats.couponsUsedToday;
          _revenueToday = stats.revenueToday;
          _totalSalesViaApp = stats.totalSalesViaApp;
          _totalDiscountsGiven = stats.totalDiscountsGiven;
          _uniqueClientsCount = stats.uniqueClientsCount;
          _topOfferTitle = stats.topOfferTitle;
          _topOfferUsageCount = stats.topOfferUsageCount;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = e.toString().replaceFirst('Exception: ', '');
        });
      }
    }
    if (mounted) setState(() => _loading = false);
  }

  @override
  Widget build(BuildContext context) {
    final activeOffers = _offers.where((o) => o.status == 'ACTIVE').length;
    final totalOffers = _offers.length;
    final merchantRole =
        (AuthService.instance.user?.merchantRole ?? 'OWNER').toUpperCase();

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Dashboard'),
        backgroundColor: AppColors.card,
        foregroundColor: AppColors.text,
        elevation: 0,
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
              ? ErrorView(message: _error!, onRetry: _load)
              : RefreshIndicator(
                  onRefresh: _load,
                  child: SingleChildScrollView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Bienvenue, ${AuthService.instance.user?.firstName ?? "Commerçant"}',
                          style: const TextStyle(
                            fontSize: 18,
                            color: AppColors.textMuted,
                          ),
                        ),
                        if (_isStaff) ...[
                          const SizedBox(height: 6),
                          Text(
                            'Vue caisse — indicateurs du jour et catalogue',
                            style: TextStyle(
                              fontSize: 13,
                              color: AppColors.textMuted.withValues(alpha: 0.9),
                            ),
                          ),
                        ] else ...[
                          const SizedBox(height: 4),
                          Text(
                            'Rôle : ${merchantRole == 'OWNER' ? 'Propriétaire' : merchantRole == 'MANAGER' ? 'Responsable' : AuthService.instance.user?.merchantRole ?? merchantRole}',
                            style: TextStyle(
                              fontSize: 13,
                              color: AppColors.textMuted.withValues(alpha: 0.9),
                            ),
                          ),
                        ],
                        const SizedBox(height: 20),
                        const _SectionTitle(title: 'Aujourd\'hui'),
                        const SizedBox(height: 10),
                        _RevenueHeroCard(amount: _formatMoney(_revenueToday)),
                        const SizedBox(height: 12),
                        GridView.count(
                          crossAxisCount: 2,
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          mainAxisSpacing: 12,
                          crossAxisSpacing: 12,
                          childAspectRatio: 1.35,
                          children: [
                            _StatCard(
                              label: 'Coupons validés',
                              value: _numberFr.format(_couponsToday),
                              color: AppColors.primary,
                              icon: Icons.confirmation_number_outlined,
                            ),
                            _StatCard(
                              label: 'Moyenne / coupon',
                              value: _couponsToday > 0
                                  ? _formatMoney(_revenueToday / _couponsToday)
                                  : '—',
                              color: AppColors.secondary,
                              icon: Icons.payments_outlined,
                            ),
                          ],
                        ),
                        const SizedBox(height: 28),
                        const _SectionTitle(title: 'Catalogue'),
                        const SizedBox(height: 10),
                        GridView.count(
                          crossAxisCount: 2,
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          mainAxisSpacing: 12,
                          crossAxisSpacing: 12,
                          childAspectRatio: 1.35,
                          children: [
                            _StatCard(
                              label: 'Offres actives',
                              value: _numberFr.format(activeOffers),
                              color: AppColors.success,
                              icon: Icons.local_offer_outlined,
                            ),
                            _StatCard(
                              label: 'Total offres',
                              value: _numberFr.format(totalOffers),
                              color: AppColors.warning,
                              icon: Icons.inventory_2_outlined,
                            ),
                          ],
                        ),
                        if (_showPerformance) ...[
                          const SizedBox(height: 28),
                          const _SectionTitle(title: 'Performance'),
                          const SizedBox(height: 10),
                          GridView.count(
                            crossAxisCount: 2,
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            mainAxisSpacing: 12,
                            crossAxisSpacing: 12,
                            childAspectRatio: 1.35,
                            children: [
                              _StatCard(
                                label: 'Ventes via l’app',
                                value: _formatMoney(_totalSalesViaApp),
                                color: AppColors.primary,
                                icon: Icons.trending_up,
                              ),
                              _StatCard(
                                label: 'Réductions accordées',
                                value: _formatMoney(_totalDiscountsGiven),
                                color: AppColors.secondary,
                                icon: Icons.percent,
                              ),
                              _StatCard(
                                label: 'Clients uniques',
                                value: _numberFr.format(_uniqueClientsCount),
                                color: AppColors.success,
                                icon: Icons.groups_outlined,
                              ),
                            ],
                          ),
                          if (_topOfferTitle != null &&
                              _topOfferTitle!.isNotEmpty) ...[
                            const SizedBox(height: 12),
                            _TopOfferCard(
                              title: _topOfferTitle!,
                              usageCount: _topOfferUsageCount,
                            ),
                          ],
                        ],
                        const SizedBox(height: 28),
                        const _SectionTitle(title: 'Raccourcis'),
                        const SizedBox(height: 4),
                        Card(
                          elevation: 0,
                          color: AppColors.card,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Column(
                            children: [
                              _ShortcutTile(
                                icon: Icons.qr_code_scanner,
                                title: 'Scanner un coupon',
                                subtitle: 'Code ou QR étudiant',
                                onTap: () => widget.onSwitchTab?.call(1),
                              ),
                              if (_canManageOffers) const Divider(height: 1),
                              if (_canManageOffers)
                                _ShortcutTile(
                                  icon: Icons.add_circle_outline,
                                  title: 'Créer une offre',
                                  subtitle: 'Nouvelle promo Campus Pass',
                                  onTap: () => context.push('/offers/create'),
                                ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
    );
  }
}

/// Évite le débordement horizontal des [ListTile] (titre + sous-titre + chevron) sur petits écrans.
class _ShortcutTile extends StatelessWidget {
  const _ShortcutTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        child: Row(
          children: [
            Icon(icon, color: AppColors.primary, size: 26),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 16,
                      color: AppColors.text,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 13,
                      color: AppColors.textMuted,
                    ),
                  ),
                ],
              ),
            ),
            const Icon(Icons.chevron_right, color: AppColors.textMuted),
          ],
        ),
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle({required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    return Text(
      title,
      style: Theme.of(context).textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
            color: AppColors.text,
          ),
    );
  }
}

class _RevenueHeroCard extends StatelessWidget {
  const _RevenueHeroCard({required this.amount});

  final String amount;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 22),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppColors.primary.withValues(alpha: 0.12),
            AppColors.primary.withValues(alpha: 0.05),
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.primary.withValues(alpha: 0.15)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.18),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(
              Icons.account_balance_wallet_outlined,
              color: AppColors.primary,
              size: 28,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Revenu du jour',
                  style: TextStyle(
                    fontSize: 13,
                    color: AppColors.textMuted.withValues(alpha: 0.95),
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  amount,
                  style: const TextStyle(
                    fontSize: 26,
                    fontWeight: FontWeight.bold,
                    color: AppColors.primary,
                    height: 1.1,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  const _StatCard({
    required this.label,
    required this.value,
    required this.color,
    required this.icon,
  });

  final String label;
  final String value;
  final Color color;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      color: AppColors.card,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 22, color: color.withValues(alpha: 0.85)),
            const SizedBox(height: 10),
            Text(
              label,
              style: const TextStyle(fontSize: 12, color: AppColors.textMuted),
            ),
            const SizedBox(height: 4),
            Text(
              value,
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: color,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
}

class _TopOfferCard extends StatelessWidget {
  const _TopOfferCard({
    required this.title,
    required this.usageCount,
  });

  final String title;
  final int usageCount;

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      color: AppColors.card,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: AppColors.warning.withValues(alpha: 0.18),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(
                Icons.emoji_events_outlined,
                color: Color(0xFFB45309),
                size: 24,
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Offre la plus utilisée',
                    style: TextStyle(
                      fontSize: 12,
                      color: AppColors.textMuted,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: AppColors.text,
                      height: 1.25,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '$usageCount utilisation${usageCount > 1 ? 's' : ''}',
                    style: TextStyle(
                      fontSize: 13,
                      color: AppColors.textMuted.withValues(alpha: 0.95),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
