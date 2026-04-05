import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../core/constants/api_constants.dart';
import '../core/theme/app_colors.dart';
import '../models/transaction.dart';
import '../services/auth_service.dart';
import '../services/transaction_service.dart';
import '../widgets/error_view.dart';

class TransactionsScreen extends StatefulWidget {
  const TransactionsScreen({super.key});

  @override
  State<TransactionsScreen> createState() => _TransactionsScreenState();
}

class _TransactionsScreenState extends State<TransactionsScreen> {
  List<Transaction> _list = [];
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final merchantId = AuthService.instance.merchantId;
    if (merchantId == null) {
      setState(() {
        _loading = false;
        _error = 'Commerce non associé';
      });
      return;
    }
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final list = await TransactionService.instance.getByMerchantId(merchantId);
      if (mounted) setState(() => _list = list);
    } catch (e) {
      if (mounted) setState(() => _error = e.toString().replaceFirst('Exception: ', ''));
    }
    if (mounted) setState(() => _loading = false);
  }

  String _formatDate(String? iso) {
    if (iso == null) return '–';
    try {
      final dt = DateTime.tryParse(iso);
      return dt != null ? DateFormat('dd/MM/yyyy HH:mm').format(dt) : iso;
    } catch (_) {
      return iso;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Transactions'),
        backgroundColor: AppColors.card,
        foregroundColor: AppColors.text,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loading ? null : _load,
          ),
        ],
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
              ? ErrorView(message: _error!, onRetry: _load)
              : _list.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.receipt_long_outlined, size: 64, color: AppColors.textMuted),
                          const SizedBox(height: 16),
                          Text(
                            'Aucune transaction',
                            style: TextStyle(fontSize: 18, color: AppColors.textMuted),
                          ),
                        ],
                      ),
                    )
                  : RefreshIndicator(
                      onRefresh: _load,
                      child: ListView.builder(
                        padding: const EdgeInsets.all(16),
                        itemCount: _list.length,
                        itemBuilder: (context, index) {
                          final t = _list[index];
                          return Card(
                            margin: const EdgeInsets.only(bottom: 12),
                            child: ListTile(
                              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                              leading: CircleAvatar(
                                backgroundColor: AppColors.primary.withValues(alpha: 0.2),
                                child: Icon(Icons.receipt, color: AppColors.primary),
                              ),
                              title: Text(
                                '${t.finalAmount?.toStringAsFixed(0) ?? "–"} $kCurrencySymbol',
                                style: const TextStyle(fontWeight: FontWeight.bold),
                              ),
                              subtitle: Text(
                                '${_formatDate(t.transactionDate)} • Offre #${t.offerId}',
                                style: TextStyle(fontSize: 12, color: AppColors.textMuted),
                              ),
                              trailing: Chip(
                                label: Text(t.status, style: const TextStyle(fontSize: 11)),
                                backgroundColor: t.status == 'SUCCESS'
                                    ? AppColors.success.withValues(alpha: 0.2)
                                    : AppColors.textMuted.withValues(alpha: 0.2),
                              ),
                            ),
                          );
                        },
                      ),
                    ),
    );
  }
}
