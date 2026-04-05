import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../models/category.dart';
import '../../models/merchant.dart';
import '../../services/categories_service.dart';
import '../../services/merchants_service.dart';
import '../../services/favorites_service.dart';
import '../../shared_widgets/cards/merchant_card.dart';
import '../../shared_widgets/chips/category_chip.dart';
import '../../shared_widgets/layout/search_bar.dart';

class MerchantsScreen extends StatefulWidget {
  const MerchantsScreen({super.key});

  @override
  State<MerchantsScreen> createState() => _MerchantsScreenState();
}

class _MerchantsScreenState extends State<MerchantsScreen> {
  late Future<_MerchantsData> _future;
  String _selectedCategoryKey = 'all';
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _future = _load();
  }

  Future<_MerchantsData> _load() async {
    final merchants = await MerchantsService.instance.getAll();
    final categories = await CategoriesService.instance.getAll();
    await FavoritesService.instance.preload();
    return _MerchantsData(merchants: merchants, categories: categories);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Commerces autour de toi',
              style: AppTextStyles.body(context).copyWith(fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 2),
            Text(
              'Découvre les lieux où utiliser ton PASS CAMPUS',
              style: AppTextStyles.caption(context).copyWith(
                color: AppColors.textMuted,
              ),
            ),
          ],
        ),
      ),
      body: FutureBuilder<_MerchantsData>(
        future: _future,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text('Impossible de charger les commerces.'),
                  const SizedBox(height: 8),
                  TextButton(
                    onPressed: () {
                      setState(() {
                        _future = _load();
                      });
                    },
                    child: const Text('Réessayer'),
                  ),
                ],
              ),
            );
          }

          final data = snapshot.data!;

          final filtered = data.merchants.where((merchant) {
            final catKey = merchant.categoryId?.toString() ?? '';
            final matchesCategory =
                _selectedCategoryKey == 'all' || catKey == _selectedCategoryKey;
            final name = merchant.name.toLowerCase();
            final query = _searchQuery.toLowerCase();
            final matchesSearch =
                query.isEmpty || name.contains(query);
            return matchesCategory && matchesSearch;
          }).toList();

          return Column(
            children: [
              // Zone de recherche + catégories (comme la maquette)
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SearchBarHome(
                      placeholder: 'Rechercher un commerce...',
                      onChanged: (value) {
                        setState(() {
                          _searchQuery = value;
                        });
                      },
                    ),
                    const SizedBox(height: 8),
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: data.categories.map((c) {
                          final key = c.id.toString();
                          final selected = _selectedCategoryKey == key;
                          final label = _buildChipLabel(c);
                          return Padding(
                            padding: const EdgeInsets.only(right: 8),
                            child: CategoryChip(
                              label: label,
                              isSelected: selected,
                              onTap: () {
                                setState(() {
                                  _selectedCategoryKey = key;
                                });
                              },
                            ),
                          );
                        }).toList(),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 8),
              Expanded(
                child: filtered.isEmpty
                    ? Center(
                        child: Text(
                          'Aucun commerce trouvé',
                          style: AppTextStyles.bodySecondary(context),
                        ),
                      )
                    : ListView.separated(
                        padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
                        itemCount: filtered.length,
                        separatorBuilder: (_, __) =>
                            const SizedBox(height: 12),
                        itemBuilder: (context, index) {
                          final merchant = filtered[index];
                          final category = data.categoryById(merchant.categoryId);
                          final categoryLabel =
                              '${category?.icon ?? '🍔'} ${category?.name ?? ''}';

                          return MerchantCard(
                            merchant: merchant,
                            categoryLabel: categoryLabel,
                            isFavorite: FavoritesService.instance
                                .isMerchantFavoriteSync(merchant.id),
                            onToggleFavorite: () async {
                              await FavoritesService.instance
                                  .toggleMerchantFavorite(merchant.id);
                              if (context.mounted) {
                                setState(() {});
                              }
                            },
                            onTap: () {
                              // La navigation vers le détail est déjà gérée
                              // par ExploreScreen via MerchantCard, mais ici
                              // on laisse le parent décider si besoin.
                              Navigator.of(context).pop(merchant);
                            },
                          );
                        },
                      ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _MerchantsData {
  _MerchantsData({
    required this.merchants,
    required this.categories,
  });

  final List<Merchant> merchants;
  final List<Category> categories;

  Category? categoryById(int? id) {
    if (id == null) return null;
    try {
      return categories.firstWhere((c) => c.id == id);
    } catch (_) {
      return null;
    }
  }
}

String _buildChipLabel(Category category) {
  if (category.icon != null && category.icon!.isNotEmpty) {
    return '${category.icon} ${category.name}';
  }

  switch (category.name.toLowerCase()) {
    case 'restaurant':
      return '🍔 Restaurant';
    case 'café':
    case 'cafe':
      return '☕ Café';
    case 'shopping':
      return '🛍️ Shopping';
    case 'sport':
      return '⚽ Sport';
    case 'culture':
      return '🎭 Culture';
    case 'transport':
      return '🚌 Transport';
    default:
      return '🏪 ${category.name}';
  }
}

