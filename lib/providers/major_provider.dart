import 'package:flutter/foundation.dart';
import '../models/nganh.dart';
import '../services/database_helper.dart';

class MajorProvider with ChangeNotifier {
  final DatabaseHelper _dbHelper = DatabaseHelper();
  List<Nganh> _majors = [];
  bool _isLoading = false;

  List<Nganh> get majors => _majors;
  bool get isLoading => _isLoading;

  Future<void> fetchMajors() async {
    _isLoading = true;
    notifyListeners();
    _majors = await _dbHelper.getAllNganh();
    _isLoading = false;
    notifyListeners();
  }

  Future<Nganh?> getMajorById(int id) async {
    return await _dbHelper.getNganhById(id);
  }

  Future<void> addMajor(Nganh nganh) async {
    await _dbHelper.insertNganh(nganh);
    await fetchMajors();
  }

  Future<void> updateMajor(Nganh nganh) async {
    await _dbHelper.updateNganh(nganh);
    await fetchMajors();
  }

  Future<void> deleteMajor(int id) async {
    await _dbHelper.deleteNganh(id);
    await fetchMajors();
  }

  Future<int> getStudentCountByMajorId(int majorId) async {
    return await _dbHelper.getStudentCountByMajorId(majorId);
  }

  String? getMajorName(int? id) {
    if (id == null) return null;
    try {
      return _majors.firstWhere((m) => m.id == id).ten;
    } catch (e) {
      return null;
    }
  }
}
