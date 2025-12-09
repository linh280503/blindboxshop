import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../datasources/discount_remote_datasource.dart';
import '../repositories/discount_repository_impl.dart';
import '../../domain/repositories/discount_repository.dart';
import '../../domain/usecases/get_discount_by_code.dart';
import '../../domain/usecases/validate_discount_code.dart';
import '../../domain/usecases/get_active_discounts.dart';

// Datasource provider
final discountRemoteDataSourceProvider = Provider<DiscountRemoteDataSource>((
  ref,
) {
  return DiscountRemoteDataSourceImpl();
});

// Repository provider
final discountRepositoryProvider = Provider<DiscountRepository>((ref) {
  final dataSource = ref.watch(discountRemoteDataSourceProvider);
  return DiscountRepositoryImpl(remoteDataSource: dataSource);
});

// Use cases providers
final getDiscountByCodeProvider = Provider<GetDiscountByCode>((ref) {
  final repository = ref.watch(discountRepositoryProvider);
  return GetDiscountByCode(repository);
});

final validateDiscountCodeProvider = Provider<ValidateDiscountCode>((ref) {
  final repository = ref.watch(discountRepositoryProvider);
  return ValidateDiscountCode(repository);
});

final getActiveDiscountsProvider = Provider<GetActiveDiscounts>((ref) {
  final repository = ref.watch(discountRepositoryProvider);
  return GetActiveDiscounts(repository);
});
