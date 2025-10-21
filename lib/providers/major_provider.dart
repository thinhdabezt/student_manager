import 'package:flutter/foundation.dart';
import '../models/nganh.dart';
import '../services/database_helper.dart';

class MajorProvider with ChangeNotifier {
  final DatabaseHelper _dbHelper = DatabaseHelper();
  List<Nganh> _majors = [];

  List<Nganh> get majors => _majors;

  Future<void> fetchMajors() async {
    _majors = await _dbHelper.getAllNganh();
    notifyListeners();
  }

  Future<void> addMajor(Nganh nganh) async {
    await _dbHelper.insertNganh(nganh);
    await fetchMajors();
  }
}
