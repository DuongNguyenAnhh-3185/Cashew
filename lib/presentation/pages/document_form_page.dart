import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_constants.dart';
import '../../domain/entities/document_entity.dart';
import '../../domain/entities/document_type.dart';
import '../controllers/document_controller.dart';

/// Man hinh Them moi hoac Chinh sua thong tin tai lieu hoc tap
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
  late final TextEditingController _urlController;
  late final TextEditingController _tagsController;
  late final TextEditingController _sizeController;
  late final TextEditingController _customSubjectController;

  late DocumentType _selectedType;
  late String _selectedSubject;
  late String _selectedFormat;
  late bool _isFavorite;
  bool _isCustomSubject = false;
  bool _isSubmitting = false;

  final List<String> _formatOptions = ['PDF', 'DOCX', 'PPTX', 'XLSX', 'ZIP', 'LINK', 'MP4'];

  @override
  void initState() {
    super.initState();
    final doc = widget.documentToEdit;

    _titleController = TextEditingController(text: doc?.title ?? '');
    _descController = TextEditingController(text: doc?.description ?? '');
    _urlController = TextEditingController(text: doc?.urlOrPath ?? '');
    _tagsController = TextEditingController(text: doc?.tags.join(', ') ?? '');
    
    // Dung luong hien thi theo MB
    final sizeInMb = doc != null ? (doc.fileSizeBytes / (1024 * 1024)).toStringAsFixed(1) : '5.0';
    _sizeController = TextEditingController(text: sizeInMb);
    _customSubjectController = TextEditingController();

    _selectedType = doc?.type ?? DocumentType.lecture;
    _selectedFormat = doc?.fileFormat.toUpperCase() ?? 'PDF';
    _isFavorite = doc?.isFavorite ?? false;

    final existingSubject = doc?.subject;
    if (existingSubject != null && AppConstants.defaultSubjects.contains(existingSubject)) {
      _selectedSubject = existingSubject;
      _isCustomSubject = false;
    } else if (existingSubject != null && existingSubject.isNotEmpty) {
      _selectedSubject = 'Khác (Tự nhập)';
      _customSubjectController.text = existingSubject;
      _isCustomSubject = true;
    } else {
      _selectedSubject = AppConstants.defaultSubjects[1];
      _isCustomSubject = false;
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descController.dispose();
    _urlController.dispose();
    _tagsController.dispose();
    _sizeController.dispose();
    _customSubjectController.dispose();
    super.dispose();
  }

  Future<void> _submitForm() async {
    if (!_formKey.currentState!.validate()) return;

    final subjectToSave = _isCustomSubject
        ? _customSubjectController.text.trim()
        : _selectedSubject;

    if (subjectToSave.isEmpty || subjectToSave == 'Tất cả') {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Vui lòng chọn hoặc nhập tên môn học hợp lệ')),
      );
      return;
    }

    setState(() => _isSubmitting = true);

    final sizeMb = double.tryParse(_sizeController.text.trim()) ?? 1.0;
    final fileSizeBytes = (sizeMb * 1024 * 1024).toInt();
    final parsedTags = widget.controller.validationService.parseTags(_tagsController.text);
    final now = DateTime.now();

    if (widget.isEditing) {
      final updatedDoc = widget.documentToEdit!.copyWith(
        title: _titleController.text.trim(),
        description: _descController.text.trim(),
        subject: subjectToSave,
        type: _selectedType,
        fileFormat: _selectedFormat,
        urlOrPath: _urlController.text.trim(),
        fileSizeBytes: fileSizeBytes,
        isFavorite: _isFavorite,
        tags: parsedTags,
        updatedAt: now,
      );

      final success = await widget.controller.updateDocument(updatedDoc);
      setState(() => _isSubmitting = false);

      if (success && mounted) {
        Navigator.of(context).pop();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Cập nhật tài liệu thành công!')),
        );
      }
    } else {
      final newDoc = DocumentEntity(
        id: const Uuid().v4(),
        title: _titleController.text.trim(),
        description: _descController.text.trim(),
        subject: subjectToSave,
        type: _selectedType,
        fileFormat: _selectedFormat,
        urlOrPath: _urlController.text.trim(),
        fileSizeBytes: fileSizeBytes,
        createdAt: now,
        updatedAt: now,
        isFavorite: _isFavorite,
        tags: parsedTags,
      );

      final success = await widget.controller.addDocument(newDoc);
      setState(() => _isSubmitting = false);

      if (success && mounted) {
        Navigator.of(context).pop();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Thêm tài liệu mới thành công!')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final subjectItems = widget.controller.availableSubjects
        .where((s) => s != 'Tất cả')
        .toList();
    if (!subjectItems.contains('Khác (Tự nhập)')) {
      subjectItems.add('Khác (Tự nhập)');
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.isEditing ? 'Chỉnh sửa tài liệu' : 'Thêm tài liệu mới'),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // Tieu de
            TextFormField(
              controller: _titleController,
              decoration: const InputDecoration(
                labelText: 'Tiêu đề tài liệu *',
                hintText: 'Ví dụ: Bài giảng Clean Architecture Chương 1',
                prefixIcon: Icon(Icons.title_rounded, color: AppColors.primary),
              ),
              validator: widget.controller.validationService.validateTitle,
              maxLines: 2,
            ),
            const SizedBox(height: 16),

            // Chon Mon hoc
            DropdownButtonFormField<String>(
              initialValue: _selectedSubject,
              decoration: const InputDecoration(
                labelText: 'Môn học *',
                prefixIcon: Icon(Icons.school_rounded, color: AppColors.primary),
              ),
              items: subjectItems.map((s) {
                return DropdownMenuItem<String>(
                  value: s,
                  child: Text(s, maxLines: 1, overflow: TextOverflow.ellipsis),
                );
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
            if (_isCustomSubject) ...[
              const SizedBox(height: 12),
              TextFormField(
                controller: _customSubjectController,
                decoration: const InputDecoration(
                  labelText: 'Nhập tên môn học mới *',
                  hintText: 'Ví dụ: Kỹ nghệ Phần mềm',
                  prefixIcon: Icon(Icons.edit_note_rounded, color: AppColors.primary),
                ),
                validator: (val) {
                  if (_isCustomSubject && (val == null || val.trim().isEmpty)) {
                    return 'Vui lòng nhập tên môn học';
                  }
                  return null;
                },
              ),
            ],
            const SizedBox(height: 16),

            // Loai tai lieu & Dinh dang tep
            Row(
              children: [
                Expanded(
                  flex: 3,
                  child: DropdownButtonFormField<DocumentType>(
                    initialValue: _selectedType,
                    decoration: const InputDecoration(
                      labelText: 'Phân loại',
                      prefixIcon: Icon(Icons.category_rounded, color: AppColors.primary),
                    ),
                    items: DocumentType.values.map((type) {
                      return DropdownMenuItem<DocumentType>(
                        value: type,
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(type.icon, size: 16, color: type.color),
                            const SizedBox(width: 8),
                            Text(type.displayName, style: const TextStyle(fontSize: 13)),
                          ],
                        ),
                      );
                    }).toList(),
                    onChanged: (val) {
                      if (val != null) setState(() => _selectedType = val);
                    },
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  flex: 2,
                  child: DropdownButtonFormField<String>(
                    initialValue: _formatOptions.contains(_selectedFormat) ? _selectedFormat : 'PDF',
                    decoration: const InputDecoration(
                      labelText: 'Định dạng',
                    ),
                    items: _formatOptions.map((fmt) {
                      return DropdownMenuItem<String>(
                        value: fmt,
                        child: Text(fmt, style: const TextStyle(fontWeight: FontWeight.w700)),
                      );
                    }).toList(),
                    onChanged: (val) {
                      if (val != null) setState(() => _selectedFormat = val);
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Dung luong & Yeu thich
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: _sizeController,
                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                    decoration: const InputDecoration(
                      labelText: 'Dung lượng (MB)',
                      hintText: '5.2',
                      prefixIcon: Icon(Icons.storage_rounded, color: AppColors.primary),
                      suffixText: 'MB',
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    decoration: BoxDecoration(
                      color: isDark ? AppColors.surfaceDark : Colors.white,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(
                        color: isDark ? AppColors.borderDark : AppColors.borderLight,
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('Yêu thích', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
                        Switch(
                          value: _isFavorite,
                          activeThumbColor: AppColors.accent,
                          onChanged: (val) => setState(() => _isFavorite = val),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Duong dan / URL
            TextFormField(
              controller: _urlController,
              decoration: const InputDecoration(
                labelText: 'Đường dẫn tệp / URL lưu trữ *',
                hintText: 'https://storage.edu.vn/... hoặc /docs/slides.pdf',
                prefixIcon: Icon(Icons.link_rounded, color: AppColors.primary),
              ),
              validator: widget.controller.validationService.validateUrlOrPath,
            ),
            const SizedBox(height: 16),

            // Tags
            TextFormField(
              controller: _tagsController,
              decoration: const InputDecoration(
                labelText: 'Thẻ phân loại (cách nhau bởi dấu phẩy)',
                hintText: 'Clean Architecture, Flutter, OOP, Bài tập lớn',
                prefixIcon: Icon(Icons.tag_rounded, color: AppColors.primary),
              ),
            ),
            const SizedBox(height: 16),

            // Mo ta
            TextFormField(
              controller: _descController,
              maxLines: 3,
              decoration: const InputDecoration(
                labelText: 'Mô tả chi tiết / Ghi chú',
                hintText: 'Tóm tắt nội dung tài liệu, nhắc nhở bài tập, kỳ thi...',
                alignLabelWithHint: true,
              ),
            ),
            const SizedBox(height: 28),

            // Nut Submit
            FilledButton.icon(
              style: FilledButton.styleFrom(
                backgroundColor: AppColors.primary,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
              ),
              icon: _isSubmitting
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                    )
                  : Icon(widget.isEditing ? Icons.save_rounded : Icons.check_circle_rounded),
              label: Text(
                widget.isEditing ? 'Lưu Thay Đổi' : 'Thêm Vào Kho Tài Liệu',
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
              ),
              onPressed: _isSubmitting ? null : _submitForm,
            ),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }
}