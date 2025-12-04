class EmployeeResource {
  final int id;
  final String name;
  final String email;
  final String phoneNumber;
  final String role;
  final String salary;
  final int branchId;

  EmployeeResource({
    required this.id,
    required this.name,
    required this.email,
    required this.phoneNumber,
    required this.role,
    required this.salary,
    required this.branchId,
  });

  factory EmployeeResource.fromJson(Map<String, dynamic> json) {
    return EmployeeResource(
      id: json['id'],
      name: json['name'],
      email: json['email'],
      phoneNumber: json['phoneNumber'],
      role: json['role'],
      salary: json['salary'],
      branchId: json['branchId'],
    );
  }
}

class EmployeeRequest {
  final String name;
  final String email;
  final String phoneNumber;
  final String role;
  final String salary;
  final int branchId;

  EmployeeRequest({
    required this.name,
    required this.email,
    required this.phoneNumber,
    required this.role,
    required this.salary,
    required this.branchId,
  });

  Map<String, dynamic> toJson() => {
    'name': name,
    'email': email,
    'phoneNumber': phoneNumber,
    'role': role,
    'salary': salary,
    'branchId': branchId,
  };
}

// ==========================================
//               PROVIDERS
// ==========================================

class ProviderResource {
  final int id;
  final String nameCompany;
  final String email;
  final String phoneNumber;
  final String ruc;

  ProviderResource({
    required this.id,
    required this.nameCompany,
    required this.email,
    required this.phoneNumber,
    required this.ruc,
  });

  factory ProviderResource.fromJson(Map<String, dynamic> json) {
    return ProviderResource(
      id: json['id'],
      nameCompany: json['nameCompany'],
      email: json['email'],
      phoneNumber: json['phoneNumber'],
      ruc: json['ruc'],
    );
  }
}

class ProviderRequest {
  final String nameCompany;
  final String email;
  final String phoneNumber;
  final String ruc;

  ProviderRequest({
    required this.nameCompany,
    required this.email,
    required this.phoneNumber,
    required this.ruc,
  });

  Map<String, dynamic> toJson() => {
    'nameCompany': nameCompany,
    'email': email,
    'phoneNumber': phoneNumber,
    'ruc': ruc,
  };
}