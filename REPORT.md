# 📑 BÁO CÁO GIẢI TRÌNH KIẾN TRÚC CASHEW (REPORT.md)
## ĐỒ ÁN: ỨNG DỤNG QUẢN LÝ TÀI LIỆU HỌC TẬP THEO KIẾN TRÚC CASHEW
> **Học phần:** Kiến trúc & Thiết kế Phần mềm / Lập trình Thiết bị Di động  
> **Bài Thực Hành:** TH1 - Xây dựng Ứng dụng Quản lý Tài liệu Học tập theo Kiến trúc Cashew  
> **Tham chiếu kiến trúc gốc:** [Cashew - jameskokoska/Cashew](https://github.com/jameskokoska/Cashew)  
> **Kho mã nguồn triển khai:** [DuongNguyenAnhh-3185/Cashew](https://github.com/DuongNguyenAnhh-3185/Cashew.git)  
> **Công nghệ:** Flutter 3.x, Dart 3.x, Material Design 3  

---

## MỤC LỤC
1. [GIỚI THIỆU TỔNG QUAN & MỤC TIÊU ĐỒ ÁN](#1-giới-thiệu-tổng-quan--mục-tiêu-đồ-án)
2. [NGHIÊN CỨU & PHÂN TÍCH KIẾN TRÚC ỨNG DỤNG CASHEW](#2-nghiên-cứu--phân-tích-kiến-trúc-ứng-dụng-cashew)
3. [CẤU TRÚC PHÂN TẦNG VÀ HIỆN THỰC VÀO DỰ ÁN](#3-cấu-trúc-phân-tầng-và-hiện-thực-vào-dự-án)
4. [CÁC NGUYÊN TẮC THIẾT KẾ CỐT LÕI ĐƯỢC ÁP DỤNG](#4-các-nguyên-tắc-thiết-kế-cốt-lõi-được-áp-dụng)
5. [HIỆN THỰC CÁC CHỨC NĂNG CỐT LÕI (CRUD & TÌM KIẾM)](#5-hiện-thực-các-chức-năng-cốt-lõi-crud--tìm-kiếm)
6. [CHIẾN LƯỢC KIỂM THỬ ĐỘC LẬP & MOCKING](#6-chiến-lược-kiểm-thử-độc-lập--mocking)
7. [KẾT LUẬN & ĐÁNH GIÁ TÍNH MỞ RỘNG](#7-kết-luận--đánh-giá-tính-mở-rộng)

---

## 1. GIỚI THIỆU TỔNG QUAN & MỤC TIÊU ĐỒ ÁN

### 1.1. Bối cảnh
Trong quá trình học tập tại giảng đường đại học, sinh viên phải tiếp nhận khối lượng tài liệu học tập khổng lồ và đa dạng từ nhiều nguồn: slide bài giảng, đề bài tập lớn, giáo trình điện tử, ngân hàng đề thi các năm và ghi chú tổng hợp. Việc quản lý thủ công qua thư mục máy tính thường dẫn đến thất lạc, khó tra cứu nhanh theo môn học hoặc định dạng tệp.

### 1.2. Mục tiêu đề tài
Xây dựng một ứng dụng di động & đa nền tảng mang tên **Cashew StudyDocs** cho phép sinh viên:
- Lưu trữ và phân loại 5 nhóm tài liệu: **Bài giảng (Lectures)**, **Bài tập & Đồ án (Exercises)**, **Tài liệu tham khảo (References)**, **Đề thi & Đáp án (Exams)**, **Ghi chú & Tóm tắt (Notes)**.
- Thực hiện đầy đủ các thao tác **Thêm, Sửa, Xóa, Tìm kiếm thời gian thực**, đánh dấu yêu thích và quản lý dung lượng.
- **Yêu cầu kỹ thuật cốt lõi:** Áp dụng nghiêm ngặt các nguyên lý của **Kiến trúc Cashew** — phân tách rạch ròi các tầng xử lý (Domain, UseCases, Data, Presentation), triệt tiêu sự phụ thuộc vòng, đảm bảo tính mô-đun hóa cao và khả năng mở rộng bền vững.

---

## 2. NGHIÊN CỨU & PHÂN TÍCH KIẾN TRÚC ỨNG DỤNG CASHEW

Tham chiếu từ ứng dụng nổi tiếng **Cashew** ([jameskokoska/Cashew](https://github.com/jameskokoska/Cashew)) — một ứng dụng quản lý ngân sách mã nguồn mở tiêu biểu được xây dựng bằng Flutter, kiến trúc của Cashew nổi bật với các đặc trưng quan trọng:

1. **Mô hình Dữ liệu Phản ứng (Reactive Data Streams):**
   - Trong Cashew gốc, dữ liệu từ cơ sở dữ liệu (Drift/SQLite) được phát ra dưới dạng luồng Stream (`watchAll...`). Bất kỳ thao tác thêm/sửa/xóa nào đều tự động kích hoạt luồng cập nhật, giao diện người dùng tự động re-render tức thì mà không cần gọi hàm reload thủ công.
   - Tránh triệt để hiện tượng lệch pha trạng thái (State Desynchronization) giữa các màn hình.

2. **Phân tách Độc lập Giữa Nghiệp Vụ và Công Nghệ Lưu Trữ:**
   - Ứng dụng Cashew tách riêng cấu trúc Entity/Model khỏi các thao tác I/O lưu trữ. Điều này cho phép ứng dụng hỗ trợ lưu dữ liệu cục bộ an toàn, đồng thời có thể cắm thêm tính năng đồng bộ đám mây (Google Drive / Firebase Sync) mà không làm vỡ logic giao diện.

3. **Giao diện Người dùng Hướng Thẻ & Trực Quan (Card-based & Analytics Dashboard):**
   - Cashew nổi tiếng với banner thống kê tổng quan (Analytics Overview) đặt ở đầu trang, hệ thống chip lọc cuộn ngang (Filter Chips) và các thẻ dữ liệu trực quan bo góc mềm mại, bảng màu tinh tế (Emerald, Mint, Slate).

---

## 3. CẤU TRÚC PHÂN TẦNG VÀ HIỆN THỰC VÀO DỰ ÁN

Hệ thống được tổ chức phân cấp 5 tầng theo cấu trúc thư mục sạch:

```
lib/
├── core/                               # TẦNG DÙNG CHUNG (Cross-Cutting Layer)
│   ├── constants/
│   │   ├── app_colors.dart             # Bảng màu chuẩn phong cách Cashew
│   │   └── app_constants.dart          # Hằng số, danh mục môn học mẫu
│   ├── theme/
│   │   └── app_theme.dart              # Giao diện Material 3 (Light/Dark Mode)
│   └── utils/
│       ├── date_formatter.dart         # Định dạng thời gian thân thiện
│       └── file_size_helper.dart       # Chuyển đổi dung lượng (B, KB, MB, GB)
│
├── domain/                             # TẦNG NGHIỆP VỤ CỐT LÕI (Core Business Layer)
│   ├── entities/
│   │   ├── document_entity.dart        # Thực thể bất biến (Immutable Entity)
│   │   └── document_type.dart          # Enum phân loại tài liệu kèm icon & màu sắc
│   ├── repositories/
│   │   └── i_document_repository.dart  # Hợp đồng trừu tượng (DIP Interface)
│   └── services/
│       ├── document_filter_service.dart# Thuật toán tìm kiếm, lọc & sắp xếp độc lập
│       └── document_validation_service.dart # Dịch vụ kiểm tra tính hợp lệ dữ liệu
│
├── usecases/                           # TẦNG USE CASES (Application Logic Layer)
│   ├── add_document_usecase.dart       # Nghiệp vụ Thêm mới tài liệu
│   ├── update_document_usecase.dart    # Nghiệp vụ Chỉnh sửa tài liệu
│   ├── delete_document_usecase.dart    # Nghiệp vụ Xóa tài liệu
│   ├── search_documents_usecase.dart   # Nghiệp vụ Tìm kiếm & Lọc dữ liệu
│   ├── document_usecases.dart          # WatchDocuments, ToggleFavorite, ResetData
│   └── usecases.dart                   # Barrel export file
│
├── data/                               # TẦNG DỮ LIỆU & TRIỂN KHAI (Data Layer)
│   ├── datasources/
│   │   └── document_local_data_source.dart # Nguồn lưu trữ SharedPreferences + Seed Data
│   ├── models/
│   │   └── document_model.dart         # Kế thừa Entity, bổ sung JSON Serialization
│   └── repositories/
│       └── document_repository_impl.dart   # Triển khai Repository với StreamController.broadcast()
│
├── presentation/                       # TẦNG TRÌNH DIỄN & TRẠNG THÁI (UI Layer)
│   ├── controllers/
│   │   └── document_controller.dart    # ViewModel / State Controller điều phối Use Cases
│   ├── pages/
│   │   ├── home_page.dart              # Màn hình chính Dashboard tổng quan
│   │   ├── document_detail_page.dart   # Màn hình chi tiết tài liệu
│   │   └── document_form_page.dart     # Form Thêm mới / Cập nhật tài liệu
│   └── widgets/
│       ├── document_card.dart          # Thẻ hiển thị một tài liệu học tập
│       ├── document_stats_header.dart  # Thẻ thống kê Analytics phong cách Cashew
│       ├── search_and_filter_bar.dart  # Thanh tìm kiếm thời gian thực & chọn môn học
│       ├── type_filter_chips.dart      # Thanh chip cuộn ngang chọn loại tài liệu
│       ├── empty_documents_view.dart   # Giao diện khi danh sách trống
│       └── delete_confirm_dialog.dart  # Hộp thoại xác nhận xóa an toàn
│
└── main.dart                           # Điểm khởi chạy & Dependency Injection
```

---

## 4. CÁC NGUYÊN TẮC THIẾT KẾ CỐT LÕI ĐƯỢC ÁP DỤNG

### 4.1. Tính Độc Lập Tuyệt Đối Của Tầng Domain (Domain Isolation)
Tầng `domain/` không import bất kỳ package UI nào của Flutter (`package:flutter/material.dart`). Toàn bộ logic bên trong chỉ sử dụng pure Dart.
- **Ý nghĩa:** Logic kiểm tra tính hợp lệ dữ liệu (`DocumentValidationService`), cấu trúc nghiệp vụ (`DocumentEntity`), thuật toán tìm kiếm và lọc (`DocumentFilterService`) có thể được mang sang chạy trên môi trường Backend Dart Frog, Server CLI hoặc tái sử dụng trên nền tảng khác mà không thay đổi bất kỳ dòng mã nào.

### 4.2. Nguyên lý Đảo Ngược Phụ Thuộc (Dependency Inversion Principle - DIP)
- Tầng `presentation/` và tầng `usecases/` **không bao giờ phụ thuộc trực tiếp** vào tầng `data/` hay thư viện `SharedPreferences`.
- Cả hai tầng bậc cao đều giao tiếp thông qua hợp đồng trừu tượng `IDocumentRepository` được định nghĩa trong `domain/repositories/`.
- Tầng `data/` chịu trách nhiệm hiện thực hóa hợp đồng này qua `DocumentRepositoryImpl`.
- **Cơ chế Tiêm phụ thuộc (Dependency Injection):** Được khởi tạo tập trung tại `main.dart`, giúp hệ thống dễ bảo trì, thay thế và kiểm thử.

### 4.3. Nguyên tắc Phân Tách Trách Nhiệm (Single Responsibility Principle - SRP)
Hệ thống loại bỏ hoàn toàn mô hình "God Class" hay việc nhồi nhét logic vào widget:
- `AddDocumentUseCase`: Chỉ phụ trách luồng kiểm tra nghiệp vụ và chuyển giao lưu trữ khi tạo mới tài liệu.
- `SearchDocumentsUseCase`: Chỉ điều phối thuật toán lọc và tìm kiếm.
- `DocumentController`: Chỉ quản lý trạng thái hiển thị giao diện, tiếp nhận thao tác người dùng và gọi các Use Case tương ứng.
- `DocumentLocalDataSource`: Chỉ chịu trách nhiệm đọc/ghi chuỗi JSON xuống bộ nhớ thiết bị.

### 4.4. Mô hình Luồng Dữ Liệu Phản Ứng (Reactive Streams Pattern)
- `DocumentRepositoryImpl` duy trì một `StreamController<List<DocumentEntity>>.broadcast()`.
- Mỗi khi có thao tác làm biến đổi dữ liệu (Thêm, Sửa, Xóa, Yêu thích, Khôi phục mẫu), Repository tự động phát danh sách mới nhất vào luồng Stream.
- `DocumentController` đăng ký lắng nghe luồng Stream này thông qua `WatchDocumentsUseCase.execute()`. Khi có dữ liệu mới, Controller gọi `notifyListeners()`, kích hoạt widget `ListenableBuilder` tự động render lại màn hình mà không cần truyền callback thủ công giữa các màn hình.

---

## 5. HIỆN THỰC CÁC CHỨC NĂNG CỐT LÕI (CRUD & TÌM KIẾM)

### 5.1. Thêm mới tài liệu (Create - UC01)
- Form nhập liệu trên `DocumentFormPage` hỗ trợ nhập tiêu đề, môn học (danh sách có sẵn hoặc tự nhập môn học mới), phân loại (5 nhóm), định dạng tệp, đường dẫn và danh sách thẻ tags.
- Trước khi lưu, dữ liệu được chuyển qua `AddDocumentUseCase` và `DocumentValidationService` để kiểm tra: Tiêu đề không rỗng và từ 3–150 ký tự; môn học hợp lệ; đường dẫn không để trống.

### 5.2. Xem chi tiết & Danh sách (Read)
- `HomePage` hiển thị danh sách tài liệu phản ứng thời gian thực với phân trang cuộn mượt mà (`CustomScrollView` & `SliverList`).
- Mỗi thẻ `DocumentCard` hiển thị biểu tượng đặc trưng của loại tài liệu, định dạng file, ngày cập nhật, nút chuyển đổi nhanh trạng thái yêu thích, và dung lượng tệp được format rõ ràng (ví dụ: `5.0 MB`).
- Màn hình chi tiết `DocumentDetailPage` hiển thị đầy đủ thông tin, hỗ trợ sao chép liên kết URL vào bộ nhớ tạm (Clipboard).

### 5.3. Chỉnh sửa tài liệu (Update - UC02)
- Cho phép người dùng cập nhật mọi trường thông tin tài liệu. Dữ liệu được đưa qua `UpdateDocumentUseCase` để kiểm định tính toàn vẹn trước khi cập nhật vào kho lưu trữ.

### 5.4. Xóa tài liệu an toàn (Delete - UC03)
- Thao tác xóa được bảo vệ thông qua `DeleteConfirmDialog` yêu cầu người dùng xác nhận rõ ràng, tránh bấm nhầm làm mất dữ liệu.

### 5.5. Tìm kiếm & Lọc đa chiều (Search & Filter - UC04)
- **Tìm kiếm tức thời:** Tự động lọc khi người dùng gõ từ khóa, tìm kiếm xuyên suốt tiêu đề, nội dung mô tả, môn học và thẻ tags.
- **Lọc theo loại:** Thanh chip cuộn ngang hỗ trợ chọn 1 trong 5 loại hoặc xem tất cả.
- **Lọc theo môn học:** Dropdown động tự động cập nhật danh sách các môn học hiện có.
- **Lọc yêu thích:** Nút lọc nhanh các tài liệu quan trọng được đánh dấu sao.
- **Sắp xếp linh hoạt:** 6 tùy chọn sắp xếp (Mới nhất, Cũ nhất, Tiêu đề A-Z, Tiêu đề Z-A, Dung lượng lớn nhất, Dung lượng nhỏ nhất).

---

## 6. CHIẾN LƯỢC KIỂM THỬ ĐỘC LẬP & MOCKING

Để chứng minh việc phân tách kiến trúc thành công, dự án áp dụng chiến lược kiểm thử đa tầng với kỹ thuật **Mocking / Faking**:

### 6.1. Fake Repository (`FakeDocumentRepository`)
Tạo lớp `FakeDocumentRepository` cài đặt `IDocumentRepository` sử dụng bộ nhớ RAM và `StreamController.broadcast()`. Lớp này ghi nhận các cờ kiểm tra (`addDocumentCalled`, `deleteDocumentCalled`,...) giúp kiểm thử các Use Cases độc lập 100% với SharedPreferences hay SQLite.

### 6.2. Kết Quả Kiểm Thử Toàn Diện (30/30 Tests Passed)

Chạy lệnh kiểm thử tự động `flutter test`:

```text
Ran 30 tests across 9 test suites:
✓ test/domain/document_validation_service_test.dart (4 tests)  -> PASS (100%)
✓ test/domain/document_filter_service_test.dart (5 tests)      -> PASS (100%)
✓ test/data/document_model_test.dart (2 tests)                 -> PASS (100%)
✓ test/presentation/document_controller_test.dart (5 tests)   -> PASS (100%)
✓ test/usecases/add_document_usecase_test.dart (4 tests)       -> PASS (100%)
✓ test/usecases/delete_document_usecase_test.dart (2 tests)    -> PASS (100%)
✓ test/usecases/update_document_usecase_test.dart (2 tests)    -> PASS (100%)
✓ test/usecases/search_documents_usecase_test.dart (5 tests)   -> PASS (100%)
✓ test/widget_test.dart (1 widget test)                        -> PASS (100%)

Result: 30/30 tests PASSED in 23s. Zero errors, zero failures.
```

Chạy phân tích cú pháp tĩnh `flutter analyze`:
```text
Analyzing TH1_CASEW...
No issues found! (ran in 6.5s)
```

---

## 7. KẾT LUẬN & ĐÁNH GIÁ TÍNH MỞ RỘNG

### 7.1. Kết luận
Đồ án **Cashew StudyDocs** đã hiện thực hóa đầy đủ và trọn vẹn 5/5 yêu cầu trong đề bài TH1:
1. Phân tích chi tiết yêu cầu chức năng và sơ đồ luồng dữ liệu hai chiều (`DESIGN.md`).
2. Thiết lập cấu trúc thư mục phân tầng sạch theo tiêu chuẩn kiến trúc Cashew.
3. Triển khai hoàn chỉnh toàn bộ chức năng cốt lõi (CRUD, tìm kiếm thời gian thực, lọc đa chiều, thống kê).
4. Xây dựng bộ kiểm thử tự động đa tầng với Mocking, chứng minh tính độc lập giữa Use Cases và Data Layer.
5. Đóng gói mã nguồn sạch, cấu hình Git Repository và biên soạn báo cáo giải trình đầy đủ.

### 7.2. Khả năng mở rộng trong tương lai (Scalability)
Nhờ kiến trúc phân lớp chuẩn hóa, hệ thống sẵn sàng mở rộng các tính năng nâng cao mà không làm ảnh hưởng đến cấu trúc hiện tại:
- **Nâng cấp Cơ sở dữ liệu:** Chuyển đổi từ `SharedPreferences` sang `Drift (SQLite)` tương tự phiên bản hoàn chỉnh của Cashew chỉ bằng cách viết thêm một lớp `DocumentDriftDataSource` và cắm vào `DocumentRepositoryImpl`.
- **Đồng bộ Đám mây (Cloud Sync):** Triển khai thêm `DocumentRemoteDataSource` kết nối Firebase Firestore hoặc REST API để đồng bộ dữ liệu đa thiết bị.
- **Tải & Mở tệp Offline:** Tích hợp `dio` và `open_file` để lưu bản sao tài liệu vào bộ nhớ ứng dụng.

---
*Báo cáo được hoàn thiện và xác nhận tính đúng đắn trên toàn bộ mã nguồn.*
