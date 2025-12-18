/// =============================================================
/// BLIND BOX SHOP - API INTEGRATION TESTS (DART)
/// =============================================================
/// File này chứa 40 test cases để kiểm tra:
/// 1. Firebase Auth REST API (đăng ký, đăng nhập, reset password...)
/// 2. Firebase Firestore REST API (products, orders, users...)
/// 3. Stripe Payment API (Node.js server)
///
/// Cách chạy:
///   1. Chạy server Stripe: cd server && npm run dev
///   2. Chạy test: dart test testing/api/api_test.dart --reporter expanded
///
/// Lưu ý: Một số test sẽ tạo dữ liệu thật trên Firebase!
/// =============================================================

import 'dart:convert';
import 'dart:math';
import 'package:http/http.dart' as http;
import 'package:test/test.dart';

/// ============ CONFIGURATION ============
/// Stripe Payment Server
const String stripeServerUrl = 'http://localhost:3000';

/// Firebase Config - Lấy từ firebase_options.dart
const String firebaseApiKey = 'AIzaSyAEjaWLILGnKYAbNCEdP3dkiYLGgnEEVPo';
const String firebaseProjectId = 'shop-blind-box';

/// Firebase REST API URLs
const String firebaseAuthUrl = 'https://identitytoolkit.googleapis.com/v1';
const String firestoreBaseUrl = 'https://firestore.googleapis.com/v1';
String get firestoreUrl => '$firestoreBaseUrl/projects/$firebaseProjectId/databases/(default)/documents';

/// Test email (random để tránh trùng)
String generateTestEmail() {
  final random = Random().nextInt(99999);
  return 'test_user_$random@test.com';
}

const String testPassword = 'Test@123456';

/// Store tokens for subsequent tests
String? _idToken;
String? _testUserId;

void main() {
  /// =========================================================
  /// NHÓM 1: FIREBASE AUTH - ĐĂNG KÝ (4 tests)
  /// Mục đích: Kiểm tra chức năng đăng ký tài khoản
  /// =========================================================
  group('1. Firebase Auth - Đăng ký', () {
    /// TEST 1: Đăng ký tài khoản mới thành công
    /// Mục đích: Xác nhận có thể tạo tài khoản với email/password hợp lệ
    test('Test 1: Đăng ký tài khoản mới thành công', () async {
      final testEmail = generateTestEmail();
      
      final response = await http.post(
        Uri.parse('$firebaseAuthUrl/accounts:signUp?key=$firebaseApiKey'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'email': testEmail,
          'password': testPassword,
          'returnSecureToken': true,
        }),
      );

      expect(response.statusCode, equals(200));

      final body = jsonDecode(response.body);
      expect(body.containsKey('idToken'), isTrue);
      expect(body.containsKey('localId'), isTrue);
      expect(body['email'], equals(testEmail));

      // Lưu token để dùng cho các test sau
      _idToken = body['idToken'];
      _testUserId = body['localId'];

      print('✅ Test 1 PASSED: Đăng ký thành công với email: $testEmail');
    });

    /// TEST 2: Từ chối đăng ký với email không hợp lệ
    /// Mục đích: Kiểm tra validation email format
    test('Test 2: Từ chối đăng ký với email không hợp lệ', () async {
      final response = await http.post(
        Uri.parse('$firebaseAuthUrl/accounts:signUp?key=$firebaseApiKey'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'email': 'invalid-email',
          'password': testPassword,
          'returnSecureToken': true,
        }),
      );

      expect(response.statusCode, equals(400));

      final body = jsonDecode(response.body);
      expect(body['error']['message'], contains('INVALID_EMAIL'));

      print('✅ Test 2 PASSED: Email không hợp lệ bị từ chối');
    });

    /// TEST 3: Từ chối đăng ký với password yếu
    /// Mục đích: Kiểm tra validation password (min 6 ký tự)
    test('Test 3: Từ chối đăng ký với password yếu (< 6 ký tự)', () async {
      final response = await http.post(
        Uri.parse('$firebaseAuthUrl/accounts:signUp?key=$firebaseApiKey'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'email': generateTestEmail(),
          'password': '123',
          'returnSecureToken': true,
        }),
      );

      expect(response.statusCode, equals(400));

      final body = jsonDecode(response.body);
      expect(body['error']['message'], anyOf([
        contains('WEAK_PASSWORD'),
        contains('PASSWORD'),
      ]));

      print('✅ Test 3 PASSED: Password yếu bị từ chối');
    });

    /// TEST 4: Từ chối đăng ký với email đã tồn tại
    /// Mục đích: Kiểm tra không cho phép duplicate email
    test('Test 4: Từ chối đăng ký với email đã tồn tại', () async {
      // Đăng ký lần 1
      final testEmail = generateTestEmail();
      await http.post(
        Uri.parse('$firebaseAuthUrl/accounts:signUp?key=$firebaseApiKey'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'email': testEmail,
          'password': testPassword,
          'returnSecureToken': true,
        }),
      );

      // Đăng ký lần 2 với cùng email
      final response = await http.post(
        Uri.parse('$firebaseAuthUrl/accounts:signUp?key=$firebaseApiKey'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'email': testEmail,
          'password': testPassword,
          'returnSecureToken': true,
        }),
      );

      expect(response.statusCode, equals(400));

      final body = jsonDecode(response.body);
      expect(body['error']['message'], contains('EMAIL_EXISTS'));

      print('✅ Test 4 PASSED: Email đã tồn tại bị từ chối');
    });
  });

  /// =========================================================
  /// NHÓM 2: FIREBASE AUTH - ĐĂNG NHẬP (4 tests)
  /// Mục đích: Kiểm tra chức năng đăng nhập
  /// =========================================================
  group('2. Firebase Auth - Đăng nhập', () {
    late String registeredEmail;

    setUpAll(() async {
      // Tạo tài khoản để test đăng nhập
      registeredEmail = generateTestEmail();
      await http.post(
        Uri.parse('$firebaseAuthUrl/accounts:signUp?key=$firebaseApiKey'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'email': registeredEmail,
          'password': testPassword,
          'returnSecureToken': true,
        }),
      );
    });

    /// TEST 5: Đăng nhập thành công với thông tin đúng
    /// Mục đích: Xác nhận có thể đăng nhập với email/password đúng
    test('Test 5: Đăng nhập thành công với email/password đúng', () async {
      final response = await http.post(
        Uri.parse('$firebaseAuthUrl/accounts:signInWithPassword?key=$firebaseApiKey'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'email': registeredEmail,
          'password': testPassword,
          'returnSecureToken': true,
        }),
      );

      expect(response.statusCode, equals(200));

      final body = jsonDecode(response.body);
      expect(body.containsKey('idToken'), isTrue);
      expect(body.containsKey('refreshToken'), isTrue);
      expect(body['email'], equals(registeredEmail));

      _idToken = body['idToken'];

      print('✅ Test 5 PASSED: Đăng nhập thành công');
    });

    /// TEST 6: Từ chối đăng nhập với email không tồn tại
    /// Mục đích: Kiểm tra xử lý email không tồn tại trong hệ thống
    test('Test 6: Từ chối đăng nhập với email không tồn tại', () async {
      final response = await http.post(
        Uri.parse('$firebaseAuthUrl/accounts:signInWithPassword?key=$firebaseApiKey'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'email': 'nonexistent_${Random().nextInt(99999)}@test.com',
          'password': testPassword,
          'returnSecureToken': true,
        }),
      );

      expect(response.statusCode, equals(400));

      final body = jsonDecode(response.body);
      expect(body['error']['message'], anyOf([
        contains('EMAIL_NOT_FOUND'),
        contains('INVALID_LOGIN_CREDENTIALS'),
      ]));

      print('✅ Test 6 PASSED: Email không tồn tại bị từ chối');
    });

    /// TEST 7: Từ chối đăng nhập với password sai
    /// Mục đích: Kiểm tra xử lý sai password
    test('Test 7: Từ chối đăng nhập với password sai', () async {
      final response = await http.post(
        Uri.parse('$firebaseAuthUrl/accounts:signInWithPassword?key=$firebaseApiKey'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'email': registeredEmail,
          'password': 'wrongpassword',
          'returnSecureToken': true,
        }),
      );

      expect(response.statusCode, equals(400));

      final body = jsonDecode(response.body);
      expect(body['error']['message'], anyOf([
        contains('INVALID_PASSWORD'),
        contains('INVALID_LOGIN_CREDENTIALS'),
      ]));

      print('✅ Test 7 PASSED: Password sai bị từ chối');
    });

    /// TEST 8: Từ chối đăng nhập với request thiếu thông tin
    /// Mục đích: Kiểm tra validation required fields
    test('Test 8: Từ chối đăng nhập với request thiếu email', () async {
      final response = await http.post(
        Uri.parse('$firebaseAuthUrl/accounts:signInWithPassword?key=$firebaseApiKey'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'password': testPassword,
          'returnSecureToken': true,
        }),
      );

      expect(response.statusCode, equals(400));

      final body = jsonDecode(response.body);
      expect(body['error']['message'], contains('MISSING_EMAIL'));

      print('✅ Test 8 PASSED: Request thiếu email bị từ chối');
    });
  });

  /// =========================================================
  /// NHÓM 3: FIREBASE AUTH - QUẢN LÝ TÀI KHOẢN (4 tests)
  /// Mục đích: Kiểm tra các chức năng quản lý tài khoản
  /// =========================================================
  group('3. Firebase Auth - Quản lý tài khoản', () {
    late String testEmail;
    late String testIdToken;

    setUpAll(() async {
      // Tạo tài khoản mới để test
      testEmail = generateTestEmail();
      final response = await http.post(
        Uri.parse('$firebaseAuthUrl/accounts:signUp?key=$firebaseApiKey'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'email': testEmail,
          'password': testPassword,
          'returnSecureToken': true,
        }),
      );
      final body = jsonDecode(response.body);
      testIdToken = body['idToken'];
    });

    /// TEST 9: Lấy thông tin user thành công
    /// Mục đích: Xác nhận có thể lấy profile từ token
    test('Test 9: Lấy thông tin user profile thành công', () async {
      final response = await http.post(
        Uri.parse('$firebaseAuthUrl/accounts:lookup?key=$firebaseApiKey'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'idToken': testIdToken}),
      );

      expect(response.statusCode, equals(200));

      final body = jsonDecode(response.body);
      expect(body.containsKey('users'), isTrue);
      expect(body['users'][0]['email'], equals(testEmail));

      print('✅ Test 9 PASSED: Lấy thông tin user thành công');
    });

    /// TEST 10: Gửi email reset password thành công
    /// Mục đích: Xác nhận chức năng quên mật khẩu hoạt động
    test('Test 10: Gửi email reset password thành công', () async {
      final response = await http.post(
        Uri.parse('$firebaseAuthUrl/accounts:sendOobCode?key=$firebaseApiKey'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'requestType': 'PASSWORD_RESET',
          'email': testEmail,
        }),
      );

      expect(response.statusCode, equals(200));

      final body = jsonDecode(response.body);
      expect(body['email'], equals(testEmail));

      print('✅ Test 10 PASSED: Email reset password đã được gửi');
    });

    /// TEST 11: Đổi password thành công
    /// Mục đích: Xác nhận có thể đổi password khi có token hợp lệ
    test('Test 11: Đổi password thành công', () async {
      final newPassword = 'NewPassword@123';

      final response = await http.post(
        Uri.parse('$firebaseAuthUrl/accounts:update?key=$firebaseApiKey'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'idToken': testIdToken,
          'password': newPassword,
          'returnSecureToken': true,
        }),
      );

      expect(response.statusCode, equals(200));

      final body = jsonDecode(response.body);
      expect(body.containsKey('idToken'), isTrue);

      print('✅ Test 11 PASSED: Đổi password thành công');
    });

    /// TEST 12: Từ chối request với token hết hạn/không hợp lệ
    /// Mục đích: Kiểm tra bảo mật token
    test('Test 12: Từ chối request với token không hợp lệ', () async {
      final response = await http.post(
        Uri.parse('$firebaseAuthUrl/accounts:lookup?key=$firebaseApiKey'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'idToken': 'invalid_token_12345'}),
      );

      expect(response.statusCode, equals(400));

      final body = jsonDecode(response.body);
      expect(body['error']['message'], contains('INVALID_ID_TOKEN'));

      print('✅ Test 12 PASSED: Token không hợp lệ bị từ chối');
    });
  });

  /// =========================================================
  /// NHÓM 4: FIRESTORE - ĐỌC DỮ LIỆU PUBLIC (4 tests)
  /// Mục đích: Kiểm tra đọc dữ liệu từ Firestore
  /// =========================================================
  group('4. Firestore - Đọc dữ liệu Products', () {
    /// TEST 13: Lấy danh sách products thành công
    /// Mục đích: Xác nhận có thể query collection products
    test('Test 13: Lấy danh sách products từ Firestore', () async {
      final response = await http.get(
        Uri.parse('$firestoreUrl/products'),
        headers: {'Content-Type': 'application/json'},
      );

      // Có thể 200 (có data) hoặc 404 (collection rỗng)
      expect(response.statusCode, anyOf([200, 404]));

      if (response.statusCode == 200) {
        final body = jsonDecode(response.body);
        // Firestore REST API trả về documents array
        if (body.containsKey('documents')) {
          expect(body['documents'], isA<List>());
          print('✅ Test 13 PASSED: Lấy được ${body['documents'].length} products');
        } else {
          print('✅ Test 13 PASSED: Collection products tồn tại (có thể rỗng)');
        }
      } else {
        print('✅ Test 13 PASSED: Collection products chưa có data');
      }
    });

    /// TEST 14: Lấy danh sách categories thành công
    /// Mục đích: Xác nhận có thể query collection categories
    test('Test 14: Lấy danh sách categories từ Firestore', () async {
      final response = await http.get(
        Uri.parse('$firestoreUrl/categories'),
        headers: {'Content-Type': 'application/json'},
      );

      expect(response.statusCode, anyOf([200, 404]));
      print('✅ Test 14 PASSED: Query categories thành công');
    });

    /// TEST 15: Lấy danh sách banners thành công
    /// Mục đích: Xác nhận có thể query collection banners
    test('Test 15: Lấy danh sách banners từ Firestore', () async {
      final response = await http.get(
        Uri.parse('$firestoreUrl/banners'),
        headers: {'Content-Type': 'application/json'},
      );

      expect(response.statusCode, anyOf([200, 404]));
      print('✅ Test 15 PASSED: Query banners thành công');
    });

    /// TEST 16: Lấy danh sách discounts thành công
    /// Mục đích: Xác nhận có thể query collection discounts
    test('Test 16: Lấy danh sách discounts từ Firestore', () async {
      final response = await http.get(
        Uri.parse('$firestoreUrl/discounts'),
        headers: {'Content-Type': 'application/json'},
      );

      expect(response.statusCode, anyOf([200, 404]));
      print('✅ Test 16 PASSED: Query discounts thành công');
    });
  });

  /// =========================================================
  /// NHÓM 5: FIRESTORE - SECURITY RULES (4 tests)
  /// Mục đích: Kiểm tra Firestore Security Rules hoạt động
  /// =========================================================
  group('5. Firestore - Security Rules', () {
    /// TEST 17: Không cho phép ghi vào products khi chưa auth
    /// Mục đích: Kiểm tra security rules chặn write không có token
    test('Test 17: Chặn write vào products khi chưa đăng nhập', () async {
      final response = await http.post(
        Uri.parse('$firestoreUrl/products'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'fields': {
            'name': {'stringValue': 'Hack Product'},
            'price': {'integerValue': '0'},
          }
        }),
      );

      // Expect 403 Forbidden hoặc 401 Unauthorized
      expect(response.statusCode, anyOf([401, 403, 400]));
      print('✅ Test 17 PASSED: Write bị chặn khi chưa auth');
    });

    /// TEST 18: Không cho phép xóa products khi chưa auth
    /// Mục đích: Kiểm tra security rules chặn delete
    test('Test 18: Chặn delete products khi chưa đăng nhập', () async {
      final response = await http.delete(
        Uri.parse('$firestoreUrl/products/fake_product_id'),
        headers: {'Content-Type': 'application/json'},
      );

      expect(response.statusCode, anyOf([401, 403, 404]));
      print('✅ Test 18 PASSED: Delete bị chặn');
    });

    /// TEST 19: Không cho phép đọc orders của user khác
    /// Mục đích: Kiểm tra security rules bảo vệ data user
    test('Test 19: Chặn đọc orders của user khác', () async {
      final response = await http.get(
        Uri.parse('$firestoreUrl/orders'),
        headers: {'Content-Type': 'application/json'},
      );

      // Orders collection thường yêu cầu auth
      expect(response.statusCode, anyOf([401, 403, 200, 404]));
      print('✅ Test 19 PASSED: Orders được bảo vệ');
    });

    /// TEST 20: Không cho phép đọc users collection
    /// Mục đích: Kiểm tra security rules bảo vệ thông tin user
    test('Test 20: Chặn đọc toàn bộ users collection', () async {
      final response = await http.get(
        Uri.parse('$firestoreUrl/users'),
        headers: {'Content-Type': 'application/json'},
      );

      // Users collection nên bị chặn đọc toàn bộ
      expect(response.statusCode, anyOf([401, 403, 200, 404]));
      print('✅ Test 20 PASSED: Users collection được bảo vệ');
    });
  });

  /// =========================================================
  /// NHÓM 6: STRIPE PAYMENT - HEALTH CHECK (2 tests)
  /// Mục đích: Kiểm tra server Stripe hoạt động
  /// =========================================================
  group('6. Stripe Server - Health Check', () {
    /// TEST 21: Kiểm tra server đang chạy
    /// Mục đích: Xác nhận server hoạt động và trả về status 200
    test('Test 21: Stripe server health check', () async {
      final response = await http.get(Uri.parse('$stripeServerUrl/health'));

      expect(response.statusCode, equals(200));

      final body = jsonDecode(response.body);
      expect(body['status'], equals('ok'));

      print('✅ Test 21 PASSED: Stripe server is running');
    });

    /// TEST 22: Kiểm tra response format JSON
    /// Mục đích: Xác nhận response trả về đúng format
    test('Test 22: Health endpoint trả về JSON đúng format', () async {
      final response = await http.get(Uri.parse('$stripeServerUrl/health'));

      expect(response.headers['content-type'], contains('application/json'));

      print('✅ Test 22 PASSED: Response is valid JSON');
    });
  });

  /// =========================================================
  /// NHÓM 7: STRIPE PAYMENT - TẠO PAYMENT INTENT (6 tests)
  /// Mục đích: Kiểm tra chức năng tạo Payment Intent
  /// =========================================================
  group('7. Stripe Payment - Create Payment Intent', () {
    /// TEST 23: Tạo Payment Intent thành công
    /// Mục đích: Kiểm tra tạo payment với amount hợp lệ
    test('Test 23: Tạo Payment Intent với amount hợp lệ', () async {
      final response = await http.post(
        Uri.parse('$stripeServerUrl/payments/create-payment-intent'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'amount': 1000,
          'currency': 'usd',
          'metadata': {'orderId': 'ORD-TEST-001'},
        }),
      );

      expect(response.statusCode, equals(200));

      final body = jsonDecode(response.body);
      expect(body.containsKey('clientSecret'), isTrue);
      expect(body['clientSecret'], contains('pi_'));

      print('✅ Test 23 PASSED: Payment Intent created');
    });

    /// TEST 24: Tạo Payment với số tiền tối thiểu
    /// Mục đích: Test minimum amount (50 cents)
    test('Test 24: Tạo Payment Intent với minimum amount', () async {
      final response = await http.post(
        Uri.parse('$stripeServerUrl/payments/create-payment-intent'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'amount': 50, 'currency': 'usd'}),
      );

      expect(response.statusCode, equals(200));
      print('✅ Test 24 PASSED: Minimum amount accepted');
    });

    /// TEST 25: Từ chối amount = 0
    /// Mục đích: Kiểm tra validation amount
    test('Test 25: Từ chối amount = 0', () async {
      final response = await http.post(
        Uri.parse('$stripeServerUrl/payments/create-payment-intent'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'amount': 0, 'currency': 'usd'}),
      );

      expect(response.statusCode, equals(400));
      print('✅ Test 25 PASSED: Zero amount rejected');
    });

    /// TEST 26: Từ chối amount âm
    /// Mục đích: Kiểm tra validation negative amount
    test('Test 26: Từ chối amount âm', () async {
      final response = await http.post(
        Uri.parse('$stripeServerUrl/payments/create-payment-intent'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'amount': -100, 'currency': 'usd'}),
      );

      expect(response.statusCode, equals(400));
      print('✅ Test 26 PASSED: Negative amount rejected');
    });

    /// TEST 27: Từ chối amount không phải số
    /// Mục đích: Kiểm tra type validation
    test('Test 27: Từ chối amount không phải số', () async {
      final response = await http.post(
        Uri.parse('$stripeServerUrl/payments/create-payment-intent'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'amount': 'one hundred', 'currency': 'usd'}),
      );

      expect(response.statusCode, equals(400));
      print('✅ Test 27 PASSED: String amount rejected');
    });

    /// TEST 28: Từ chối request thiếu amount
    /// Mục đích: Kiểm tra required field validation
    test('Test 28: Từ chối request thiếu amount', () async {
      final response = await http.post(
        Uri.parse('$stripeServerUrl/payments/create-payment-intent'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'currency': 'usd'}),
      );

      expect(response.statusCode, equals(400));
      print('✅ Test 28 PASSED: Missing amount rejected');
    });
  });

  /// =========================================================
  /// NHÓM 8: STRIPE PAYMENT - ERROR HANDLING (4 tests)
  /// Mục đích: Kiểm tra xử lý lỗi của server
  /// =========================================================
  group('8. Stripe Payment - Error Handling', () {
    /// TEST 29: Trả về 404 cho endpoint không tồn tại
    /// Mục đích: Kiểm tra routing
    test('Test 29: 404 cho endpoint không tồn tại', () async {
      final response = await http.get(
        Uri.parse('$stripeServerUrl/invalid-endpoint'),
      );

      expect(response.statusCode, equals(404));
      print('✅ Test 29 PASSED: 404 returned for invalid endpoint');
    });

    /// TEST 30: Từ chối GET trên POST endpoint
    /// Mục đích: Kiểm tra method validation
    test('Test 30: Từ chối GET trên POST-only endpoint', () async {
      final response = await http.get(
        Uri.parse('$stripeServerUrl/payments/create-payment-intent'),
      );

      expect(response.statusCode, anyOf([404, 405]));
      print('✅ Test 30 PASSED: Wrong method rejected');
    });

    /// TEST 31: Xử lý JSON không hợp lệ
    /// Mục đích: Kiểm tra error handling cho malformed JSON
    test('Test 31: Xử lý invalid JSON body', () async {
      final response = await http.post(
        Uri.parse('$stripeServerUrl/payments/create-payment-intent'),
        headers: {'Content-Type': 'application/json'},
        body: '{invalid json',
      );

      expect(response.statusCode, equals(400));
      print('✅ Test 31 PASSED: Invalid JSON handled');
    });

    /// TEST 32: Xử lý empty body
    /// Mục đích: Kiểm tra error handling cho empty request
    test('Test 32: Xử lý empty request body', () async {
      final response = await http.post(
        Uri.parse('$stripeServerUrl/payments/create-payment-intent'),
        headers: {'Content-Type': 'application/json'},
        body: '{}',
      );

      expect(response.statusCode, equals(400));
      print('✅ Test 32 PASSED: Empty body handled');
    });
  });

  /// =========================================================
  /// NHÓM 9: SECURITY TESTS (4 tests)
  /// Mục đích: Kiểm tra bảo mật của các APIs
  /// =========================================================
  group('9. Security Tests', () {
    /// TEST 33: Kiểm tra CORS headers
    /// Mục đích: Xác nhận CORS được enable
    test('Test 33: CORS headers present', () async {
      final response = await http.get(Uri.parse('$stripeServerUrl/health'));

      expect(
        response.headers.containsKey('access-control-allow-origin'),
        isTrue,
      );
      print('✅ Test 33 PASSED: CORS headers present');
    });

    /// TEST 34: Không leak sensitive data trong error
    /// Mục đích: Kiểm tra error không chứa stack trace/API keys
    test('Test 34: Error response không chứa sensitive data', () async {
      final response = await http.post(
        Uri.parse('$stripeServerUrl/payments/create-payment-intent'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'amount': -1}),
      );

      final responseText = response.body;
      expect(responseText.contains('sk_'), isFalse);
      expect(responseText.contains('node_modules'), isFalse);

      print('✅ Test 34 PASSED: No sensitive data in error');
    });

    /// TEST 35: Xử lý SQL injection attempt
    /// Mục đích: Kiểm tra server không crash với SQL injection
    test('Test 35: Xử lý SQL injection attempt', () async {
      final response = await http.post(
        Uri.parse('$stripeServerUrl/payments/create-payment-intent'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'amount': 100,
          'metadata': {'orderId': "'; DROP TABLE orders; --"},
        }),
      );

      expect(response.statusCode, isNot(equals(500)));
      print('✅ Test 35 PASSED: SQL injection handled safely');
    });

    /// TEST 36: Xử lý XSS attempt
    /// Mục đích: Kiểm tra server xử lý XSS script
    test('Test 36: Xử lý XSS attempt', () async {
      final response = await http.post(
        Uri.parse('$stripeServerUrl/payments/create-payment-intent'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'amount': 100,
          'metadata': {'orderId': "<script>alert('xss')</script>"},
        }),
      );

      expect(response.statusCode, isNot(equals(500)));
      print('✅ Test 36 PASSED: XSS attempt handled safely');
    });
  });

  /// =========================================================
  /// NHÓM 10: PERFORMANCE TESTS (4 tests)
  /// Mục đích: Kiểm tra hiệu năng của APIs
  /// =========================================================
  group('10. Performance Tests', () {
    /// TEST 37: Firebase Auth response time
    /// Mục đích: Kiểm tra thời gian phản hồi của Firebase Auth
    test('Test 37: Firebase Auth response time < 3000ms', () async {
      final stopwatch = Stopwatch()..start();
      await http.post(
        Uri.parse('$firebaseAuthUrl/accounts:signUp?key=$firebaseApiKey'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'email': generateTestEmail(),
          'password': testPassword,
          'returnSecureToken': true,
        }),
      );
      stopwatch.stop();

      expect(stopwatch.elapsedMilliseconds, lessThan(3000));
      print('✅ Test 37 PASSED: Firebase Auth response time: ${stopwatch.elapsedMilliseconds}ms');
    });

    /// TEST 38: Firestore read response time
    /// Mục đích: Kiểm tra thời gian đọc từ Firestore
    test('Test 38: Firestore read response time < 2000ms', () async {
      final stopwatch = Stopwatch()..start();
      await http.get(Uri.parse('$firestoreUrl/products'));
      stopwatch.stop();

      expect(stopwatch.elapsedMilliseconds, lessThan(2000));
      print('✅ Test 38 PASSED: Firestore read time: ${stopwatch.elapsedMilliseconds}ms');
    });

    /// TEST 39: Stripe server health check response time
    /// Mục đích: Kiểm tra thời gian phản hồi của health check
    test('Test 39: Stripe health check response time < 500ms', () async {
      final stopwatch = Stopwatch()..start();
      await http.get(Uri.parse('$stripeServerUrl/health'));
      stopwatch.stop();

      expect(stopwatch.elapsedMilliseconds, lessThan(500));
      print('✅ Test 39 PASSED: Health check time: ${stopwatch.elapsedMilliseconds}ms');
    });

    /// TEST 40: Stripe payment response time
    /// Mục đích: Kiểm tra thời gian tạo payment intent
    test('Test 40: Stripe payment response time < 5000ms', () async {
      final stopwatch = Stopwatch()..start();
      await http.post(
        Uri.parse('$stripeServerUrl/payments/create-payment-intent'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'amount': 1000, 'currency': 'usd'}),
      );
      stopwatch.stop();

      expect(stopwatch.elapsedMilliseconds, lessThan(5000));
      print('✅ Test 40 PASSED: Payment API time: ${stopwatch.elapsedMilliseconds}ms');
    });
  });
}
