import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../../core/constants/app_constants.dart';
import '../models/document_model.dart';
import '../../domain/entities/document_type.dart';

/// Hop dong truu tuong cho nguon luu tru cuc bo
abstract class IDocumentLocalDataSource {
  Future<List<DocumentModel>> getDocuments();
  Future<void> saveDocuments(List<DocumentModel> documents);
  Future<void> clear();
  Future<List<DocumentModel>> getInitialSampleDocuments();
}

/// Trien khai nguon du lieu cuc bo su dung SharedPreferences
class DocumentLocalDataSource implements IDocumentLocalDataSource {
  final SharedPreferences _prefs;

  DocumentLocalDataSource(this._prefs);

  @override
  Future<List<DocumentModel>> getDocuments() async {
    final rawJson = _prefs.getString(AppConstants.storageKeyDocuments);
    if (rawJson == null || rawJson.trim().isEmpty) {
      final initialDocs = await getInitialSampleDocuments();
      await saveDocuments(initialDocs);
      return initialDocs;
    }

    try {
      final List<dynamic> decoded = jsonDecode(rawJson) as List<dynamic>;
      return decoded
          .map((item) => DocumentModel.fromJson(item as Map<String, dynamic>))
          .toList();
    } catch (e) {
      final initialDocs = await getInitialSampleDocuments();
      await saveDocuments(initialDocs);
      return initialDocs;
    }
  }

  @override
  Future<void> saveDocuments(List<DocumentModel> documents) async {
    final List<Map<String, dynamic>> rawList =
        documents.map((doc) => doc.toJson()).toList();
    final jsonString = jsonEncode(rawList);
    await _prefs.setString(AppConstants.storageKeyDocuments, jsonString);
  }

  @override
  Future<void> clear() async {
    await _prefs.remove(AppConstants.storageKeyDocuments);
  }

  @override
  Future<List<DocumentModel>> getInitialSampleDocuments() async {
    final now = DateTime.now();
    return [
      DocumentModel(
        id: 'doc-001',
        title: 'Giáo trình Kiến trúc & Thiết kế Phần mềm (Clean Architecture & Cashew Pattern)',
        description: 'Tài liệu chi tiết về các nguyên lý SOLID, phân tách đa tầng, Clean Architecture và ca nghiên cứu kiến trúc Cashew trong Flutter.',
        subject: 'Kiến trúc & Thiết kế Phần mềm',
        type: DocumentType.lecture,
        fileFormat: 'PDF',
        urlOrPath: 'https://storage.edu.vn/lectures/software_architecture_full.pdf',
        fileSizeBytes: 14680064,
        createdAt: now.subtract(const Duration(days: 3)),
        updatedAt: now.subtract(const Duration(days: 1)),
        isFavorite: true,
        tags: const ['Clean Architecture', 'SOLID', 'Cashew', 'Flutter'],
      ),
      DocumentModel(
        id: 'doc-002',
        title: 'Đề bài Thực hành 1: Quản lý Tài liệu Học tập theo Kiến trúc Cashew',
        description: 'Nhiệm vụ thiết kế và phân tách các tầng Domain, Data, Presentation cho ứng dụng học tập di động.',
        subject: 'Lập trình Ứng dụng Di động',
        type: DocumentType.exercise,
        fileFormat: 'DOCX',
        urlOrPath: 'https://courses.edu.vn/mobile/TH1_QuanLyTaiLieu_Cashew.docx',
        fileSizeBytes: 2457600,
        createdAt: now.subtract(const Duration(days: 2)),
        updatedAt: now.subtract(const Duration(hours: 12)),
        isFavorite: true,
        tags: const ['Thực hành', 'Flutter', 'Cashew', 'Báo cáo'],
      ),
      DocumentModel(
        id: 'doc-003',
        title: 'Slide Bài giảng Lập trình Flutter & Quản lý Trạng thái Provider/Bloc',
        description: 'Tổng hợp slide bài học từ tuần 1 đến tuần 8, kỹ thuật State Management và tối ưu hiệu năng widget tree.',
        subject: 'Lập trình Ứng dụng Di động',
        type: DocumentType.lecture,
        fileFormat: 'PPTX',
        urlOrPath: 'https://slides.edu.vn/flutter/flutter_state_management_master.pptx',
        fileSizeBytes: 35651584,
        createdAt: now.subtract(const Duration(days: 5)),
        updatedAt: now.subtract(const Duration(days: 4)),
        isFavorite: false,
        tags: const ['Flutter', 'Provider', 'Widget Tree', 'UI/UX'],
      ),
      DocumentModel(
        id: 'doc-004',
        title: 'Đề thi & Đáp án Mẫu Môn Cơ sở Dữ liệu Nâng cao (Kỳ 2025-2026)',
        description: 'Bộ 5 đề thi cuối kỳ có kèm lời giải chi tiết về tối ưu truy vấn SQL, đánh chỉ mục Indexing và phân tán dữ liệu.',
        subject: 'Cơ sở Dữ liệu Nâng cao',
        type: DocumentType.exam,
        fileFormat: 'PDF',
        urlOrPath: 'https://exams.edu.vn/db/de_thi_csdl_nang_cao_2025.pdf',
        fileSizeBytes: 5242880,
        createdAt: now.subtract(const Duration(days: 10)),
        updatedAt: now.subtract(const Duration(days: 8)),
        isFavorite: true,
        tags: const ['Đề thi', 'Ôn tập', 'SQL', 'Indexing'],
      ),
      DocumentModel(
        id: 'doc-005',
        title: 'Sách Tham khảo: Computer Networking - A Top-Down Approach (8th Edition)',
        description: 'Tài liệu tham khảo chính thức về các giao thức mạng TCP/IP, Socket Programming và bảo mật mạng.',
        subject: 'Mạng Máy tính & Truyền thông',
        type: DocumentType.reference,
        fileFormat: 'PDF',
        urlOrPath: 'https://ebooks.edu.vn/networking/top_down_approach_8th.pdf',
        fileSizeBytes: 48234496,
        createdAt: now.subtract(const Duration(days: 15)),
        updatedAt: now.subtract(const Duration(days: 15)),
        isFavorite: false,
        tags: const ['Sách tham khảo', 'TCP/IP', 'Giao thức'],
      ),
      DocumentModel(
        id: 'doc-006',
        title: 'Ghi chú Tóm tắt Công thức & Thuật toán Cấu trúc Dữ liệu',
        description: 'Cheat-sheet tóm tắt độ phức tạp thuật toán O(n), các giải thuật sắp xếp (QuickSort, MergeSort) và duyệt cây nhị phân.',
        subject: 'Cấu trúc Dữ liệu & Giải thuật',
        type: DocumentType.note,
        fileFormat: 'PDF',
        urlOrPath: 'https://notes.edu.vn/dsa/dsa_cheatsheet_summary.pdf',
        fileSizeBytes: 1048576,
        createdAt: now.subtract(const Duration(days: 1)),
        updatedAt: now.subtract(const Duration(hours: 3)),
        isFavorite: true,
        tags: const ['Ghi chú', 'Tóm tắt', 'DSA', 'Thuật toán'],
      ),
    ];
  }
}