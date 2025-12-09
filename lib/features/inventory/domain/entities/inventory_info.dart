class InventoryInfo {
  final String productId;
  final int currentStock;
  final bool isLowStock; // <= 10 and > 0
  final bool isOutOfStock; // == 0

  const InventoryInfo({
    required this.productId,
    required this.currentStock,
    required this.isLowStock,
    required this.isOutOfStock,
  });
}
