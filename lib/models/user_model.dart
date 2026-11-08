enum UserRole {
  customer,
  reader,
  admin;

  String get label {
    switch (this) {
      case UserRole.customer:
        return 'Customer';
      case UserRole.reader:
        return 'Meter Reader';
      case UserRole.admin:
        return 'Admin';
    }
  }

  static UserRole fromString(String? role) {
    if (role == null) return UserRole.customer;
    final r = role.toLowerCase().trim();
    if (r == 'admin' || r == 'administrator') return UserRole.admin;
    if (r == 'reader' ||
        r == 'meter reader' ||
        r == 'meter_reader' ||
        r == 'field_officer' ||
        r == 'field officer') {
      return UserRole.reader;
    }
    return UserRole.customer;
  }
}

class UserModel {
  final String id;
  final String name;
  final String email;
  final UserRole role;
  final String status;
  final String? meterId;
  final String? employeeCode;
  final String? area;
  final String? phone;
  final DateTime? createdAt;

  UserModel({
    required this.id,
    required this.name,
    required this.email,
    required this.role,
    this.status = 'Active',
    this.meterId,
    this.employeeCode,
    this.area,
    this.phone,
    this.createdAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'role': role.name,
      'status': status,
      if (meterId != null) 'meterId': meterId,
      if (employeeCode != null) 'employeeCode': employeeCode,
      if (area != null) 'area': area,
      if (phone != null) 'phone': phone,
      'createdAt': createdAt?.toIso8601String(),
    };
  }

  factory UserModel.fromMap(Map<String, dynamic> map, String docId) {
    return UserModel(
      id: docId,
      name: map['name'] ?? '',
      email: map['email'] ?? '',
      role: UserRole.fromString(map['role']),
      status: map['status'] ?? 'Active',
      meterId: map['meterId'] ?? map['meter_id'],
      employeeCode: map['employeeCode'] ?? map['employee_code'],
      area: map['area'],
      phone: map['phone'],
      createdAt: map['createdAt'] != null
          ? (map['createdAt'] is DateTime
              ? map['createdAt']
              : DateTime.tryParse(map['createdAt'].toString()))
          : null,
    );
  }
}

