import 'dart:convert';
import 'package:blind_box_shop/core/constants/app_constants.dart';
import 'package:blind_box_shop/core/services/notification_service.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_stripe/flutter_stripe.dart';

class PaymentCanceledException implements Exception {
  final String message;
  PaymentCanceledException(this.message);

  @override
  String toString() => message;
}

class StripeService {
  StripeService._();

  static Future<void> presentPaymentSheet({
    required int amountInMinorUnit,
    String currency = 'usd',
    Map<String, dynamic>? metadata,
    String? merchantDisplayName,
  }) async {
    // amountInMinorUnit: số tiền VND đã nhân 100 (từ checkout_page)
    // Ví dụ: 980000 VND * 100 = 98000000
    // Chuyển sang USD cents: 98000000 / 100 / 24000 * 100 = (98000000 / 24000) = amount in USD cents
    final amountInCents = (amountInMinorUnit / AppConstants.dollarToVnd).round();
    
    // Tạo PaymentIntent trên backend
    final uri = Uri.parse(
      '${AppConstants.baseUrl}/payments/create-payment-intent',
    );
    final response = await http.post(
      uri,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'amount': amountInCents,
        'currency': currency,
        if (metadata != null) 'metadata': metadata,
      }),
    );
    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw Exception(
        'Create PaymentIntent failed: ${response.statusCode} ${response.body}',
      );
    }
    final data = jsonDecode(response.body) as Map<String, dynamic>;
    final clientSecret =
        (data['clientSecret'] as String?) ?? (data['client_secret'] as String?);
    if (clientSecret == null) {
      throw Exception('Invalid backend response: missing client secret');
    }

    await Stripe.instance.initPaymentSheet(
      paymentSheetParameters: SetupPaymentSheetParameters(
        paymentIntentClientSecret: clientSecret,
        merchantDisplayName: merchantDisplayName ?? 'Blind Box Shop',
        allowsDelayedPaymentMethods: true,
      ),
    );
    try {
      await Stripe.instance.presentPaymentSheet();
    } catch (e) {
      // Xử lý các loại lỗi khác nhau
      String errorMessage = "Thanh toán thất bại";

      if (e is StripeException) {
        switch (e.error.code) {
          case FailureCode.Canceled:
            throw PaymentCanceledException(
              'Thanh toán đã bị hủy bởi người dùng',
            );
          case FailureCode.Failed:
            errorMessage =
                "Thanh toán thất bại: ${e.error.message ?? 'Lỗi không xác định'}";
            break;
          case FailureCode.Timeout:
            errorMessage = "Thanh toán hết thời gian chờ. Vui lòng thử lại";
            break;
          default:
            errorMessage =
                "Lỗi thanh toán: ${e.error.message ?? 'Lỗi không xác định'}";
        }
      } else {
        errorMessage =
            "Lỗi hệ thống. Vui lòng kiểm tra kết nối mạng và thử lại";
      }

      NotificationService.showError(errorMessage);
      rethrow;
    }
  }
}
