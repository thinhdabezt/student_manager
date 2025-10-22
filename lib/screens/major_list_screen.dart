import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/major_provider.dart';
import '../utils/app_theme.dart';
import 'major_form_screen.dart';

class MajorListScreen extends StatefulWidget {
  const MajorListScreen({super.key});

  @override
  State<MajorListScreen> createState() => _MajorListScreenState();
}

class _MajorListScreenState extends State<MajorListScreen> {
  @override
  void initState() {
    super.initState();
    Future.microtask(
      () => Provider.of<MajorProvider>(context, listen: false).fetchMajors(),
    );
  }

  void _deleteMajor(BuildContext context, int id, String name) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Xác nhận xóa'),
        content: Text('Bạn có chắc muốn xóa ngành "$name"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Hủy'),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(ctx);
              try {
                await Provider.of<MajorProvider>(context, listen: false)
                    .deleteMajor(id);
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: const Text('Xóa ngành thành công'),
                      backgroundColor: AppTheme.accentGreen,
                    ),
                  );
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
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
            ),
            child: const Text('Xóa'),
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
        title: const Text('Quản lý Ngành'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => majorProvider.fetchMajors(),
          ),
        ],
      ),
      body: majorProvider.isLoading
          ? const Center(child: CircularProgressIndicator())
          : majorProvider.majors.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.school_outlined,
                        size: 80,
                        color: Colors.grey[400],
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'Chưa có ngành nào',
                        style: TextStyle(
                          fontSize: 18,
                          color: Colors.grey[600],
                        ),
                      ),
                      const SizedBox(height: 8),
                      TextButton.icon(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => const MajorFormScreen(),
                            ),
                          );
                        },
                        icon: const Icon(Icons.add),
                        label: const Text('Thêm ngành đầu tiên'),
                      ),
                    ],
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: majorProvider.majors.length,
                  itemBuilder: (context, index) {
                    final major = majorProvider.majors[index];
                    return Card(
                      margin: const EdgeInsets.only(bottom: 12),
                      elevation: 2,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                        side: BorderSide(
                          color: AppTheme.primaryBlue.withOpacity(0.3),
                          width: 1,
                        ),
                      ),
                      child: ListTile(
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 8,
                        ),
                        leading: Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: AppTheme.primaryBlue.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Icon(
                            Icons.school,
                            color: AppTheme.primaryBlue,
                          ),
                        ),
                        title: Text(
                          major.ten,
                          style: const TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 16,
                          ),
                        ),
                        subtitle: Text('ID: ${major.id}'),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              icon: Icon(
                                Icons.edit,
                                color: AppTheme.secondaryOrange,
                              ),
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => MajorFormScreen(
                                      existingMajor: major,
                                    ),
                                  ),
                                );
                              },
                            ),
                            IconButton(
                              icon: const Icon(
                                Icons.delete,
                                color: Colors.red,
                              ),
                              onPressed: () => _deleteMajor(
                                context,
                                major.id!,
                                major.ten,
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => const MajorFormScreen(),
            ),
          );
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
