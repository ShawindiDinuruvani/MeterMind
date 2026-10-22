class OutageReportModel {
  final String id;
  final String area;
  final int reportCount;
  final String status; // 'Unverified', 'Reported issue', 'No active reports', 'Restored'
  final bool isHotspot;
  final int radiusMeters;
  final double latitude;
  final double longitude;
  final String description;
  final DateTime reportedAt;
  final String? reportedBy;

  OutageReportModel({
    required this.id,
    required this.area,
    required this.reportCount,
    required this.status,
    this.isHotspot = false,
    this.radiusMeters = 600,
    required this.latitude,
    required this.longitude,
    required this.description,
    DateTime? reportedAt,
    this.reportedBy,
  }) : reportedAt = reportedAt ?? DateTime.now();

  OutageReportModel copyWith({
    String? id,
    String? area,
    int? reportCount,
    String? status,
    bool? isHotspot,
    int? radiusMeters,
    double? latitude,
    double? longitude,
    String? description,
    DateTime? reportedAt,
    String? reportedBy,
  }) {
    return OutageReportModel(
      id: id ?? this.id,
      area: area ?? this.area,
      reportCount: reportCount ?? this.reportCount,
      status: status ?? this.status,
      isHotspot: isHotspot ?? this.isHotspot,
      radiusMeters: radiusMeters ?? this.radiusMeters,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      description: description ?? this.description,
      reportedAt: reportedAt ?? this.reportedAt,
      reportedBy: reportedBy ?? this.reportedBy,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'area': area,
      'reportCount': reportCount,
      'status': status,
      'isHotspot': isHotspot,
      'radiusMeters': radiusMeters,
      'latitude': latitude,
      'longitude': longitude,
      'description': description,
      'reportedAt': reportedAt.toIso8601String(),
      'reportedBy': reportedBy,
    };
  }

  factory OutageReportModel.fromMap(Map<String, dynamic> map, String docId) {
    return OutageReportModel(
      id: docId,
      area: map['area'] ?? '',
      reportCount: (map['reportCount'] as num?)?.toInt() ?? 0,
      status: map['status'] ?? 'Unverified',
      isHotspot: map['isHotspot'] ?? false,
      radiusMeters: (map['radiusMeters'] as num?)?.toInt() ?? 600,
      latitude: (map['latitude'] as num?)?.toDouble() ?? 6.8404,
      longitude: (map['longitude'] as num?)?.toDouble() ?? 80.0034,
      description: map['description'] ?? '',
      reportedAt: _parseDateTime(map['reportedAt']),
      reportedBy: map['reportedBy'],
    );
  }

  static DateTime _parseDateTime(dynamic val) {
    if (val == null) return DateTime.now();
    if (val is DateTime) return val;
    try {
      return (val as dynamic).toDate() as DateTime;
    } catch (_) {}
    if (val is String) {
      return DateTime.tryParse(val) ?? DateTime.now();
    }
    if (val is num) {
      return DateTime.fromMillisecondsSinceEpoch(val.toInt());
    }
    return DateTime.now();
  }
}
