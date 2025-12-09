import '../../../../core/usecase/usecase.dart';
import '../repositories/inventory_repository.dart';

class IncreaseStockParams {
  final String productId;
  final int quantity;
  IncreaseStockParams({required this.productId, required this.quantity});
}

class IncreaseStock implements UseCase<int, IncreaseStockParams> {
  final InventoryRepository repository;
  IncreaseStock(this.repository);

  @override
  Future<int> call(IncreaseStockParams params) {
    return repository.increaseStock(params.productId, params.quantity);
  }
}
