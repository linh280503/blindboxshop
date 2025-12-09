import '../../domain/entities/discount.dart';
import '../../domain/repositories/discount_repository.dart';
import '../datasources/discount_remote_datasource.dart';
import '../mappers/discount_mapper.dart';

/// Implementation of DiscountRepository
class DiscountRepositoryImpl implements DiscountRepository {
  final DiscountRemoteDataSource remoteDataSource;

  DiscountRepositoryImpl({required this.remoteDataSource});

  @override
  Future<Discount?> getDiscountByCode(String code) async {
    final model = await remoteDataSource.getDiscountByCode(code);
    return model != null ? DiscountMapper.toEntity(model) : null;
  }

  @override
  Future<List<Discount>> getActiveDiscounts() async {
    final models = await remoteDataSource.getActiveDiscounts();
    return DiscountMapper.toEntityList(models);
  }

  @override
  Future<List<Discount>> getFirstOrderDiscounts() async {
    final models = await remoteDataSource.getFirstOrderDiscounts();
    return DiscountMapper.toEntityList(models);
  }

  @override
  Future<Map<String, dynamic>> validateDiscountCode(
    String code,
    double orderAmount,
    List<Map<String, dynamic>> orderItems,
    bool isFirstOrder,
  ) async {
    final result = await remoteDataSource.validateDiscountCode(
      code,
      orderAmount,
      orderItems,
      isFirstOrder,
    );

    // Convert discount model to entity if present
    if (result['discount'] != null) {
      result['discount'] = DiscountMapper.toEntity(result['discount']);
    }

    return result;
  }

  @override
  Future<void> useDiscountCode(String code) async {
    await remoteDataSource.useDiscountCode(code);
  }

  @override
  Future<String> createDiscount(Discount discount) async {
    final model = DiscountMapper.toModel(discount);
    return await remoteDataSource.createDiscount(model);
  }

  @override
  Future<void> updateDiscount(String discountId, Discount discount) async {
    final model = DiscountMapper.toModel(discount);
    await remoteDataSource.updateDiscount(discountId, model);
  }

  @override
  Future<void> deleteDiscount(String discountId) async {
    await remoteDataSource.deleteDiscount(discountId);
  }

  @override
  Future<List<Discount>> getAllDiscounts() async {
    final models = await remoteDataSource.getAllDiscounts();
    return DiscountMapper.toEntityList(models);
  }

  @override
  Future<List<Discount>> searchDiscounts(String query) async {
    final models = await remoteDataSource.searchDiscounts(query);
    return DiscountMapper.toEntityList(models);
  }

  @override
  Future<void> toggleDiscountStatus(String discountId, bool isActive) async {
    await remoteDataSource.toggleDiscountStatus(discountId, isActive);
  }

  @override
  Future<Map<String, dynamic>> getDiscountOverview() async {
    return await remoteDataSource.getDiscountOverview();
  }

  @override
  Future<String> duplicateDiscount(String discountId) async {
    return await remoteDataSource.duplicateDiscount(discountId);
  }
}
