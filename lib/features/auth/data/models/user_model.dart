import 'package:cloud_firestore/cloud_firestore.dart';

class UserModel {
  final String uid;
  final String email;
  final String name;
  final String phone;
  final String avatar;
  final DateTime createdAt;
  final DateTime updatedAt;
  final bool isActive;
  final String role;
  final int points;
  final int totalOrders;
  final double totalSpent;

  UserModel({
    required this.uid,
    required this.email,
    required this.name,
    required this.phone,
    required this.avatar,
    required this.createdAt,
    required this.updatedAt,
    required this.isActive,
    required this.role,
    required this.points,
    required this.totalOrders,
    required this.totalSpent,
  });

  factory UserModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return UserModel(
      uid: data['uid'] ?? '',
      email: data['email'] ?? '',
      name: data['name'] ?? '',
      phone: data['phone'] ?? '',
      avatar: data['avatar'] ?? '',
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      updatedAt: (data['updatedAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      isActive: data['isActive'] ?? true,
      role: data['role'] ?? 'customer',
      points: data['points'] ?? 0,
      totalOrders: data['totalOrders'] ?? 0,
      totalSpent: (data['totalSpent'] ?? 0.0).toDouble(),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'uid': uid,
      'email': email,
      'name': name,
      'phone': phone,
      'avatar': avatar,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': Timestamp.fromDate(updatedAt),
      'isActive': isActive,
      'role': role,
      'points': points,
      'totalOrders': totalOrders,
      'totalSpent': totalSpent,
    };
  }

  UserModel copyWith({
    String? uid,
    String? email,
    String? name,
    String? phone,
    String? avatar,
    DateTime? createdAt,
    DateTime? updatedAt,
    bool? isActive,
    String? role,
    int? points,
    int? totalOrders,
    double? totalSpent,
  }) {
    return UserModel(
      uid: uid ?? this.uid,
      email: email ?? this.email,
      name: name ?? this.name,
      phone: phone ?? this.phone,
      avatar: avatar ?? this.avatar,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      isActive: isActive ?? this.isActive,
      role: role ?? this.role,
      points: points ?? this.points,
      totalOrders: totalOrders ?? this.totalOrders,
      totalSpent: totalSpent ?? this.totalSpent,
    );
  }
}
