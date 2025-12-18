# 🧪 Blind Box Shop - API Tests (Dart)

## 📋 Tổng quan

File `api_test.dart` chứa **20 integration tests** để kiểm tra API của server, được viết hoàn toàn bằng **Dart** (không cần Postman hay Node.js test tools).

## 📂 Danh sách 20 Tests

| # | Nhóm | Tên Test | Mục đích |
|---|------|----------|----------|
| **1** | Health Check | Server Running | Kiểm tra server hoạt động, status = 200 |
| **2** | Health Check | Response Format | Kiểm tra response trả về đúng JSON |
| **3** | Stripe Payment | Valid Amount | Tạo Payment Intent với $10 |
| **4** | Stripe Payment | Minimum Amount | Test số tiền tối thiểu ($0.50) |
| **5** | Stripe Payment | Large Amount | Test số tiền lớn ($99,999) |
| **6** | Stripe Payment | Zero Amount | Từ chối số tiền = 0 |
| **7** | Stripe Payment | Negative Amount | Từ chối số tiền âm |
| **8** | Stripe Payment | String Amount | Từ chối amount không phải số |
| **9** | Stripe Payment | Missing Amount | Từ chối request thiếu amount |
| **10** | Stripe Payment | Default Currency | Test default currency USD |
| **11** | Error Handling | 404 Not Found | Kiểm tra endpoint không tồn tại |
| **12** | Error Handling | Method Not Allowed | Từ chối GET trên POST endpoint |
| **13** | Error Handling | Invalid JSON | Xử lý JSON không hợp lệ |
| **14** | Error Handling | Empty Body | Xử lý body rỗng |
| **15** | Performance | Health Check Time | Response time < 500ms |
| **16** | Performance | Payment Time | Response time < 5000ms |
| **17** | Security | CORS Headers | Kiểm tra CORS được enable |
| **18** | Security | No Sensitive Data | Không leak stack trace, API keys |
| **19** | Security | SQL Injection | Xử lý SQL injection attempts |
| **20** | Security | XSS Prevention | Xử lý XSS script attempts |

## 🚀 Cách chạy Tests

### Bước 1: Chạy Server trước
```bash
cd server
npm install    # Nếu chưa install
npm run dev    # Chạy server ở port 3000
```

### Bước 2: Chạy API Tests
```bash
# Cách 1: Dùng dart test (recommended)
dart test testing/api/api_test.dart

# Cách 2: Với output chi tiết
dart test testing/api/api_test.dart --reporter expanded

# Cách 3: Dùng flutter test
flutter test testing/api/api_test.dart
```

## 📊 Kết quả mong đợi

Khi server chạy đúng:
```
✅ 20 tests passed
```

Nếu server chưa chạy:
```
❌ Connection refused - Server not running
```

## ⚙️ Cấu hình

### Thay đổi Base URL
Mở file `api_test.dart`, sửa dòng:
```dart
const String baseUrl = 'http://localhost:3000';
```

### Thay đổi thành:
```dart
const String baseUrl = 'http://localhost:8080';  // Port khác
// hoặc
const String baseUrl = 'https://api.example.com';  // Production
```

## 📦 Dependencies

File sử dụng các packages:
- `http` - Gửi HTTP requests
- `test` - Framework testing của Dart

Đã được thêm vào `pubspec.yaml`:
```yaml
dependencies:
  http: ^1.2.1

dev_dependencies:
  test: ^1.25.0
```

## 🔧 Troubleshooting

### Lỗi "Connection refused"
```
ClientException: The remote computer refused the network connection
```
**Giải pháp:** Chạy server trước: `cd server && npm run dev`

### Lỗi "Package not found"
```
Could not find package "test"
```
**Giải pháp:** Chạy `flutter pub get`

### Lỗi timeout
```
Test timeout after 30 seconds
```
**Giải pháp:** Server có thể chậm, tăng timeout trong test file

## 📝 So sánh với Postman

| Tiêu chí | Dart Test | Postman |
|----------|-----------|---------|
| **Ngôn ngữ** | Dart (cùng project) | JavaScript |
| **CI/CD** | ✅ Dễ tích hợp | Cần Newman |
| **IDE** | VS Code, Android Studio | Postman App |
| **Dependencies** | Chỉ cần Dart SDK | Cần cài Postman |
| **Version Control** | ✅ Git-friendly | JSON file |

---

**Tạo bởi:** GitHub Copilot  
**Version:** 1.0.0
