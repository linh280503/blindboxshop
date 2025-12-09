// ignore_for_file: avoid_print

import 'package:flutter/material.dart';

class NotificationService {
  static final GlobalKey<ScaffoldMessengerState> _scaffoldMessengerKey =
      GlobalKey<ScaffoldMessengerState>();

  static GlobalKey<ScaffoldMessengerState> get scaffoldMessengerKey =>
      _scaffoldMessengerKey;

  /// Hiển thị thông báo thành công
  static void showSuccess(
    String message, {
    Duration duration = const Duration(seconds: 3),
  }) {
    _scaffoldMessengerKey.currentState?.showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.check_circle, color: Colors.white, size: 20),
            const SizedBox(width: 8),
            Expanded(child: Text(message)),
          ],
        ),
        backgroundColor: Colors.green,
        duration: duration,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
    );
  }

  /// Hiển thị thông báo lỗi
  static void showError(
    String message, {
    Duration duration = const Duration(seconds: 4),
  }) {
    _scaffoldMessengerKey.currentState?.showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.error, color: Colors.white, size: 20),
            const SizedBox(width: 8),
            Expanded(child: Text(message)),
          ],
        ),
        backgroundColor: Colors.red,
        duration: duration,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
    );
  }

  /// Hiển thị thông báo cảnh báo
  static void showWarning(
    String message, {
    Duration duration = const Duration(seconds: 3),
  }) {
    _scaffoldMessengerKey.currentState?.showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.warning, color: Colors.white, size: 20),
            const SizedBox(width: 8),
            Expanded(child: Text(message)),
          ],
        ),
        backgroundColor: Colors.orange,
        duration: duration,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
    );
  }

  /// Hiển thị thông báo thông tin
  static void showInfo(
    String message, {
    Duration duration = const Duration(seconds: 3),
  }) {
    _scaffoldMessengerKey.currentState?.showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.info, color: Colors.white, size: 20),
            const SizedBox(width: 8),
            Expanded(child: Text(message)),
          ],
        ),
        backgroundColor: Colors.blue,
        duration: duration,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
    );
  }

  /// Hiển thị thông báo hết hàng
  static void showOutOfStock(String productName) {
    showWarning(
      'Sản phẩm "$productName" đã hết hàng',
      duration: const Duration(seconds: 4),
    );
  }

  /// Hiển thị thông báo vượt quá tồn kho
  static void showExceedStock(String productName, int availableStock) {
    showWarning(
      'Sản phẩm "$productName" chỉ còn $availableStock sản phẩm',
      duration: const Duration(seconds: 4),
    );
  }

  /// Hiển thị thông báo thêm vào giỏ hàng thành công
  static void showAddToCartSuccess(String productName, int quantity) {
    showSuccess('Đã thêm $quantity sản phẩm "$productName" vào giỏ hàng');
  }

  /// Hiển thị thông báo cập nhật giỏ hàng thành công
  static void showUpdateCartSuccess(String productName, int quantity) {
    showSuccess('Đã cập nhật "$productName" thành $quantity sản phẩm');
  }

  /// Hiển thị thông báo xóa sản phẩm thành công
  static void showRemoveFromCartSuccess(String productName) {
    showSuccess('Đã xóa "$productName" khỏi giỏ hàng');
  }

  /// Hiển thị thông báo xóa giỏ hàng thành công
  static void showClearCartSuccess() {
    showSuccess('Đã xóa toàn bộ giỏ hàng');
  }

  /// Hiển thị thông báo đồng bộ thành công
  static void showSyncSuccess() {
    showSuccess('Đã đồng bộ giỏ hàng thành công');
  }

  /// Hiển thị thông báo lỗi mạng
  static void showNetworkError() {
    showError(
      'Lỗi kết nối mạng. Vui lòng kiểm tra kết nối internet.',
      duration: const Duration(seconds: 5),
    );
  }

  /// Hiển thị thông báo lỗi chung
  static void showGenericError(String operation) {
    showError('Có lỗi xảy ra khi $operation. Vui lòng thử lại.');
  }

  /// Hiển thị thông báo loading
  static void showLoading(String message) {
    _scaffoldMessengerKey.currentState?.showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(child: Text(message)),
          ],
        ),
        backgroundColor: Colors.blue,
        duration: const Duration(seconds: 2),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
    );
  }

  /// Ẩn tất cả thông báo
  static void hideAll() {
    _scaffoldMessengerKey.currentState?.clearSnackBars();
  }
}
