import '../../../../core/usecase/usecase.dart';
import '../repositories/inventory_repository.dart';

class CheckStockParams {
  final String productId;
  final int quantity;
  CheckStockParams({required this.productId, required this.quantity});
}

class CheckStock implements UseCase<bool, CheckStockParams> {
  final InventoryRepository repository;
  CheckStock(this.repository);

  @override
  Future<bool> call(CheckStockParams params) {
    return repository.checkStock(params.productId, params.quantity);
  }
}
