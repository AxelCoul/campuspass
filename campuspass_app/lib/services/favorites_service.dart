import 'package:dio/dio.dart';

import 'api_client.dart';

/// Gestion des favoris synchronisée avec le backend (IDs d'offres et de commerces) + cache local en mémoire.
class FavoritesService {
  FavoritesService._();
  static final FavoritesService instance = FavoritesService._();

  Set<int> _offerIds = {};
  Set<int> _merchantIds = {};
  bool _initialized = false;

  Future<void> _ensureLoaded() async {
    if (_initialized) return;
    final Response<List<dynamic>> offersRes =
        await ApiClient.instance.dio.get('/favorites');
    final offersData = offersRes.data ?? const [];
    _offerIds = offersData.map((e) => (e as num).toInt()).toSet();

    final Response<List<dynamic>> merchantsRes =
        await ApiClient.instance.dio.get('/merchant-favorites');
    final merchantsData = merchantsRes.data ?? const [];
    _merchantIds = merchantsData.map((e) => (e as num).toInt()).toSet();
    _initialized = true;
  }

  Future<bool> isFavorite(int offerId) async {
    await _ensureLoaded();
    return _offerIds.contains(offerId);
  }

  /// Version synchrone utilisée après initialisation (pour éviter trop d'await dans les builds).
  bool isFavoriteSync(int offerId) {
    return _offerIds.contains(offerId);
  }

  Future<void> toggleFavorite(int offerId) async {
    await _ensureLoaded();
    if (_offerIds.contains(offerId)) {
      _offerIds.remove(offerId);
      await ApiClient.instance.dio.delete('/favorites/$offerId');
    } else {
      _offerIds.add(offerId);
      await ApiClient.instance.dio.post('/favorites/$offerId');
    }
  }

  Set<int> get currentIds => _offerIds;

  // ---------- Favoris commerces ----------

  Future<bool> isMerchantFavorite(int merchantId) async {
    await _ensureLoaded();
    return _merchantIds.contains(merchantId);
  }

  bool isMerchantFavoriteSync(int merchantId) {
    return _merchantIds.contains(merchantId);
  }

  Future<void> toggleMerchantFavorite(int merchantId) async {
    await _ensureLoaded();
    if (_merchantIds.contains(merchantId)) {
      _merchantIds.remove(merchantId);
      await ApiClient.instance.dio
          .delete('/merchant-favorites/$merchantId');
    } else {
      _merchantIds.add(merchantId);
      await ApiClient.instance.dio.post('/merchant-favorites/$merchantId');
    }
  }

  Set<int> get currentMerchantIds => _merchantIds;

  /// Optionnel : précharger les favoris au démarrage d'un écran.
  Future<void> preload() => _ensureLoaded();
}

