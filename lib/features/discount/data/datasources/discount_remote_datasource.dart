// ignore_for_file: avoid_print, avoid_types_as_parameter_names

import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/discount_model.dart';
import '../../domain/entities/discount_status.dart';

/// Abstract datasource for remote discount data
abstract class DiscountRemoteDataSource {
  Future<DiscountModel?> getDiscountByCode(String code);
  Future<List<DiscountModel>> getActiveDiscounts();
  Future<List<DiscountModel>> getFirstOrderDiscounts();
  Future<Map<String, dynamic>> validateDiscountCode(
    String code,
    double orderAmount,
    List<Map<String, dynamic>> orderItems,
    bool isFirstOrder,
  );
  Future<void> useDiscountCode(String code);
  Future<String> createDiscount(DiscountModel discount);
  Future<void> updateDiscount(String discountId, DiscountModel discount);
  Future<void> deleteDiscount(String discountId);
  Future<List<DiscountModel>> getAllDiscounts();
  Future<List<DiscountModel>> searchDiscounts(String query);
  Future<void> toggleDiscountStatus(String discountId, bool isActive);
  Future<Map<String, dynamic>> getDiscountOverview();
  Future<String> duplicateDiscount(String discountId);
}

/// Firestore implementation of DiscountRemoteDataSource
/// Refactored from DiscountService
class DiscountRemoteDataSourceImpl implements DiscountRemoteDataSource {
  final FirebaseFirestore firestore;
  static const String _discountsCollection = 'discounts';

  DiscountRemoteDataSourceImpl({FirebaseFirestore? firestore})
    : firestore = firestore ?? FirebaseFirestore.instance;

  @override
  Future<DiscountModel?> getDiscountByCode(String code) async {
    try {
      final snapshot = await firestore
          .collection(_discountsCollection)
          .where('code', isEqualTo: code.toUpperCase())
          .limit(1)
          .get();

      if (snapshot.docs.isEmpty) {
        return null;
      }

      return DiscountModel.fromFirestore(snapshot.docs.first);
    } catch (e) {
      throw Exception('Lỗi lấy mã giảm giá: $e');
    }
  }

  @override
  Future<List<DiscountModel>> getActiveDiscounts() async {
    try {
      final snapshot = await firestore
          .collection(_discountsCollection)
          .where('status', isEqualTo: 'active')
          .where('startDate', isLessThanOrEqualTo: Timestamp.now())
          .where('endDate', isGreaterThan: Timestamp.now())
          .get();

      return snapshot.docs
          .map((doc) => DiscountModel.fromFirestore(doc))
          .where((discount) => discount.canBeUsed)
          .toList();
    } catch (e) {
      throw Exception('Lỗi lấy danh sách mã giảm giá: $e');
    }
  }

  @override
  Future<List<DiscountModel>> getFirstOrderDiscounts() async {
    try {
      final snapshot = await firestore
          .collection(_discountsCollection)
          .where('status', isEqualTo: 'active')
          .where('isFirstOrderOnly', isEqualTo: true)
          .where('startDate', isLessThanOrEqualTo: Timestamp.now())
          .where('endDate', isGreaterThan: Timestamp.now())
          .get();

      return snapshot.docs
          .map((doc) => DiscountModel.fromFirestore(doc))
          .where((discount) => discount.canBeUsed)
          .toList();
    } catch (e) {
      throw Exception('Lỗi lấy mã giảm giá đơn đầu: $e');
    }
  }

  @override
  Future<Map<String, dynamic>> validateDiscountCode(
    String code,
    double orderAmount,
    List<Map<String, dynamic>> orderItems,
    bool isFirstOrder,
  ) async {
    try {
      final discount = await getDiscountByCode(code);

      if (discount == null) {
        return {
          'isValid': false,
          'message': 'Mã giảm giá không tồn tại',
          'discount': null,
        };
      }

      if (!discount.isActive) {
        return {
          'isValid': false,
          'message': 'Mã giảm giá đã hết hạn',
          'discount': null,
        };
      }

      if (discount.isUsageLimitReached) {
        return {
          'isValid': false,
          'message': 'Mã giảm giá đã hết lượt sử dụng',
          'discount': null,
        };
      }

      if (discount.isFirstOrderOnly && !isFirstOrder) {
        return {
          'isValid': false,
          'message': 'Mã giảm giá chỉ áp dụng cho đơn hàng đầu tiên',
          'discount': null,
        };
      }

      if (discount.minOrderAmount != null &&
          orderAmount < discount.minOrderAmount!) {
        return {
          'isValid': false,
          'message': 'Đơn hàng tối thiểu ${discount.formattedMinOrderAmount}',
          'discount': null,
        };
      }

      // Kiểm tra sản phẩm áp dụng
      bool hasApplicableProduct = false;
      for (final item in orderItems) {
        final productId = item['productId'] as String;
        final category = item['category'] as String;

        if (discount.isApplicableToProduct(productId, category)) {
          hasApplicableProduct = true;
          break;
        }
      }

      if (!hasApplicableProduct) {
        return {
          'isValid': false,
          'message': 'Mã giảm giá không áp dụng cho sản phẩm trong giỏ hàng',
          'discount': null,
        };
      }

      final discountAmount = discount.calculateDiscount(orderAmount);

      return {
        'isValid': true,
        'message': 'Mã giảm giá hợp lệ',
        'discount': discount,
        'discountAmount': discountAmount,
        'finalAmount': orderAmount - discountAmount,
      };
    } catch (e) {
      return {
        'isValid': false,
        'message': 'Lỗi kiểm tra mã giảm giá: $e',
        'discount': null,
      };
    }
  }

  @override
  Future<void> useDiscountCode(String code) async {
    try {
      final discount = await getDiscountByCode(code);

      if (discount == null) {
        throw Exception('Mã giảm giá không tồn tại');
      }

      if (!discount.canBeUsed) {
        throw Exception('Mã giảm giá không thể sử dụng');
      }

      await firestore.collection(_discountsCollection).doc(discount.id).update({
        'usedCount': FieldValue.increment(1),
        'updatedAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      throw Exception('Lỗi sử dụng mã giảm giá: $e');
    }
  }

  @override
  Future<String> createDiscount(DiscountModel discount) async {
    try {
      // Kiểm tra code đã tồn tại chưa
      final existingDiscount = await getDiscountByCode(discount.code);
      if (existingDiscount != null) {
        throw Exception('Mã giảm giá đã tồn tại');
      }

      final docRef = await firestore
          .collection(_discountsCollection)
          .add(discount.toFirestore());
      return docRef.id;
    } catch (e) {
      throw Exception('Lỗi tạo mã giảm giá: $e');
    }
  }

  @override
  Future<void> updateDiscount(String discountId, DiscountModel discount) async {
    try {
      await firestore
          .collection(_discountsCollection)
          .doc(discountId)
          .update(discount.toFirestore());
    } catch (e) {
      throw Exception('Lỗi cập nhật mã giảm giá: $e');
    }
  }

  @override
  Future<void> deleteDiscount(String discountId) async {
    try {
      await firestore.collection(_discountsCollection).doc(discountId).delete();
    } catch (e) {
      throw Exception('Lỗi xóa mã giảm giá: $e');
    }
  }

  @override
  Future<List<DiscountModel>> getAllDiscounts() async {
    try {
      final snapshot = await firestore
          .collection(_discountsCollection)
          .orderBy('createdAt', descending: true)
          .get();

      return snapshot.docs
          .map((doc) => DiscountModel.fromFirestore(doc))
          .toList();
    } catch (e) {
      throw Exception('Lỗi lấy danh sách mã giảm giá: $e');
    }
  }

  @override
  Future<List<DiscountModel>> searchDiscounts(String query) async {
    try {
      final snapshot = await firestore.collection(_discountsCollection).get();

      return snapshot.docs
          .map((doc) => DiscountModel.fromFirestore(doc))
          .where(
            (discount) =>
                discount.code.toLowerCase().contains(query.toLowerCase()) ||
                discount.name.toLowerCase().contains(query.toLowerCase()) ||
                discount.description.toLowerCase().contains(
                  query.toLowerCase(),
                ),
          )
          .toList();
    } catch (e) {
      throw Exception('Lỗi tìm kiếm mã giảm giá: $e');
    }
  }

  @override
  Future<void> toggleDiscountStatus(String discountId, bool isActive) async {
    try {
      await firestore.collection(_discountsCollection).doc(discountId).update({
        'status': isActive ? 'active' : 'inactive',
        'updatedAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      throw Exception('Lỗi cập nhật trạng thái mã giảm giá: $e');
    }
  }

  @override
  Future<Map<String, dynamic>> getDiscountOverview() async {
    try {
      final snapshot = await firestore.collection(_discountsCollection).get();
      final discounts = snapshot.docs
          .map((doc) => DiscountModel.fromFirestore(doc))
          .toList();

      int totalDiscounts = discounts.length;
      int activeDiscounts = discounts
          .where((d) => d.status == DiscountStatus.active)
          .length;
      int inactiveDiscounts = discounts
          .where((d) => d.status == DiscountStatus.inactive)
          .length;
      int expiredDiscounts = discounts.where((d) => d.isExpired).length;

      double totalUsageCount = discounts.fold(
        0.0,
        (sum, d) => sum + d.usedCount,
      );
      double totalValue = discounts.fold(0.0, (sum, d) => sum + d.value);

      return {
        'totalDiscounts': totalDiscounts,
        'activeDiscounts': activeDiscounts,
        'inactiveDiscounts': inactiveDiscounts,
        'expiredDiscounts': expiredDiscounts,
        'totalUsageCount': totalUsageCount,
        'totalValue': totalValue,
        'averageUsage': totalDiscounts > 0
            ? totalUsageCount / totalDiscounts
            : 0,
      };
    } catch (e) {
      throw Exception('Lỗi lấy thống kê tổng quan mã giảm giá: $e');
    }
  }

  @override
  Future<String> duplicateDiscount(String discountId) async {
    try {
      final originalDiscount = await firestore
          .collection(_discountsCollection)
          .doc(discountId)
          .get();
      if (!originalDiscount.exists) {
        throw Exception('Mã giảm giá không tồn tại');
      }

      final newDiscount = DiscountModel.fromFirestore(originalDiscount);

      // Tạo mã mới
      final newCode =
          '${newDiscount.code}_COPY_${DateTime.now().millisecondsSinceEpoch}';

      final duplicatedDiscount = newDiscount.copyWith(
        id: '', // Sẽ được tạo mới
        code: newCode,
        name: '${newDiscount.name} (Copy)',
        usedCount: 0,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      final docRef = await firestore
          .collection(_discountsCollection)
          .add(duplicatedDiscount.toFirestore());

      return docRef.id;
    } catch (e) {
      throw Exception('Lỗi sao chép mã giảm giá: $e');
    }
  }
}
