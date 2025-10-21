import 'dart:convert';

import 'package:crypto/crypto.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path_provider/path_provider.dart';
import '../models/sinhvien.dart';
import '../models/nganh.dart';
import '../models/user_account.dart';

class DatabaseHelper {
  static final DatabaseHelper _instance = DatabaseHelper._();
  static Database? _database;

  DatabaseHelper._();

  factory DatabaseHelper() => _instance;

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDb();
    return _database!;
  }

  // 🧩 Khởi tạo database
  Future<Database> _initDb() async {
    final directory = await getApplicationDocumentsDirectory();
    final path = join(directory.path, 'student_manager.db');
    return await openDatabase(
      path,
      version: 2, // bump version
      onCreate: _onCreate,
      onUpgrade: _onUpgrade,
    );
  }

  // 📜 Tạo bảng
  Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE Nganh (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        ten TEXT NOT NULL
      )
    ''');

    await db.execute('''
      CREATE TABLE Sinhvien (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        ten TEXT NOT NULL,
        ma_sv TEXT,
        email TEXT,
        sdt TEXT,
        dia_chi TEXT,
        nganh_id INTEGER,
        avatar_path TEXT,
        lat REAL,
        lng REAL,
        FOREIGN KEY (nganh_id) REFERENCES Nganh(id)
      )
    ''');

    await db.execute('''
      CREATE TABLE UserAccount (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        username TEXT UNIQUE,
        password_hash TEXT,
        role TEXT DEFAULT 'student',
        sinhvien_id INTEGER,
        FOREIGN KEY (sinhvien_id) REFERENCES Sinhvien(id)
      )
    ''');

    // Seed sample data for Nganh
    int cnttId = await db.insert('Nganh', {'ten': 'Công nghệ thông tin'});
    int qtkdId = await db.insert('Nganh', {'ten': 'Quản trị kinh doanh'});

    // Seed sample data for Sinhvien
    await db.insert('Sinhvien', {
      'ten': 'Nguyễn Văn A',
      'ma_sv': 'SV001',
      'email': 'vana@example.com',
      'sdt': '0123456789',
      'dia_chi': 'Hà Nội',
      'nganh_id': cnttId,
      'avatar_path': null,
      'lat': 21.0285,
      'lng': 105.8542,
    });
    await db.insert('Sinhvien', {
      'ten': 'Trần Thị B',
      'ma_sv': 'SV002',
      'email': 'thib@example.com',
      'sdt': '0987654321',
      'dia_chi': 'Hồ Chí Minh',
      'nganh_id': qtkdId,
      'avatar_path': null,
      'lat': 10.7769,
      'lng': 106.7009,
    });

    print('Database created successfully!');
  }

  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 2) {
      // add role column with default 'student' to existing table
      await db.execute(
          "ALTER TABLE UserAccount ADD COLUMN role TEXT DEFAULT 'student'");
    }
  }

  // ===========================================
  // CRUD cho bảng NGANH
  // ===========================================

  Future<int> insertNganh(Nganh nganh) async {
    final db = await database;
    return await db.insert('Nganh', nganh.toMap());
  }

  Future<List<Nganh>> getAllNganh() async {
    final db = await database;
    final maps = await db.query('Nganh');
    return maps.map((e) => Nganh.fromMap(e)).toList();
  }

  Future<int> updateNganh(Nganh nganh) async {
    final db = await database;
    return await db.update('Nganh', nganh.toMap(), where: 'id = ?', whereArgs: [nganh.id]);
  }

  Future<int> deleteNganh(int id) async {
    final db = await database;
    return await db.delete('Nganh', where: 'id = ?', whereArgs: [id]);
  }

  // ===========================================
  // CRUD cho bảng SINHVIEN
  // ===========================================

  Future<int> insertSinhVien(SinhVien sv) async {
    final db = await database;
    return await db.insert('Sinhvien', sv.toMap());
  }

  Future<List<SinhVien>> getAllSinhVien() async {
    final db = await database;
    final maps = await db.query('Sinhvien');
    return maps.map((e) => SinhVien.fromMap(e)).toList();
  }

  Future<SinhVien?> getSinhVienById(int id) async {
    final db = await database;
    final maps = await db.query('Sinhvien', where: 'id = ?', whereArgs: [id]);
    if (maps.isNotEmpty) return SinhVien.fromMap(maps.first);
    return null;
  }

  Future<int> updateSinhVien(SinhVien sv) async {
    final db = await database;
    return await db.update('Sinhvien', sv.toMap(), where: 'id = ?', whereArgs: [sv.id]);
  }

  Future<int> deleteSinhVien(int id) async {
    final db = await database;
    return await db.delete('Sinhvien', where: 'id = ?', whereArgs: [id]);
  }

  // ===========================================
  // CRUD cho bảng USERACCOUNT
  // ===========================================

  Future<int> insertUser(UserAccount user) async {
    final db = await database;
    return await db.insert('UserAccount', user.toMap());
  }

  Future<UserAccount?> getUserByUsername(String username) async {
    final db = await database;
    final maps = await db.query('UserAccount', where: 'username = ?', whereArgs: [username]);
    if (maps.isNotEmpty) return UserAccount.fromMap(maps.first);
    return null;
  }

  Future<int> deleteUser(int id) async {
    final db = await database;
    return await db.delete('UserAccount', where: 'id = ?', whereArgs: [id]);
  }
  Future<int> registerUser(UserAccount user) async {
  final db = await database;
  return await db.insert('UserAccount', user.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace);
}

Future<UserAccount?> loginUser(String username, String password) async {
  final db = await database;
  final hash = sha256.convert(utf8.encode(password)).toString();

  final result = await db.query(
    'UserAccount',
    where: 'username = ? AND password_hash = ?',
    whereArgs: [username, hash],
  );

  if (result.isNotEmpty) {
    return UserAccount.fromMap(result.first);
  }
  return null;
}
}
