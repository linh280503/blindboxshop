import '../../domain/entities/inventory_info.dart';
import '../../domain/repositories/inventory_repository.dart';
import '../datasources/inventory_remote_datasource.dart';

class InventoryRepositoryImpl implements InventoryRepository {
  final InventoryRemoteDataSource remoteDataSource;

  InventoryRepositoryImpl({required this.remoteDataSource});

  @override
  Future<bool> checkStock(String productId, int quantity) {
    return remoteDataSource.checkStock(productId, quantity);
  }

  @override
  Future<bool> checkBoxSetStock(String productId, int quantity, int size) {
    return remoteDataSource.checkBoxSetStock(productId, quantity, size);
  }

  @override
  Future<InventoryInfo> getStockInfo(String productId) {
    return remoteDataSource.getStockInfo(productId);
  }

  @override
  Future<int> decreaseStock(String productId, int quantity) {
    return remoteDataSource.decreaseStock(productId, quantity);
  }

  @override
  Future<int> increaseStock(String productId, int quantity) {
    return remoteDataSource.increaseStock(productId, quantity);
  }

  @override
  Future<int> setStock(String productId, int newStock) {
    return remoteDataSource.setStock(productId, newStock);
  }

  @override
  Stream<InventoryInfo> watchStock(String productId) {
    return remoteDataSource.watchStock(productId);
  }
}
