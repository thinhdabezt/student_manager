import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/nganh.dart';
import '../providers/major_provider.dart';
import '../utils/app_theme.dart';

class MajorFormScreen extends StatefulWidget {
  final Nganh? existingMajor;

  const MajorFormScreen({super.key, this.existingMajor});

  @override
  State<MajorFormScreen> createState() => _MajorFormScreenState();
}

class _MajorFormScreenState extends State<MajorFormScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _tenController;

  @override
  void initState() {
    super.initState();
    _tenController = TextEditingController(text: widget.existingMajor?.ten ?? '');
  }

  @override
  void dispose() {
    _tenController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (_formKey.currentState!.validate()) {
      final majorProvider = Provider.of<MajorProvider>(context, listen: false);
      
      final nganh = Nganh(
        id: widget.existingMajor?.id,
        ten: _tenController.text.trim(),
      );

      try {
        if (widget.existingMajor == null) {
          await majorProvider.addMajor(nganh);
        } else {
          await majorProvider.updateMajor(nganh);
        }

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                widget.existingMajor == null
                    ? 'Thêm ngành thành công'
                    : 'Cập nhật ngành thành công',
              ),
              backgroundColor: AppTheme.accentGreen,
            ),
          );
          Navigator.pop(context);
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Lỗi: $e'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isEdit = widget.existingMajor != null;

    return Scaffold(
      appBar: AppBar(
        title: Text(isEdit ? 'Chỉnh sửa ngành' : 'Thêm ngành mới'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Card(
                elevation: 2,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      Icon(
                        Icons.school,
                        size: 64,
                        color: AppTheme.primaryBlue,
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _tenController,
                        decoration: const InputDecoration(
                          labelText: 'Tên ngành',
                          prefixIcon: Icon(Icons.label),
                          hintText: 'Ví dụ: Công nghệ thông tin',
                        ),
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Vui lòng nhập tên ngành';
                          }
                          return null;
                        },
                        textCapitalization: TextCapitalization.words,
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),
              ElevatedButton.icon(
                onPressed: _save,
                icon: Icon(isEdit ? Icons.save : Icons.add),
                label: Text(isEdit ? 'Lưu thay đổi' : 'Thêm ngành'),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
