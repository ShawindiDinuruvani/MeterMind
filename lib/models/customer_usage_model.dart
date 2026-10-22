class CustomerUsageModel {
  final String id;
  final String meterId;
  final String periodType; // 'monthly', 'weekly', 'daily'
  final String label; // e.g. 'Jun', 'Jul', 'Aug', 'Sep', 'Oct' or 'Mon', 'Tue'
  final int kwh;
  final bool isCurrent;
  final String? subLabel;
  final DateTime timestamp;

  CustomerUsageModel({
    required this.id,
    required this.meterId,
    required this.periodType,
    required this.label,
    required this.kwh,
    this.isCurrent = false,
    this.subLabel,
    DateTime? timestamp,
  }) : timestamp = timestamp ?? DateTime.now();

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'meterId': meterId,
      'periodType': periodType,
      'label': label,
      'kwh': kwh,
      'isCurrent': isCurrent,
      'subLabel': subLabel,
      'timestamp': timestamp.toIso8601String(),
    };
  }

  factory CustomerUsageModel.fromMap(Map<String, dynamic> map, String docId) {
    return CustomerUsageModel(
      id: docId,
      meterId: map['meterId'] ?? '',
      periodType: map['periodType'] ?? 'monthly',
      label: map['label'] ?? '',
      kwh: (map['kwh'] as num?)?.toInt() ?? 0,
      isCurrent: map['isCurrent'] ?? false,
      subLabel: map['subLabel'],
      timestamp: _parseDateTime(map['timestamp']),
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
