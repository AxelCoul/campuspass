import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../core/constants/api_constants.dart';
import '../core/theme/app_colors.dart';
import '../models/offer.dart';
import '../services/auth_service.dart';
import '../services/feature_flags_service.dart';
import '../services/offer_service.dart';

class OffersScreen extends StatefulWidget {
  const OffersScreen({super.key});

  @override
  State<OffersScreen> createState() => _OffersScreenState();
}

class _OffersScreenState extends State<OffersScreen> {
  List<Offer> _offers = [];
  bool _loading = true;
  String _filter = 'active'; // active | proposed | scheduled | expired | history

  static const _filters = [
    ('active', 'Offres actives', Icons.check_circle_outline),
    ('proposed', 'À valider', Icons.hourglass_empty_outlined),
    ('scheduled', 'Programmées', Icons.schedule),
    ('expired', 'Expirées', Icons.cancel_outlined),
    ('history', 'Historique', Icons.history),
  ];

  @override
  void initState() {
    super.initState();
    _load();
  }

  /// Appelé par MainShell pour rafraîchir quand on revient sur l'onglet Offres.
  void load() => _load();

  bool get _isStaff =>
      AuthService.instance.user?.merchantRole?.toUpperCase() == 'STAFF';

  bool get _canManageOffers =>
      !_isStaff && FeatureFlagsService.instance.merchantOfferManagementEnabled;

  Future<void> _load() async {
    final merchantId = AuthService.instance.merchantId;
    if (merchantId == null) return;
    setState(() => _loading = true);
    try {
      final list = await OfferService.instance.getByMerchantIdWithFilter(merchantId, _filter);
      if (mounted) setState(() => _offers = list);
    } catch (_) {}
    if (mounted) setState(() => _loading = false);
  }

  void _setFilter(String value) {
    if (_filter == value) return;
    setState(() => _filter = value);
    _load();
  }

  Future<void> _openCreate() async {
    await context.push('/offers/create');
    if (mounted) _load();
  }

  Future<void> _openEdit(Offer o) async {
    await context.push('/offers/edit/${o.id}');
    if (mounted) _load();
  }

  Future<void> _confirmDelete(Offer o) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Supprimer l\'offre ?'),
        content: Text('« ${o.title} » sera supprimée définitivement.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Annuler')),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: AppColors.danger),
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Supprimer'),
          ),
        ],
      ),
    );
    if (confirm != true || !mounted) return;
    try {
      await OfferService.instance.delete(o.id);
      if (mounted) _load();
    } catch (_) {}
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Offres'),
        backgroundColor: AppColors.card,
        foregroundColor: AppColors.text,
        actions: [
          if (_canManageOffers)
            IconButton(
              icon: const Icon(Icons.add),
              onPressed: _openCreate,
            ),
        ],
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.fromLTRB(12, 8, 12, 0),
            child: Row(
              children: _filters.map((f) {
                final selected = _filter == f.$1;
                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: FilterChip(
                    label: Text(f.$2),
                    avatar: Icon(f.$3, size: 18, color: selected ? Theme.of(context).colorScheme.onPrimary : null),
                    selected: selected,
                    onSelected: (_) => _setFilter(f.$1),
                    selectedColor: AppColors.primary.withValues(alpha: 0.3),
                    checkmarkColor: AppColors.primary,
                  ),
                );
              }).toList(),
            ),
          ),
          Expanded(
            child: _loading
                ? const Center(child: CircularProgressIndicator())
                : RefreshIndicator(
                    onRefresh: _load,
                    child: _offers.isEmpty
                        ? ListView(
                            children: [
                              const SizedBox(height: 48),
                              Icon(Icons.local_offer_outlined, size: 64, color: AppColors.textMuted),
                              const SizedBox(height: 16),
                              Text(
                                _emptyMessage,
                                textAlign: TextAlign.center,
                                style: TextStyle(fontSize: 18, color: AppColors.textMuted),
                              ),
                              const SizedBox(height: 8),
                              if (_canManageOffers)
                                Center(
                                  child: FilledButton.icon(
                                    onPressed: _openCreate,
                                    icon: const Icon(Icons.add),
                                    label: const Text('Créer une offre'),
                                    style: FilledButton.styleFrom(backgroundColor: AppColors.primary),
                                  ),
                                )
                              else
                                Padding(
                                  padding: const EdgeInsets.symmetric(horizontal: 24),
                                  child: Text(
                                    'Les offres sont gérées par l’équipe Campus Pass.',
                                    textAlign: TextAlign.center,
                                    style: TextStyle(fontSize: 14, color: AppColors.textMuted),
                                  ),
                                ),
                            ],
                          )
                        : ListView.builder(
                            padding: const EdgeInsets.all(16),
                            itemCount: _offers.length,
                            itemBuilder: (context, i) {
                              final o = _offers[i];
                              final showUsages = _filter == 'history' || _filter == 'expired';
                              return _OfferCard(
                                offer: o,
                                showUsages: showUsages,
                                canManage: _canManageOffers,
                                onEdit: () => _openEdit(o),
                                onDelete: () => _confirmDelete(o),
                              );
                            },
                          ),
                  ),
          ),
        ],
      ),
      floatingActionButton: _canManageOffers && _offers.isNotEmpty
          ? FloatingActionButton(
              onPressed: _openCreate,
              backgroundColor: AppColors.primary,
              child: const Icon(Icons.add),
            )
          : null,
    );
  }

  String get _emptyMessage {
    switch (_filter) {
      case 'active':
        return 'Aucune offre active';
      case 'proposed':
        return 'Aucune offre en attente de validation';
      case 'scheduled':
        return 'Aucune offre programmée';
      case 'expired':
        return 'Aucune offre expirée';
      case 'history':
        return 'Aucun historique';
      default:
        return 'Aucune offre';
    }
  }
}

class _OfferCard extends StatelessWidget {
  final Offer offer;
  final bool showUsages;
  final bool canManage;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const _OfferCard({
    required this.offer,
    this.showUsages = false,
    this.canManage = true,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final o = offer;
    final status = _statusInfo(o.status);
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          AspectRatio(
            aspectRatio: 2,
            child: o.imageUrl != null && o.imageUrl!.isNotEmpty
                ? Image.network(resolveImageUrl(o.imageUrl), fit: BoxFit.cover, errorBuilder: (_, __, ___) => _placeholder())
                : _placeholder(),
          ),
          Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        o.title,
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 4),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: AppColors.secondary.withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          o.discountLabel,
                          style: TextStyle(fontWeight: FontWeight.bold, color: AppColors.secondary),
                        ),
                      ),
                      if (o.priceDisplay != null) ...[
                        const SizedBox(height: 4),
                        Text(
                          o.priceDisplay!,
                          style: TextStyle(
                            fontSize: 12,
                            color: AppColors.textMuted,
                            decoration: TextDecoration.lineThrough,
                          ),
                        ),
                        Text(o.promoPriceDisplay, style: const TextStyle(fontWeight: FontWeight.bold)),
                      ],
                      const SizedBox(height: 4),
                      if (showUsages && (offer.usedCoupons ?? 0) > 0)
                        Padding(
                          padding: const EdgeInsets.only(bottom: 4),
                          child: Text(
                            'Utilisations : ${offer.usedCoupons}',
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              color: AppColors.primary,
                            ),
                          ),
                        ),
                      if (showUsages && offer.startDate != null && offer.endDate != null)
                        Padding(
                          padding: const EdgeInsets.only(bottom: 4),
                          child: Text(
                            '${offer.startDate} → ${offer.endDate}',
                            style: TextStyle(fontSize: 12, color: AppColors.textMuted),
                          ),
                        ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: status.color.withValues(alpha: 0.15),
                              borderRadius: BorderRadius.circular(999),
                            ),
                            child: Text(
                              status.label,
                              style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: status.color),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            'Valable jusqu\'au ${o.endDate ?? "—"}',
                            style: TextStyle(fontSize: 11, color: AppColors.textMuted),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                if (canManage) ...[
                  IconButton(icon: const Icon(Icons.edit_outlined), onPressed: onEdit),
                  IconButton(icon: const Icon(Icons.delete_outline), onPressed: onDelete),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _placeholder() {
    return Container(
      color: AppColors.textMuted.withValues(alpha: 0.15),
      child: const Center(child: Icon(Icons.image_not_supported_outlined, size: 48, color: AppColors.textMuted)),
    );
  }

  /// Libellé et couleur de statut, en français.
  ({String label, Color color}) _statusInfo(String? status) {
    switch (status) {
      case 'ACTIVE':
        return (label: 'Active (en ligne)', color: AppColors.success);
      case 'PROPOSED':
        return (label: 'Proposée — validation admin', color: AppColors.warning);
      case 'PENDING':
        return (label: 'En attente de validation', color: AppColors.warning);
      case 'EXPIRED':
        return (label: 'Expirée', color: AppColors.textMuted);
      case 'INACTIVE':
        return (label: 'Désactivée', color: AppColors.textMuted);
      default:
        return (label: status ?? 'Inconnu', color: AppColors.textMuted);
    }
  }
}
