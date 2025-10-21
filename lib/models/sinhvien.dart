class SinhVien {
  final int? id;
  final String ten;
  final String? maSv;
  final String? email;
  final String? sdt;
  final String? diaChi;
  final int? nganhId;
  final String? avatarPath;
  final double? lat;
  final double? lng;

  SinhVien({
    this.id,
    required this.ten,
    this.maSv,
    this.email,
    this.sdt,
    this.diaChi,
    this.nganhId,
    this.avatarPath,
    this.lat,
    this.lng,
  });

  factory SinhVien.fromMap(Map<String, dynamic> map) {
    return SinhVien(
      id: map['id'],
      ten: map['ten'],
      maSv: map['ma_sv'],
      email: map['email'],
      sdt: map['sdt'],
      diaChi: map['dia_chi'],
      nganhId: map['nganh_id'],
      avatarPath: map['avatar_path'],
      lat: map['lat'] != null ? map['lat'] * 1.0 : null,
      lng: map['lng'] != null ? map['lng'] * 1.0 : null,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'ten': ten,
      'ma_sv': maSv,
      'email': email,
      'sdt': sdt,
      'dia_chi': diaChi,
      'nganh_id': nganhId,
      'avatar_path': avatarPath,
      'lat': lat,
      'lng': lng,
    };
  }
}
