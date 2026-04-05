import 'package:flutter/material.dart';

import '../../../core/theme/app_text_styles.dart';
import '../../../services/api_client.dart';

class PaymentHistoryScreen extends StatefulWidget {
  const PaymentHistoryScreen({super.key});

  @override
  State<PaymentHistoryScreen> createState() => _PaymentHistoryScreenState();
}

class _PaymentHistoryScreenState extends State<PaymentHistoryScreen> {
  late Future<List<_PaymentHistoryItem>> _paymentsFuture;

  @override
  void initState() {
    super.initState();
    _paymentsFuture = _loadPaymentHistory();
  }

  Future<List<_PaymentHistoryItem>> _loadPaymentHistory() async {
    final res = await ApiClient.instance.dio.get<List<dynamic>>('/subscription/payments');
    final data = res.data ?? const [];
    return data
        .map((e) => _PaymentHistoryItem.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Historique des paiements')),
      body: FutureBuilder<List<_PaymentHistoryItem>>(
        future: _paymentsFuture,
        builder: (context, snap) {
          if (snap.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snap.hasError) {
            return Center(
              child: Text(
                'Impossible de charger l’historique.',
                style: AppTextStyles.bodySecondary(context),
              ),
            );
          }
          final items = snap.data ?? const [];
          if (items.isEmpty) {
            return Center(
              child: Text(
                'Aucun paiement enregistré pour le moment.',
                style: AppTextStyles.bodySecondary(context),
              ),
            );
          }
          return ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: items.length,
            separatorBuilder: (_, __) => const Divider(height: 1),
            itemBuilder: (context, index) {
              final it = items[index];
              return ListTile(
                contentPadding: const EdgeInsets.symmetric(vertical: 6),
                title: Text(
                  it.planName,
                  style: AppTextStyles.body(context).copyWith(fontWeight: FontWeight.w700),
                ),
                subtitle: Text(
                  '${it.amount.toStringAsFixed(0)} ${it.currency} - ${it.status}',
                  style: AppTextStyles.bodySecondary(context),
                ),
                trailing: Text(
                  it.createdAt,
                  style: AppTextStyles.caption(context),
                ),
              );
            },
          );
        },
      ),
    );
  }
}

class _PaymentHistoryItem {
  final String planName;
  final double amount;
  final String currency;
  final String status;
  final String createdAt;

  const _PaymentHistoryItem({
    required this.planName,
    required this.amount,
    required this.currency,
    required this.status,
    required this.createdAt,
  });

  factory _PaymentHistoryItem.fromJson(Map<String, dynamic> json) {
    return _PaymentHistoryItem(
      planName: json['planName']?.toString() ?? 'Plan',
      amount: (json['amount'] as num?)?.toDouble() ?? 0.0,
      currency: json['currency']?.toString() ?? 'FCFA',
      status: json['status']?.toString() ?? 'PENDING',
      createdAt: json['createdAt']?.toString() ?? '',
    );
  }
}
