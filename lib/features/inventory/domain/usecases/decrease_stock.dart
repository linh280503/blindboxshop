import '../../../../core/usecase/usecase.dart';
import '../repositories/inventory_repository.dart';

class DecreaseStockParams {
  final String productId;
  final int quantity;
  DecreaseStockParams({required this.productId, required this.quantity});
}

class DecreaseStock implements UseCase<int, DecreaseStockParams> {
  final InventoryRepository repository;
  DecreaseStock(this.repository);

  @override
  Future<int> call(DecreaseStockParams params) {
    return repository.decreaseStock(params.productId, params.quantity);
  }
}
