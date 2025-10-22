import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:student_manager/providers/auth_provider.dart';
import '../models/sinhvien.dart';
import '../providers/student_provider.dart';
import '../providers/major_provider.dart';
import '../services/image_helper.dart';
import 'dart:io';
import 'package:flutter_contacts/flutter_contacts.dart';
import '../services/contact_helper.dart';

class StudentFormScreen extends StatefulWidget {
  final SinhVien? existingStudent; // nếu có -> là chế độ sửa

  const StudentFormScreen({super.key, this.existingStudent});

  @override
  State<StudentFormScreen> createState() => _StudentFormScreenState();
}

class _StudentFormScreenState extends State<StudentFormScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _tenController;
  late TextEditingController _maSvController;
  late TextEditingController _emailController;
  late TextEditingController _sdtController;
  late TextEditingController _diaChiController;
  File? _selectedImage;
  int? _selectedMajorId;

  @override
  void initState() {
    super.initState();
    _tenController = TextEditingController(
      text: widget.existingStudent?.ten ?? '',
    );
    _maSvController = TextEditingController(
      text: widget.existingStudent?.maSv ?? '',
    );
    _emailController = TextEditingController(
      text: widget.existingStudent?.email ?? '',
    );
    _sdtController = TextEditingController(
      text: widget.existingStudent?.sdt ?? '',
    );
    _diaChiController = TextEditingController(
      text: widget.existingStudent?.diaChi ?? '',
    );
    _selectedMajorId = widget.existingStudent?.nganhId;
  }

  @override
  void dispose() {
    _tenController.dispose();
    _maSvController.dispose();
    _emailController.dispose();
    _sdtController.dispose();
    _diaChiController.dispose();
    super.dispose();
  }

  void _saveForm() async {
    if (_formKey.currentState!.validate()) {
      final newStudent = SinhVien(
        id: widget.existingStudent?.id,
        ten: _tenController.text,
        maSv: _maSvController.text,
        email: _emailController.text,
        sdt: _sdtController.text,
        diaChi: _diaChiController.text,
        nganhId: _selectedMajorId,
        avatarPath: _selectedImage?.path ?? widget.existingStudent?.avatarPath,
      );

      final studentProvider = Provider.of<StudentProvider>(
        context,
        listen: false,
      );

      if (widget.existingStudent == null) {
        await studentProvider.addStudent(newStudent);
        // Lấy lại sinh viên vừa thêm (cuối danh sách)
        final students = studentProvider.students;
        final added = students.isNotEmpty ? students.last : null;
        if (mounted) Navigator.pop(context, added?.id);
      } else {
        await studentProvider.updateStudent(newStudent);
        if (mounted) Navigator.pop(context);
      }
    }
  }

  Widget _buildImagePickerSheet(BuildContext context) {
    return SafeArea(
      child: Wrap(
        children: [
          ListTile(
            leading: const Icon(Icons.camera_alt),
            title: const Text('Chụp ảnh'),
            onTap: () async {
              final file = await ImageHelper.takePhoto();
              if (file != null) {
                setState(() => _selectedImage = file);
              }
              if (mounted) Navigator.pop(context);
            },
          ),
          ListTile(
            leading: const Icon(Icons.photo_library),
            title: const Text('Chọn từ thư viện'),
            onTap: () async {
              final file = await ImageHelper.pickFromGallery();
              if (file != null) {
                setState(() => _selectedImage = file);
              }
              if (mounted) Navigator.pop(context);
            },
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final majorProvider = Provider.of<MajorProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.existingStudent == null
              ? 'Thêm Sinh viên'
              : 'Cập nhật Sinh viên',
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              Column(
                children: [
                  GestureDetector(
                    onTap: () async {
                      showModalBottomSheet(
                        context: context,
                        builder: (_) => _buildImagePickerSheet(context),
                      );
                    },
                    child: CircleAvatar(
                      radius: 50,
                      backgroundImage: _selectedImage != null
                          ? FileImage(_selectedImage!)
                          : (widget.existingStudent?.avatarPath != null &&
                                File(
                                  widget.existingStudent!.avatarPath!,
                                ).existsSync())
                          ? FileImage(File(widget.existingStudent!.avatarPath!))
                          : const AssetImage('assets/default_avatar.png')
                                as ImageProvider,
                    ),
                  ),
                  const SizedBox(height: 12),
                  const Text('Chạm để thay đổi ảnh đại diện'),
                  const SizedBox(height: 16),
                ],
              ),
              TextFormField(
                controller: _tenController,
                decoration: const InputDecoration(labelText: 'Tên sinh viên'),
                validator: (value) =>
                    value == null || value.isEmpty ? 'Vui lòng nhập tên' : null,
              ),
              TextFormField(
                controller: _maSvController,
                decoration: const InputDecoration(labelText: 'Mã sinh viên'),
              ),
              TextFormField(
                controller: _emailController,
                decoration: const InputDecoration(labelText: 'Email'),
                validator: (value) {
                  if (value == null || value.isEmpty) return null;
                  final emailRegex = RegExp(r'^[^@]+@[^@]+\.[^@]+');
                  if (!emailRegex.hasMatch(value)) return 'Email không hợp lệ';
                  return null;
                },
              ),
              // TextFormField(
              //   controller: _sdtController,
              //   decoration: const InputDecoration(labelText: 'Số điện thoại'),
              // ),
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _sdtController,
                      keyboardType: TextInputType.phone,
                      decoration: const InputDecoration(
                        labelText: 'Số điện thoại',
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty)
                          return 'Nhập số điện thoại';
                        return null;
                      },
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.contacts),
                    tooltip: 'Chọn từ danh bạ',
                    onPressed: () async {
                      final auth = Provider.of<AuthProvider>(
                        context,
                        listen: false,
                      );
                      if (!auth.isAdmin &&
                          auth.currentUser?.sinhvienId !=
                              widget.existingStudent?.id) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text(
                              'Bạn không có quyền chỉnh sửa danh bạ',
                            ),
                          ),
                        );
                        return;
                      }
                      final contact = await ContactHelper.pickContactFromList(
                        context,
                      );
                      if (contact != null && contact.phones.isNotEmpty) {
                        setState(() {
                          _sdtController.text = contact.phones.first.number;
                        });
                      }
                    },
                  ),
                ],
              ),
              TextFormField(
                controller: _diaChiController,
                decoration: const InputDecoration(labelText: 'Địa chỉ'),
              ),
              const SizedBox(height: 12),
              FutureBuilder(
                future: majorProvider.fetchMajors(),
                builder: (context, snapshot) {
                  final majors = majorProvider.majors;
                  return DropdownButtonFormField<int>(
                    value: _selectedMajorId,
                    items: majors
                        .map(
                          (nganh) => DropdownMenuItem<int>(
                            value: nganh.id,
                            child: Text(nganh.ten),
                          ),
                        )
                        .toList(),
                    onChanged: (value) {
                      setState(() => _selectedMajorId = value);
                    },
                    decoration: const InputDecoration(labelText: 'Ngành học'),
                  );
                },
              ),
              const SizedBox(height: 20),
              ElevatedButton.icon(
                onPressed: _saveForm,
                icon: const Icon(Icons.save),
                label: const Text('Lưu'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
