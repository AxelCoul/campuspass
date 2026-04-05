import 'api_client.dart';

/// Capacités pilotées par le backend (`GET /features/merchant-capabilities`).
class FeatureFlagsService {
  FeatureFlagsService._();
  static final FeatureFlagsService instance = FeatureFlagsService._();

  bool? _merchantOfferManagementEnabled;

  /// Par défaut `false` si pas encore chargé ou en erreur (comportement sûr).
  bool get merchantOfferManagementEnabled =>
      _merchantOfferManagementEnabled ?? false;

  Future<void> refresh() async {
    try {
      final res = await ApiClient.instance.dio.get<Map<String, dynamic>>(
        '/features/merchant-capabilities',
      );
      final data = res.data ?? {};
      _merchantOfferManagementEnabled =
          data['merchantOfferManagementEnabled'] == true ||
              data['canManageOffers'] == true;
    } catch (_) {
      _merchantOfferManagementEnabled = false;
    }
  }

  void clear() {
    _merchantOfferManagementEnabled = null;
  }
}
