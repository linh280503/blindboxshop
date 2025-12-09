import '../../../../core/usecase/usecase.dart';
import '../repositories/inventory_repository.dart';

class SetStockParams {
  final String productId;
  final int newStock;
  SetStockParams({required this.productId, required this.newStock});
}

class SetStock implements UseCase<int, SetStockParams> {
  final InventoryRepository repository;
  SetStock(this.repository);

  @override
  Future<int> call(SetStockParams params) {
    return repository.setStock(params.productId, params.newStock);
  }
}
