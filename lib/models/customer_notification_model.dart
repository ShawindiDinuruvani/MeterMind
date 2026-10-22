class CustomerNotificationModel {
  final String id;
  final String meterId;
  final String title;
  final String message;
  final String type; // 'reading', 'outage', 'billing', 'tip'
  final DateTime timestamp;
  final bool isRead;

  CustomerNotificationModel({
    required this.id,
    required this.meterId,
    required this.title,
    required this.message,
    this.type = 'reading',
    DateTime? timestamp,
    this.isRead = false,
  }) : timestamp = timestamp ?? DateTime.now();

  CustomerNotificationModel copyWith({
    String? id,
    String? meterId,
    String? title,
    String? message,
    String? type,
    DateTime? timestamp,
    bool? isRead,
  }) {
    return CustomerNotificationModel(
      id: id ?? this.id,
      meterId: meterId ?? this.meterId,
      title: title ?? this.title,
      message: message ?? this.message,
      type: type ?? this.type,
      timestamp: timestamp ?? this.timestamp,
      isRead: isRead ?? this.isRead,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'meterId': meterId,
      'title': title,
      'message': message,
      'type': type,
      'timestamp': timestamp.toIso8601String(),
      'isRead': isRead,
    };
  }

  factory CustomerNotificationModel.fromMap(Map<String, dynamic> map, String docId) {
    return CustomerNotificationModel(
      id: docId,
      meterId: map['meterId'] ?? '',
      title: map['title'] ?? '',
      message: map['message'] ?? '',
      type: map['type'] ?? 'reading',
      timestamp: _parseDateTime(map['timestamp']),
      isRead: map['isRead'] ?? false,
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
