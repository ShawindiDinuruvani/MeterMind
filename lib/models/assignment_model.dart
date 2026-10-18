class AssignmentModel {
  final String id;
  final String meterId;
  final String customerName;
  final String address;
  final String area;
  final int previousReading;
  final String previousReadingDate;
  final String dueDate;
  final String status; // 'Pending' or 'Completed'
  final double latitude;
  final double longitude;
  final int averageMonthlyUsage;
  final int sequence;

  AssignmentModel({
    required this.id,
    required this.meterId,
    required this.customerName,
    required this.address,
    required this.area,
    required this.previousReading,
    required this.previousReadingDate,
    required this.dueDate,
    this.status = 'Pending',
    required this.latitude,
    required this.longitude,
    this.averageMonthlyUsage = 312,
    this.sequence = 1,
  });

  bool get isCompleted => status == 'Completed';

  AssignmentModel copyWith({
    String? id,
    String? meterId,
    String? customerName,
    String? address,
    String? area,
    int? previousReading,
    String? previousReadingDate,
    String? dueDate,
    String? status,
    double? latitude,
    double? longitude,
    int? averageMonthlyUsage,
    int? sequence,
  }) {
    return AssignmentModel(
      id: id ?? this.id,
      meterId: meterId ?? this.meterId,
      customerName: customerName ?? this.customerName,
      address: address ?? this.address,
      area: area ?? this.area,
      previousReading: previousReading ?? this.previousReading,
      previousReadingDate: previousReadingDate ?? this.previousReadingDate,
      dueDate: dueDate ?? this.dueDate,
      status: status ?? this.status,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      averageMonthlyUsage: averageMonthlyUsage ?? this.averageMonthlyUsage,
      sequence: sequence ?? this.sequence,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'meterId': meterId,
      'customerName': customerName,
      'address': address,
      'area': area,
      'previousReading': previousReading,
      'previousReadingDate': previousReadingDate,
      'dueDate': dueDate,
      'status': status,
      'latitude': latitude,
      'longitude': longitude,
      'averageMonthlyUsage': averageMonthlyUsage,
      'sequence': sequence,
    };
  }

  factory AssignmentModel.fromMap(Map<String, dynamic> map, String docId) {
    return AssignmentModel(
      id: docId,
      meterId: map['meterId'] ?? '',
      customerName: map['customerName'] ?? '',
      address: map['address'] ?? '',
      area: map['area'] ?? '',
      previousReading: (map['previousReading'] as num?)?.toInt() ?? 0,
      previousReadingDate: map['previousReadingDate'] ?? '',
      dueDate: map['dueDate'] ?? '',
      status: map['status'] ?? 'Pending',
      latitude: (map['latitude'] as num?)?.toDouble() ?? 6.8404,
      longitude: (map['longitude'] as num?)?.toDouble() ?? 80.0034,
      averageMonthlyUsage: (map['averageMonthlyUsage'] as num?)?.toInt() ?? 312,
      sequence: (map['sequence'] as num?)?.toInt() ?? 1,
    );
  }
}
