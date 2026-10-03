# BÁO CÁO GIẢI TRÌNH KIẾN TRÚC CASHEW
## BÀI THỰC HÀNH 1 (TH1): XÂY DỰNG ỨNG DỤNG QUẢN LÝ TÀI LIỆU HỌC TẬP THEO KIẾN TRÚC CASHEW
**Công nghệ:** Flutter (Dart 3.x, Material 3)  
**Tên dự án:** Cashew StudyDocs (`cashew_study_docs`)  
**Mục tiêu:** Quản lý lưu trữ bài giảng, bài tập, đề thi, sách tham khảo và ghi chú học tập tuân thủ nghiêm ngặt các nguyên lý phân tách lớp, tính mô-đun hóa và khả năng mở rộng của kiến trúc Cashew.

---

## 1. PHÂN TÍCH YÊU CẦU & SƠ ĐỒ LUỒNG DỮ LIỆU (DATA FLOW)

### 1.1. Yêu cầu chức năng
1. **Lưu trữ & Phân loại tài liệu đa dạng:** Hỗ trợ 5 nhóm tài liệu cốt lõi của sinh viên:
   - Bài giảng (Lecture / Slide)
   - Bài tập & Đồ án (Exercise / Assignment)
   - Tài liệu tham khảo & Giáo trình (Reference Book)
   - Đề thi & Đáp án (Exam / Quiz)
   - Ghi chú & Tóm tắt kiến thức (Note / Cheat-sheet)
2. **Quản lý thông tin chi tiết:** Tiêu đề, môn học, phân loại, định dạng tệp (PDF, DOCX, PPTX, XLSX, MP4, LINK,...), đường dẫn/URL, dung lượng (Bytes/MB), ngày tạo, ngày cập nhật, trạng thái yêu thích (Favorite) và các thẻ phân loại (Tags).
3. **Thao tác dữ liệu toàn diện (CRUD):**
   - **Thêm mới (Create):** Form nhập liệu với kiểm tra hợp lệ nghiêm ngặt (Validation Service).
   - **Xem chi tiết (Read):** Danh sách phản ứng thời gian thực (Reactive stream), màn hình chi tiết, sao chép liên kết.
   - **Chỉnh sửa (Update):** Cập nhật thuộc tính tài liệu và đồng bộ tức thời.
   - **Xóa (Delete):** Hộp thoại xác nhận an toàn kèm thông báo hoàn tác (Undo).
4. **Tìm kiếm & Lọc đa chiều (Search & Filter):**
   - Tìm kiếm thời gian thực theo từ khóa trong tiêu đề, mô tả, tên môn học và thẻ tags.
   - Lọc theo loại tài liệu (Chip cuộn ngang kèm số lượng thống kê).
   - Lọc theo môn học (Dropdown thông minh).
   - Lọc riêng tài liệu đánh dấu yêu thích.
   - Sắp xếp linh hoạt: Ngày tạo (mới/cũ nhất), Tiêu đề (A-Z/Z-A), Dung lượng file (lớn/nhỏ nhất).
5. **Thống kê tổng quan:** Thẻ Analytics phong cách Cashew hiển thị tổng số tài liệu, tổng dung lượng lưu trữ, số tài liệu yêu thích và phân bổ theo từng loại.

---

### 1.2. Sơ đồ luồng dữ liệu (Data Flow Diagram)

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
        IR[<<Interface>> IDocumentRepository]
        E[DocumentEntity & DocumentType]
    end

    subgraph Data["Tầng Data (Dữ liệu & Triển khai)"]
        RI[DocumentRepositoryImpl]
        M[DocumentModel - JSON Serializer]
        LDS[DocumentLocalDataSource]
        SP[(SharedPreferences / Local Storage)]
    end

    %% User Interaction Flow
    V -->|1. Hành động người dùng: Thêm/Sửa/Xóa/Lọc| C
    C -->|2. Xác thực dữ liệu| VS
    C -->|3. Lọc & Sắp xếp thuật toán| FS
    C -->|4. Gọi nghiệp vụ qua Interface| IR
    IR -.->|Thực thi| RI
    RI -->|5. Ánh xạ Entity <-> Model| M
    RI -->|6. Đọc/Ghi dữ liệu| LDS
    LDS -->|7. Lưu trữ lâu dài| SP

    %% Reactive Flow
    RI -->|8. Phát luồng Stream broadcast| IR
    IR -.->|9. Cập nhật luồng dữ liệu| C
    C -->|10. notifyListeners()| V
    C -->|11. Re-render dữ liệu mới nhất| W
```

---

## 2. CẤU TRÚC THƯ MỤC THEO TIÊU CHUẨN KIẾN TRÚC CASHEW

Dự án được phân cấp mô-đun rõ ràng, loại bỏ hoàn toàn sự phụ thuộc vòng và tách biệt tuyệt đối giữa Logic và Giao diện:

```
lib/
├── core/                               # Tầng dùng chung toàn hệ thống
│   ├── constants/
│   │   ├── app_colors.dart             # Bảng màu sắc Cashew (Emerald, Teal, Semantic)
│   │   └── app_constants.dart          # Hằng số hệ thống, danh sách môn học mặc định
│   ├── theme/
│   │   └── app_theme.dart              # Cấu hình Material 3 Light/Dark Theme
│   └── utils/
│       ├── date_formatter.dart         # Định dạng ngày giờ thân thiện tiếng Việt
│       └── file_size_helper.dart       # Chuyển đổi dung lượng (B, KB, MB, GB)
│
├── domain/                             # Tầng Nghiệp vụ cốt lõi (Không phụ thuộc Flutter UI)
│   ├── entities/
│   │   ├── document_entity.dart        # Thực thể tài liệu học tập (Immutability pattern)
│   │   └── document_type.dart          # Enum phân loại tài liệu kèm icon & màu sắc
│   ├── repositories/
│   │   └── i_document_repository.dart  # Hợp đồng trừu tượng (DIP Contract)
│   └── services/
│       ├── document_filter_service.dart# Thuật toán tìm kiếm, lọc đa tiêu chí & sắp xếp
│       └── document_validation_service.dart # Kiểm tra tính hợp lệ dữ liệu nhập
│
├── data/                               # Tầng Xử lý Dữ liệu
│   ├── datasources/
│   │   └── document_local_data_source.dart # Nguồn dữ liệu SharedPreferences & Seed data
│   ├── models/
│   │   └── document_model.dart         # Kế thừa Entity, bổ sung JSON Serialization
│   └── repositories/
│       └── document_repository_impl.dart   # Cài đặt Repository với Reactive StreamController
│
├── presentation/                       # Tầng Giao diện & Trạng thái
│   ├── controllers/
│   │   └── document_controller.dart    # ViewModel / Controller điều phối trạng thái
│   ├── pages/
│   │   ├── home_page.dart              # Màn hình chính Dashboard tổng quan
│   │   ├── document_detail_page.dart   # Màn hình chi tiết tài liệu học tập
│   │   └── document_form_page.dart     # Form Thêm mới / Chỉnh sửa tài liệu
│   └── widgets/
│       ├── document_card.dart          # Thẻ hiển thị một tài liệu học tập
│       ├── document_stats_header.dart  # Banner thống kê Analytics phong cách Cashew
│       ├── search_and_filter_bar.dart  # Thanh công cụ tìm kiếm và lọc môn học
│       ├── type_filter_chips.dart      # Thanh chip chọn loại tài liệu
│       ├── empty_documents_view.dart   # Giao diện khi không có dữ liệu
│       └── delete_confirm_dialog.dart  # Hộp thoại xác nhận xóa an toàn
│
└── main.dart                           # Khởi tạo Dependency Injection & App Runner
```

---

## 3. NGUYÊN LÝ THIẾT KẾ ÁP DỤNG TRONG KIẾN TRÚC CASHEW

### 3.1. Phân tách đa tầng & Độc lập nghiệp vụ (Clean Architecture)
- **Tầng Domain hoàn toàn cô lập:** Các tệp trong `domain/` không import bất kỳ widget hay thư viện UI nào (chỉ sử dụng pure Dart). Nhờ đó, logic tính toán, lọc, sắp xếp và kiểm tra tính hợp lệ có thể được tái sử dụng hoặc chạy trên máy chủ (Backend Dart Frog / CLI) mà không cần thay đổi.
- **Tầng Data độc lập:** Giao tiếp qua `IDocumentRepository`. Có thể thay thế SharedPreferences bằng SQLite (Drift), Hive hoặc REST API/Firebase trong tương lai mà không ảnh hưởng một dòng code nào ở tầng Presentation hay Domain.

### 3.2. Dependency Inversion Principle (DIP)
- `DocumentController` chỉ phụ thuộc vào trừu tượng `IDocumentRepository`, không phụ thuộc vào `DocumentRepositoryImpl` hay `DocumentLocalDataSource`.
- Cho phép dễ dàng viết Unit Test bằng cách truyền vào `FakeDocumentRepository` mà không cần dựng SQLite hay Mock phức tạp.

### 3.3. Mô hình luồng dữ liệu một chiều & Reactive Streams (Cashew Pattern)
- Tương tự như ứng dụng gốc Cashew sử dụng Drift Stream để cập nhật tức thời khi cơ sở dữ liệu biến đổi, `DocumentRepositoryImpl` duy trì một `StreamController<List<DocumentEntity>>.broadcast()`.
- Bất kỳ thao tác thêm, sửa, xóa, đổi trạng thái yêu thích hay khôi phục dữ liệu mẫu đều tự động phát tín hiệu vào luồng, `DocumentController` tiếp nhận và thông báo cho UI re-render mượt mà, không gặp hiện tượng lệch trạng thái (State desynchronization).

### 3.4. Single Responsibility Principle (SRP)
- `DocumentValidationService`: Chỉ đảm nhận nhiệm vụ kiểm tra tính hợp lệ của dữ liệu.
- `DocumentFilterService`: Chỉ đảm nhận việc lọc và sắp xếp.
- `DocumentController`: Chỉ quản lý trạng thái giao diện và điều phối luồng gọi service.
- `DocumentLocalDataSource`: Chỉ tương tác trực tiếp với bộ nhớ lưu trữ `SharedPreferences`.

---

## 4. KẾT QUẢ KIỂM THỬ (AUTOMATED TESTING)

Dự án đã được thiết lập bộ kiểm thử tự động toàn diện trên cả 4 tầng:

```
Ran 17 tests across 5 test suites:
+ test/domain/document_validation_service_test.dart (4 tests)  -> PASS (100%)
+ test/domain/document_filter_service_test.dart (5 tests)      -> PASS (100%)
+ test/data/document_model_test.dart (2 tests)                 -> PASS (100%)
+ test/presentation/document_controller_test.dart (5 tests)   -> PASS (100%)
+ test/widget_test.dart (1 widget test)                        -> PASS (100%)

Result: 17/17 tests PASSED in 13s. Zero errors, zero warnings.
```

---

## 5. HƯỚNG DẪN KHỞI CHẠY DỰ ÁN

1. **Di chuyển vào thư mục dự án:**
   ```bash
   cd e:\TH1_CASEW
   ```

2. **Cài đặt thư viện dependencies:**
   ```bash
   flutter pub get
   ```

3. **Chạy kiểm thử:**
   ```bash
   flutter test
   ```

4. **Kiểm tra cú pháp code (Static Analysis):**
   ```bash
   flutter analyze
   ```

5. **Chạy ứng dụng:**
   - Trên trình duyệt Web:
     ```bash
     flutter run -d chrome
     ```
   - Trên máy tính Windows:
     ```bash
     flutter run -d windows
     ```
   - Trên thiết bị di động Android:
     ```bash
     flutter run -d android
     ```

---
*Báo cáo được chuẩn bị hoàn chỉnh phục vụ đánh giá bài thực hành TH1.*