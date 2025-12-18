import 'package:flutter_test/flutter_test.dart';

/// =============================================================================
/// TEST FILE 6: ADMIN USER MANAGEMENT TEST
/// =============================================================================
/// 
/// MỤC ĐÍCH: Kiểm tra các chức năng quản lý người dùng cho Admin
/// - Validate thông tin user
/// - Kiểm tra quyền (role)
/// - Tính điểm thưởng
/// - Kiểm tra trạng thái tài khoản
/// 
/// CÁCH CHẠY: flutter test testing/function/admin_user_test.dart

// ============== MOCK CLASSES ==============

enum UserRole { customer, admin, moderator }

class UserModel {
  final String uid;
  final String email;
  final String name;
  final String phone;
  final String avatar;
  final DateTime createdAt;
  final DateTime updatedAt;
  final bool isActive;
  final String role;
  final int points;
  final int totalOrders;
  final double totalSpent;

  UserModel({
    required this.uid,
    required this.email,
    required this.name,
    required this.phone,
    required this.avatar,
    required this.createdAt,
    required this.updatedAt,
    required this.isActive,
    required this.role,
    required this.points,
    required this.totalOrders,
    required this.totalSpent,
  });

  UserModel copyWith({
    String? uid,
    String? email,
    String? name,
    String? phone,
    String? avatar,
    DateTime? createdAt,
    DateTime? updatedAt,
    bool? isActive,
    String? role,
    int? points,
    int? totalOrders,
    double? totalSpent,
  }) {
    return UserModel(
      uid: uid ?? this.uid,
      email: email ?? this.email,
      name: name ?? this.name,
      phone: phone ?? this.phone,
      avatar: avatar ?? this.avatar,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      isActive: isActive ?? this.isActive,
      role: role ?? this.role,
      points: points ?? this.points,
      totalOrders: totalOrders ?? this.totalOrders,
      totalSpent: totalSpent ?? this.totalSpent,
    );
  }
}

// ============== HELPER FUNCTIONS ==============

/// Validate email format
bool isValidEmail(String email) {
  if (email.isEmpty) return false;
  final emailRegex = RegExp(r'^[^\s@]+@[^\s@]+\.[^\s@]+$');
  return emailRegex.hasMatch(email);
}

/// Validate phone number (Vietnam format)
bool isValidPhoneNumber(String phone) {
  if (phone.isEmpty) return true; // Phone is optional
  final phoneRegex = RegExp(r'^(0|\+84)[0-9]{9,10}$');
  return phoneRegex.hasMatch(phone);
}

/// Validate user name
class NameValidationResult {
  final bool valid;
  final String? error;
  
  NameValidationResult({required this.valid, this.error});
}

NameValidationResult validateUserName(String name) {
  if (name.isEmpty) {
    return NameValidationResult(valid: false, error: 'Name is required');
  }
  if (name.length < 2) {
    return NameValidationResult(valid: false, error: 'Name must be at least 2 characters');
  }
  if (name.length > 50) {
    return NameValidationResult(valid: false, error: 'Name cannot exceed 50 characters');
  }
  return NameValidationResult(valid: true);
}

/// Kiểm tra quyền truy cập admin
bool hasAdminAccess(String role) {
  return role == 'admin' || role == 'moderator';
}

/// Kiểm tra quyền sửa user
bool canEditUser(String editorRole, String targetRole) {
  if (editorRole == 'admin') return true;
  if (editorRole == 'moderator' && targetRole == 'customer') return true;
  return false;
}

/// Tính điểm thưởng từ đơn hàng
/// Quy tắc: 1 điểm cho mỗi 10,000 VND
int calculatePoints(double orderAmount) {
  if (orderAmount < 0) return 0;
  return (orderAmount / 10000).floor();
}

/// Xác định hạng thành viên dựa trên tổng chi tiêu
String getMembershipTier(double totalSpent) {
  if (totalSpent >= 50000000) return 'Diamond';
  if (totalSpent >= 20000000) return 'Gold';
  if (totalSpent >= 5000000) return 'Silver';
  return 'Bronze';
}

/// Tính phần trăm đạt hạng tiếp theo
double getProgressToNextTier(double totalSpent) {
  if (totalSpent >= 50000000) return 100.0; // Already Diamond
  
  if (totalSpent >= 20000000) {
    // Gold -> Diamond (need 50M)
    return ((totalSpent - 20000000) / (50000000 - 20000000)) * 100;
  }
  if (totalSpent >= 5000000) {
    // Silver -> Gold (need 20M)
    return ((totalSpent - 5000000) / (20000000 - 5000000)) * 100;
  }
  // Bronze -> Silver (need 5M)
  return (totalSpent / 5000000) * 100;
}

/// Kiểm tra tài khoản có bị khóa không
class AccountStatus {
  final bool isLocked;
  final String? reason;
  final DateTime? lockedUntil;
  
  AccountStatus({required this.isLocked, this.reason, this.lockedUntil});
}

AccountStatus checkAccountStatus(UserModel user) {
  if (!user.isActive) {
    return AccountStatus(isLocked: true, reason: 'Account is deactivated');
  }
  return AccountStatus(isLocked: false);
}

/// Validate toàn bộ thông tin user
class UserValidationResult {
  final bool valid;
  final List<String> errors;
  
  UserValidationResult({required this.valid, this.errors = const []});
}

UserValidationResult validateUser(UserModel user) {
  final errors = <String>[];
  
  if (!isValidEmail(user.email)) {
    errors.add('Invalid email format');
  }
  
  final nameResult = validateUserName(user.name);
  if (!nameResult.valid) {
    errors.add(nameResult.error!);
  }
  
  if (!isValidPhoneNumber(user.phone)) {
    errors.add('Invalid phone number format');
  }
  
  if (!['customer', 'admin', 'moderator'].contains(user.role)) {
    errors.add('Invalid role');
  }
  
  return UserValidationResult(
    valid: errors.isEmpty,
    errors: errors,
  );
}

// ============== TEST CASES ==============

void main() {
  group('Admin User Management - Validation', () {
    /// TEST 1: Validate email hợp lệ
    /// 
    /// MỤC ĐÍCH: Kiểm tra validation email với các format khác nhau
    test('Test 1: Validate email format', () {
      expect(isValidEmail('test@example.com'), true);
      expect(isValidEmail('user.name@domain.co.vn'), true);
      expect(isValidEmail('admin@blindboxshop.com'), true);
      
      expect(isValidEmail('invalid'), false);
      expect(isValidEmail('invalid@'), false);
      expect(isValidEmail('@domain.com'), false);
      expect(isValidEmail(''), false);
    });

    /// TEST 2: Validate số điện thoại Việt Nam
    /// 
    /// MỤC ĐÍCH: Kiểm tra validation phone number format
    test('Test 2: Validate số điện thoại Việt Nam', () {
      expect(isValidPhoneNumber('0912345678'), true);
      expect(isValidPhoneNumber('0123456789'), true);
      expect(isValidPhoneNumber('+84912345678'), true);
      expect(isValidPhoneNumber(''), true); // Optional field
      
      expect(isValidPhoneNumber('12345'), false);
      expect(isValidPhoneNumber('abc'), false);
      expect(isValidPhoneNumber('091234567890'), false); // Too long
    });

    /// TEST 3: Validate tên người dùng
    /// 
    /// MỤC ĐÍCH: Kiểm tra validation user name với các điều kiện
    test('Test 3: Validate tên người dùng', () {
      expect(validateUserName('Nguyen Van A').valid, true);
      expect(validateUserName('AB').valid, true);
      
      expect(validateUserName('').valid, false);
      expect(validateUserName('').error, 'Name is required');
      
      expect(validateUserName('A').valid, false);
      expect(validateUserName('A').error, 'Name must be at least 2 characters');
      
      final longName = 'A' * 51;
      expect(validateUserName(longName).valid, false);
    });
  });

  group('Admin User Management - Quyền truy cập', () {
    /// TEST 4: Kiểm tra quyền truy cập admin
    /// 
    /// MỤC ĐÍCH: Kiểm tra logic phân quyền truy cập admin dashboard
    test('Test 4: Kiểm tra quyền truy cập admin', () {
      expect(hasAdminAccess('admin'), true);
      expect(hasAdminAccess('moderator'), true);
      expect(hasAdminAccess('customer'), false);
      expect(hasAdminAccess(''), false);
    });

    /// TEST 5: Kiểm tra quyền sửa user
    /// 
    /// MỤC ĐÍCH: Kiểm tra logic ai có thể sửa thông tin user nào
    test('Test 5: Kiểm tra quyền sửa user', () {
      // Admin có thể sửa tất cả
      expect(canEditUser('admin', 'customer'), true);
      expect(canEditUser('admin', 'moderator'), true);
      expect(canEditUser('admin', 'admin'), true);
      
      // Moderator chỉ sửa được customer
      expect(canEditUser('moderator', 'customer'), true);
      expect(canEditUser('moderator', 'moderator'), false);
      expect(canEditUser('moderator', 'admin'), false);
      
      // Customer không sửa được ai
      expect(canEditUser('customer', 'customer'), false);
    });
  });

  group('Admin User Management - Điểm thưởng & Hạng thành viên', () {
    /// TEST 6: Tính điểm thưởng từ đơn hàng
    /// 
    /// MỤC ĐÍCH: Kiểm tra công thức tính điểm (1 điểm / 10,000 VND)
    test('Test 6: Tính điểm thưởng từ đơn hàng', () {
      expect(calculatePoints(100000), 10);     // 100K = 10 điểm
      expect(calculatePoints(350000), 35);     // 350K = 35 điểm
      expect(calculatePoints(999999), 99);     // 999K = 99 điểm (làm tròn xuống)
      expect(calculatePoints(5000), 0);        // < 10K = 0 điểm
      expect(calculatePoints(-10000), 0);      // Số âm = 0 điểm
    });

    /// TEST 7: Xác định hạng thành viên
    /// 
    /// MỤC ĐÍCH: Kiểm tra logic phân hạng dựa trên tổng chi tiêu
    test('Test 7: Xác định hạng thành viên', () {
      expect(getMembershipTier(60000000), 'Diamond');  // >= 50M
      expect(getMembershipTier(50000000), 'Diamond');
      expect(getMembershipTier(30000000), 'Gold');     // >= 20M
      expect(getMembershipTier(20000000), 'Gold');
      expect(getMembershipTier(10000000), 'Silver');   // >= 5M
      expect(getMembershipTier(5000000), 'Silver');
      expect(getMembershipTier(3000000), 'Bronze');    // < 5M
      expect(getMembershipTier(0), 'Bronze');
    });

    /// TEST 8: Tính tiến độ lên hạng tiếp theo
    /// 
    /// MỤC ĐÍCH: Kiểm tra tính phần trăm tiến độ đến hạng kế tiếp
    test('Test 8: Tính tiến độ lên hạng tiếp theo', () {
      // Diamond - đã max
      expect(getProgressToNextTier(60000000), 100.0);
      
      // Gold -> Diamond (50% of 30M range)
      expect(getProgressToNextTier(35000000), 50.0);
      
      // Silver -> Gold (50% of 15M range)
      expect(getProgressToNextTier(12500000), 50.0);
      
      // Bronze -> Silver (50% of 5M)
      expect(getProgressToNextTier(2500000), 50.0);
    });
  });

  group('Admin User Management - Trạng thái tài khoản', () {
    /// TEST 9: Kiểm tra trạng thái tài khoản
    /// 
    /// MỤC ĐÍCH: Kiểm tra logic xác định tài khoản bị khóa hay hoạt động
    test('Test 9: Kiểm tra trạng thái tài khoản', () {
      final activeUser = UserModel(
        uid: 'user-001',
        email: 'active@test.com',
        name: 'Active User',
        phone: '0912345678',
        avatar: '',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
        isActive: true,
        role: 'customer',
        points: 100,
        totalOrders: 5,
        totalSpent: 2000000,
      );

      final inactiveUser = activeUser.copyWith(isActive: false);

      expect(checkAccountStatus(activeUser).isLocked, false);
      expect(checkAccountStatus(inactiveUser).isLocked, true);
      expect(checkAccountStatus(inactiveUser).reason, 'Account is deactivated');
    });

    /// TEST 10: Validate toàn bộ thông tin user
    /// 
    /// MỤC ĐÍCH: Kiểm tra validation đầy đủ cho user model
    test('Test 10: Validate toàn bộ thông tin user', () {
      final validUser = UserModel(
        uid: 'user-001',
        email: 'valid@test.com',
        name: 'Valid User',
        phone: '0912345678',
        avatar: '',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
        isActive: true,
        role: 'customer',
        points: 100,
        totalOrders: 5,
        totalSpent: 2000000,
      );

      final invalidUser = UserModel(
        uid: 'user-002',
        email: 'invalid-email',
        name: 'A', // Too short
        phone: '123', // Invalid format
        avatar: '',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
        isActive: true,
        role: 'invalid-role',
        points: 0,
        totalOrders: 0,
        totalSpent: 0,
      );

      final validResult = validateUser(validUser);
      expect(validResult.valid, true);
      expect(validResult.errors.isEmpty, true);

      final invalidResult = validateUser(invalidUser);
      expect(invalidResult.valid, false);
      expect(invalidResult.errors.length, greaterThan(0));
    });
  });
}
