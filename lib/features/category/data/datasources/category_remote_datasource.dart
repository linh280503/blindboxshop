// ignore_for_file: avoid_print

import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/category_model.dart';

abstract class CategoryRemoteDataSource {
  Future<List<CategoryModel>> getCategories({
    bool? isActive,
    int? limit,
    String? orderBy,
    bool descending = false,
  });
  Future<CategoryModel?> getCategoryById(String categoryId);
  Future<List<CategoryModel>> getActiveCategories({int? limit});
  Future<CategoryModel> createCategory(CategoryModel category);
  Future<void> updateCategory(CategoryModel category);
  Future<void> deleteCategory(String categoryId);
  Future<void> updateCategoryStatus(String categoryId, bool isActive);
  Future<void> updateCategoryOrder(String categoryId, int newOrder);
  Future<void> reorderCategories(List<String> categoryIds);
  Future<Map<String, dynamic>> getCategoryStats();
  Future<List<CategoryModel>> searchCategories(String query);
  Future<CategoryModel?> getCategoryByName(String name);
  Future<bool> categoryExists(String name);
  Future<List<String>> getCategoryNames();
  Stream<CategoryModel?> watchCategory(String categoryId);
  Stream<List<CategoryModel>> watchCategories({bool? isActive, int? limit});
  Stream<List<CategoryModel>> watchActiveCategories({int? limit});
}

class CategoryRemoteDataSourceImpl implements CategoryRemoteDataSource {
  final FirebaseFirestore firestore;
  static const String _categoriesCollection = 'categories';

  CategoryRemoteDataSourceImpl({FirebaseFirestore? firestore})
    : firestore = firestore ?? FirebaseFirestore.instance;

  @override
  Future<List<CategoryModel>> getCategories({
    bool? isActive,
    int? limit,
    String? orderBy,
    bool descending = false,
  }) async {
    try {
      Query query = firestore.collection(_categoriesCollection);

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
          .map((doc) => CategoryModel.fromFirestore(doc))
          .toList();
    } catch (e) {
      throw Exception('Lỗi lấy danh sách danh mục: $e');
    }
  }

  @override
  Future<CategoryModel?> getCategoryById(String categoryId) async {
    try {
      final doc = await firestore
          .collection(_categoriesCollection)
          .doc(categoryId)
          .get();

      if (!doc.exists) return null;

      return CategoryModel.fromFirestore(doc);
    } catch (e) {
      throw Exception('Lỗi lấy danh mục: $e');
    }
  }

  @override
  Future<List<CategoryModel>> getActiveCategories({int? limit}) async {
    try {
      return await getCategories(
        isActive: true,
        limit: limit,
        orderBy: 'order',
        descending: false,
      );
    } catch (e) {
      throw Exception('Lỗi lấy danh mục đang hoạt động: $e');
    }
  }

  @override
  Future<CategoryModel> createCategory(CategoryModel category) async {
    try {
      final docRef = await firestore
          .collection(_categoriesCollection)
          .add(category.toFirestore());

      return category.copyWith(id: docRef.id);
    } catch (e) {
      throw Exception('Lỗi tạo danh mục: $e');
    }
  }

  @override
  Future<void> updateCategory(CategoryModel category) async {
    try {
      await firestore
          .collection(_categoriesCollection)
          .doc(category.id)
          .update(category.toFirestore());
    } catch (e) {
      throw Exception('Lỗi cập nhật danh mục: $e');
    }
  }

  @override
  Future<void> deleteCategory(String categoryId) async {
    try {
      await firestore
          .collection(_categoriesCollection)
          .doc(categoryId)
          .delete();
    } catch (e) {
      throw Exception('Lỗi xóa danh mục: $e');
    }
  }

  @override
  Future<void> updateCategoryStatus(String categoryId, bool isActive) async {
    try {
      await firestore.collection(_categoriesCollection).doc(categoryId).update({
        'isActive': isActive,
        'updatedAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      throw Exception('Lỗi cập nhật trạng thái danh mục: $e');
    }
  }

  @override
  Future<void> updateCategoryOrder(String categoryId, int newOrder) async {
    try {
      await firestore.collection(_categoriesCollection).doc(categoryId).update({
        'order': newOrder,
        'updatedAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      throw Exception('Lỗi cập nhật thứ tự danh mục: $e');
    }
  }

  @override
  Future<void> reorderCategories(List<String> categoryIds) async {
    try {
      final batch = firestore.batch();

      for (int i = 0; i < categoryIds.length; i++) {
        final categoryRef = firestore
            .collection(_categoriesCollection)
            .doc(categoryIds[i]);
        batch.update(categoryRef, {
          'order': i,
          'updatedAt': FieldValue.serverTimestamp(),
        });
      }

      await batch.commit();
    } catch (e) {
      throw Exception('Lỗi sắp xếp lại danh mục: $e');
    }
  }

  @override
  Future<Map<String, dynamic>> getCategoryStats() async {
    try {
      final snapshot = await firestore.collection(_categoriesCollection).get();

      final categories = snapshot.docs
          .map((doc) => CategoryModel.fromFirestore(doc))
          .toList();

      final totalCategories = categories.length;
      final activeCategories = categories.where((c) => c.isActive).length;
      final inactiveCategories = categories.where((c) => !c.isActive).length;

      return {
        'totalCategories': totalCategories,
        'activeCategories': activeCategories,
        'inactiveCategories': inactiveCategories,
      };
    } catch (e) {
      throw Exception('Lỗi lấy thống kê danh mục: $e');
    }
  }

  @override
  Future<List<CategoryModel>> searchCategories(String query) async {
    try {
      final snapshot = await firestore.collection(_categoriesCollection).get();

      List<CategoryModel> categories = snapshot.docs
          .map((doc) => CategoryModel.fromFirestore(doc))
          .toList();

      if (query.isNotEmpty) {
        categories = categories.where((category) {
          return category.name.toLowerCase().contains(query.toLowerCase()) ||
              category.description.toLowerCase().contains(query.toLowerCase());
        }).toList();
      }

      categories.sort((a, b) => a.order.compareTo(b.order));

      return categories;
    } catch (e) {
      throw Exception('Lỗi tìm kiếm danh mục: $e');
    }
  }

  @override
  Future<CategoryModel?> getCategoryByName(String name) async {
    try {
      final snapshot = await firestore
          .collection(_categoriesCollection)
          .where('name', isEqualTo: name)
          .limit(1)
          .get();

      if (snapshot.docs.isEmpty) return null;

      return CategoryModel.fromFirestore(snapshot.docs.first);
    } catch (e) {
      throw Exception('Lỗi lấy danh mục theo tên: $e');
    }
  }

  @override
  Future<bool> categoryExists(String name) async {
    try {
      final category = await getCategoryByName(name);
      return category != null;
    } catch (e) {
      throw Exception('Lỗi kiểm tra danh mục: $e');
    }
  }

  @override
  Future<List<String>> getCategoryNames() async {
    try {
      final categories = await getActiveCategories();
      return categories.map((c) => c.name).toList();
    } catch (e) {
      throw Exception('Lỗi lấy danh sách tên danh mục: $e');
    }
  }

  @override
  Stream<CategoryModel?> watchCategory(String categoryId) {
    return firestore
        .collection(_categoriesCollection)
        .doc(categoryId)
        .snapshots()
        .map((snapshot) {
          if (!snapshot.exists) return null;
          return CategoryModel.fromFirestore(snapshot);
        });
  }

  @override
  Stream<List<CategoryModel>> watchCategories({bool? isActive, int? limit}) {
    Query query = firestore.collection(_categoriesCollection);

    if (isActive != null) {
      query = query.where('isActive', isEqualTo: isActive);
    }

    query = query.orderBy('order', descending: false);

    if (limit != null) {
      query = query.limit(limit);
    }

    return query.snapshots().map((snapshot) {
      return snapshot.docs
          .map((doc) => CategoryModel.fromFirestore(doc))
          .toList();
    });
  }

  @override
  Stream<List<CategoryModel>> watchActiveCategories({int? limit}) {
    return watchCategories(isActive: true, limit: limit);
  }
}
