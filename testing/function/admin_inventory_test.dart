import 'package:flutter_test/flutter_test.dart';

/// =============================================================================
/// TEST FILE 7: ADMIN INVENTORY MANAGEMENT TEST
/// =============================================================================
/// 
/// MỤC ĐÍCH: Kiểm tra các chức năng quản lý kho hàng cho Admin
/// - Kiểm tra số lượng tồn kho
/// - Cảnh báo hàng sắp hết
/// - Kiểm tra hết hàng
/// - Tính giá trị kho hàng
/// - Quản lý nhập/xuất kho
/// 
/// CÁCH CHẠY: flutter test testing/function/admin_inventory_test.dart

// ============== MOCK CLASSES ==============

class InventoryInfo {
  final String productId;
  final int currentStock;
  final bool isLowStock;
  final bool isOutOfStock;

  const InventoryInfo({
    required this.productId,
    required this.currentStock,
    required this.isLowStock,
    required this.isOutOfStock,
  });
}

class InventoryItem {
  final String productId;
  final String productName;
  final int currentStock;
  final int minStock; // Ngưỡng cảnh báo
  final double unitPrice;
  final DateTime lastUpdated;

  InventoryItem({
    required this.productId,
    required this.productName,
    required this.currentStock,
    required this.minStock,
    required this.unitPrice,
    required this.lastUpdated,
  });

  InventoryItem copyWith({
    String? productId,
    String? productName,
    int? currentStock,
    int? minStock,
    double? unitPrice,
    DateTime? lastUpdated,
  }) {
    return InventoryItem(
      productId: productId ?? this.productId,
      productName: productName ?? this.productName,
      currentStock: currentStock ?? this.currentStock,
      minStock: minStock ?? this.minStock,
      unitPrice: unitPrice ?? this.unitPrice,
      lastUpdated: lastUpdated ?? DateTime.now(),
    );
  }
}

enum StockMovementType { import_, export_, adjustment, return_ }

class StockMovement {
  final String id;
  final String productId;
  final StockMovementType type;
  final int quantity;
  final String reason;
  final DateTime createdAt;
  final String createdBy;

  StockMovement({
    required this.id,
    required this.productId,
    required this.type,
    required this.quantity,
    required this.reason,
    required this.createdAt,
    required this.createdBy,
  });
}

// ============== HELPER FUNCTIONS ==============

/// Kiểm tra trạng thái tồn kho
InventoryInfo checkInventoryStatus(String productId, int stock, {int lowStockThreshold = 10}) {
  return InventoryInfo(
    productId: productId,
    currentStock: stock,
    isLowStock: stock > 0 && stock <= lowStockThreshold,
    isOutOfStock: stock == 0,
  );
}

/// Phân loại trạng thái kho
String getStockStatus(int stock, {int lowThreshold = 10, int criticalThreshold = 5}) {
  if (stock == 0) return 'OUT_OF_STOCK';
  if (stock <= criticalThreshold) return 'CRITICAL';
  if (stock <= lowThreshold) return 'LOW_STOCK';
  if (stock >= 100) return 'OVERSTOCKED';
  return 'NORMAL';
}

/// Tính giá trị tồn kho
double calculateInventoryValue(List<InventoryItem> items) {
  return items.fold(0.0, (sum, item) => sum + (item.currentStock * item.unitPrice));
}

/// Tính số lượng cần nhập thêm để đạt mức tối thiểu
int calculateReorderQuantity(int currentStock, int minStock, int reorderMultiple) {
  if (currentStock >= minStock) return 0;
  
  final deficit = minStock - currentStock;
  // Làm tròn lên theo bội số reorderMultiple
  return ((deficit / reorderMultiple).ceil()) * reorderMultiple;
}

/// Kiểm tra có đủ hàng để xuất không
class StockCheckResult {
  final bool canFulfill;
  final int availableQuantity;
  final int shortfall;
  
  StockCheckResult({
    required this.canFulfill,
    required this.availableQuantity,
    required this.shortfall,
  });
}

StockCheckResult checkStockAvailability(int currentStock, int requestedQuantity) {
  if (requestedQuantity < 0) {
    return StockCheckResult(canFulfill: false, availableQuantity: currentStock, shortfall: 0);
  }
  
  final canFulfill = currentStock >= requestedQuantity;
  final shortfall = canFulfill ? 0 : requestedQuantity - currentStock;
  
  return StockCheckResult(
    canFulfill: canFulfill,
    availableQuantity: currentStock,
    shortfall: shortfall,
  );
}

/// Cập nhật số lượng tồn kho sau movement
class StockUpdateResult {
  final bool success;
  final int newStock;
  final String? error;
  
  StockUpdateResult({required this.success, required this.newStock, this.error});
}

StockUpdateResult updateStock(int currentStock, StockMovementType type, int quantity) {
  if (quantity < 0) {
    return StockUpdateResult(success: false, newStock: currentStock, error: 'Quantity cannot be negative');
  }
  
  int newStock;
  switch (type) {
    case StockMovementType.import_:
    case StockMovementType.return_:
      newStock = currentStock + quantity;
      break;
    case StockMovementType.export_:
      if (currentStock < quantity) {
        return StockUpdateResult(success: false, newStock: currentStock, error: 'Insufficient stock');
      }
      newStock = currentStock - quantity;
      break;
    case StockMovementType.adjustment:
      newStock = quantity; // Điều chỉnh về số cụ thể
      break;
  }
  
  return StockUpdateResult(success: true, newStock: newStock);
}

/// Tính tỷ lệ quay vòng kho (inventory turnover)
double calculateInventoryTurnover(double costOfGoodsSold, double averageInventory) {
  if (averageInventory == 0) return 0;
  return costOfGoodsSold / averageInventory;
}

/// Tính số ngày tồn kho trung bình
double calculateDaysInInventory(double inventoryTurnover) {
  if (inventoryTurnover == 0) return double.infinity;
  return 365 / inventoryTurnover;
}

/// Lấy danh sách sản phẩm cần nhập hàng
List<InventoryItem> getItemsNeedReorder(List<InventoryItem> items) {
  return items.where((item) => item.currentStock <= item.minStock).toList();
}

// ============== TEST CASES ==============

void main() {
  group('Admin Inventory - Kiểm tra tồn kho', () {
    /// TEST 1: Kiểm tra trạng thái tồn kho
    /// 
    /// MỤC ĐÍCH: Kiểm tra logic xác định hàng còn, sắp hết, hoặc hết
    test('Test 1: Kiểm tra trạng thái tồn kho', () {
      final normalStock = checkInventoryStatus('prod-001', 50);
      expect(normalStock.isLowStock, false);
      expect(normalStock.isOutOfStock, false);
      
      final lowStock = checkInventoryStatus('prod-002', 5);
      expect(lowStock.isLowStock, true);
      expect(lowStock.isOutOfStock, false);
      
      final outOfStock = checkInventoryStatus('prod-003', 0);
      expect(outOfStock.isLowStock, false);
      expect(outOfStock.isOutOfStock, true);
    });

    /// TEST 2: Phân loại trạng thái kho chi tiết
    /// 
    /// MỤC ĐÍCH: Kiểm tra phân loại kho với nhiều mức cảnh báo
    test('Test 2: Phân loại trạng thái kho chi tiết', () {
      expect(getStockStatus(0), 'OUT_OF_STOCK');
      expect(getStockStatus(3), 'CRITICAL');
      expect(getStockStatus(8), 'LOW_STOCK');
      expect(getStockStatus(50), 'NORMAL');
      expect(getStockStatus(150), 'OVERSTOCKED');
    });

    /// TEST 3: Tính giá trị tồn kho
    /// 
    /// MỤC ĐÍCH: Kiểm tra công thức tính tổng giá trị hàng tồn
    test('Test 3: Tính giá trị tồn kho', () {
      final items = [
        InventoryItem(productId: 'p1', productName: 'Box A', currentStock: 100, minStock: 10, unitPrice: 350000, lastUpdated: DateTime.now()),
        InventoryItem(productId: 'p2', productName: 'Box B', currentStock: 50, minStock: 10, unitPrice: 280000, lastUpdated: DateTime.now()),
        InventoryItem(productId: 'p3', productName: 'Box C', currentStock: 30, minStock: 5, unitPrice: 420000, lastUpdated: DateTime.now()),
      ];

      // 100*350000 + 50*280000 + 30*420000 = 35M + 14M + 12.6M = 61.6M
      final totalValue = calculateInventoryValue(items);
      expect(totalValue, 61600000);
    });

    /// TEST 4: Tính số lượng cần nhập thêm
    /// 
    /// MỤC ĐÍCH: Kiểm tra logic tính toán số lượng cần đặt hàng
    test('Test 4: Tính số lượng cần nhập thêm', () {
      // Stock: 5, Min: 20, Reorder by 12 -> need 15, round up to 24
      expect(calculateReorderQuantity(5, 20, 12), 24);
      
      // Stock: 15, Min: 20, Reorder by 10 -> need 5, round up to 10
      expect(calculateReorderQuantity(15, 20, 10), 10);
      
      // Stock đủ
      expect(calculateReorderQuantity(25, 20, 10), 0);
    });
  });

  group('Admin Inventory - Xuất nhập kho', () {
    /// TEST 5: Kiểm tra đủ hàng để xuất
    /// 
    /// MỤC ĐÍCH: Kiểm tra logic kiểm tra khả năng đáp ứng đơn hàng
    test('Test 5: Kiểm tra đủ hàng để xuất', () {
      final canFulfill = checkStockAvailability(50, 30);
      expect(canFulfill.canFulfill, true);
      expect(canFulfill.shortfall, 0);
      
      final cantFulfill = checkStockAvailability(20, 30);
      expect(cantFulfill.canFulfill, false);
      expect(cantFulfill.shortfall, 10);
      
      final exactMatch = checkStockAvailability(30, 30);
      expect(exactMatch.canFulfill, true);
    });

    /// TEST 6: Cập nhật tồn kho khi nhập hàng
    /// 
    /// MỤC ĐÍCH: Kiểm tra logic tăng stock khi import
    test('Test 6: Cập nhật tồn kho khi nhập hàng', () {
      final result = updateStock(50, StockMovementType.import_, 30);
      expect(result.success, true);
      expect(result.newStock, 80);
    });

    /// TEST 7: Cập nhật tồn kho khi xuất hàng
    /// 
    /// MỤC ĐÍCH: Kiểm tra logic giảm stock khi export
    test('Test 7: Cập nhật tồn kho khi xuất hàng', () {
      final successResult = updateStock(50, StockMovementType.export_, 30);
      expect(successResult.success, true);
      expect(successResult.newStock, 20);
      
      // Không đủ hàng
      final failResult = updateStock(20, StockMovementType.export_, 30);
      expect(failResult.success, false);
      expect(failResult.error, 'Insufficient stock');
    });

    /// TEST 8: Điều chỉnh tồn kho (adjustment)
    /// 
    /// MỤC ĐÍCH: Kiểm tra logic điều chỉnh stock về số cụ thể
    test('Test 8: Điều chỉnh tồn kho', () {
      final result = updateStock(50, StockMovementType.adjustment, 35);
      expect(result.success, true);
      expect(result.newStock, 35);
    });
  });

  group('Admin Inventory - Báo cáo & Phân tích', () {
    /// TEST 9: Tính tỷ lệ quay vòng kho
    /// 
    /// MỤC ĐÍCH: Kiểm tra công thức inventory turnover
    test('Test 9: Tính tỷ lệ quay vòng kho (Inventory Turnover)', () {
      // COGS: 100M, Avg Inventory: 25M => Turnover = 4
      expect(calculateInventoryTurnover(100000000, 25000000), 4.0);
      
      // Edge case
      expect(calculateInventoryTurnover(0, 0), 0);
    });

    /// TEST 10: Tính số ngày tồn kho trung bình
    /// 
    /// MỤC ĐÍCH: Kiểm tra công thức days in inventory
    test('Test 10: Tính số ngày tồn kho trung bình', () {
      // Turnover = 4 => Days = 365/4 = 91.25 ngày
      expect(calculateDaysInInventory(4), closeTo(91.25, 0.01));
      
      // Turnover = 12 => Days = 365/12 = 30.42 ngày
      expect(calculateDaysInInventory(12), closeTo(30.42, 0.01));
      
      // Edge case: turnover = 0
      expect(calculateDaysInInventory(0), double.infinity);
    });

    /// TEST 11: Lấy danh sách sản phẩm cần nhập hàng
    /// 
    /// MỤC ĐÍCH: Kiểm tra logic lọc sản phẩm cần reorder
    test('Test 11: Lấy danh sách sản phẩm cần nhập hàng', () {
      final now = DateTime.now();
      final items = [
        InventoryItem(productId: 'p1', productName: 'Box A', currentStock: 5, minStock: 10, unitPrice: 350000, lastUpdated: now),
        InventoryItem(productId: 'p2', productName: 'Box B', currentStock: 50, minStock: 10, unitPrice: 280000, lastUpdated: now),
        InventoryItem(productId: 'p3', productName: 'Box C', currentStock: 10, minStock: 10, unitPrice: 420000, lastUpdated: now),
        InventoryItem(productId: 'p4', productName: 'Box D', currentStock: 0, minStock: 5, unitPrice: 300000, lastUpdated: now),
      ];

      final needReorder = getItemsNeedReorder(items);
      
      expect(needReorder.length, 3); // p1, p3, p4
      expect(needReorder.any((item) => item.productId == 'p2'), false); // p2 có đủ hàng
    });

    /// TEST 12: Từ chối số lượng âm
    /// 
    /// MỤC ĐÍCH: Kiểm tra validation quantity không được âm
    test('Test 12: Từ chối số lượng âm', () {
      final result = updateStock(50, StockMovementType.import_, -10);
      expect(result.success, false);
      expect(result.error, 'Quantity cannot be negative');
    });
  });
}
