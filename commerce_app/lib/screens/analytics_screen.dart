import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../core/constants/api_constants.dart';
import '../core/theme/app_colors.dart';
import '../services/auth_service.dart';
import '../services/merchant_stats_service.dart';

class AnalyticsScreen extends StatefulWidget {
  const AnalyticsScreen({super.key});

  @override
  State<AnalyticsScreen> createState() => _AnalyticsScreenState();
}

class _AnalyticsScreenState extends State<AnalyticsScreen> {
  bool _loading = true;
  int _couponsToday = 0;
  double _revenueToday = 0.0;
  int _activeOffers = 0;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final merchantId = AuthService.instance.merchantId;
    if (merchantId == null) return;
    setState(() => _loading = true);
    try {
      final stats = await MerchantStatsService.instance.getByMerchantId(merchantId);
      if (mounted) setState(() {
        _couponsToday = stats.couponsUsedToday;
        _revenueToday = stats.revenueToday;
        _activeOffers = stats.activeOffersCount;
        _loading = false;
      });
    } catch (_) {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Statistiques'),
        backgroundColor: AppColors.card,
        foregroundColor: AppColors.text,
        leading: IconButton(icon: const Icon(Icons.arrow_back), onPressed: () => context.pop()),
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        children: [
                          Text('Coupons utilisés aujourd\'hui', style: TextStyle(color: AppColors.textMuted)),
                          const SizedBox(height: 8),
                          Text('$_couponsToday', style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: AppColors.primary)),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        children: [
                          Text('Revenu du jour', style: TextStyle(color: AppColors.textMuted)),
                          const SizedBox(height: 8),
                          Text('${_revenueToday.toStringAsFixed(0)} $kCurrencySymbol', style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: AppColors.secondary)),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        children: [
                          Text('Offres actives', style: TextStyle(color: AppColors.textMuted)),
                          const SizedBox(height: 8),
                          Text('$_activeOffers', style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: AppColors.success)),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
    );
  }
}
