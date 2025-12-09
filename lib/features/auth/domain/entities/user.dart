/// User domain entity
class User {
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

  const User({
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
    this.isEmailVerified = false,
  });

  final bool isEmailVerified;

  // Business logic
  bool get isAdmin => role == 'admin';
  bool get isCustomer => role == 'customer';

  User copyWith({
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
    return User(
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

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is User && runtimeType == other.runtimeType && uid == other.uid;

  @override
  int get hashCode => uid.hashCode;
}
