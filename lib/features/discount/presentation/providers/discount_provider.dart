import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/models/discount_model.dart';
import '../../data/mappers/discount_mapper.dart';
import '../../data/di/discount_providers.dart';
import '../../domain/repositories/discount_repository.dart';
import '../../domain/entities/discount.dart';
import '../../domain/usecases/validate_discount_code.dart';
import '../../domain/usecases/get_active_discounts.dart';
import '../../../../core/services/notification_service.dart';

// Discount state
class DiscountState {
  final DiscountModel? selectedDiscount;
  final double discountAmount;
  final bool isLoading;
  final String? error;

  DiscountState({
    this.selectedDiscount,
    this.discountAmount = 0.0,
    this.isLoading = false,
    this.error,
  });

  DiscountState copyWith({
    DiscountModel? selectedDiscount,
    double? discountAmount,
    bool? isLoading,
    String? error,
  }) {
    return DiscountState(
      selectedDiscount: selectedDiscount ?? this.selectedDiscount,
      discountAmount: discountAmount ?? this.discountAmount,
      isLoading: isLoading ?? this.isLoading,
      error: error ?? this.error,
    );
  }

  // Lấy thông tin mã giảm giá
  String get discountInfo {
    if (selectedDiscount == null) return '';

    final discount = selectedDiscount!;
    return '${discount.name} (${discount.formattedValue})';
  }
}

// Discount provider
final discountProvider = StateNotifierProvider<DiscountNotifier, DiscountState>(
  (ref) {
    final repo = ref.watch(discountRepositoryProvider);
    final validateDiscountCode = ref.watch(validateDiscountCodeProvider);
    final getActiveDiscounts = ref.watch(getActiveDiscountsProvider);
    return DiscountNotifier(
      repository: repo,
      validateDiscountCodeUC: validateDiscountCode,
      getActiveDiscountsUC: getActiveDiscounts,
    );
  },
);

class DiscountNotifier extends StateNotifier<DiscountState> {
  final DiscountRepository repository;
  final ValidateDiscountCode validateDiscountCodeUC;
  final GetActiveDiscounts getActiveDiscountsUC;

  DiscountNotifier({
    required this.repository,
    required this.validateDiscountCodeUC,
    required this.getActiveDiscountsUC,
  }) : super(DiscountState());

  // Áp dụng mã giảm giá
  Future<bool> applyDiscountCode(
    String code,
    double orderAmount,
    List<Map<String, dynamic>> orderItems,
    bool isFirstOrder,
  ) async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      final result = await validateDiscountCodeUC(
        ValidateDiscountCodeParams(
          code: code,
          orderAmount: orderAmount,
          orderItems: orderItems,
          isFirstOrder: isFirstOrder,
        ),
      );

      if (result['isValid'] as bool) {
        final discountEntity = result['discount'] as Discount?;
        final discountModel = discountEntity != null
            ? DiscountMapper.toModel(discountEntity)
            : null;

        state = state.copyWith(
          selectedDiscount: discountModel,
          discountAmount: (result['discountAmount'] as num).toDouble(),
          isLoading: false,
        );
        NotificationService.showSuccess('Áp dụng mã giảm giá thành công!');
        return true;
      } else {
        state = state.copyWith(
          isLoading: false,
          error: result['message'] as String?,
        );
        NotificationService.showError(
          'Mã giảm giá không hợp lệ: ${result['message']}',
        );
        return false;
      }
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
      NotificationService.showError('Lỗi áp dụng mã giảm giá: ${e.toString()}');
      return false;
    }
  }

  // Xóa mã giảm giá
  void removeDiscount() {
    state = state.copyWith(
      selectedDiscount: null,
      discountAmount: 0.0,
      error: null,
    );
    NotificationService.showInfo('Đã xóa mã giảm giá');
  }

  // Lấy mã giảm giá cho đơn hàng đầu tiên
  Future<List<DiscountModel>> getFirstOrderDiscounts() async {
    try {
      final discountEntities = await repository.getFirstOrderDiscounts();
      return DiscountMapper.toModelList(discountEntities);
    } catch (e) {
      state = state.copyWith(error: e.toString());
      NotificationService.showError(
        'Lỗi tải mã giảm giá đơn hàng đầu: ${e.toString()}',
      );
      return [];
    }
  }

  // Lấy tất cả mã giảm giá đang hoạt động
  Future<List<DiscountModel>> getActiveDiscounts() async {
    try {
      final discountEntities = await getActiveDiscountsUC(null);
      return DiscountMapper.toModelList(discountEntities);
    } catch (e) {
      state = state.copyWith(error: e.toString());
      NotificationService.showError('Lỗi tải mã giảm giá: ${e.toString()}');
      return [];
    }
  }

  // Sử dụng mã giảm giá
  Future<void> useDiscountCode() async {
    if (state.selectedDiscount == null) return;

    try {
      await repository.useDiscountCode(state.selectedDiscount!.code);
      NotificationService.showSuccess('Sử dụng mã giảm giá thành công!');
    } catch (e) {
      state = state.copyWith(error: e.toString());
      NotificationService.showError('Lỗi sử dụng mã giảm giá: ${e.toString()}');
    }
  }

  // Tính toán tổng tiền sau giảm giá
  double calculateFinalAmount(double orderAmount) {
    return orderAmount - state.discountAmount;
  }

  // Kiểm tra có mã giảm giá đang áp dụng
  bool get hasDiscount => state.selectedDiscount != null;

  // Lấy thông tin mã giảm giá
  String get discountInfo {
    if (state.selectedDiscount == null) return '';

    final discount = state.selectedDiscount!;
    return '${discount.name} (${discount.formattedValue})';
  }
}

// Provider cho danh sách mã giảm giá đang hoạt động
final activeDiscountsProvider = FutureProvider<List<DiscountModel>>((
  ref,
) async {
  final getActiveDiscounts = ref.watch(getActiveDiscountsProvider);
  final discountEntities = await getActiveDiscounts(null);
  return DiscountMapper.toModelList(discountEntities);
});

// Provider cho mã giảm giá đơn hàng đầu tiên
final firstOrderDiscountsProvider = FutureProvider<List<DiscountModel>>((
  ref,
) async {
  final repo = ref.watch(discountRepositoryProvider);
  final discountEntities = await repo.getFirstOrderDiscounts();
  return DiscountMapper.toModelList(discountEntities);
});
