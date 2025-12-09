import '../../../../core/usecase/usecase.dart';
import '../repositories/discount_repository.dart';

class ValidateDiscountCodeParams {
  final String code;
  final double orderAmount;
  final List<Map<String, dynamic>> orderItems;
  final bool isFirstOrder;

  ValidateDiscountCodeParams({
    required this.code,
    required this.orderAmount,
    required this.orderItems,
    required this.isFirstOrder,
  });
}

/// Use case to validate discount code
class ValidateDiscountCode
    implements UseCase<Map<String, dynamic>, ValidateDiscountCodeParams> {
  final DiscountRepository repository;

  ValidateDiscountCode(this.repository);

  @override
  Future<Map<String, dynamic>> call(ValidateDiscountCodeParams params) async {
    return await repository.validateDiscountCode(
      params.code,
      params.orderAmount,
      params.orderItems,
      params.isFirstOrder,
    );
  }
}
