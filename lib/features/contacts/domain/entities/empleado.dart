class Empleado {
  final String id;
  final String nombre;
  final String rol;
  final String gmail;
  final String telefono;
  final String sueldo;
  final int? branchId;

  Empleado({
    required this.id,
    required this.nombre,
    required this.rol,
    required this.gmail,
    required this.telefono,
    required this.sueldo,
    this.branchId,
  });

  Empleado copyWith({
    String? id,
    String? nombre,
    String? rol,
    String? gmail,
    String? telefono,
    String? sueldo,
    int? branchId,
  }) {
    return Empleado(
      id: id ?? this.id,
      nombre: nombre ?? this.nombre,
      rol: rol ?? this.rol,
      gmail: gmail ?? this.gmail,
      telefono: telefono ?? this.telefono,
      sueldo: sueldo ?? this.sueldo,
      branchId: branchId ?? this.branchId,
    );
  }

  factory Empleado.fromJson(Map<String, dynamic> json) {
    return Empleado(
      id: json['id']?.toString() ?? json['_id']?.toString() ?? '',
      nombre: json['nombre'] ?? json['name'] ?? '',
      rol: json['rol'] ?? json['role'] ?? '',
      gmail: json['gmail'] ?? json['email'] ?? '',
      telefono: json['telefono'] ?? json['phoneNumber'] ?? json['phone'] ?? '',
      sueldo: json['sueldo']?.toString() ?? json['salary']?.toString() ?? '',
      branchId: json['branchId'] is int ? json['branchId'] : (json['branchId'] != null ? int.tryParse(json['branchId'].toString()) : null),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': nombre,
      'email': gmail,
      'phoneNumber': telefono,
      'role': rol,
      'salary': sueldo,
      if (branchId != null) 'branchId': branchId,
    };
  }
}


