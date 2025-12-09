import '../../../../core/usecase/usecase.dart';
import '../entities/inventory_info.dart';
import '../repositories/inventory_repository.dart';

class GetStockInfo implements UseCase<InventoryInfo, String> {
  final InventoryRepository repository;
  GetStockInfo(this.repository);

  @override
  Future<InventoryInfo> call(String productId) {
    return repository.getStockInfo(productId);
  }
}
