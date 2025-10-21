class Nganh {
  final int? id;
  final String ten;

  Nganh({this.id, required this.ten});

  factory Nganh.fromMap(Map<String, dynamic> map) {
    return Nganh(
      id: map['id'],
      ten: map['ten'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'ten': ten,
    };
  }
}
