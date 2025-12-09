import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/entities/inventory_info.dart';

abstract class InventoryRemoteDataSource {
  Future<bool> checkStock(String productId, int quantity);
  Future<bool> checkBoxSetStock(String productId, int quantity, int size);
  Future<InventoryInfo> getStockInfo(String productId);
  Future<int> decreaseStock(String productId, int quantity);
  Future<int> increaseStock(String productId, int quantity);
  Future<int> setStock(String productId, int newStock);
  Stream<InventoryInfo> watchStock(String productId);
}

class InventoryRemoteDataSourceImpl implements InventoryRemoteDataSource {
  final FirebaseFirestore firestore;
  static const String _productsCollection = 'products';

  InventoryRemoteDataSourceImpl({FirebaseFirestore? firestore})
    : firestore = firestore ?? FirebaseFirestore.instance;

  @override
  Future<bool> checkStock(String productId, int quantity) async {
    if (quantity <= 0) return false;
    final doc = await firestore
        .collection(_productsCollection)
        .doc(productId)
        .get();
    if (!doc.exists) return false;
    final data = doc.data() as Map<String, dynamic>;
    final int stock = (data['stock'] ?? 0) as int;
    return stock >= quantity;
  }

  @override
  Future<bool> checkBoxSetStock(String productId, int quantity, int size) {
    return checkStock(productId, quantity);
  }

  @override
  Future<InventoryInfo> getStockInfo(String productId) async {
    final doc = await firestore
        .collection(_productsCollection)
        .doc(productId)
        .get();
    if (!doc.exists) {
      return const InventoryInfo(
        productId: '',
        currentStock: 0,
        isLowStock: false,
        isOutOfStock: true,
      );
    }
    final data = doc.data() as Map<String, dynamic>;
    final int stock = (data['stock'] ?? 0) as int;
    return InventoryInfo(
      productId: doc.id,
      currentStock: stock,
      isLowStock: stock > 0 && stock <= 10,
      isOutOfStock: stock <= 0,
    );
  }

  @override
  Future<int> decreaseStock(String productId, int quantity) async {
    if (quantity <= 0) return _getCurrentStock(productId);
    return firestore.runTransaction<int>((tx) async {
      final ref = firestore.collection(_productsCollection).doc(productId);
      final snap = await tx.get(ref);
      if (!snap.exists) return 0;
      final data = snap.data() as Map<String, dynamic>;
      final int current = (data['stock'] ?? 0) as int;
      final int updated = (current - quantity) < 0 ? 0 : (current - quantity);
      tx.update(ref, {
        'stock': updated,
        'updatedAt': FieldValue.serverTimestamp(),
      });
      return updated;
    });
  }

  @override
  Future<int> increaseStock(String productId, int quantity) async {
    if (quantity <= 0) return _getCurrentStock(productId);
    return firestore.runTransaction<int>((tx) async {
      final ref = firestore.collection(_productsCollection).doc(productId);
      final snap = await tx.get(ref);
      if (!snap.exists) return 0;
      final data = snap.data() as Map<String, dynamic>;
      final int current = (data['stock'] ?? 0) as int;
      final int updated = current + quantity;
      tx.update(ref, {
        'stock': updated,
        'updatedAt': FieldValue.serverTimestamp(),
      });
      return updated;
    });
  }

  @override
  Future<int> setStock(String productId, int newStock) async {
    final updated = newStock < 0 ? 0 : newStock;
    await firestore.collection(_productsCollection).doc(productId).update({
      'stock': updated,
      'updatedAt': FieldValue.serverTimestamp(),
    });
    return updated;
  }

  @override
  Stream<InventoryInfo> watchStock(String productId) {
    return firestore
        .collection(_productsCollection)
        .doc(productId)
        .snapshots()
        .map((snap) {
          if (!snap.exists) {
            return const InventoryInfo(
              productId: '',
              currentStock: 0,
              isLowStock: false,
              isOutOfStock: true,
            );
          }
          final data = snap.data() as Map<String, dynamic>;
          final int stock = (data['stock'] ?? 0) as int;
          return InventoryInfo(
            productId: snap.id,
            currentStock: stock,
            isLowStock: stock > 0 && stock <= 10,
            isOutOfStock: stock <= 0,
          );
        });
  }

  Future<int> _getCurrentStock(String productId) async {
    try {
      final doc = await firestore
          .collection(_productsCollection)
          .doc(productId)
          .get();
      if (!doc.exists) return 0;
      final data = doc.data() as Map<String, dynamic>;
      return (data['stock'] ?? 0) as int;
    } catch (_) {
      return 0;
    }
  }
}
