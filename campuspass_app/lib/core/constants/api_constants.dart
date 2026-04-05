/// API backend. Défaut = émulateur Android vers localhost.
/// Build prod : `flutter run/build --dart-define=API_BASE_URL=https://.../api --dart-define=SERVER_BASE_URL=https://...`
const String kApiBaseUrl = String.fromEnvironment(
  'API_BASE_URL',
  defaultValue: 'http://10.0.2.2:8081/api',
);
const String kServerBaseUrl = String.fromEnvironment(
  'SERVER_BASE_URL',
  defaultValue: 'http://10.0.2.2:8081',
);
const String kCurrencySymbol = 'FCFA';
const String kTokenKey = 'student_token';
const String kUserIdKey = 'student_user_id';

String resolveImageUrl(String? url) {
  if (url == null || url.isEmpty) return '';
  if (url.startsWith('http://localhost')) {
    return url.replaceFirst('http://localhost', 'http://10.0.2.2');
  }
  if (url.startsWith('http://127.0.0.1')) {
    return url.replaceFirst('http://127.0.0.1', 'http://10.0.2.2');
  }
  if (url.startsWith('http')) return url;
  return kServerBaseUrl + (url.startsWith('/') ? url : '/$url');
}
