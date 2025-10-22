import 'dart:io';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:provider/provider.dart';
import 'package:student_manager/providers/auth_provider.dart';
import 'package:student_manager/providers/major_provider.dart';
import 'package:student_manager/providers/student_provider.dart';
import 'package:student_manager/screens/map_screen.dart';
import 'package:student_manager/screens/student_form_screen.dart';
import 'package:student_manager/utils/app_theme.dart';
import '../models/sinhvien.dart';
import '../services/database_helper.dart';

class StudentDetailScreen extends StatefulWidget {
  const StudentDetailScreen({super.key});

  @override
  State<StudentDetailScreen> createState() => _StudentDetailScreenState();
}

class _StudentDetailScreenState extends State<StudentDetailScreen> {
  SinhVien? _student;
  String? _majorName;
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
    
    String? majorName;
    if (sv?.nganhId != null) {
      final majorProvider = Provider.of<MajorProvider>(context, listen: false);
      await majorProvider.fetchMajors();
      majorName = majorProvider.getMajorName(sv!.nganhId);
    }
    
    setState(() {
      _student = sv;
      _majorName = majorName;
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
            _buildInfoCard(
              icon: Icons.badge,
              label: 'Mã SV',
              value: sv.maSv,
              color: AppTheme.primaryBlue,
            ),
            _buildInfoCard(
              icon: Icons.email,
              label: 'Email',
              value: sv.email,
              color: AppTheme.secondaryOrange,
            ),
            _buildInfoCard(
              icon: Icons.phone,
              label: 'SĐT',
              value: sv.sdt,
              color: AppTheme.accentGreen,
            ),
            _buildInfoCard(
              icon: Icons.location_on,
              label: 'Địa chỉ',
              value: sv.diaChi,
              color: AppTheme.primaryBlue,
            ),
            _buildInfoCard(
              icon: Icons.school,
              label: 'Ngành',
              value: _majorName ?? 'Chưa có',
              color: AppTheme.secondaryOrange,
            ),
            if (sv.latitude != null && sv.longitude != null)
              Text('Tọa độ: (${sv.latitude}, ${sv.longitude})'),
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
            if (isAdmin) ...[
              const SizedBox(height: 12),
              ElevatedButton.icon(
                onPressed: () {
                  Navigator.pushNamed(context, '/majors');
                },
                icon: const Icon(Icons.admin_panel_settings),
                label: const Text('Quản lý Ngành'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.secondaryOrange,
                ),
              ),
              const SizedBox(height: 12),
              ElevatedButton.icon(
                onPressed: () async {
                  // Show confirmation dialog
                  final confirmed = await showDialog<bool>(
                    context: context,
                    builder: (context) => AlertDialog(
                      title: const Text('Xác nhận xóa'),
                      content: Text(
                        'Bạn có chắc chắn muốn xóa sinh viên "${sv.ten}"?\n\n'
                        'Hành động này không thể hoàn tác.',
                      ),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.pop(context, false),
                          child: const Text('Hủy'),
                        ),
                        TextButton(
                          onPressed: () => Navigator.pop(context, true),
                          style: TextButton.styleFrom(
                            foregroundColor: Colors.red,
                          ),
                          child: const Text('Xóa'),
                        ),
                      ],
                    ),
                  );

                  if (confirmed == true && mounted) {
                    try {
                      await Provider.of<StudentProvider>(
                        context,
                        listen: false,
                      ).deleteStudent(sv.id!);

                      if (mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Đã xóa sinh viên thành công'),
                            backgroundColor: Colors.green,
                          ),
                        );
                        Navigator.pop(context); // Go back to student list
                      }
                    } catch (e) {
                      if (mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('Lỗi khi xóa sinh viên: $e'),
                            backgroundColor: Colors.red,
                          ),
                        );
                      }
                    }
                  }
                },
                icon: const Icon(Icons.delete),
                label: const Text('Xóa sinh viên'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                  foregroundColor: Colors.white,
                ),
              ),
            ],
            const SizedBox(height: 12),
            ElevatedButton.icon(
              onPressed: () async {
                final auth = Provider.of<AuthProvider>(context, listen: false);
                final result = await Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) =>
                        MapScreen(sinhVien: sv, isAdmin: auth.isAdmin),
                  ),
                );
                // Nếu admin cập nhật tọa độ mới
                if (auth.isAdmin && result is Map<String, dynamic>) {
                  final coordinates = result['coordinates'] as LatLng?;
                  final address = result['address'] as String?;
                  
                  if (coordinates != null) {
                    final updatedStudent = SinhVien(
                      id: sv.id,
                      ten: sv.ten,
                      maSv: sv.maSv,
                      email: sv.email,
                      sdt: sv.sdt,
                      diaChi: address ?? sv.diaChi, // Use new address if available
                      nganhId: sv.nganhId,
                      avatarPath: sv.avatarPath,
                      latitude: coordinates.latitude,
                      longitude: coordinates.longitude,
                    );
                    await Provider.of<StudentProvider>(
                      context,
                      listen: false,
                    ).updateStudent(updatedStudent);
                    
                    // Reload student data to show updated info
                    if (mounted) {
                      _loadStudent(sv.id!);
                    }
                    
                    // Show feedback
                    if (mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            address != null 
                              ? 'Đã cập nhật vị trí và địa chỉ'
                              : 'Đã cập nhật vị trí (không tìm thấy địa chỉ)',
                          ),
                          backgroundColor: address != null ? Colors.green : Colors.orange,
                        ),
                      );
                    }
                  }
                }
              },
              icon: const Icon(Icons.map),
              label: const Text('Xem vị trí trên bản đồ'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoCard({
    required IconData icon,
    required String label,
    required String value,
    required Color color,
  }) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: color.withOpacity(0.3), width: 1),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, color: color, size: 24),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey[600],
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    value,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
