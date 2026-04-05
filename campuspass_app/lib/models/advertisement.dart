class Advertisement {
  final int id;
  final int merchantId;
  final String title;
  final String? imageUrl;
  final String? videoUrl;
  final String? description;
  /// Texte du bouton (bandeau accueil HOME_TOP, etc.).
  final String? ctaLabel;
  final String position; // HOME_BANNER, HOME_TOP, SPONSORED_OFFER, OFFERS_PAGE, SEARCH_PAGE, NOTIFICATION
  final int? offerId;
  final String? targetUrl;
  final String? startDate;
  final String? endDate;
  final String status; // ACTIVE, INACTIVE...
  final double? budget;
  final String? createdAt;

  Advertisement({
    required this.id,
    required this.merchantId,
    required this.title,
    this.imageUrl,
    this.videoUrl,
    this.description,
    this.ctaLabel,
    required this.position,
    this.offerId,
    this.targetUrl,
    this.startDate,
    this.endDate,
    required this.status,
    this.budget,
    this.createdAt,
  });

  factory Advertisement.fromJson(Map<String, dynamic> json) {
    // Backend parfois en snake_case: on rend le parsing tolérant.
    String? asString(dynamic v) => v == null ? null : v.toString();
    int asInt(dynamic v) => (v is num) ? v.toInt() : int.parse(v.toString());

    final imageUrl = asString(json['imageUrl'] ?? json['image_url'] ?? json['image']);
    final videoUrl = asString(json['videoUrl'] ?? json['video_url'] ?? json['video']);
    final targetUrl = asString(json['targetUrl'] ?? json['target_url'] ?? json['link']);
    final title = asString(json['title'] ?? json['name'] ?? json['label']) ?? '';
    final description = asString(json['description'] ?? json['text'] ?? json['subtitle']);
    final ctaLabel = asString(json['ctaLabel'] ?? json['cta_label']);
    final offerId = json['offerId'] ?? json['offer_id'];

    return Advertisement(
      id: asInt(json['id']),
      merchantId: asInt(json['merchantId'] ?? json['merchant_id']),
      title: title,
      imageUrl: imageUrl,
      videoUrl: videoUrl,
      description: description,
      ctaLabel: ctaLabel,
      position: json['position'] as String? ?? 'HOME_TOP',
      offerId: offerId == null ? null : asInt(offerId),
      targetUrl: targetUrl,
      startDate: json['startDate']?.toString(),
      endDate: json['endDate']?.toString(),
      status: json['status'] as String? ?? 'ACTIVE',
      budget: (json['budget'] as num?)?.toDouble(),
      createdAt: json['createdAt']?.toString(),
    );
  }
}

