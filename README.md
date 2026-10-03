# 📚 Cashew StudyDocs - Ứng Dụng Quản Lý Tài Liệu Học Tập Theo Kiến Trúc Cashew

> **Bài Thực Hành 1 (TH1):** Xây dựng Ứng dụng Quản lý Tài liệu Học tập theo Kiến trúc Cashew  
> **Tham chiếu kiến trúc gốc:** [Cashew - jameskokoska/Cashew](https://github.com/jameskokoska/Cashew)  
> **Kho mã nguồn:** [GitHub Repository](https://github.com/DuongNguyenAnhh-3185/Cashew.git)  
> **Tài liệu Thiết kế Use Cases & Sequence Diagrams:** [DESIGN.md](./DESIGN.md)  
> **Báo cáo Giải trình Kiến trúc Cashew:** [REPORT.md](./REPORT.md) | [BAO_CAO_KIEN_TRUC_CASHEW.md](./BAO_CAO_KIEN_TRUC_CASHEW.md)  
> **Nền tảng:** Flutter 3.x (Dart 3.x) - Material Design 3  

---

## 🌟 Tổng Quan Dự Án

**Cashew StudyDocs** là giải pháp số hóa và quản lý tài liệu học tập toàn diện cho sinh viên (bài giảng, bài tập lớn, đề thi, sách tham khảo, ghi chú tóm tắt), được xây dựng tuân thủ nghiêm ngặt **Kiến trúc Cashew** (Clean Architecture kết hợp Reactive Stream Pattern đặc trưng của ứng dụng nổi tiếng Cashew).

Hệ thống tập trung tối đa vào **tính phân tách đa tầng (Layer Separation)**, **độc lập nghiệp vụ (Domain Independence)**, **tính mô-đun hóa (Modularization)** và **khả năng mở rộng bền vững (Scalability)**.

---

## ✅ Bảng Đối Chiếu 5 Mục Yêu Cầu

| STT | Mục Yêu Cầu | Tình Trạng | Vị Trí Hiện Thực Trong Mã Nguồn |
|:---:|:---|:---:|:---|
| **1** | **Tạo file DESIGN.md: Phân tích Use Cases & Sơ đồ luồng dữ liệu (Data Flow / Sequence Diagram) cho Thêm & Tìm kiếm** | **ĐẠT 100%** | Chi tiết trong [DESIGN.md](./DESIGN.md) gồm đặc tả Use Cases, sơ đồ tổng quan Mermaid Data Flow và 2 sơ đồ tuần tự Sequence Diagrams cho Thêm mới & Tìm kiếm |
| **2** | **Cấu trúc phân tầng sạch: Domain (Entities, Interfaces), Data (Repositories, Storage), UseCases (Logic nghiệp vụ), Presentation (UI/Controllers)** | **ĐẠT 100%** | Phân tầng chuẩn Clean Architecture: `lib/domain/`, `lib/usecases/`, `lib/data/`, `lib/presentation/`, `lib/core/` |
| **3** | **Viết code hoàn chỉnh cho các chức năng cốt lõi: Thêm, sửa, xóa, tìm kiếm tài liệu học tập (bài giảng, bài tập, tham khảo)** | **ĐẠT 100%** | Đầy đủ CRUD hoàn chỉnh, tìm kiếm thời gian thực, lọc 5 nhóm tài liệu, lọc môn học, yêu thích, khôi phục dữ liệu mẫu |
| **4** | **Thư mục test/: Bộ Unit Test kèm mock kiểm thử việc phân tách độc lập giữa Use Cases và Tầng Data** | **ĐẠT 100%** | **30/30 tests PASS 100%** qua 9 test suites; có lớp `FakeDocumentRepository` kiểm thử độc lập Use Cases với Data Layer |
| **5** | **Tạo file REPORT.md giải trình chi tiết về cách kiến trúc Cashew được áp dụng vào hệ thống** | **ĐẠT 100%** | Báo cáo chi tiết trong [REPORT.md](./REPORT.md) và [BAO_CAO_KIEN_TRUC_CASHEW.md](./BAO_CAO_KIEN_TRUC_CASHEW.md) |

---

## 🏗️ Kiến Trúc Hệ Thống (Cashew Architecture)

### Sơ đồ Luồng Dữ Liệu Hai Chiều (Data Flow Diagram)

```mermaid
flowchart TD
    subgraph UI["Tầng Presentation (Giao diện người dùng)"]
        V[HomePage / DetailPage / FormPage]
        W[Widgets: DocumentCard, SearchBar, FilterChips, StatsHeader]
    end

    subgraph State["Tầng Presentation (Quản lý trạng thái)"]
        C[DocumentController - ChangeNotifier]
    end

    subgraph UseCases["Tầng Use Cases (Logic Nghiệp vụ Ứng dụng)"]
        UC1[AddDocumentUseCase]
        UC2[UpdateDocumentUseCase]
        UC3[DeleteDocumentUseCase]
        UC4[SearchDocumentsUseCase]
        UC5[WatchDocumentsUseCase]
    end

    subgraph Domain["Tầng Domain (Nghiệp vụ cốt lõi - Độc lập 100%)"]
        VS[DocumentValidationService]
        FS[DocumentFilterService]
        IR["<<Interface>> IDocumentRepository"]
        E[DocumentEntity & DocumentType]
    end

    subgraph Data["Tầng Data (Dữ liệu & Triển khai)"]
        RI[DocumentRepositoryImpl]
        M[DocumentModel - JSON Serializer]
        LDS[DocumentLocalDataSource]
        SP[(SharedPreferences / Local Storage)]
    end

    %% Tương tác người dùng
    V -->|1. Thao tác CRUD & Lọc| C
    C -->|2. Gọi nghiệp vụ tương ứng| UseCases
    UC1 -->|3. Kiểm tra tính hợp lệ| VS
    UC4 -->|3. Thuật toán Lọc & Sắp xếp độc lập| FS
    UseCases -->|4. Thao tác dữ liệu qua Interface| IR
    IR -.->|Thực thi triển khai| RI
    RI -->|5. Ánh xạ Entity <-> Model| M
    RI -->|6. Đọc/Ghi dữ liệu| LDS
    LDS -->|7. Lưu trữ lâu dài| SP

    %% Luồng phản ứng thời gian thực (Reactive Streams)
    RI -->|8. Phát luồng Stream broadcast| IR
    IR -.->|9. Cập nhật luồng dữ liệu| UC5
    UC5 -.->|10. Luồng Stream cập nhật| C
    C -->|11. notifyListeners()| V
    C -->|12. Re-render UI tức thì| W
```

### Cấu Trúc Thư Mục Phân Tầng Sạch

```text
lib/
├── core/                               # Tầng Dùng chung (Cross-cutting)
│   ├── constants/
│   │   ├── app_colors.dart             # Bảng màu phong cách Cashew (Emerald, Slate, Mint)
│   │   └── app_constants.dart          # Hằng số hệ thống, danh mục môn học mẫu
│   ├── theme/
│   │   └── app_theme.dart              # Giao diện Material 3 hỗ trợ Light/Dark mode
│   └── utils/
│       ├── date_formatter.dart         # Định dạng ngày giờ thân thiện tiếng Việt
│       └── file_size_helper.dart       # Chuyển đổi dung lượng (Bytes -> KB, MB, GB)
│
├── domain/                             # Tầng Nghiệp Vụ Cốt Lõi (Độc lập 100% với UI/Database)
│   ├── entities/
│   │   ├── document_entity.dart        # Thực thể tài liệu học tập (Bất biến - Immutable)
│   │   └── document_type.dart          # Enum phân loại 5 nhóm tài liệu kèm metadata
│   ├── repositories/
│   │   └── i_document_repository.dart  # Hợp đồng trừu tượng (DIP Contract)
│   └── services/
│       ├── document_filter_service.dart# Thuật toán tìm kiếm, lọc đa chiều & sắp xếp
│       └── document_validation_service.dart # Dịch vụ xác thực dữ liệu đầu vào
│
├── usecases/                           # Tầng Use Cases (Business Logic Layer)
│   ├── add_document_usecase.dart       # Use Case: Thêm mới tài liệu
│   ├── update_document_usecase.dart    # Use Case: Cập nhật tài liệu
│   ├── delete_document_usecase.dart    # Use Case: Xóa tài liệu
│   ├── search_documents_usecase.dart   # Use Case: Tìm kiếm & Lọc tài liệu
│   ├── document_usecases.dart          # WatchDocuments, ToggleFavorite, ResetData
│   └── usecases.dart                   # Barrel export file
│
├── data/                               # Tầng Xử Lý Dữ Liệu
│   ├── datasources/
│   │   └── document_local_data_source.dart # Nguồn lưu trữ nội bộ (SharedPreferences + Seeder)
│   ├── models/
│   │   └── document_model.dart         # Kế thừa Entity, xử lý chuyển đổi JSON
│   └── repositories/
│       └── document_repository_impl.dart   # Cài đặt Repository với luồng StreamController
│
├── presentation/                       # Tầng Giao Diện & Trạng Thái
│   ├── controllers/
│   │   └── document_controller.dart    # State Controller điều phối Use Cases & UI
│   ├── pages/
│   │   ├── home_page.dart              # Màn hình Dashboard tổng quan tài liệu
│   │   ├── document_detail_page.dart   # Màn hình chi tiết tài liệu học tập
│   │   └── document_form_page.dart     # Form Thêm mới / Cập nhật tài liệu
│   └── widgets/
│       ├── document_card.dart          # Thẻ tài liệu hiển thị trực quan
│       ├── document_stats_header.dart  # Thẻ thống kê tổng quan theo phong cách Cashew
│       ├── search_and_filter_bar.dart  # Thanh tìm kiếm thời gian thực & chọn môn học
│       ├── type_filter_chips.dart      # Thanh chip cuộn ngang chọn loại tài liệu
│       ├── empty_documents_view.dart   # Giao diện khi không có tài liệu phù hợp
│       └── delete_confirm_dialog.dart  # Hộp thoại xác nhận xóa an toàn
│
└── main.dart                           # Điểm khởi chạy ứng dụng & Dependency Injection
```

---

## ⚡ Các Tính Năng Nổi Bật

1. **Quản lý 5 nhóm học tập cốt lõi:**
   - 📖 **Bài giảng (Lecture):** Slide thuyết trình, bài giảng điện tử.
   - 📝 **Bài tập & Đồ án (Exercise):** Đề bài, source code mẫu, bài giải.
   - 📚 **Sách tham khảo (Reference):** Sách chuyên ngành, cẩm nang tra cứu.
   - 🎯 **Đề thi & Đáp án (Exam):** Ngân hàng đề thi, bài trắc nghiệm các năm.
   - 💡 **Ghi chú & Tóm tắt (Note):** Cheat-sheets, công thức ghi nhớ nhanh.
2. **Thao tác dữ liệu toàn diện (CRUD):**
   - Thêm tài liệu mới với xác thực nghiệp vụ nghiêm ngặt (`AddDocumentUseCase` & `DocumentValidationService`).
   - Xem chi tiết tài liệu, định dạng file, dung lượng, sao chép URL nhanh chóng.
   - Chỉnh sửa linh hoạt mọi thuộc tính (`UpdateDocumentUseCase`).
   - Xóa tài liệu an toàn qua dialog xác nhận (`DeleteDocumentUseCase`).
3. **Tìm kiếm & Lọc đa chiều (Real-time Filter - `SearchDocumentsUseCase`):**
   - Tìm kiếm tức thời theo từ khóa trong tiêu đề, mô tả, môn học hoặc hashtag.
   - Lọc nhanh theo 5 nhóm tài liệu.
   - Lọc theo từng môn học chuyên biệt.
   - Lọc danh sách tài liệu quan trọng được đánh dấu Yêu thích (Favorite).
   - Sắp xếp đa dạng: Mới nhất, Cũ nhất, Tiêu đề A-Z, Dung lượng file.
4. **Trải nghiệm người dùng cao cấp:**
   - Chế độ Giao diện Sáng / Tối (Light / Dark Mode).
   - Banner phân tích Analytics trực quan phong cách Cashew.
   - Nút khôi phục dữ liệu mẫu (Reset to Default Sample Data).

---

## 🧪 Kết Quả Kiểm Thử Tự Động (Automated Testing)

Dự án bao gồm **30 bài kiểm thử đơn vị, mock và tích hợp** (100% Pass):

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

Chạy phân tích mã nguồn tĩnh:
```text
flutter analyze
No issues found!
```

---

## 🚀 Hướng Dẫn Cài Đặt & Khởi Chạy

### 1. Chuẩn bị môi trường
- Đã cài đặt Flutter SDK (khuyến nghị phiên bản 3.13 trở lên).
- Thiết bị chạy (Trình duyệt Chrome, máy tính Windows, hoặc máy ảo Android).

### 2. Tải mã nguồn & Cài đặt thư viện
```bash
git clone https://github.com/DuongNguyenAnhh-3185/Cashew.git
cd Cashew
flutter pub get
```

### 3. Chạy kiểm thử tự động
```bash
flutter test
```

### 4. Kiểm tra phân tích mã nguồn
```bash
flutter analyze
```

### 5. Chạy ứng dụng
- **Trên trình duyệt Web:**
  ```bash
  flutter run -d chrome
  ```
- **Trên máy tính Windows:**
  ```bash
  flutter run -d windows
  ```
- **Trên điện thoại/máy ảo Android:**
  ```bash
  flutter run -d android
  ```

---

## 📄 Tài Liệu Thiết Kế & Báo Cáo Giải Trình
- [DESIGN.md](./DESIGN.md): Đặc tả phân tích Use Cases, sơ đồ luồng dữ liệu (Data Flow) và 2 sơ đồ tuần tự (Sequence Diagrams).
- [REPORT.md](./REPORT.md): Báo cáo giải trình toàn diện về cách áp dụng kiến trúc Cashew vào đồ án.
