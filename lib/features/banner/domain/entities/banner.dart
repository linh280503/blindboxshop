class Banner {
  final String id;
  final String title;
  final String subtitle;
  final String image;
  final String? link;
  final String? linkType;
  final String? linkValue;
  final bool isActive;
  final int order;
  final DateTime createdAt;
  final DateTime updatedAt;

  const Banner({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.image,
    this.link,
    this.linkType,
    this.linkValue,
    required this.isActive,
    required this.order,
    required this.createdAt,
    required this.updatedAt,
  });

  Banner copyWith({
    String? id,
    String? title,
    String? subtitle,
    String? image,
    String? link,
    String? linkType,
    String? linkValue,
    bool? isActive,
    int? order,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Banner(
      id: id ?? this.id,
      title: title ?? this.title,
      subtitle: subtitle ?? this.subtitle,
      image: image ?? this.image,
      link: link ?? this.link,
      linkType: linkType ?? this.linkType,
      linkValue: linkValue ?? this.linkValue,
      isActive: isActive ?? this.isActive,
      order: order ?? this.order,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Banner && runtimeType == other.runtimeType && id == other.id;

  @override
  int get hashCode => id.hashCode;
}
