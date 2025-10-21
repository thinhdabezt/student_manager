import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:student_manager/providers/student_provider.dart';
import 'package:student_manager/providers/auth_provider.dart';

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
    final studentProvider = Provider.of<StudentProvider>(context);
    final students = studentProvider.students;

    final auth = Provider.of<AuthProvider>(context);
    final isAdmin = auth.isAdmin;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Danh sách sinh viên'),
        actions: [
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
          : ListView.builder(
              itemCount: students.length,
              itemBuilder: (context, index) {
                final sv = students[index];
                return Card(
                  margin: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  child: ListTile(
                    leading: CircleAvatar(
                      radius: 25,
                      backgroundImage:
                          (sv.avatarPath != null &&
                              File(sv.avatarPath!).existsSync())
                          ? FileImage(File(sv.avatarPath!))
                          : const AssetImage('assets/default_avatar.png')
                                as ImageProvider,
                    ),
                    title: Text(
                      sv.ten,
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    subtitle: Text(sv.email ?? 'Chưa có email'),
                    trailing: IconButton(
                      icon: const Icon(Icons.delete, color: Colors.red),
                      onPressed: () async {
                        final confirm = await showDialog<bool>(
                          context: context,
                          builder: (context) => AlertDialog(
                            title: const Text('Xác nhận xóa'),
                            content: const Text(
                              'Bạn có chắc muốn xóa sinh viên này không?',
                            ),
                            actions: [
                              TextButton(
                                onPressed: () => Navigator.pop(context, false),
                                child: const Text('Hủy'),
                              ),
                              TextButton(
                                onPressed: () => Navigator.pop(context, true),
                                child: const Text(
                                  'Xóa',
                                  style: TextStyle(color: Colors.red),
                                ),
                              ),
                            ],
                          ),
                        );
                        if (confirm == true) {
                          studentProvider.deleteStudent(sv.id!);
                        }
                      },
                    ),
                    onTap: () {
                      Navigator.pushNamed(
                        context,
                        '/student_detail',
                        arguments: sv.id,
                      );
                    },
                  ),
                );
              },
            ),
      floatingActionButton: isAdmin
          ? FloatingActionButton(
              onPressed: () {
                Navigator.pushNamed(context, '/student_form');
              },
              child: const Icon(Icons.add),
            )
          : null,
    );
  }
}
