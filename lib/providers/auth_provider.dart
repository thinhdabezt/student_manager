import 'package:flutter/foundation.dart';
import '../services/database_helper.dart';
import '../models/user_account.dart';
import 'package:crypto/crypto.dart';
import 'dart:convert';

class AuthProvider with ChangeNotifier {
  final DatabaseHelper _dbHelper = DatabaseHelper();
  UserAccount? _currentUser;

  UserAccount? get currentUser => _currentUser;
  bool get isLoggedIn => _currentUser != null;
  bool get isAdmin => _currentUser?.role == 'admin';

  Future<bool> login(String username, String password) async {
    final hash = sha256.convert(utf8.encode(password)).toString();
    final db = await _dbHelper.database;

    final result = await db.query(
      'UserAccount',
      where: 'username = ? AND password_hash = ?',
      whereArgs: [username, hash],
    );

    if (result.isNotEmpty) {
      _currentUser = UserAccount.fromMap(result.first);
      notifyListeners();
      return true;
    }
    return false;
  }

  Future<bool> register(String username, String password, {String role = 'student'}) async {
    final hash = sha256.convert(utf8.encode(password)).toString();
    final user = UserAccount(username: username, passwordHash: hash, role: role);
    await _dbHelper.registerUser(user);
    return true;
  }

  void logout() {
    _currentUser = null;
    notifyListeners();
  }
}
