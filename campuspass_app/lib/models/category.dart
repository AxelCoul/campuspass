class Category {
  final int id;
  final String name;
  final String? icon;
  final String? description;

  Category({
    required this.id,
    required this.name,
    this.icon,
    this.description,
  });

  factory Category.fromJson(Map<String, dynamic> json) {
    return Category(
      id: (json['id'] as num).toInt(),
      name: json['name'] as String? ?? '',
      icon: json['icon'] as String?,
      description: json['description'] as String?,
    );
  }
}

