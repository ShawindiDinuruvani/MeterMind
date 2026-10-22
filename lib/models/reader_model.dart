class ReaderModel {
  final String id;
  final String name;
  final String employeeCode;
  final String area;
  final String email;
  final int assignedCount;
  final int completedCount;
  final int pendingCount;
  final double completionPercentage;

  ReaderModel({
    required this.id,
    required this.name,
    required this.employeeCode,
    required this.area,
    required this.email,
    this.assignedCount = 40,
    this.completedCount = 28,
    this.pendingCount = 12,
  }) : completionPercentage = assignedCount > 0 ? (completedCount / assignedCount) * 100 : 0.0;

  ReaderModel copyWith({
    String? id,
    String? name,
    String? employeeCode,
    String? area,
    String? email,
    int? assignedCount,
    int? completedCount,
    int? pendingCount,
  }) {
    return ReaderModel(
      id: id ?? this.id,
      name: name ?? this.name,
      employeeCode: employeeCode ?? this.employeeCode,
      area: area ?? this.area,
      email: email ?? this.email,
      assignedCount: assignedCount ?? this.assignedCount,
      completedCount: completedCount ?? this.completedCount,
      pendingCount: pendingCount ?? this.pendingCount,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'employeeCode': employeeCode,
      'area': area,
      'email': email,
      'assignedCount': assignedCount,
      'completedCount': completedCount,
      'pendingCount': pendingCount,
    };
  }

  factory ReaderModel.fromMap(Map<String, dynamic> map, String docId) {
    return ReaderModel(
      id: docId,
      name: map['name'] ?? 'Nimal Perera',
      employeeCode: map['employeeCode'] ?? 'MR001',
      area: map['area'] ?? 'Homagama',
      email: map['email'] ?? 'nimal.perera@metermind.lk',
      assignedCount: (map['assignedCount'] as num?)?.toInt() ?? 40,
      completedCount: (map['completedCount'] as num?)?.toInt() ?? 28,
      pendingCount: (map['pendingCount'] as num?)?.toInt() ?? 12,
    );
  }
}
