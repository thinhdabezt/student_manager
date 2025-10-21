import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:student_manager/providers/auth_provider.dart';
import 'package:student_manager/screens/student_form_screen.dart';
import '../models/sinhvien.dart';
import '../services/database_helper.dart';

class StudentDetailScreen extends StatefulWidget {
  const StudentDetailScreen({super.key});

  @override
  State<StudentDetailScreen> createState() => _StudentDetailScreenState();
}

class _StudentDetailScreenState extends State<StudentDetailScreen> {
  SinhVien? _student;
  bool _loading = true;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final studentId = ModalRoute.of(context)?.settings.arguments as int;
    _loadStudent(studentId);
  }

  Future<void> _loadStudent(int id) async {
    final db = DatabaseHelper();
    final sv = await db.getSinhVienById(id);
    setState(() {
      _student = sv;
      _loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    if (_student == null) {
      return const Scaffold(
        body: Center(child: Text('Không tìm thấy sinh viên')),
      );
    }

    final sv = _student!;

    final auth = Provider.of<AuthProvider>(context);
    final currentUser = auth.currentUser;
    final isAdmin = auth.isAdmin;
    final isOwner = currentUser?.sinhvienId == sv.id;

    return Scaffold(
      appBar: AppBar(title: Text(sv.ten)),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: CircleAvatar(
                radius: 60,
                backgroundImage:
                    (sv.avatarPath != null && File(sv.avatarPath!).existsSync())
                    ? FileImage(File(sv.avatarPath!))
                    : const AssetImage('assets/default_avatar.png')
                          as ImageProvider,
              ),
            ),
            const SizedBox(height: 20),
            Text('Mã SV: ${sv.maSv ?? 'Chưa có'}'),
            Text('Email: ${sv.email ?? 'Chưa có'}'),
            Text('SĐT: ${sv.sdt ?? 'Chưa có'}'),
            Text('Địa chỉ: ${sv.diaChi ?? 'Chưa có'}'),
            Text('Ngành ID: ${sv.nganhId ?? 'Chưa có'}'),
            if (sv.lat != null && sv.lng != null)
              Text('Tọa độ: (${sv.lat}, ${sv.lng})'),
            const SizedBox(height: 20),
            if (isAdmin || isOwner)
              ElevatedButton.icon(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => StudentFormScreen(existingStudent: sv),
                    ),
                  );
                },
                icon: const Icon(Icons.edit),
                label: const Text('Chỉnh sửa thông tin'),
              ),
          ],
        ),
      ),
    );
  }
}
