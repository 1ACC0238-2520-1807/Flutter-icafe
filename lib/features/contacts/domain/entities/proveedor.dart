class Proveedor {
  final String id;
  final String nombre;
  final String ruc;
  final String gmail;
  final String telefono;

  Proveedor({
    required this.id,
    required this.nombre,
    required this.ruc,
    required this.gmail,
    required this.telefono,
  });

  Proveedor copyWith({
    String? id,
    String? nombre,
    String? ruc,
    String? gmail,
    String? telefono,
  }) {
    return Proveedor(
      id: id ?? this.id,
      nombre: nombre ?? this.nombre,
      ruc: ruc ?? this.ruc,
      gmail: gmail ?? this.gmail,
      telefono: telefono ?? this.telefono,
    );
  }

  factory Proveedor.fromJson(Map<String, dynamic> json) {
    return Proveedor(
      id: json['id']?.toString() ?? json['_id']?.toString() ?? '',
      nombre: json['nombre'] ?? json['nameCompany'] ?? json['name'] ?? '',
      ruc: json['ruc'] ?? '',
      gmail: json['gmail'] ?? json['email'] ?? '',
      telefono: json['telefono'] ?? json['phoneNumber'] ?? json['phone'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'nameCompany': nombre,
      'email': gmail,
      'phoneNumber': telefono,
      'ruc': ruc,
    };
  }
}


