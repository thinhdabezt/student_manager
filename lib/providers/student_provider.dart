import 'package:flutter/foundation.dart';
import '../models/sinhvien.dart';
import '../services/database_helper.dart';

class StudentProvider with ChangeNotifier {
  final DatabaseHelper _dbHelper = DatabaseHelper();
  List<SinhVien> _students = [];
  bool _isLoading = false;

  List<SinhVien> get students => _students;
  bool get isLoading => _isLoading;

  Future<void> fetchStudents() async {
    _isLoading = true;
    notifyListeners();
    _students = await _dbHelper.getAllSinhVien();
    _isLoading = false;
    notifyListeners();
  }

  Future<void> addStudent(SinhVien student) async {
    await _dbHelper.insertSinhVien(student);
    await fetchStudents();
  }

  Future<void> updateStudent(SinhVien student) async {
    await _dbHelper.updateSinhVien(student);
    await fetchStudents();
  }

  Future<void> deleteStudent(int id) async {
    await _dbHelper.deleteSinhVien(id);
    await fetchStudents();
  }
}
