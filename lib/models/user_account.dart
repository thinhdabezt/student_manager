class UserAccount {
  final int? id;
  final String username;
  final String passwordHash;
  final String role; // 'admin' hoặc 'student'
  final int? sinhvienId;

  UserAccount({
    this.id,
    required this.username,
    required this.passwordHash,
    this.role = 'student',
    this.sinhvienId,
  });

  factory UserAccount.fromMap(Map<String, dynamic> map) {
    return UserAccount(
      id: map['id'],
      username: map['username'],
      passwordHash: map['password_hash'],
      role: map['role'] ?? 'student',
      sinhvienId: map['sinhvien_id'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'username': username,
      'password_hash': passwordHash,
      'role': role,
      'sinhvien_id': sinhvienId,
    };
  }
}
