import 'package:cloud_firestore/cloud_firestore.dart';

class AddressModel {
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

  AddressModel({
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

  factory AddressModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return AddressModel(
      id: doc.id,
      userId: data['userId'] ?? '',
      name: data['name'] ?? '',
      phone: data['phone'] ?? '',
      address: data['address'] ?? '',
      ward: data['ward'] ?? '',
      district: data['district'] ?? '',
      city: data['city'] ?? '',
      note: data['note'],
      isDefault: data['isDefault'] ?? false,
      createdAt: (data['createdAt'] as Timestamp).toDate(),
      updatedAt: (data['updatedAt'] as Timestamp).toDate(),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'userId': userId,
      'name': name,
      'phone': phone,
      'address': address,
      'ward': ward,
      'district': district,
      'city': city,
      'note': note,
      'isDefault': isDefault,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': Timestamp.fromDate(updatedAt),
    };
  }

  AddressModel copyWith({
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
    return AddressModel(
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

  // Helper methods
  String get fullAddress => '$address, $ward, $district, $city';

  String get shortAddress => '$ward, $district, $city';

  bool get isValid =>
      name.isNotEmpty &&
      phone.isNotEmpty &&
      address.isNotEmpty &&
      ward.isNotEmpty &&
      district.isNotEmpty &&
      city.isNotEmpty;
}
