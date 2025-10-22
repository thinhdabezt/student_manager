import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:student_manager/providers/student_provider.dart';
import 'package:student_manager/providers/auth_provider.dart';
import 'package:student_manager/screens/student_form_screen.dart';
import 'package:student_manager/utils/app_theme.dart';

class StudentListScreen extends StatefulWidget {
  const StudentListScreen({super.key});

  @override
  State<StudentListScreen> createState() => _StudentListScreenState();
}

class _StudentListScreenState extends State<StudentListScreen> {
  @override
  void initState() {
    super.initState();
    Future.microtask(
      () =>
          Provider.of<StudentProvider>(context, listen: false).fetchStudents(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final auth = Provider.of<AuthProvider>(context);
    final studentProvider = Provider.of<StudentProvider>(context);
    final isAdmin = auth.isAdmin;
    final currentUser = auth.currentUser;
    final students = studentProvider.students;

    final myStudent = currentUser?.sinhvienId != null
        ? students.firstWhere(
            (sv) => sv.id == currentUser!.sinhvienId,
            orElse: () => null as dynamic, // tránh lỗi nếu chưa có
          )
        : null;

    final otherStudents = students
        .where((sv) => sv.id != myStudent?.id)
        .toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Danh sách sinh viên'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            tooltip: 'Đăng xuất',
            onPressed: () {
              final auth = Provider.of<AuthProvider>(context, listen: false);
              auth.logout();
              Navigator.pushReplacementNamed(context, '/login');
            },
          ),
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => studentProvider.fetchStudents(),
          ),
        ],
      ),
      body: studentProvider.isLoading
          ? const Center(child: CircularProgressIndicator())
          : students.isEmpty
          ? const Center(child: Text('Chưa có sinh viên nào'))
          : ListView(
              padding: const EdgeInsets.all(8),
              children: [
                if (myStudent != null) ...[
                  Container(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    child: Row(
                      children: [
                        Icon(Icons.person, color: AppTheme.accentGreen),
                        const SizedBox(width: 8),
                        const Text(
                          'Hồ sơ của tôi',
                          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 8),
                  Card(
                    elevation: 4,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                      side: BorderSide(color: AppTheme.accentGreen, width: 2),
                    ),
                    child: ListTile(
                      leading: CircleAvatar(
                        backgroundImage: myStudent.avatarPath != null
                            ? FileImage(File(myStudent.avatarPath!))
                            : const AssetImage('assets/default_avatar.png')
                                  as ImageProvider,
                      ),
                      title: Text(myStudent.ten),
                      subtitle: Text(myStudent.maSv),
                      onTap: () {
                        Navigator.pushNamed(
                          context,
                          '/student_detail',
                          arguments: myStudent.id,
                        );
                      },
                      trailing: IconButton(
                        icon: const Icon(Icons.edit),
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) =>
                                  StudentFormScreen(existingStudent: myStudent),
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                ],
                isAdmin
                    ? const Text(
                        '📋 Tất cả sinh viên',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      )
                    : const Text(
                        '👥 Sinh viên khác',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                const SizedBox(height: 8),
                ...otherStudents.map(
                  (sv) => Card(
                    child: ListTile(
                      leading: CircleAvatar(
                        backgroundImage:
                            (sv.avatarPath != null &&
                                File(sv.avatarPath!).existsSync())
                            ? FileImage(File(sv.avatarPath!))
                            : const AssetImage('assets/default_avatar.png')
                                  as ImageProvider,
                      ),
                      title: Text(sv.ten),
                      subtitle: Text(sv.maSv),
                      onTap: () {
                        Navigator.pushNamed(
                          context,
                          '/student_detail',
                          arguments: sv.id,
                        );
                      },
                    ),
                  ),
                ),
              ],
            ),
      floatingActionButton: isAdmin
          ? FloatingActionButton(
              onPressed: () {
                Navigator.pushNamed(context, '/student_form');
              },
              child: const Icon(Icons.add),
            )
          : (currentUser?.role == 'student' && currentUser?.sinhvienId == null)
          ? FloatingActionButton.extended(
              onPressed: () async {
                // student chưa có hồ sơ => tạo mới
                final result = await Navigator.pushNamed(
                  context,
                  '/student_form',
                );
                if (result is int) {
                  // sau khi thêm sinh viên, gắn ID vào tài khoản
                  await Provider.of<AuthProvider>(
                    context,
                    listen: false,
                  ).linkSinhvienToCurrentUser(result);
                }
              },
              icon: const Icon(Icons.person_add),
              label: const Text('Tạo hồ sơ của tôi'),
            )
          : null,
    );
  }
}
