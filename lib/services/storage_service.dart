import 'dart:io';
import 'dart:typed_data';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:open_filex/open_filex.dart';
import 'package:path_provider/path_provider.dart';
import 'package:http/http.dart' as http;

/// Kết quả thao tác tải tệp
class FileDownloadResult {
  final bool isSuccess;
  final String? localFilePath;
  final String? errorMessage;

  const FileDownloadResult({
    required this.isSuccess,
    this.localFilePath,
    this.errorMessage,
  });
}

/// Dịch vụ quản lý tệp tin vật lý trên Firebase Storage
class StorageService {
  final FirebaseStorage _storage;

  StorageService({FirebaseStorage? storage})
      : _storage = storage ?? FirebaseStorage.instance;

  /// Tạo đường dẫn chuẩn: documents/{firebase_uid}/{document_id}/{fileName}
  static String buildStoragePath({
    required String uid,
    required String documentId,
    required String fileName,
  }) {
    // Làm sạch tên file để tránh ký tự đặc biệt gây lỗi đường dẫn URL
    final sanitizedFileName = fileName.replaceAll(RegExp(r'[#?\[\]]'), '_');
    return 'documents/$uid/$documentId/$sanitizedFileName';
  }

  /// Tải tệp lên Firebase Storage từ đường dẫn trên thiết bị
  Future<String> uploadFileFromPath({
    required String uid,
    required String documentId,
    required String fileName,
    required String filePath,
    String? contentType,
  }) async {
    final file = File(filePath);
    if (!await file.exists()) {
      throw FileSystemException('Tệp không tồn tại trên thiết bị', filePath);
    }

    final storagePath = buildStoragePath(
      uid: uid,
      documentId: documentId,
      fileName: fileName,
    );

    final ref = _storage.ref().child(storagePath);
    final metadata = SettableMetadata(
      contentType: contentType,
      customMetadata: {
        'owner_uid': uid,
        'document_id': documentId,
        'original_name': fileName,
      },
    );

    await ref.putFile(file, metadata);
    return storagePath;
  }

  /// Tải tệp lên Firebase Storage từ mảng Bytes (hỗ trợ Web & File Picker in-memory)
  Future<String> uploadFileFromBytes({
    required String uid,
    required String documentId,
    required String fileName,
    required Uint8List bytes,
    String? contentType,
  }) async {
    final storagePath = buildStoragePath(
      uid: uid,
      documentId: documentId,
      fileName: fileName,
    );

    final ref = _storage.ref().child(storagePath);
    final metadata = SettableMetadata(
      contentType: contentType,
      customMetadata: {
        'owner_uid': uid,
        'document_id': documentId,
        'original_name': fileName,
      },
    );

    await ref.putData(bytes, metadata);
    return storagePath;
  }

  /// Lấy liên kết tải xuống (Download URL) từ Firebase Storage
  Future<String> getDownloadUrl(String storagePath) async {
    final ref = _storage.ref().child(storagePath);
    return await ref.getDownloadURL();
  }

  /// Tải tệp về bộ nhớ tạm của thiết bị và mở tệp bằng ứng dụng mặc định của hệ điều hành
  Future<FileDownloadResult> downloadAndOpenFile({
    required String storagePath,
    required String fileName,
  }) async {
    try {
      // 1. Lấy Download URL từ Storage
      final downloadUrl = await getDownloadUrl(storagePath);

      // 2. Tải nội dung tệp qua HTTP
      final response = await http.get(Uri.parse(downloadUrl));
      if (response.statusCode != 200) {
        return FileDownloadResult(
          isSuccess: false,
          errorMessage: 'Không thể tải tệp từ máy chủ (HTTP ${response.statusCode})',
        );
      }

      // 3. Lưu vào thư mục tạm trên thiết bị
      final tempDir = await getTemporaryDirectory();
      final localFilePath = '${tempDir.path}/$fileName';
      final file = File(localFilePath);
      await file.writeAsBytes(response.bodyBytes);

      // 4. Mở tệp bằng trình xem mặc định (PDF, DOCX, ZIP, v.v.)
      final openResult = await OpenFilex.open(localFilePath);
      if (openResult.type != ResultType.done) {
        return FileDownloadResult(
          isSuccess: true,
          localFilePath: localFilePath,
          errorMessage: 'Đã tải tệp về: $localFilePath (Không tìm thấy ứng dụng mở tương thích)',
        );
      }

      return FileDownloadResult(
        isSuccess: true,
        localFilePath: localFilePath,
      );
    } catch (e) {
      return FileDownloadResult(
        isSuccess: false,
        errorMessage: 'Lỗi khi tải hoặc mở tệp: $e',
      );
    }
  }

  /// Xóa tệp tin trên Firebase Storage
  Future<void> deleteFile(String storagePath) async {
    try {
      final ref = _storage.ref().child(storagePath);
      await ref.delete();
    } catch (e) {
      // Nếu tệp đã bị xóa trước đó trên Storage thì không ném exception làm gián đoạn việc xóa bản ghi DB
      if (e is FirebaseException && e.code == 'object-not-found') {
        return;
      }
      rethrow;
    }
  }
}
