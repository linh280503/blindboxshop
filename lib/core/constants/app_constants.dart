import 'dart:io';

class AppConstants {
  AppConstants._();

  // App Info
  static const String appName = 'Blind Box Shop';

  // Base URLs
  // Sử dụng 10.0.2.2 cho Android Emulator, hoặc IP thực cho thiết bị thật
  // Nếu chạy trên thiết bị thật, thay bằng IP máy tính: 192.168.1.189
  static const String baseUrl = 'http://10.0.2.2:3000';

  // Authentication
  static const int minPasswordLength = 6;

  // Order Status
  static const String orderPending = 'pending';
  static const String orderConfirmed = 'confirmed';
  static const String orderShipping = 'shipping';
  static const String orderDelivered = 'delivered';
  static const String orderCancelled = 'cancelled';

  // Payment methods
  static const String paymentCod = 'cod';
  static const String paymentVnpay = 'vnpay';
  static const String paymentMomo = 'momo';
  static const String paymentStripe = 'stripe';

  // TODO: Replace with your Stripe API keys
  // Get your keys from: https://dashboard.stripe.com/apikeys
  static const String stripePrivateKey = "";
  static const String stripePublicKey = "";
  static const double dollarToVnd = 24000.0;
}
