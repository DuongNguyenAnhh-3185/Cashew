<div align="center">
  <img src="promotional/icons/icon.png" alt="Cashew Logo" width="120px" />
  <h1>🌰 Cashew - Quản lý Chi tiêu & Ngân sách Cá nhân Thông minh</h1>
  <p><b>Ứng dụng tài chính cá nhân đa nền tảng, mã nguồn mở, hoạt động ngoại tuyến (Offline-First) với phong cách thiết kế Material You hiện đại.</b></p>

  <p>
    <a href="https://flutter.dev"><img src="https://img.shields.io/badge/Flutter-3.x-02569B?logo=flutter" alt="Flutter"></a>
    <a href="https://dart.dev"><img src="https://img.shields.io/badge/Dart-3.x-0175C2?logo=dart" alt="Dart"></a>
    <a href="https://drift.simonbinder.eu/"><img src="https://img.shields.io/badge/Database-Drift%20SQLite-00599C?logo=sqlite" alt="SQLite Drift"></a>
    <a href="https://firebase.google.com/"><img src="https://img.shields.io/badge/Cloud-Firebase-FFCA28?logo=firebase" alt="Firebase"></a>
    <a href="LICENSE"><img src="https://img.shields.io/badge/License-GPL--3.0-blue.svg" alt="License"></a>
  </p>
</div>

---

## 📌 Bối cảnh & Vấn đề giải quyết

Quản lý tài chính cá nhân là một kỹ năng thiết yếu nhưng người dùng thường gặp nhiều rào cản trong cuộc sống số:

- **Dữ liệu tài chính phân mảnh:** Người dùng sở hữu nhiều tài khoản (tiền mặt, thẻ tín dụng, ngân hàng, ví điện tử) và chi tiêu bằng nhiều loại tiền tệ khác nhau mà không có công cụ gom nhóm và quy đổi tự động.
- **Vượt hạn mức ngân sách:** Việc không thiết lập được hạn mức chi tiết cho từng hạng mục (ăn uống, mua sắm, hóa đơn cố định) dẫn đến tình trạng chi tiêu mất kiểm soát.
- **Thống kê sơ sài & thao tác nhập liệu rườm rà:** Các ứng dụng truyền thống tốn nhiều thời gian nhập liệu, thiếu gợi ý thông minh và biểu đồ trực quan hóa dòng tiền.
- **Rủi ro quyền riêng tư & phụ thuộc mạng:** Đa số các ứng dụng yêu cầu kết nối mạng liên tục và lưu trữ thông tin nhạy cảm trên máy chủ bên thứ ba, tiềm ẩn nguy cơ rò rỉ dữ liệu tài chính.

**Cashew** ra đời nhằm giải quyết triệt để những bài toán trên với triết lý **Offline-First**, tôn trọng quyền riêng tư người dùng, tự động hóa tối đa quy trình ghi chép và mang lại trải nghiệm thị giác ấn tượng theo chuẩn **Material You**.

---

## ✨ Tính năng chính

### 💸 1. Phân hệ Quản lý Ngân sách & Mục tiêu (Budget & Goal Module - BG)
- **BG-01: Ngân sách linh hoạt (Custom Budget Periods):** Thiết lập ngân sách theo chu kỳ ngày, tuần, tháng hoặc khoảng thời gian tùy chọn (ví dụ: tạo ngân sách riêng cho một chuyến du lịch).
- **BG-02: Giới hạn chi tiêu theo danh mục (Category Spending Limits):** Đặt trần chi tiêu cho từng danh mục con trong một ngân sách tổng, cảnh báo khi chạm ngưỡng giới hạn.
- **BG-03: Mục tiêu tích lũy & Tiết kiệm (Goals & Objectives):** Đặt mục tiêu mua sắm hoặc trả nợ dài hạn; hệ thống tự động tính toán tiến độ dựa trên các giao dịch thực tế.
- **BG-04: Lịch sử & Phân tích chu kỳ cũ (Past Budget Archive):** Xem lại chi tiết và biểu đồ so sánh mức chi tiêu của các kỳ ngân sách đã qua để đánh giá kỷ luật tài chính.

### 💰 2. Phân hệ Quản lý Giao dịch (Transaction Module - TM)
- **TM-01: Đa dạng loại hình giao dịch:** Phân loại rõ ràng giữa Chi tiêu (Expense), Thu nhập (Income), Hóa đơn định kỳ (Subscriptions), Giao dịch sắp tới (Upcoming) và Khoản nợ / Cho vay (Debt / Credit).
- **TM-02: Tiêu đề & Danh mục thông minh:** Hệ thống ghi nhớ tên giao dịch thường dùng để tự động gắn danh mục tương ứng trong các lần nhập tiếp theo, đi kèm kho biểu tượng phong phú.
- **TM-03: Bộ lọc & Tìm kiếm đa năng:** Tra cứu giao dịch theo từ khóa, khoảng ngày, hạn mức tiền, danh mục, tài khoản hoặc thẻ tag tùy chỉnh.
- **TM-04: Chia hóa đơn (Bill Splitter):** Tiện ích phân chia chi phí nhóm trực tiếp trong ứng dụng, tự động tính toán số tiền mỗi người cần thanh toán.

### 💱 3. Phân hệ Tài khoản & Đa Tiền tệ (Account & Currency Module - AC)
- **AC-01: Quản lý đa tài khoản / ví:** Tạo không giới hạn tài khoản (ví tiền mặt, thẻ ngân hàng, tài khoản tiết kiệm) với số dư độc lập.
- **AC-02: Tự động quy đổi tỷ giá hối đoái:** Hỗ trợ hầu hết các loại tiền tệ trên thế giới với tỷ giá cập nhật; tự động quy đổi số tiền giao dịch về đồng tiền cơ sở của tài khoản.
- **AC-03: Chuyển đổi ngữ cảnh tức thì:** Chuyển đổi nhanh giữa các tài khoản và đơn vị tiền tệ ngay trên màn hình chính chỉ với một thao tác chạm.

### 🔒 4. Phân hệ Bảo mật, Sao lưu & Tự động hóa (Security, Sync & Automation - SA)
- **SA-01: Bảo mật sinh trắc học (Biometric Authentication):** Hỗ trợ khóa ứng dụng bằng vân tay hoặc nhận diện khuôn mặt (Face ID / Fingerprint) thông qua `local_auth`.
- **SA-02: Đồng bộ đám mây & Đăng nhập Google:** Đồng bộ dữ liệu đa thiết bị theo thời gian thực với Firebase và đăng nhập an toàn bằng Google Account.
- **SA-03: Sao lưu Google Drive & Nhập / Xuất dữ liệu:** Hỗ trợ backup an toàn lên Google Drive cá nhân; nhập/xuất lịch sử giao dịch qua file CSV và Google Sheets.
- **SA-04: Tự động hóa nhập liệu (App Links & Auto-Transactions):** Hỗ trợ liên kết ứng dụng (App Links) và tích hợp trình lắng nghe thông báo / email biến động số dư.

### 🎨 5. Phân hệ Trải nghiệm & Trực quan hóa Dữ liệu (UX & Analytics - UX)
- **UX-01: Thiết kế Material You thế hệ mới:** Màu sắc giao diện thích ứng mượt mà theo màu nền hệ thống (Dynamic Color) hoặc bảng màu tùy chỉnh của người dùng.
- **UX-02: Chế độ Sáng / Tối (Light & Dark Mode):** Tối ưu hóa độ tương phản, giảm mỏi mắt và tiết kiệm pin trên màn hình OLED.
- **UX-03: Biểu đồ trực quan chuyên sâu:** Tích hợp `fl_chart` hiển thị cơ cấu chi tiêu, biểu đồ cột so sánh thu chi và đường xu hướng dòng tiền theo thời gian thực.
- **UX-04: Bố cục thích ứng & Tùy biến trang chủ:** Tự do sắp xếp thứ tự các widget trên trang chủ; giao diện tương thích hoàn hảo trên cả điện thoại, máy tính bảng và Web (PWA).

---

## 💡 Triết lý Thiết kế: "Offline-First & Frictionless UX"

Cashew được xây dựng dựa trên nguyên tắc tối giản hóa ma sát nhập liệu và trao toàn quyền kiểm soát dữ liệu cho người dùng:

- **Offline-First làm trọng tâm:** Toàn bộ dữ liệu được ghi và đọc trực tiếp từ cơ sở dữ liệu SQLite cục bộ (Drift ORM). Ứng dụng vận hành trơn tru ngay cả khi không có kết nối Internet.
- **Thao tác nhanh (Zero Friction):** Tối ưu thời gian nhập một giao dịch dưới 5 giây thông qua bộ nhớ tên thông minh, chọn nhanh danh mục bằng cử chỉ một chạm và hỗ trợ phím tắt tiện ích (Quick Actions).
- **Thao tác hàng loạt (Batch Operations):** Hỗ trợ nhấn giữ và vuốt chọn nhiều giao dịch để chỉnh sửa, gán nhãn hoặc xóa đồng thời.
- **Tôn trọng quyền riêng tư (Privacy-by-Design):** Không theo dõi người dùng, không quảng cáo, mã nguồn minh bạch và chỉ đồng bộ lên đám mây khi có sự ủy quyền của người dùng.

---

## 🛠️ Công nghệ & Kiến trúc

### Công nghệ sử dụng (Tech Stack)

- **Framework:** [Flutter](https://flutter.dev/) (Dart SDK >= 3.0.0)
- **Kiến trúc:** Clean Architecture & Feature-Driven (Domain - Data - Presentation / Struct-based)
- **Quản lý State:** [Provider](https://pub.dev/packages/provider) kết hợp luồng phản ứng (Reactive Streams) của Drift ORM
- **Cơ sở dữ liệu cục bộ (Local Database):** [Drift](https://drift.simonbinder.eu/) + `sqlite3_flutter_libs`
- **Cloud & Xác thực:**
  - Firebase Authentication (Google Sign-In)
  - Cloud Firestore (Đồng bộ đa thiết bị theo thời gian thực)
  - Google Drive API (Sao lưu dữ liệu cá nhân)
- **Thư viện UI & Tiện ích:**
  - `fl_chart`: Vẽ biểu đồ tài chính động
  - `local_auth`: Xác thực sinh trắc học vân tay / khuôn mặt
  - `flutter_local_notifications`: Thông báo nhắc nhở chi tiêu định kỳ
  - `csv` & `googleapis`: Nhập/xuất dữ liệu bảng tính
  - `home_widget`: Hỗ trợ widget tiện ích trên màn hình chính

### Cấu trúc Thư mục Dự án

```
Cashew/
├── budget/                                 # Thư mục mã nguồn chính ứng dụng Flutter
│   ├── assets/                             # Tài nguyên tĩnh (icons, fonts, translations đa ngôn ngữ)
│   ├── lib/                                # Toàn bộ mã nguồn Dart
│   │   ├── database/                       # Tầng dữ liệu Drift SQLite (tables, schemas, migration scripts)
│   │   ├── modified/                       # Các thư viện & widget tùy biến mở rộng
│   │   ├── pages/                          # Các màn hình chức năng (Home, Budget, Transactions, Wallet,...)
│   │   │   └── homePage/                   # Màn hình trang chủ và các sub-components widget
│   │   ├── struct/                         # Quản lý State toàn cục, Sync Client, Currency & Tiện ích hệ thống
│   │   ├── widgets/                        # Bộ thư viện UI dùng chung (Cards, Modals, Sliders, Charts)
│   │   ├── colors.dart                     # Hệ thống bảng màu & định nghĩa chủ đề Material You
│   │   ├── firebase_options.dart           # Cấu hình Firebase đa nền tảng
│   │   ├── functions.dart                  # Hàm tiện ích chung (Routing, Formatter, Platform Handler)
│   │   └── main.dart                       # Entry point khởi chạy ứng dụng
│   ├── packages/                           # Các package phụ trợ được tối ưu nội bộ
│   └── pubspec.yaml                        # Quản lý dependencies & cấu hình môi trường Flutter
├── promotional/                            # Hình ảnh quảng bá, banner, store screenshots
└── scripts/                                # Scripts tự động hóa build & deployment
```

---

## 🚀 Hướng dẫn Cài đặt & Chạy ứng dụng

### 1. Yêu cầu môi trường (Prerequisites)
- Đã cài đặt [Flutter SDK](https://docs.flutter.dev/get-started/install) (phiên bản `>= 3.0.0`)
- Đã cài đặt [Android Studio](https://developer.android.com/studio) (kèm Android SDK 26+) hoặc [Xcode](https://developer.apple.com/xcode/) (cho macOS / iOS)
- Git được cài đặt trên hệ điều hành

### 2. Các bước cài đặt chi tiết

**Bước 1: Clone repository**
```bash
git clone https://github.com/DuongNguyenAnhh-3185/Cashew.git
cd Cashew/budget
```

**Bước 2: Cài đặt các gói phụ thuộc (Dependencies)**
```bash
flutter pub get
```

**Bước 3: Sinh mã nguồn cơ sở dữ liệu (Drift Code Generation)**
```bash
dart run build_runner build --delete-conflicting-outputs
```

**Bước 4: Cấu hình Firebase (Tùy chọn cho tính năng Sync & Auth)**
- Đặt file `google-services.json` vào thư mục `budget/android/app/` (cho Android)
- Đặt file `GoogleService-Info.plist` vào thư mục `budget/ios/Runner/` (cho iOS)
- Hoặc cấu hình tự động thông qua FlutterFire CLI:
```bash
flutterfire configure
```

**Bước 5: Khởi chạy ứng dụng**
```bash
# Chạy trên thiết bị thật hoặc máy ảo (Emulator/Simulator)
flutter run
```

---

## 🎯 Định hướng Phát triển (Roadmap)

- [x] Quản lý chi tiêu, ngân sách đa chu kỳ và đa ví tài khoản.
- [x] Giao diện Material You Dynamic Theming & Dark/Light mode thích ứng.
- [x] Hoạt động ngoại tuyến 100% với SQLite Drift, đồng bộ Firebase Realtime.
- [x] Nhập và xuất dữ liệu linh hoạt qua CSV, Google Drive và Google Sheets.
- [x] Khóa sinh trắc học vân tay / Face ID và chia hóa đơn (Bill Splitter).
- [ ] **AI Financial Assistant:** Tích hợp mô hình AI (Google Gemini) để phân tích thói quen tiêu dùng, cảnh báo lạm chi và dự đoán dòng tiền tương lai.
- [ ] **Smart OCR Receipt Scanner:** Nhận diện và tự động trích xuất thông tin hóa đơn mua sắm qua camera bằng AI.
- [ ] **Mở rộng nền tảng:** Tối ưu hóa trải nghiệm trên Desktop (Windows / macOS / Linux) và đồng bộ trên Wear OS / Apple Watch.

---

## 👥 Đội ngũ Phát triển & Thông tin Dự án

- **Dự án:** Ứng dụng Quản lý Tài chính Cá nhân Thông minh - **Cashew**
- **Repository:** [https://github.com/DuongNguyenAnhh-3185/Cashew](https://github.com/DuongNguyenAnhh-3185/Cashew)
- **Mã nguồn gốc & Lời cảm ơn:** Dự án được phát triển và kế thừa trên nền tảng dự án mã nguồn mở Cashew của tác giả [James Kokoska](https://github.com/jameskokoska/Cashew).

<div align="center">
  <sub>Phát triển với ❤️ bằng Flutter & SQLite Drift.</sub>
</div>
