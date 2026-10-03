# 📚 Cashew StudyDocs - Ứng Dụng Quản Lý Tài Liệu Học Tập Theo Kiến Trúc Cashew

> **Bài Thực Hành 1 (TH1):** Xây dựng Ứng dụng Quản lý Tài liệu Học tập theo Kiến trúc Cashew  
> **Nền tảng:** Flutter 3.x (Dart 3.x) - Material 3  
> **Kho mã nguồn:** [GitHub Repository](https://github.com/DuongNguyenAnhh-3185/Cashew.git)  
> **Báo cáo giải trình chi tiết:** [BAO_CAO_KIEN_TRUC_CASHEW.md](./BAO_CAO_KIEN_TRUC_CASHEW.md)

---

## 🌟 Tổng Quan Dự Án

**Cashew StudyDocs** là giải pháp số hóa và quản lý tài liệu học tập toàn diện cho sinh viên (bài giảng, bài tập lớn, đề thi, sách tham khảo, ghi chú tóm tắt), được xây dựng tuân thủ nghiêm ngặt **Kiến trúc Cashew** (Clean Architecture kết hợp Reactive Stream Pattern đặc trưng của ứng dụng nổi tiếng Cashew).

Hệ thống tập trung tối đa vào **tính phân tách đa tầng (Layer Separation)**, **độc lập nghiệp vụ (Domain Independence)**, **tính mô-đun hóa (Modularization)** và **khả năng mở rộng bền vững (Scalability)**.

---

## ✅ Bảng Đối Chiếu 5 Mục Checklist Yêu Cầu

| STT | Mục Yêu Cầu (Checklist) | Tình Trạng | Vị Trí Hiện Thực Trong Mã Nguồn |
|:---:|:---|:---:|:---|
| **1** | **Phân tích yêu cầu chức năng & Sơ đồ luồng dữ liệu (Data Flow)** | **ĐẠT 100%** | Sơ đồ luồng dữ liệu chi tiết trong [BAO_CAO_KIEN_TRUC_CASHEW.md](./BAO_CAO_KIEN_TRUC_CASHEW.md) và thiết kế hệ thống tương tác |
| **2** | **Cấu trúc thư mục & Phân lớp hệ thống theo chuẩn Cashew** | **ĐẠT 100%** | Phân tầng rõ rệt: `core/`, `domain/`, `data/`, `presentation/` |
| **3** | **Triển khai các chức năng cốt lõi: Thêm, sửa, xóa, tìm kiếm** | **ĐẠT 100%** | Đầy đủ CRUD, tìm kiếm thời gian thực, lọc 5 loại tài liệu, lọc môn học, yêu thích, khôi phục dữ liệu mẫu |
| **4** | **Kiểm thử tính đúng đắn việc phân tách logic giữa các lớp** | **ĐẠT 100%** | Bộ kiểm thử tự động 17/17 tests pass trên cả 4 tầng (Domain, Data, Presentation, Widget) |
| **5** | **Đóng gói mã nguồn & Viết báo cáo giải trình kiến trúc** | **ĐẠT 100%** | Tài liệu giải trình toàn diện [BAO_CAO_KIEN_TRUC_CASHEW.md](./BAO_CAO_KIEN_TRUC_CASHEW.md) |

---

## 🏗️ Kiến Trúc Hệ Thống (Cashew Architecture)

### Sơ đồ Luồng Dữ Liệu (Data Flow Diagram)

```mermaid
flowchart TD
    subgraph UI["Tầng Presentation (Giao diện người dùng)"]
        V[HomePage / DetailPage / FormPage]
        W[Widgets: DocumentCard, SearchBar, FilterChips, StatsHeader]
    end

    subgraph State["Tầng Presentation (Quản lý trạng thái)"]
        C[DocumentController - ChangeNotifier]
    end

    subgraph Domain["Tầng Domain (Nghiệp vụ cốt lõi - Độc lập 100%)"]
        VS[DocumentValidationService]
        FS[DocumentFilterService]
        IR["&lt;&lt;Interface&gt;&gt; IDocumentRepository"]
        E[DocumentEntity & DocumentType]
    end

    subgraph Data["Tầng Data (Dữ liệu & Triển khai)"]
        RI[DocumentRepositoryImpl]
        M[DocumentModel - JSON Serializer]
        LDS[DocumentLocalDataSource]
        SP[(SharedPreferences / Local Storage)]
    end

    %% Tương tác người dùng
    V -->|1. Thao tác: Thêm / Sửa / Xóa / Tìm kiếm| C
    C -->|2. Kiểm tra tính hợp lệ| VS
    C -->|3. Thuật toán Lọc & Sắp xếp độc lập| FS
    C -->|4. Gọi nghiệp vụ qua Interface| IR
    IR -.->|Thực thi triển khai| RI
    RI -->|5. Ánh xạ Entity <-> Model| M
    RI -->|6. Đọc/Ghi dữ liệu| LDS
    LDS -->|7. Lưu trữ lâu dài| SP

    %% Luồng phản ứng thời gian thực (Reactive)
    RI -->|8. Phát luồng Stream broadcast| IR
    IR -.->|9. Cập nhật luồng dữ liệu| C
    C -->|10. notifyListeners()| V
    C -->|11. Re-render UI tức thì| W
```

### Cấu Trúc Thư Mục Chuẩn Hóa

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
│   │   └── document_controller.dart    # State Controller điều phối luồng dữ liệu
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

1. **Quản lý danh mục học tập phong phú:**
   - 📖 **Bài giảng:** Slide thuyết trình, giáo trình điện tử.
   - 📝 **Bài tập & Đồ án:** Đề bài, source code mẫu, bài giải.
   - 📚 **Sách tham khảo:** Sách chuyên ngành, cẩm nang tra cứu.
   - 🎯 **Đề thi & Đáp án:** Ngân hàng đề thi, bài trắc nghiệm các năm.
   - 💡 **Ghi chú & Tóm tắt:** Cheat-sheets, công thức ghi nhớ nhanh.
2. **Thao tác dữ liệu toàn diện (CRUD):**
   - Thêm tài liệu mới với xác thực form nghiêm ngặt (Validation Service).
   - Xem chi tiết tài liệu, định dạng file, dung lượng, sao chép URL nhanh chóng.
   - Chỉnh sửa linh hoạt mọi thuộc tính (tiêu đề, môn học, dung lượng, tags).
   - Xóa tài liệu an toàn qua dialog xác nhận.
3. **Tìm kiếm & Lọc đa chiều (Real-time Filter):**
   - Tìm kiếm tức thời theo từ khóa trong tiêu đề, mô tả, môn học hoặc hashtag.
   - Lọc nhanh theo 5 nhóm tài liệu.
   - Lọc theo từng môn học chuyên biệt.
   - Lọc danh sách tài liệu quan trọng được đánh dấu Yêu thích (Favorite).
   - Sắp xếp đa dạng: Mới nhất, Cũ nhất, Tiêu đề A-Z, Dung lượng file.
4. **Trải nghiệm người dùng cao cấp:**
   - Chế độ Giao diện Sáng / Tối (Light / Dark Mode).
   - Banner phân tích Analytics trực quan (tổng tài liệu, tổng dung lượng MB, tài liệu yêu thích).
   - Nút khôi phục dữ liệu mẫu (Reset to Default Sample Data).

---

## 🧪 Kết Quả Kiểm Thử Tự Động (Automated Testing)

Dự án bao gồm 17 bài kiểm thử đơn vị và tích hợp (100% Pass):

```text
Ran 17 tests across 5 test suites:
✓ test/domain/document_validation_service_test.dart (4 tests)  -> PASS (100%)
✓ test/domain/document_filter_service_test.dart (5 tests)      -> PASS (100%)
✓ test/data/document_model_test.dart (2 tests)                 -> PASS (100%)
✓ test/presentation/document_controller_test.dart (5 tests)   -> PASS (100%)
✓ test/widget_test.dart (1 widget test)                        -> PASS (100%)

Result: 17/17 tests PASSED. Zero errors, zero warnings.
```

---

## 🚀 Hướng Dẫn Cài Đặt & Khởi Chạy

### 1. Chuẩn bị môi trường
- Đã cài đặt Flutter SDK (khuyến nghị phiên bản 3.13 trở lên).
- Thiết bị chạy (Trình duyệt Chrome, máy ảo Android, hoặc máy tính Windows).

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

## 📄 Tài Liệu Báo Cáo
Vui lòng tham khảo tài liệu [BAO_CAO_KIEN_TRUC_CASHEW.md](./BAO_CAO_KIEN_TRUC_CASHEW.md) để xem chi tiết lý thuyết, giải trình sơ đồ kiến trúc, nguyên tắc thiết kế SOLID và cơ chế phản ứng dữ liệu thời gian thực.
