class BannerModel {
  final int id;
  final String title;
  final String? description;
  final String? imageUrl;
  final String type; // SUBSCRIPTION, SPONSORED, EVENT...
  final String? linkUrl;
  final String? startDate;
  final String? endDate;
  final int? position;

  BannerModel({
    required this.id,
    required this.title,
    this.description,
    this.imageUrl,
    required this.type,
    this.linkUrl,
    this.startDate,
    this.endDate,
    this.position,
  });

  factory BannerModel.fromJson(Map<String, dynamic> json) {
    return BannerModel(
      id: (json['id'] as num).toInt(),
      title: json['title'] as String? ?? '',
      description: json['description'] as String?,
      imageUrl: json['imageUrl'] as String?,
      type: json['type'] as String? ?? 'GENERIC',
      linkUrl: json['linkUrl'] as String?,
      startDate: json['startDate']?.toString(),
      endDate: json['endDate']?.toString(),
      position: (json['position'] as num?)?.toInt(),
    );
  }
}

