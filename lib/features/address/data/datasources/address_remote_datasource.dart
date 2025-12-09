// ignore_for_file: avoid_print

import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/address_model.dart';

abstract class AddressRemoteDataSource {
  Future<List<AddressModel>> getUserAddresses(String userId);
  Future<AddressModel?> getDefaultAddress(String userId);
  Future<AddressModel?> getAddressById(String addressId);
  Future<String> createAddress(AddressModel address);
  Future<void> updateAddress(AddressModel address);
  Future<void> deleteAddress(String addressId);
  Future<void> setDefaultAddress(String addressId, String userId);
  List<String> getCities();
  List<String> getDistricts(String city);
  List<String> getWards(String district);
}

class AddressRemoteDataSourceImpl implements AddressRemoteDataSource {
  final FirebaseFirestore firestore;
  static const String _addressesCollection = 'addresses';

  AddressRemoteDataSourceImpl({FirebaseFirestore? firestore})
    : firestore = firestore ?? FirebaseFirestore.instance;

  Future<void> _removeDefaultFromOtherAddresses(
    String userId, {
    String? excludeId,
  }) async {
    try {
      Query query = firestore
          .collection(_addressesCollection)
          .where('userId', isEqualTo: userId)
          .where('isDefault', isEqualTo: true);

      if (excludeId != null) {
        query = query
            .where(FieldPath.documentId, isNotEqualTo: excludeId)
            .orderBy(FieldPath.documentId);
      }

      final snapshot = await query.get();

      if (snapshot.docs.isNotEmpty) {
        final batch = firestore.batch();
        for (final doc in snapshot.docs) {
          batch.update(doc.reference, {
            'isDefault': false,
            'updatedAt': FieldValue.serverTimestamp(),
          });
        }
        await batch.commit();
      }
    } catch (e) {
      throw Exception('Lỗi bỏ default địa chỉ: $e');
    }
  }

  @override
  Future<List<AddressModel>> getUserAddresses(String userId) async {
    try {
      final snapshot = await firestore
          .collection(_addressesCollection)
          .where('userId', isEqualTo: userId)
          .get();

      final list = snapshot.docs
          .map((doc) => AddressModel.fromFirestore(doc))
          .toList();

      list.sort((a, b) {
        if (a.isDefault != b.isDefault) {
          return a.isDefault ? -1 : 1;
        }
        return b.createdAt.compareTo(a.createdAt);
      });

      return list;
    } catch (e) {
      throw Exception('Lỗi lấy danh sách địa chỉ: $e');
    }
  }

  @override
  Future<AddressModel?> getDefaultAddress(String userId) async {
    try {
      final snapshot = await firestore
          .collection(_addressesCollection)
          .where('userId', isEqualTo: userId)
          .where('isDefault', isEqualTo: true)
          .limit(1)
          .get();

      if (snapshot.docs.isEmpty) {
        return null;
      }

      return AddressModel.fromFirestore(snapshot.docs.first);
    } catch (e) {
      throw Exception('Lỗi lấy địa chỉ mặc định: $e');
    }
  }

  @override
  Future<AddressModel?> getAddressById(String addressId) async {
    try {
      final doc = await firestore
          .collection(_addressesCollection)
          .doc(addressId)
          .get();

      if (!doc.exists) {
        return null;
      }

      return AddressModel.fromFirestore(doc);
    } catch (e) {
      throw Exception('Lỗi lấy địa chỉ: $e');
    }
  }

  @override
  Future<String> createAddress(AddressModel address) async {
    try {
      if (address.isDefault) {
        await _removeDefaultFromOtherAddresses(address.userId);
      }

      final docRef = await firestore
          .collection(_addressesCollection)
          .add(address.toFirestore());

      return docRef.id;
    } catch (e) {
      throw Exception('Lỗi tạo địa chỉ: $e');
    }
  }

  @override
  Future<void> updateAddress(AddressModel address) async {
    try {
      if (address.isDefault) {
        await _removeDefaultFromOtherAddresses(
          address.userId,
          excludeId: address.id,
        );
      }

      await firestore
          .collection(_addressesCollection)
          .doc(address.id)
          .update(address.toFirestore());
    } catch (e) {
      throw Exception('Lỗi cập nhật địa chỉ: $e');
    }
  }

  @override
  Future<void> deleteAddress(String addressId) async {
    try {
      await firestore.collection(_addressesCollection).doc(addressId).delete();
    } catch (e) {
      throw Exception('Lỗi xóa địa chỉ: $e');
    }
  }

  @override
  Future<void> setDefaultAddress(String addressId, String userId) async {
    try {
      await _removeDefaultFromOtherAddresses(userId, excludeId: addressId);

      await firestore.collection(_addressesCollection).doc(addressId).update({
        'isDefault': true,
        'updatedAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      throw Exception('Lỗi đặt địa chỉ mặc định: $e');
    }
  }

  @override
  List<String> getCities() {
    return [
      'Hà Nội',
      'TP. Hồ Chí Minh',
      'Đà Nẵng',
      'Hải Phòng',
      'Cần Thơ',
      'An Giang',
      'Bà Rịa - Vũng Tàu',
      'Bắc Giang',
      'Bắc Kạn',
      'Bạc Liêu',
      'Bắc Ninh',
      'Bến Tre',
      'Bình Định',
      'Bình Dương',
      'Bình Phước',
      'Bình Thuận',
      'Cà Mau',
      'Cao Bằng',
      'Đắk Lắk',
      'Đắk Nông',
      'Điện Biên',
      'Đồng Nai',
      'Đồng Tháp',
      'Gia Lai',
      'Hà Giang',
      'Hà Nam',
      'Hà Tĩnh',
      'Hải Dương',
      'Hậu Giang',
      'Hòa Bình',
      'Hưng Yên',
      'Khánh Hòa',
      'Kiên Giang',
      'Kon Tum',
      'Lai Châu',
      'Lâm Đồng',
      'Lạng Sơn',
      'Lào Cai',
      'Long An',
      'Nam Định',
      'Nghệ An',
      'Ninh Bình',
      'Ninh Thuận',
      'Phú Thọ',
      'Phú Yên',
      'Quảng Bình',
      'Quảng Nam',
      'Quảng Ngãi',
      'Quảng Ninh',
      'Quảng Trị',
      'Sóc Trăng',
      'Sơn La',
      'Tây Ninh',
      'Thái Bình',
      'Thái Nguyên',
      'Thanh Hóa',
      'Thừa Thiên Huế',
      'Tiền Giang',
      'Trà Vinh',
      'Tuyên Quang',
      'Vĩnh Long',
      'Vĩnh Phúc',
      'Yên Bái',
    ];
  }

  @override
  List<String> getDistricts(String city) {
    final districts = <String, List<String>>{
      'Hà Nội': [
        'Quận Ba Đình',
        'Quận Hoàn Kiếm',
        'Quận Tây Hồ',
        'Quận Long Biên',
        'Quận Cầu Giấy',
        'Quận Đống Đa',
        'Quận Hai Bà Trưng',
        'Quận Hoàng Mai',
        'Quận Thanh Xuân',
        'Huyện Sóc Sơn',
        'Huyện Đông Anh',
        'Huyện Gia Lâm',
        'Quận Nam Từ Liêm',
        'Huyện Thanh Trì',
        'Quận Bắc Từ Liêm',
        'Huyện Mê Linh',
        'Huyện Hà Đông',
        'Quận Hà Đông',
        'Huyện Sơn Tây',
        'Huyện Ba Vì',
        'Huyện Phúc Thọ',
        'Huyện Đan Phượng',
        'Huyện Hoài Đức',
        'Huyện Quốc Oai',
        'Huyện Thạch Thất',
        'Huyện Chương Mỹ',
        'Huyện Thanh Oai',
        'Huyện Thường Tín',
        'Huyện Phú Xuyên',
        'Huyện Ứng Hòa',
        'Huyện Mỹ Đức',
      ],
      'TP. Hồ Chí Minh': [
        'Quận 1',
        'Quận 2',
        'Quận 3',
        'Quận 4',
        'Quận 5',
        'Quận 6',
        'Quận 7',
        'Quận 8',
        'Quận 9',
        'Quận 10',
        'Quận 11',
        'Quận 12',
        'Quận Thủ Đức',
        'Quận Gò Vấp',
        'Quận Bình Thạnh',
        'Quận Tân Bình',
        'Quận Tân Phú',
        'Quận Phú Nhuận',
        'Quận Bình Tân',
        'Huyện Củ Chi',
        'Huyện Hóc Môn',
        'Huyện Bình Chánh',
        'Huyện Nhà Bè',
        'Huyện Cần Giờ',
      ],
    };

    return districts[city] ?? ['Chọn quận/huyện'];
  }

  @override
  List<String> getWards(String district) {
    return [
      'Chọn phường/xã',
      'Phường 1',
      'Phường 2',
      'Phường 3',
      'Phường 4',
      'Phường 5',
      'Phường 6',
      'Phường 7',
      'Phường 8',
      'Phường 9',
      'Phường 10',
    ];
  }
}
