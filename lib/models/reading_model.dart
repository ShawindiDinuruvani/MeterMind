class ReadingModel {
  final String id;
  final String meterId;
  final String customerName;
  final String readerId;
  final String readerName;
  final int previousReading;
  final int currentReading;
  final int units;
  final String date;
  final DateTime timestamp;
  final String status; // 'Submitted' or 'Verified'
  final String note;
  final bool isAnomaly;
  final String? anomalyReason;
  final double aiConfidence;
  final String? photoPath;

  ReadingModel({
    required this.id,
    required this.meterId,
    required this.customerName,
    required this.readerId,
    required this.readerName,
    required this.previousReading,
    required this.currentReading,
    required this.units,
    required this.date,
    required this.timestamp,
    this.status = 'Submitted',
    this.note = '',
    this.isAnomaly = false,
    this.anomalyReason,
    this.aiConfidence = 0.98,
    this.photoPath,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'meterId': meterId,
      'customerName': customerName,
      'readerId': readerId,
      'readerName': readerName,
      'previousReading': previousReading,
      'currentReading': currentReading,
      'units': units,
      'date': date,
      'timestamp': timestamp.toIso8601String(),
      'status': status,
      'note': note,
      'isAnomaly': isAnomaly,
      'anomalyReason': anomalyReason,
      'aiConfidence': aiConfidence,
      'photoPath': photoPath,
    };
  }

  factory ReadingModel.fromMap(Map<String, dynamic> map, String docId) {
    return ReadingModel(
      id: docId,
      meterId: map['meterId'] ?? '',
      customerName: map['customerName'] ?? '',
      readerId: map['readerId'] ?? '',
      readerName: map['readerName'] ?? '',
      previousReading: (map['previousReading'] as num?)?.toInt() ?? 0,
      currentReading: (map['currentReading'] as num?)?.toInt() ?? 0,
      units: (map['units'] as num?)?.toInt() ?? 0,
      date: map['date'] ?? '',
      timestamp: _parseDateTime(map['timestamp']),
      status: map['status'] ?? 'Submitted',
      note: map['note'] ?? '',
      isAnomaly: map['isAnomaly'] ?? false,
      anomalyReason: map['anomalyReason'],
      aiConfidence: (map['aiConfidence'] as num?)?.toDouble() ?? 0.98,
      photoPath: map['photoPath'],
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

