/// Address domain entity
class Address {
  final String id;
  final String userId;
  final String name;
  final String phone;
  final String address;
  final String ward; // Phường/Xã
  final String district; // Quận/Huyện
  final String city; // Tỉnh/Thành phố
  final String? note; // Ghi chú
  final bool isDefault;
  final DateTime createdAt;
  final DateTime updatedAt;

  const Address({
    required this.id,
    required this.userId,
    required this.name,
    required this.phone,
    required this.address,
    required this.ward,
    required this.district,
    required this.city,
    this.note,
    this.isDefault = false,
    required this.createdAt,
    required this.updatedAt,
  });

  // Business logic
  String get fullAddress => '$address, $ward, $district, $city';
  String get shortAddress => '$ward, $district, $city';
  bool get isValid =>
      name.isNotEmpty &&
      phone.isNotEmpty &&
      address.isNotEmpty &&
      ward.isNotEmpty &&
      district.isNotEmpty &&
      city.isNotEmpty;

  Address copyWith({
    String? id,
    String? userId,
    String? name,
    String? phone,
    String? address,
    String? ward,
    String? district,
    String? city,
    String? note,
    bool? isDefault,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Address(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      name: name ?? this.name,
      phone: phone ?? this.phone,
      address: address ?? this.address,
      ward: ward ?? this.ward,
      district: district ?? this.district,
      city: city ?? this.city,
      note: note ?? this.note,
      isDefault: isDefault ?? this.isDefault,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Address && runtimeType == other.runtimeType && id == other.id;

  @override
  int get hashCode => id.hashCode;
}
