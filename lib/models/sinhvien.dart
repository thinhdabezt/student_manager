class SinhVien {
  final int? id;
  final String ten;
  final String maSv;
  final String email;
  final String sdt;
  final String diaChi;
  final int? nganhId;
  final String? avatarPath;
  final double? latitude;
  final double? longitude;

  SinhVien({
    this.id,
    required this.ten,
    required this.maSv,
    required this.email,
    required this.sdt,
    required this.diaChi,
    this.nganhId,
    this.avatarPath,
    this.latitude,
    this.longitude,
  });

  Map<String, dynamic> toMap() => {
        'id': id,
        'ten': ten,
        'ma_sv': maSv,
        'email': email,
        'sdt': sdt,
        'dia_chi': diaChi,
        'nganh_id': nganhId,
        'avatar_path': avatarPath,
        'latitude': latitude,
        'longitude': longitude,
      };

  factory SinhVien.fromMap(Map<String, dynamic> map) => SinhVien(
        id: map['id'],
        ten: map['ten'],
        maSv: map['ma_sv'],
        email: map['email'],
        sdt: map['sdt'],
        diaChi: map['dia_chi'],
        nganhId: map['nganh_id'],
        avatarPath: map['avatar_path'],
        latitude: map['latitude']?.toDouble(),
        longitude: map['longitude']?.toDouble(),
      );
}
