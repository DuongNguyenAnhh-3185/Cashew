# 📚 Cashew StudyDocs - Ứng Dụng Quản Lý Tài Liệu Học Tập Theo Kiến Trúc Cashew

> **Bài Thực Hành 1 (TH1):** Xây dựng Ứng dụng Quản lý Tài liệu Học tập theo Kiến trúc Cashew  
> **Tham chiếu kiến trúc:** [Cashew - jameskokoska/Cashew](https://github.com/jameskokoska/Cashew)  
> **Kho mã nguồn:** [GitHub Repository](https://github.com/DuongNguyenAnhh-3185/Cashew.git)  
> **Tài liệu Báo cáo & Sơ đồ kiến trúc:** [REPORT.md](./REPORT.md)  
> **Tài liệu Thiết kế Use Cases & Sơ đồ tuần tự:** [DESIGN.md](./DESIGN.md)  
> **Nền tảng:** Flutter 3.x (Dart 3.x) - Material Design 3  

---

## 🌟 Tổng Quan Dự Án

**Cashew StudyDocs** là ứng dụng số hóa và quản lý tài liệu học tập (bài giảng, bài tập, tài liệu tham khảo, đề thi, ghi chú) áp dụng nghiêm ngặt các nguyên lý của **Kiến trúc Cashew**:
- **Phân tách các lớp xử lý (Layer Separation):** Domain, UseCases, Data, Presentation độc lập 100%.
- **Tính mô-đun hóa (Modularity):** Mỗi Use Case, Service, Widget đảm nhận một trách nhiệm duy nhất (SRP & DIP).
- **Khả năng mở rộng bền vững (Scalability):** Dễ dàng chuyển đổi sang Drift (SQLite) hoặc Cloud Sync mà không sửa đổi UI/Domain.
- **Cơ chế phản ứng thời gian thực (Reactive Streams):** Tự động đồng bộ và re-render giao diện qua luồng Stream broadcast.

---

## ✅ Bảng Đối Chiếu 5 Mục Checklist TH1

| STT | Mục Yêu Cầu Theo Checklist | Tình Trạng | Vị Trí Hiện Thực Trong Dự Án |
|:---:|:---|:---:|:---|
| **1** | **Phân tích yêu cầu chức năng và thiết kế sơ đồ luồng dữ liệu** | **ĐẠT 100%** | Chi tiết trong [REPORT.md (Mục 1)](./REPORT.md#mục-1-phân-tích-yêu-cầu-chức-năng-và-thiết-kế-sơ-đồ-luồng-dữ-liệu) & [DESIGN.md](./DESIGN.md) gồm yêu cầu, Data Flow Mermaid, 2 Sequence Diagrams (Thêm & Tìm kiếm) |
| **2** | **Thiết lập cấu trúc thư mục và phân lớp hệ thống theo chuẩn Cashew** | **ĐẠT 100%** | Cấu trúc phân tầng chuẩn: `lib/domain/`, `lib/usecases/`, `lib/data/`, `lib/presentation/`, `lib/core/` (Xem [REPORT.md (Mục 2)](./REPORT.md#mục-2-thiết-lập-cấu-trúc-thư-mục-và-phân-lớp-hệ-thống)) |
| **3** | **Triển khai các chức năng cốt lõi: Thêm, sửa, xóa, tìm kiếm tài liệu** | **ĐẠT 100%** | Đầy đủ 4 chức năng cốt lõi cho bài giảng, bài tập, tham khảo; tìm kiếm thời gian thực, lọc 5 nhóm tài liệu, yêu thích (Xem [REPORT.md (Mục 3)](./REPORT.md#mục-3-triển-khai-các-chức-năng-cốt-lõi-thêm-sửa-xóa-tìm-kiếm)) |
| **4** | **Kiểm thử tính đúng đắn của việc phân tách logic giữa các lớp** | **ĐẠT 100%** | **30/30 Unit Tests PASS 100%**, có lớp `FakeDocumentRepository` mock độc lập tầng Data và Domain/UseCases (Xem [REPORT.md (Mục 4)](./REPORT.md#mục-4-kiểm-thử-tính-đúng-đắn-của-việc-phân-tách-logic-giữa-các-lớp)) |
| **5** | **Đóng gói mã nguồn và viết báo cáo giải trình cách áp dụng kiến trúc** | **ĐẠT 100%** | Báo cáo hoàn chỉnh tại [REPORT.md](./REPORT.md), mã nguồn sạch không lỗi `flutter analyze` |

---

## 🏗️ Sơ Đồ Luồng Dữ Liệu Kiến Trúc (Architecture Data Flow)

```mermaid
flowchart TD
    subgraph UI["1. TẦNG PRESENTATION (Giao diện người dùng)"]
        Page["Pages: HomePage, DocumentFormPage, DocumentDetailPage"]
        Widget["Widgets: DocumentCard, SearchAndFilterBar, TypeFilterChips, StatsHeader"]
    end

    subgraph State["2. TẦNG PRESENTATION (Quản lý trạng thái)"]
        Ctrl["DocumentController (ChangeNotifier)"]
    end

    subgraph UseCases["3. TẦNG USE CASES (Application Logic)"]
        UC1[AddDocumentUseCase]
        UC2[UpdateDocumentUseCase]
        UC3[DeleteDocumentUseCase]
        UC4[SearchDocumentsUseCase]
        UC5[WatchDocumentsUseCase]
    end

    subgraph Domain["4. TẦNG DOMAIN (Nghiệp vụ cốt lõi - Pure Dart 100%)"]
        VS[DocumentValidationService]
        FS[DocumentFilterService]
        IR["<<Interface>> IDocumentRepository"]
        E[DocumentEntity & DocumentType]
    end

    subgraph Data["5. TẦNG DATA (Lưu trữ & Triển khai)"]
        RI[DocumentRepositoryImpl]
        M[DocumentModel - JSON Serializer]
        LDS[DocumentLocalDataSource]
        SP[(SharedPreferences / Storage)]
    end

    %% Luồng tương tác
    Page -->|Thao tác người dùng| Ctrl
    Ctrl -->|Gọi thực thi| UseCases
    UC1 -->|Kiểm tra hợp lệ| VS
    UC4 -->|Lọc & Sắp xếp độc lập| FS
    UseCases -->|Truy xuất dữ liệu| IR
    IR -.->|Triển khai cài đặt| RI
    RI -->|Ánh xạ Entity <-> Model| M
    RI -->|Đọc / Ghi| LDS
    LDS -->|Lưu trữ bền vững| SP

    %% Luồng phản ứng thời gian thực (Reactive Stream)
    RI -->|Phát Stream broadcast| IR
    IR -.->|Cập nhật dữ liệu| UC5
    UC5 -.->|Luồng Stream| Ctrl
    Ctrl -->|notifyListeners()| Page
    Page -->|Re-render tự động| Widget
```

---

## 📁 Cấu Trúc Thư Mục Phân Tầng

```text
lib/
├── core/                               # Tầng dùng chung (Colors, Themes, Utils, Formatters)
├── domain/                             # Tầng Nghiệp vụ cốt lõi (Entities, Repository Interfaces, Services)
│   ├── entities/                       # DocumentEntity, DocumentType
│   ├── repositories/                   # IDocumentRepository
│   └── services/                       # DocumentValidationService, DocumentFilterService
├── usecases/                           # Tầng Use Cases (Add, Update, Delete, Search, Watch)
├── data/                               # Tầng Dữ liệu (Models, LocalDataSource, RepositoryImpl)
│   ├── datasources/                    # SharedPreferences & Seed data
│   ├── models/                         # DocumentModel (JSON serialization)
│   └── repositories/                   # DocumentRepositoryImpl (Reactive Streams)
├── presentation/                       # Tầng Giao diện (Controllers, Pages, Widgets)
│   ├── controllers/                    # DocumentController
│   ├── pages/                          # HomePage, DocumentDetailPage, DocumentFormPage
│   └── widgets/                        # DocumentCard, SearchBar, FilterChips, StatsHeader
└── main.dart                           # Khởi tạo App & Dependency Injection
```

---

## 🧪 Kết Quả Kiểm Thử (30/30 Tests Passed)

```text
Ran 30 tests across 9 test suites:
✓ test/data/document_model_test.dart (2 tests)                 -> PASS (100%)
✓ test/domain/document_validation_service_test.dart (4 tests)  -> PASS (100%)
✓ test/domain/document_filter_service_test.dart (5 tests)      -> PASS (100%)
✓ test/usecases/add_document_usecase_test.dart (4 tests)       -> PASS (100%)
✓ test/usecases/delete_document_usecase_test.dart (2 tests)    -> PASS (100%)
✓ test/usecases/update_document_usecase_test.dart (2 tests)    -> PASS (100%)
✓ test/usecases/search_documents_usecase_test.dart (5 tests)   -> PASS (100%)
✓ test/presentation/document_controller_test.dart (5 tests)   -> PASS (100%)
✓ test/widget_test.dart (1 widget test)                        -> PASS (100%)

Result: 30/30 tests PASSED in 25s. Zero errors, zero failures.
```

Kiểm tra cú pháp code tĩnh:
```text
flutter analyze
No issues found! (ran in 14.7s)
```

---

## 🚀 Hướng Dẫn Chạy Dự Án

1. **Cài đặt dependencies:**
   ```bash
   flutter pub get
   ```

2. **Chạy kiểm thử:**
   ```bash
   flutter test
   ```

3. **Chạy ứng dụng:**
   - Web: `flutter run -d chrome`
   - Windows: `flutter run -d windows`
   - Android: `flutter run -d android`

---

## 📑 Báo Cáo Đầy Đủ
Mọi nội dung giải trình chi tiết về kiến trúc, các sơ đồ tuần tự và minh chứng được trình bày đầy đủ trong tài liệu [REPORT.md](./REPORT.md).
