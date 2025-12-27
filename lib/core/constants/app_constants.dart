class AppConstants {
  AppConstants._();

  // App Info
  static const String appName = 'Blind Box Shop';

  // Base URLs
  static const String baseUrl = 'http://localhost:3000';

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
