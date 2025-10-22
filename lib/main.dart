import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:student_manager/providers/auth_provider.dart';
import 'package:student_manager/providers/major_provider.dart';
import 'package:student_manager/providers/student_provider.dart';
import 'package:student_manager/screens/major_list_screen.dart';
import 'package:student_manager/screens/student_detail_screen.dart';
import 'package:student_manager/screens/student_form_screen.dart';
import 'package:student_manager/utils/app_theme.dart';
import 'screens/login_screen.dart';
import 'screens/student_list_screen.dart';

void main() {
  runApp(const StudentManagerApp());
}

class StudentManagerApp extends StatelessWidget {
  const StudentManagerApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
      ChangeNotifierProvider(create: (_) => StudentProvider()),
      ChangeNotifierProvider(create: (_) => MajorProvider()),
      ],
      child: MaterialApp(
        title: 'Quản lý Sinh viên',
        theme: AppTheme.lightTheme,
        initialRoute: '/login',
        routes: {
          '/login': (context) => const LoginScreen(),
          '/students': (context) => const StudentListScreen(),
          '/student_detail': (context) => const StudentDetailScreen(),
          '/student_form': (context) => const StudentFormScreen(),
          '/majors': (context) => const MajorListScreen(),
        },
      ),
    );
  }
}
