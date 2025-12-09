import '../../../../core/usecase/usecase.dart';
import '../entities/discount.dart';
import '../repositories/discount_repository.dart';

/// Use case to get active discounts
class GetActiveDiscounts implements UseCase<List<Discount>, void> {
  final DiscountRepository repository;

  GetActiveDiscounts(this.repository);

  @override
  Future<List<Discount>> call(void params) async {
    return await repository.getActiveDiscounts();
  }
}
