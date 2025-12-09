import '../../../../core/usecase/usecase.dart';
import '../entities/discount.dart';
import '../repositories/discount_repository.dart';

/// Use case to get discount by code
class GetDiscountByCode implements UseCase<Discount?, String> {
  final DiscountRepository repository;

  GetDiscountByCode(this.repository);

  @override
  Future<Discount?> call(String code) async {
    return await repository.getDiscountByCode(code);
  }
}
