import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../datasources/inventory_remote_datasource.dart';
import '../repositories/inventory_repository_impl.dart';
import '../../domain/repositories/inventory_repository.dart';
import '../../domain/usecases/check_stock.dart';
import '../../domain/usecases/get_stock_info.dart';
import '../../domain/usecases/increase_stock.dart';
import '../../domain/usecases/decrease_stock.dart';
import '../../domain/usecases/set_stock.dart';

// Datasource
final inventoryRemoteDataSourceProvider = Provider<InventoryRemoteDataSource>((
  ref,
) {
  return InventoryRemoteDataSourceImpl();
});

// Repository
final inventoryRepositoryProvider = Provider<InventoryRepository>((ref) {
  final ds = ref.watch(inventoryRemoteDataSourceProvider);
  return InventoryRepositoryImpl(remoteDataSource: ds);
});

// Use cases
final checkStockProvider = Provider<CheckStock>((ref) {
  final repo = ref.watch(inventoryRepositoryProvider);
  return CheckStock(repo);
});

final getStockInfoProvider = Provider<GetStockInfo>((ref) {
  final repo = ref.watch(inventoryRepositoryProvider);
  return GetStockInfo(repo);
});

final increaseStockProvider = Provider<IncreaseStock>((ref) {
  final repo = ref.watch(inventoryRepositoryProvider);
  return IncreaseStock(repo);
});

final decreaseStockProvider = Provider<DecreaseStock>((ref) {
  final repo = ref.watch(inventoryRepositoryProvider);
  return DecreaseStock(repo);
});

final setStockProvider = Provider<SetStock>((ref) {
  final repo = ref.watch(inventoryRepositoryProvider);
  return SetStock(repo);
});
