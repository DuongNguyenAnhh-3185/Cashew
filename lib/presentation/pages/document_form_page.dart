import 'dart:typed_data';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_constants.dart';
import '../../domain/entities/document_entity.dart';
import '../../domain/entities/document_type.dart';
import '../controllers/document_controller.dart';

/// Màn hình Nộp tệp mới (Upload lên Firebase Storage & lưu Supabase) hoặc Chỉnh sửa Metadata
class DocumentFormPage extends StatefulWidget {
  final DocumentController controller;
  final DocumentEntity? documentToEdit;

  const DocumentFormPage({
    super.key,
    required this.controller,
    this.documentToEdit,
  });

  bool get isEditing => documentToEdit != null;

  @override
  State<DocumentFormPage> createState() => _DocumentFormPageState();
}

class _DocumentFormPageState extends State<DocumentFormPage> {
  final _formKey = GlobalKey<FormState>();

  late final TextEditingController _titleController;
  late final TextEditingController _descController;
  late final TextEditingController _customSubjectController;

  late DocumentType _selectedType;
  late String _selectedSubject;
  late String _selectedFormat;
  bool _isCustomSubject = false;
  bool _isSubmitting = false;

  // Trạng thái tệp đã chọn
  String? _selectedFileName;
  String? _selectedFilePath;
  Uint8List? _selectedFileBytes;
  int _selectedFileSize = 0;
  bool _isFileSelected = false;

  @override
  void initState() {
    super.initState();
    final doc = widget.documentToEdit;

    _titleController = TextEditingController(text: doc?.title ?? '');
    _descController = TextEditingController(text: doc?.description ?? '');
    _customSubjectController = TextEditingController();

    _selectedType = doc?.type ?? DocumentType.lecture;
    _selectedFormat = doc?.fileType.toUpperCase() ?? 'PDF';

    if (doc != null) {
      _isFileSelected = true;
      _selectedFileName = doc.fileName.isNotEmpty ? doc.fileName : 'Tệp hiện tại';
      _selectedFileSize = doc.fileSize;
    }

    final existingSubject = doc?.subject;
    if (existingSubject != null && AppConstants.defaultSubjects.contains(existingSubject)) {
      _selectedSubject = existingSubject;
    } else if (existingSubject != null && existingSubject.isNotEmpty && existingSubject != 'Chung') {
      _selectedSubject = 'Khác (Tự nhập)';
      _isCustomSubject = true;
      _customSubjectController.text = existingSubject;
    } else {
      _selectedSubject = AppConstants.defaultSubjects.first;
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descController.dispose();
    _customSubjectController.dispose();
    super.dispose();
  }

  /// Chọn tệp từ thiết bị bằng FilePicker
  Future<void> _pickFileFromDevice() async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['pdf', 'doc', 'docx', 'ppt', 'pptx', 'xls', 'xlsx', 'zip', 'rar', 'mp4', 'txt'],
        withData: true,
      );

      if (result != null && result.files.isNotEmpty) {
        final file = result.files.first;
        setState(() {
          _selectedFileName = file.name;
          _selectedFilePath = file.path;
          _selectedFileBytes = file.bytes;
          _selectedFileSize = file.size;
          _selectedFormat = (file.extension ?? 'PDF').toUpperCase();
          _isFileSelected = true;

          // Nếu tiêu đề đang để trống thì tự động điền theo tên tệp (bỏ phần mở rộng)
          if (_titleController.text.trim().isEmpty) {
            final rawName = file.name.replaceAll(RegExp(r'\.[^.]+$'), '');
            _titleController.text = rawName.replaceAll('_', ' ');
          }
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Không thể chọn tệp: $e'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }

  Future<void> _submitForm() async {
    if (!_formKey.currentState!.validate()) return;

    // Kiểm tra quyền chỉnh sửa nếu đang ở chế độ Edit
    if (widget.isEditing && !widget.documentToEdit!.canEdit) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Bạn chỉ có quyền xem, không được phép chỉnh sửa tài liệu này.'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    // Nếu tạo mới thì bắt buộc phải chọn file
    if (!widget.isEditing && !_isFileSelected) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Vui lòng chọn tệp tài liệu để tải lên.')),
      );
      return;
    }

    final subjectToSave = _isCustomSubject
        ? _customSubjectController.text.trim()
        : _selectedSubject;

    setState(() => _isSubmitting = true);

    if (widget.isEditing) {
      // 1. Chế độ Chỉnh sửa: Cập nhật title, description (chỉ owner hoặc editor)
      final success = await widget.controller.updateDocument(
        id: widget.documentToEdit!.id,
        title: _titleController.text.trim(),
        description: _descController.text.trim(),
      );

      setState(() => _isSubmitting = false);

      if (success && mounted) {
        Navigator.of(context).pop();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Cập nhật thông tin tài liệu thành công!'),
            backgroundColor: AppColors.success,
          ),
        );
      }
    } else {
      // 2. Chế độ Nộp mới: Upload file lên Firebase Storage & lưu Supabase
      final success = await widget.controller.uploadAndAddDocument(
        title: _titleController.text.trim(),
        description: _descController.text.trim(),
        subject: subjectToSave,
        type: _selectedType,
        fileName: _selectedFileName ?? 'document.pdf',
        fileType: _selectedFormat,
        fileSize: _selectedFileSize,
        filePath: _selectedFilePath ?? '',
        fileBytes: _selectedFileBytes,
      );

      setState(() => _isSubmitting = false);

      if (success && mounted) {
        Navigator.of(context).pop();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Đã tải tệp lên Firebase Storage và lưu vào kho học liệu!'),
            backgroundColor: AppColors.success,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isEditing = widget.isEditing;
    final canEdit = !isEditing || (widget.documentToEdit?.canEdit ?? false);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          isEditing ? 'Sửa thông tin tài liệu' : 'Nộp tài liệu mới',
          style: const TextStyle(fontWeight: FontWeight.w800),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Thông báo nếu không có quyền sửa
              if (isEditing && !canEdit) ...[
                Container(
                  padding: const EdgeInsets.all(12),
                  margin: const EdgeInsets.only(bottom: 16),
                  decoration: BoxDecoration(
                    color: Colors.orange.shade50,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.orange.shade300),
                  ),
                  child: Row(
                    children: const [
                      Icon(Icons.lock_outline, color: Colors.orange),
                      SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'Bạn chỉ có quyền xem tài liệu này. Chỉ Chủ sở hữu hoặc Biên tập viên mới có thể chỉnh sửa.',
                          style: TextStyle(color: Colors.deepOrange, fontSize: 13),
                        ),
                      ),
                    ],
                  ),
                ),
              ],

              // Khu vực nộp file vật lý (Chỉ hiển thị khi tạo mới)
              if (!isEditing) ...[
                Text(
                  '1. Tệp tin học tập (Lưu trên Firebase Storage)',
                  style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                InkWell(
                  onTap: _pickFileFromDevice,
                  borderRadius: BorderRadius.circular(16),
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: _isFileSelected
                          ? AppColors.primary.withOpacity(0.08)
                          : theme.colorScheme.surfaceVariant.withOpacity(0.4),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: _isFileSelected ? AppColors.primary : theme.colorScheme.outlineVariant,
                        width: _isFileSelected ? 2 : 1,
                      ),
                    ),
                    child: Column(
                      children: [
                        Icon(
                          _isFileSelected ? Icons.check_circle_rounded : Icons.cloud_upload_outlined,
                          size: 44,
                          color: _isFileSelected ? AppColors.primary : Colors.grey,
                        ),
                        const SizedBox(height: 10),
                        Text(
                          _isFileSelected ? _selectedFileName! : 'Nhấn để chọn tệp từ máy tính/thiết bị',
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                            color: _isFileSelected ? AppColors.primary : null,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          _isFileSelected
                              ? 'Định dạng: $_selectedFormat • Dung lượng: ${(_selectedFileSize / 1024).toStringAsFixed(1)} KB'
                              : 'Hỗ trợ PDF, Word (DOCX), PowerPoint (PPTX), Excel, ZIP...',
                          style: theme.textTheme.bodySmall,
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 24),
              ],

              // Phần nhập Metadata
              Text(
                isEditing ? 'Thông tin tài liệu' : '2. Thông tin mô tả (Lưu trên Supabase)',
                style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 12),

              // Tiêu đề tài liệu
              TextFormField(
                controller: _titleController,
                enabled: canEdit,
                decoration: InputDecoration(
                  labelText: 'Tiêu đề tài liệu *',
                  hintText: 'Nhập tiêu đề học liệu...',
                  prefixIcon: const Icon(Icons.title_rounded),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                ),
                validator: (val) {
                  if (val == null || val.trim().length < 3) {
                    return 'Tiêu đề tài liệu phải có ít nhất 3 ký tự.';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // Mô tả chi tiết
              TextFormField(
                controller: _descController,
                enabled: canEdit,
                maxLines: 4,
                decoration: InputDecoration(
                  labelText: 'Mô tả tóm tắt nội dung',
                  hintText: 'Nhập tóm tắt bài học, hướng dẫn sử dụng tài liệu...',
                  alignLabelWithHint: true,
                  prefixIcon: const Padding(
                    padding: EdgeInsets.only(bottom: 50),
                    child: Icon(Icons.description_outlined),
                  ),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),
              const SizedBox(height: 16),

              // Môn học (chỉ chỉnh sửa khi tạo mới hoặc nếu muốn giữ nguyên khi edit)
              if (!isEditing) ...[
                DropdownButtonFormField<String>(
                  value: _selectedSubject,
                  decoration: InputDecoration(
                    labelText: 'Môn học *',
                    prefixIcon: const Icon(Icons.school_outlined),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  items: AppConstants.defaultSubjects.map((s) {
                    return DropdownMenuItem(value: s, child: Text(s));
                  }).toList(),
                  onChanged: (val) {
                    if (val != null) {
                      setState(() {
                        _selectedSubject = val;
                        _isCustomSubject = (val == 'Khác (Tự nhập)');
                      });
                    }
                  },
                ),
                const SizedBox(height: 16),

                // Phân loại tài liệu
                DropdownButtonFormField<DocumentType>(
                  value: _selectedType,
                  decoration: InputDecoration(
                    labelText: 'Loại học liệu *',
                    prefixIcon: const Icon(Icons.category_outlined),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  items: DocumentType.values.map((t) {
                    return DropdownMenuItem(
                      value: t,
                      child: Text(t.displayName),
                    );
                  }).toList>,
                  onChanged: (val) {
                    if (val != null) setState(() => _selectedType = val);
                  },
                ),
                const SizedBox(height: 24),
              ],

              // Nút Submit
              SizedBox(
                width: double.infinity,
                height: 52,
                child: FilledButton.icon(
                  onPressed: (!canEdit || _isSubmitting) ? null : _submitForm,
                  icon: _isSubmitting
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                        )
                      : Icon(isEditing ? Icons.save_rounded : Icons.cloud_upload_rounded),
                  label: Text(
                    _isSubmitting
                        ? (isEditing ? 'Đang lưu thay đổi...' : 'Đang tải lên Firebase & Supabase...')
                        : (isEditing ? 'Lưu thay đổi' : 'Xác nhận nộp tài liệu'),
                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  style: FilledButton.styleFrom(
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}