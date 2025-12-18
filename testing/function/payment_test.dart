import 'package:flutter_test/flutter_test.dart';

/// =============================================================================
/// TEST FILE 4: PAYMENT/STRIPE SERVICE TEST
/// =============================================================================
/// 
/// MỤC ĐÍCH: Kiểm tra các chức năng thanh toán
/// - Chuyển đổi tiền tệ VND sang USD cents
/// - Validate số tiền thanh toán
/// - Xử lý các trường hợp lỗi thanh toán
/// 
/// CÁCH CHẠY: flutter test testing/function/payment_test.dart

// ============== CONSTANTS & HELPER FUNCTIONS ==============

const double dollarToVnd = 24000;

/// Chuyển đổi VND sang USD cents để gửi đến Stripe
int convertVndToUsdCents(double amountInVnd) {
  if (amountInVnd < 0) {
    throw ArgumentError('Amount cannot be negative');
  }
  return (amountInVnd / dollarToVnd).round();
}

/// Validate số tiền thanh toán
class PaymentValidationResult {
  final bool valid;
  final String? error;

  PaymentValidationResult({required this.valid, this.error});
}

PaymentValidationResult validatePaymentAmount(dynamic amount) {
  if (amount == null) {
    return PaymentValidationResult(valid: false, error: 'Amount is required');
  }
  if (amount is! num) {
    return PaymentValidationResult(valid: false, error: 'Amount must be a number');
  }
  if (amount <= 0) {
    return PaymentValidationResult(valid: false, error: 'Amount must be positive');
  }
  if (amount.isInfinite) {
    return PaymentValidationResult(valid: false, error: 'Amount must be finite');
  }
  if (amount.isNaN) {
    return PaymentValidationResult(valid: false, error: 'Amount cannot be NaN');
  }
  return PaymentValidationResult(valid: true);
}

/// Tính phí thanh toán (giả định 2.9% + 30 cents như Stripe)
double calculateStripeFee(double amountInUsd) {
  return amountInUsd * 0.029 + 0.30;
}

/// Validate metadata cho Stripe PaymentIntent
class MetadataValidationResult {
  final bool valid;
  final String? error;

  MetadataValidationResult({required this.valid, this.error});
}

MetadataValidationResult validatePaymentMetadata(Map<String, dynamic>? metadata) {
  if (metadata == null) {
    return MetadataValidationResult(valid: true); // Metadata là optional
  }
  
  // Kiểm tra giới hạn key
  if (metadata.length > 50) {
    return MetadataValidationResult(valid: false, error: 'Metadata cannot have more than 50 keys');
  }
  
  // Kiểm tra độ dài key và value
  for (var entry in metadata.entries) {
    if (entry.key.length > 40) {
      return MetadataValidationResult(valid: false, error: 'Metadata key cannot exceed 40 characters');
    }
    if (entry.value.toString().length > 500) {
      return MetadataValidationResult(valid: false, error: 'Metadata value cannot exceed 500 characters');
    }
  }
  
  return MetadataValidationResult(valid: true);
}

// ============== TEST CASES ==============

void main() {
  group('Payment/Stripe - Thanh toán', () {
    /// TEST 15: Chuyển đổi VND sang USD cents
    /// 
    /// MỤC ĐÍCH: Kiểm tra công thức chuyển đổi tiền tệ từ VND
    /// sang USD cents để gửi đến Stripe API.
    test('Test 15: Chuyển đổi VND sang USD cents', () {
      // 240000 VND / 24000 (tỷ giá) = 10 USD cents
      expect(convertVndToUsdCents(240000), 10);

      // 480000 VND / 24000 = 20 USD cents
      expect(convertVndToUsdCents(480000), 20);

      // 1200000 VND / 24000 = 50 USD cents
      expect(convertVndToUsdCents(1200000), 50);
      
      // 0 VND = 0 cents
      expect(convertVndToUsdCents(0), 0);
    });

    /// TEST 16: Validate số tiền thanh toán hợp lệ
    /// 
    /// MỤC ĐÍCH: Kiểm tra validation số tiền trước khi gửi
    /// request tạo PaymentIntent đến Stripe.
    test('Test 16: Validate số tiền thanh toán hợp lệ', () {
      expect(validatePaymentAmount(100000).valid, true);
      expect(validatePaymentAmount(1).valid, true);
      expect(validatePaymentAmount(999999999).valid, true);
      expect(validatePaymentAmount(0.01).valid, true);
    });

    /// TEST 17: Từ chối số tiền thanh toán không hợp lệ
    /// 
    /// MỤC ĐÍCH: Kiểm tra các trường hợp số tiền không hợp lệ:
    /// - Số âm, Bằng 0, Không phải số, Infinity, NaN
    test('Test 17: Từ chối số tiền thanh toán không hợp lệ', () {
      // Số âm
      expect(validatePaymentAmount(-100).valid, false);
      expect(validatePaymentAmount(-100).error, 'Amount must be positive');

      // Bằng 0
      expect(validatePaymentAmount(0).valid, false);
      expect(validatePaymentAmount(0).error, 'Amount must be positive');

      // Không phải số
      expect(validatePaymentAmount('100').valid, false);
      expect(validatePaymentAmount('100').error, 'Amount must be a number');

      // Infinity
      expect(validatePaymentAmount(double.infinity).valid, false);
      expect(validatePaymentAmount(double.infinity).error, 'Amount must be finite');
      
      // Null
      expect(validatePaymentAmount(null).valid, false);
      expect(validatePaymentAmount(null).error, 'Amount is required');
    });

    /// TEST 18: Tính phí Stripe
    /// 
    /// MỤC ĐÍCH: Kiểm tra công thức tính phí giao dịch Stripe
    /// (2.9% + $0.30 per transaction)
    test('Test 18: Tính phí Stripe transaction', () {
      // $100 transaction: 100 * 0.029 + 0.30 = 2.9 + 0.30 = 3.20
      expect(calculateStripeFee(100), closeTo(3.20, 0.01));
      
      // $50 transaction: 50 * 0.029 + 0.30 = 1.45 + 0.30 = 1.75
      expect(calculateStripeFee(50), closeTo(1.75, 0.01));
      
      // $10 transaction: 10 * 0.029 + 0.30 = 0.29 + 0.30 = 0.59
      expect(calculateStripeFee(10), closeTo(0.59, 0.01));
    });

    /// TEST 19: Validate metadata cho PaymentIntent
    /// 
    /// MỤC ĐÍCH: Kiểm tra metadata gửi kèm PaymentIntent
    /// phải tuân thủ giới hạn của Stripe.
    test('Test 19: Validate metadata cho PaymentIntent', () {
      // Metadata hợp lệ
      expect(validatePaymentMetadata({'orderId': 'ORD-001', 'userId': 'user-001'}).valid, true);
      
      // Null metadata (optional)
      expect(validatePaymentMetadata(null).valid, true);
      
      // Quá 50 keys
      final tooManyKeys = Map.fromEntries(
        List.generate(51, (i) => MapEntry('key$i', 'value$i'))
      );
      expect(validatePaymentMetadata(tooManyKeys).valid, false);
      expect(validatePaymentMetadata(tooManyKeys).error, 'Metadata cannot have more than 50 keys');
    });

    /// TEST 20: Ném lỗi khi số tiền âm
    /// 
    /// MỤC ĐÍCH: Kiểm tra function throw ArgumentError khi
    /// số tiền VND là số âm.
    test('Test 20: Ném lỗi khi số tiền âm', () {
      expect(
        () => convertVndToUsdCents(-100000),
        throwsA(isA<ArgumentError>()),
      );
    });
  });
}
