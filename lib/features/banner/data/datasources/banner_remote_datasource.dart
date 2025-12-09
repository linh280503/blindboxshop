// ignore_for_file: avoid_print

import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/banner_model.dart';

abstract class BannerRemoteDataSource {
  Future<List<BannerModel>> getBanners({
    bool? isActive,
    int? limit,
    String? orderBy,
    bool descending = false,
  });
  Future<BannerModel?> getBannerById(String bannerId);
  Future<List<BannerModel>> getActiveBanners({int? limit});
  Future<BannerModel> createBanner(BannerModel banner);
  Future<void> updateBanner(BannerModel banner);
  Future<void> deleteBanner(String bannerId);
  Future<void> updateBannerStatus(String bannerId, bool isActive);
  Future<void> updateBannerOrder(String bannerId, int newOrder);
  Future<void> reorderBanners(List<String> bannerIds);
  Future<Map<String, dynamic>> getBannerStats();
  Future<List<BannerModel>> searchBanners(String query);
  Future<List<BannerModel>> getBannersByLinkType(String linkType);
  Future<List<BannerModel>> getBannersByLinkValue(String linkValue);
  Stream<BannerModel?> watchBanner(String bannerId);
  Stream<List<BannerModel>> watchBanners({bool? isActive, int? limit});
  Stream<List<BannerModel>> watchActiveBanners({int? limit});
}

class BannerRemoteDataSourceImpl implements BannerRemoteDataSource {
  final FirebaseFirestore firestore;
  static const String _bannersCollection = 'banners';

  BannerRemoteDataSourceImpl({FirebaseFirestore? firestore})
    : firestore = firestore ?? FirebaseFirestore.instance;

  @override
  Future<List<BannerModel>> getBanners({
    bool? isActive,
    int? limit,
    String? orderBy,
    bool descending = false,
  }) async {
    try {
      Query query = firestore.collection(_bannersCollection);

      if (isActive != null) {
        query = query.where('isActive', isEqualTo: isActive);
      }

      if (orderBy != null) {
        query = query.orderBy(orderBy, descending: descending);
      } else {
        query = query.orderBy('order', descending: false);
      }

      if (limit != null) {
        query = query.limit(limit);
      }

      final snapshot = await query.get();
      return snapshot.docs
          .map((doc) => BannerModel.fromFirestore(doc))
          .toList();
    } catch (e) {
      throw Exception('Lỗi lấy danh sách banner: $e');
    }
  }

  @override
  Future<BannerModel?> getBannerById(String bannerId) async {
    try {
      final doc = await firestore
          .collection(_bannersCollection)
          .doc(bannerId)
          .get();

      if (!doc.exists) return null;

      return BannerModel.fromFirestore(doc);
    } catch (e) {
      throw Exception('Lỗi lấy banner: $e');
    }
  }

  @override
  Future<List<BannerModel>> getActiveBanners({int? limit}) async {
    try {
      return await getBanners(
        isActive: true,
        limit: limit,
        orderBy: 'order',
        descending: false,
      );
    } catch (e) {
      throw Exception('Lỗi lấy banner đang hoạt động: $e');
    }
  }

  @override
  Future<BannerModel> createBanner(BannerModel banner) async {
    try {
      final docRef = await firestore
          .collection(_bannersCollection)
          .add(banner.toFirestore());

      return banner.copyWith(id: docRef.id);
    } catch (e) {
      throw Exception('Lỗi tạo banner: $e');
    }
  }

  @override
  Future<void> updateBanner(BannerModel banner) async {
    try {
      await firestore
          .collection(_bannersCollection)
          .doc(banner.id)
          .update(banner.toFirestore());
    } catch (e) {
      throw Exception('Lỗi cập nhật banner: $e');
    }
  }

  @override
  Future<void> deleteBanner(String bannerId) async {
    try {
      await firestore.collection(_bannersCollection).doc(bannerId).delete();
    } catch (e) {
      throw Exception('Lỗi xóa banner: $e');
    }
  }

  @override
  Future<void> updateBannerStatus(String bannerId, bool isActive) async {
    try {
      await firestore.collection(_bannersCollection).doc(bannerId).update({
        'isActive': isActive,
        'updatedAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      throw Exception('Lỗi cập nhật trạng thái banner: $e');
    }
  }

  @override
  Future<void> updateBannerOrder(String bannerId, int newOrder) async {
    try {
      await firestore.collection(_bannersCollection).doc(bannerId).update({
        'order': newOrder,
        'updatedAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      throw Exception('Lỗi cập nhật thứ tự banner: $e');
    }
  }

  @override
  Future<void> reorderBanners(List<String> bannerIds) async {
    try {
      final batch = firestore.batch();

      for (int i = 0; i < bannerIds.length; i++) {
        final bannerRef = firestore
            .collection(_bannersCollection)
            .doc(bannerIds[i]);
        batch.update(bannerRef, {
          'order': i,
          'updatedAt': FieldValue.serverTimestamp(),
        });
      }

      await batch.commit();
    } catch (e) {
      throw Exception('Lỗi sắp xếp lại banner: $e');
    }
  }

  @override
  Future<Map<String, dynamic>> getBannerStats() async {
    try {
      final snapshot = await firestore.collection(_bannersCollection).get();

      final banners = snapshot.docs
          .map((doc) => BannerModel.fromFirestore(doc))
          .toList();

      final totalBanners = banners.length;
      final activeBanners = banners.where((b) => b.isActive).length;
      final inactiveBanners = banners.where((b) => !b.isActive).length;

      return {
        'totalBanners': totalBanners,
        'activeBanners': activeBanners,
        'inactiveBanners': inactiveBanners,
      };
    } catch (e) {
      throw Exception('Lỗi lấy thống kê banner: $e');
    }
  }

  @override
  Future<List<BannerModel>> searchBanners(String query) async {
    try {
      final snapshot = await firestore.collection(_bannersCollection).get();

      List<BannerModel> banners = snapshot.docs
          .map((doc) => BannerModel.fromFirestore(doc))
          .toList();

      if (query.isNotEmpty) {
        banners = banners.where((banner) {
          return banner.title.toLowerCase().contains(query.toLowerCase()) ||
              banner.subtitle.toLowerCase().contains(query.toLowerCase());
        }).toList();
      }

      banners.sort((a, b) => a.order.compareTo(b.order));

      return banners;
    } catch (e) {
      throw Exception('Lỗi tìm kiếm banner: $e');
    }
  }

  @override
  Future<List<BannerModel>> getBannersByLinkType(String linkType) async {
    try {
      final snapshot = await firestore
          .collection(_bannersCollection)
          .where('linkType', isEqualTo: linkType)
          .where('isActive', isEqualTo: true)
          .orderBy('order')
          .get();

      return snapshot.docs
          .map((doc) => BannerModel.fromFirestore(doc))
          .toList();
    } catch (e) {
      throw Exception('Lỗi lấy banner theo loại link: $e');
    }
  }

  @override
  Future<List<BannerModel>> getBannersByLinkValue(String linkValue) async {
    try {
      final snapshot = await firestore
          .collection(_bannersCollection)
          .where('linkValue', isEqualTo: linkValue)
          .where('isActive', isEqualTo: true)
          .orderBy('order')
          .get();

      return snapshot.docs
          .map((doc) => BannerModel.fromFirestore(doc))
          .toList();
    } catch (e) {
      throw Exception('Lỗi lấy banner theo giá trị link: $e');
    }
  }

  @override
  Stream<BannerModel?> watchBanner(String bannerId) {
    return firestore
        .collection(_bannersCollection)
        .doc(bannerId)
        .snapshots()
        .map((snapshot) {
          if (!snapshot.exists) return null;
          return BannerModel.fromFirestore(snapshot);
        });
  }

  @override
  Stream<List<BannerModel>> watchBanners({bool? isActive, int? limit}) {
    Query query = firestore.collection(_bannersCollection);

    if (isActive != null) {
      query = query.where('isActive', isEqualTo: isActive);
    }

    query = query.orderBy('order', descending: false);

    if (limit != null) {
      query = query.limit(limit);
    }

    return query.snapshots().map((snapshot) {
      return snapshot.docs
          .map((doc) => BannerModel.fromFirestore(doc))
          .toList();
    });
  }

  @override
  Stream<List<BannerModel>> watchActiveBanners({int? limit}) {
    return watchBanners(isActive: true, limit: limit);
  }
}
