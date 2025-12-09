# 🎁 Blind Box Shop

<div align="center">
  <h3>Ứng dụng thương mại điện tử mua bán hộp bí ẩn (Blind Box)</h3>
  <p>Trải nghiệm mua sắm độc đáo với các sản phẩm hộp bí ẩn chứa đồ chơi, mô hình và quà tặng ngẫu nhiên</p>
</div>

---

## 📖 Giới thiệu

**Blind Box Shop** là một nền tảng thương mại điện tử được xây dựng bằng Flutter, chuyên về việc mua bán các hộp bí ẩn (blind box). Ứng dụng mang đến trải nghiệm mua sắm thú vị và hấp dẫn với yếu tố bất ngờ, phù hợp với người yêu thích sưu tầm đồ chơi và mô hình.

### ✨ Tính năng chính

#### 👥 Người dùng
- **🔐 Xác thực & Bảo mật**: Đăng ký, đăng nhập với Firebase Authentication
- **🛍️ Mua sắm**: Duyệt và tìm kiếm sản phẩm blind box theo danh mục
- **🛒 Giỏ hàng**: Quản lý giỏ hàng với tính năng thêm/xóa/cập nhật số lượng
- **💳 Thanh toán**: Hỗ trợ thanh toán qua Stripe và COD (tiền mặt)
- **📦 Quản lý đơn hàng**: Theo dõi lịch sử đơn hàng và trạng thái giao hàng
- **⭐ Đánh giá**: Đánh giá và nhận xét sản phẩm sau khi nhận hàng
- **🎨 Giao diện**: UI/UX hiện đại, mượt mà với animations và shimmer effects
- **📍 Địa chỉ**: Quản lý nhiều địa chỉ giao hàng

#### 👨‍💼 Quản trị viên
- **📊 Dashboard**: Thống kê doanh thu, đơn hàng với biểu đồ trực quan
- **📦 Quản lý sản phẩm**: CRUD sản phẩm với upload hình ảnh
- **🏷️ Quản lý danh mục**: Tạo và quản lý các danh mục sản phẩm
- **🎫 Quản lý khuyến mãi**: Tạo và quản lý mã giảm giá
- **📋 Quản lý đơn hàng**: Xem và cập nhật trạng thái đơn hàng
- **📈 Báo cáo**: Xuất báo cáo doanh thu ra file Excel
- **🎪 Banner**: Quản lý banner quảng cáo trên trang chủ

---

## 🛠️ Công nghệ sử dụng

### Frontend (Flutter)
- **Framework**: Flutter SDK 3.9.2
- **Ngôn ngữ**: Dart
- **State Management**: Provider + Riverpod
- **Routing**: GoRouter
- **UI/UX**: 
  - Flutter ScreenUtil (responsive design)
  - Shimmer (loading effects)
  - Lottie (animations)
  - Carousel Slider
  - Staggered Grid View

### Backend & Services
- **Backend**: Node.js + Express
- **Database**: Cloud Firestore (Firebase)
- **Authentication**: Firebase Auth
- **Storage**: Firebase Storage (lưu trữ hình ảnh)
- **Payment**: Stripe API

### Thư viện chính
```yaml
# Core
flutter: sdk
dart: ^3.9.2

# State Management
provider: ^6.1.2
riverpod: ^2.5.1
flutter_riverpod: ^2.5.1

# Navigation
go_router: ^14.2.7

# Firebase
firebase_core: ^2.24.2
firebase_auth: ^4.17.8
cloud_firestore: ^4.15.8
firebase_storage: ^11.6.8

# Payment
flutter_stripe: ^10.1.0

# HTTP & API
dio: ^5.5.0+1
http: ^1.2.1

# Local Storage
shared_preferences: ^2.2.2
sqflite: ^2.3.2

# Image & Media
cached_network_image: ^3.3.1
image_picker: ^1.0.7
flutter_image_compress: ^2.3.0

# UI Components
shimmer: ^3.0.0
lottie: ^3.1.2
carousel_slider: ^5.0.0
flutter_staggered_grid_view: ^0.7.0

# Charts
fl_chart: ^0.68.0

# Utils
intl: ^0.19.0
uuid: ^4.3.3
file_picker: ^8.0.0+1
excel: ^4.0.6
share_plus: ^7.2.2
```

---

## 🚀 Cài đặt và Chạy Project

### Yêu cầu hệ thống
- Flutter SDK: `>=3.9.2`
- Dart SDK: `>=3.9.2`
- Node.js: `>=14.x`
- Android Studio / Xcode (để chạy emulator)
- Git

### 1️⃣ Clone Repository
```bash
git clone https://github.com/linh280503/blindboxshop.git
cd blindboxshop
```

### 2️⃣ Cài đặt Flutter Dependencies
```bash
flutter pub get
```

### 3️⃣ Cấu hình Firebase
1. Tạo project trên [Firebase Console](https://console.firebase.google.com/)
2. Thêm app Android/iOS vào Firebase project
3. Tải file cấu hình:
   - Android: `google-services.json` → đặt vào `android/app/`
   - iOS: `GoogleService-Info.plist` → đặt vào `ios/Runner/`
4. Cấu hình file `lib/firebase_options.dart` bằng FlutterFire CLI:
```bash
flutterfire configure
```

### 4️⃣ Cấu hình Stripe
1. Đăng ký tài khoản [Stripe](https://stripe.com)
2. Lấy API keys (Publishable key & Secret key)
3. Cập nhật keys trong:
   - `lib/main.dart` (Publishable key)
   - `lib/core/constants/app_constants.dart` (cả 2 keys)
   - `server/.env` (Secret key)

### 5️⃣ Cài đặt Backend Server
```bash
cd server
npm install
```

Tạo file `.env` trong thư mục `server/`:
```env
PORT=3000
STRIPE_SECRET_KEY=your_stripe_secret_key
```

Chạy server:
```bash
npm run dev
```

### 6️⃣ Chạy ứng dụng Flutter

**Android Emulator:**
```bash
flutter run
```

**iOS Simulator:**
```bash
flutter run -d ios
```

**Chrome (Web):**
```bash
flutter run -d chrome
```

### 7️⃣ Build ứng dụng

**Android APK:**
```bash
flutter build apk --release
```

**Android App Bundle:**
```bash
flutter build appbundle --release
```

**iOS:**
```bash
flutter build ios --release
```

---

## 📁 Cấu trúc Project

```
blind_box_shop/
├── lib/
│   ├── main.dart                 # Entry point
│   ├── firebase_options.dart     # Firebase config
│   ├── core/                     # Core functionality
│   │   ├── config/              # App configuration
│   │   ├── constants/           # Constants
│   │   ├── router/              # GoRouter setup
│   │   ├── services/            # Services (notification, etc)
│   │   ├── theme/               # App theme
│   │   ├── usecase/             # Base usecase
│   │   ├── util/                # Utilities
│   │   └── widgets/             # Common widgets
│   └── features/                 # Feature modules
│       ├── auth/                # Authentication
│       ├── product/             # Products management
│       ├── cart/                # Shopping cart
│       ├── order/               # Orders & checkout
│       ├── category/            # Categories
│       ├── discount/            # Discount codes
│       ├── review/              # Product reviews
│       ├── address/             # User addresses
│       ├── banner/              # Banner management
│       ├── admin/               # Admin dashboard
│       ├── inventory/           # Inventory management
│       └── intro/               # Intro screens
├── server/                       # Backend server
│   ├── index.js                 # Express server
│   ├── package.json
│   └── .env                     # Environment variables
├── android/                      # Android native
├── ios/                          # iOS native
├── web/                          # Web support
└── pubspec.yaml                 # Dependencies
```

---

## 🔑 Tài khoản Demo

### Admin
- Email: `admin@example.com`
- Password: `admin123`

### User
- Email: `user@example.com`
- Password: `user123`

---

## 📸 Screenshots

_Đang cập nhật..._

---

## 🤝 Đóng góp

Mọi đóng góp đều được chào đón! Vui lòng:
1. Fork repository
2. Tạo branch mới (`git checkout -b feature/AmazingFeature`)
3. Commit changes (`git commit -m 'Add some AmazingFeature'`)
4. Push to branch (`git push origin feature/AmazingFeature`)
5. Mở Pull Request

---

## 📝 License

Distributed under the MIT License. See `LICENSE` for more information.

---

## 📧 Liên hệ

- **Developer**: [linh280503](https://github.com/linh280503)
- **Project Link**: [https://github.com/linh280503/blindboxshop](https://github.com/linh280503/blindboxshop)

---

<div align="center">
  <p>Made with ❤️ using Flutter</p>
</div>
