import 'package:cloud_firestore/cloud_firestore.dart';

class BannerModel {
  final String id;
  final String title;
  final String subtitle;
  final String image;
  final String? link;
  final String? linkType; // 'product', 'category', 'external'
  final String? linkValue; // productId, categoryId, or URL
  final bool isActive;
  final int order;
  final DateTime createdAt;
  final DateTime updatedAt;

  BannerModel({
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

  factory BannerModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return BannerModel(
      id: doc.id,
      title: data['title'] ?? '',
      subtitle: data['subtitle'] ?? '',
      image: data['image'] ?? '',
      link: data['link'],
      linkType: data['linkType'],
      linkValue: data['linkValue'],
      isActive: data['isActive'] ?? true,
      order: data['order'] ?? 0,
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      updatedAt: (data['updatedAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  factory BannerModel.fromMap(Map<String, dynamic> data) {
    return BannerModel(
      id: data['id'] ?? '',
      title: data['title'] ?? '',
      subtitle: data['subtitle'] ?? '',
      image: data['image'] ?? '',
      link: data['link'],
      linkType: data['linkType'],
      linkValue: data['linkValue'],
      isActive: data['isActive'] ?? true,
      order: data['order'] ?? 0,
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      updatedAt: (data['updatedAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'title': title,
      'subtitle': subtitle,
      'image': image,
      'link': link,
      'linkType': linkType,
      'linkValue': linkValue,
      'isActive': isActive,
      'order': order,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': Timestamp.fromDate(updatedAt),
    };
  }

  BannerModel copyWith({
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
    return BannerModel(
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
}
