import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/banner_model.dart';

abstract class BannerDataSource {
  Future<List<BannerModel>> getActiveBanners();
  Future<BannerModel> createBanner(BannerModel banner);
  Future<BannerModel> updateBanner(BannerModel banner);
  Future<void> deleteBanner(String bannerId);
  Future<void> updateBannerOrder(String bannerId, int newOrder);
}

class BannerFirestoreDataSource implements BannerDataSource {
  final FirebaseFirestore _firestore;

  BannerFirestoreDataSource(this._firestore);

  @override
  Future<List<BannerModel>> getActiveBanners() async {
    try {
      final snapshot = await _firestore
          .collection('banners')
          .where('isActive', isEqualTo: true)
          .orderBy('order', descending: false)
          .get();

      return snapshot.docs
          .map((doc) => BannerModel.fromFirestore(doc))
          .toList();
    } catch (e) {
      throw Exception('Lỗi lấy danh sách banner: $e');
    }
  }

  @override
  Future<BannerModel> createBanner(BannerModel banner) async {
    try {
      final docRef = await _firestore
          .collection('banners')
          .add(banner.toFirestore());

      return banner.copyWith(id: docRef.id);
    } catch (e) {
      throw Exception('Lỗi tạo banner: $e');
    }
  }

  @override
  Future<BannerModel> updateBanner(BannerModel banner) async {
    try {
      await _firestore
          .collection('banners')
          .doc(banner.id)
          .update(banner.toFirestore());

      return banner;
    } catch (e) {
      throw Exception('Lỗi cập nhật banner: $e');
    }
  }

  @override
  Future<void> deleteBanner(String bannerId) async {
    try {
      await _firestore.collection('banners').doc(bannerId).delete();
    } catch (e) {
      throw Exception('Lỗi xóa banner: $e');
    }
  }

  @override
  Future<void> updateBannerOrder(String bannerId, int newOrder) async {
    try {
      await _firestore.collection('banners').doc(bannerId).update({
        'order': newOrder,
        'updatedAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      throw Exception('Lỗi cập nhật thứ tự banner: $e');
    }
  }
}
