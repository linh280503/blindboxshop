import '../entities/inventory_info.dart';

abstract class InventoryRepository {
  Future<bool> checkStock(String productId, int quantity);
  Future<bool> checkBoxSetStock(String productId, int quantity, int size);
  Future<InventoryInfo> getStockInfo(String productId);
  Future<int> decreaseStock(String productId, int quantity);
  Future<int> increaseStock(String productId, int quantity);
  Future<int> setStock(String productId, int newStock);
  Stream<InventoryInfo> watchStock(String productId);
}
