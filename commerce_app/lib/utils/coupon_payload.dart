import 'dart:convert';

/// Le QR étudiant contient souvent le code coupon en Base64 (`qrCodeData`).
/// Sinon c’est directement le code `CP-…`.
String normalizeCouponPayload(String raw) {
  final t = raw.trim();
  if (t.isEmpty) return '';
  final upper = t.toUpperCase();
  if (upper.startsWith('CP-')) return t;
  try {
    final decoded = utf8.decode(base64Decode(t));
    final d = decoded.trim();
    if (d.isNotEmpty) return d;
  } catch (_) {}
  return t;
}
