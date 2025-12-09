import '../entities/discount.dart';

abstract class DiscountRepository {
  Future<Discount?> getDiscountByCode(String code);
  Future<List<Discount>> getActiveDiscounts();
  Future<List<Discount>> getFirstOrderDiscounts();
  Future<Map<String, dynamic>> validateDiscountCode(
    String code,
    double orderAmount,
    List<Map<String, dynamic>> orderItems,
    bool isFirstOrder,
  );
  Future<void> useDiscountCode(String code);
  Future<String> createDiscount(Discount discount);
  Future<void> updateDiscount(String discountId, Discount discount);
  Future<void> deleteDiscount(String discountId);
  Future<List<Discount>> getAllDiscounts();
  Future<List<Discount>> searchDiscounts(String query);
  Future<void> toggleDiscountStatus(String discountId, bool isActive);
  Future<Map<String, dynamic>> getDiscountOverview();
  Future<String> duplicateDiscount(String discountId);
}
