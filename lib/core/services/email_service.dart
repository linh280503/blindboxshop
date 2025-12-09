import 'package:emailjs/emailjs.dart' as emailjs;
import '../../features/order/data/models/order_model.dart';
import '../config/email_config.dart';

class EmailService {
  /// Gửi email thông báo đơn hàng
  static Future<bool> sendOrderNotificationEmail({
    required String userEmail,
    required OrderModel order,
    required String userName,
  }) async {
    try {
      // Tạo template parameters cho EmailJS
      final templateParams = _createOrderNotificationParams(
        order: order,
        userName: userName,
        userEmail: userEmail,
      );

      // Gửi email thật bằng EmailJS
      await emailjs.send(
        EmailConfig.serviceId,
        EmailConfig.templateOrderNotificationId,
        templateParams,
        emailjs.Options(
          publicKey: EmailConfig.publicKey,
          privateKey: EmailConfig.privateKey,
        ),
      );

      return true;
    } catch (e) {
      return false;
    }
  }

  /// Tạo template parameters cho email thông báo đơn hàng
  static Map<String, dynamic> _createOrderNotificationParams({
    required OrderModel order,
    required String userName,
    required String userEmail,
  }) {
    // Tạo danh sách orders theo format template EmailJS
    final orders = order.items
        .map(
          (item) => {
            'name': item.productName,
            'units': item.quantity,
            'price': item.price.toStringAsFixed(0),
            'image_url': item.productImage,
          },
        )
        .toList();

    return {
      'order_id': order.orderNumber,
      'email': userEmail,
      'orders': orders,
      'cost': {
        'shipping': order.shippingFee.toStringAsFixed(0),
        'tax': '0',
        'total': order.totalAmount.toStringAsFixed(0),
      },
    };
  }
}
