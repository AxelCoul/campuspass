/// URL de base de l'API. Défaut = émulateur. Prod : `--dart-define=API_BASE_URL=...`
const String kApiBaseUrl = String.fromEnvironment(
  'API_BASE_URL',
  defaultValue: 'http://10.0.2.2:8081/api',
);
const String kServerBaseUrl = String.fromEnvironment(
  'SERVER_BASE_URL',
  defaultValue: 'http://10.0.2.2:8081',
);

/// Devise affichée dans l'app (Franc CFA).
const String kCurrency = 'FCFA';
const String kCurrencySymbol = 'FCFA';

const String kTokenKey = 'merchant_token';
const String kUserIdKey = 'merchant_user_id';
const String kMerchantIdKey = 'merchant_id';

/// Retourne l'URL complète pour afficher une image (backend peut renvoyer /uploads/... ou une URL complète).
String resolveImageUrl(String? url) {
  if (url == null || url.isEmpty) return '';
  if (url.startsWith('http')) return url;
  return kServerBaseUrl + (url.startsWith('/') ? url : '/$url');
}
