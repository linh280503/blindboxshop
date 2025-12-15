class AppConstants {
  AppConstants._();

  // Base URLs
  static const String baseUrl = 'http://localhost:3000';

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
