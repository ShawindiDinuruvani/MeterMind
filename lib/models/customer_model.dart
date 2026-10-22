class CustomerModel {
  final String id;
  final String meterId;
  final String name;
  final String email;
  final String phone;
  final String address;
  final String area;
  final String avatarInitials;
  final String meterStatus; // e.g. 'Meter active'
  final bool isMeterActive;
  final int currentUsageKwh;
  final double usageChangePercent; // e.g. -8.0
  final int latestReadingKwh;
  final String latestReadingDate; // e.g. '01 Oct'
  final double estimatedBillLkr; // e.g. 8100.0
  final int forecastMinKwh; // e.g. 328
  final int forecastMaxKwh; // e.g. 345
  final int averageUsageKwh; // e.g. 311
  final String highestMonth; // e.g. 'September'
  final int highestMonthUsageKwh; // e.g. 339
  final String tariffPlan; // e.g. 'Domestic General'
  final DateTime lastUpdated;

  CustomerModel({
    required this.id,
    required this.meterId,
    required this.name,
    required this.email,
    required this.phone,
    required this.address,
    required this.area,
    required this.avatarInitials,
    this.meterStatus = 'Meter active',
    this.isMeterActive = true,
    this.currentUsageKwh = 312,
    this.usageChangePercent = -8.0,
    this.latestReadingKwh = 15700,
    this.latestReadingDate = '01 Oct',
    this.estimatedBillLkr = 8100.0,
    this.forecastMinKwh = 328,
    this.forecastMaxKwh = 345,
    this.averageUsageKwh = 311,
    this.highestMonth = 'September',
    this.highestMonthUsageKwh = 339,
    this.tariffPlan = 'Domestic General',
    DateTime? lastUpdated,
  }) : lastUpdated = lastUpdated ?? DateTime.now();

  CustomerModel copyWith({
    String? id,
    String? meterId,
    String? name,
    String? email,
    String? phone,
    String? address,
    String? area,
    String? avatarInitials,
    String? meterStatus,
    bool? isMeterActive,
    int? currentUsageKwh,
    double? usageChangePercent,
    int? latestReadingKwh,
    String? latestReadingDate,
    double? estimatedBillLkr,
    int? forecastMinKwh,
    int? forecastMaxKwh,
    int? averageUsageKwh,
    String? highestMonth,
    int? highestMonthUsageKwh,
    String? tariffPlan,
    DateTime? lastUpdated,
  }) {
    return CustomerModel(
      id: id ?? this.id,
      meterId: meterId ?? this.meterId,
      name: name ?? this.name,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      address: address ?? this.address,
      area: area ?? this.area,
      avatarInitials: avatarInitials ?? this.avatarInitials,
      meterStatus: meterStatus ?? this.meterStatus,
      isMeterActive: isMeterActive ?? this.isMeterActive,
      currentUsageKwh: currentUsageKwh ?? this.currentUsageKwh,
      usageChangePercent: usageChangePercent ?? this.usageChangePercent,
      latestReadingKwh: latestReadingKwh ?? this.latestReadingKwh,
      latestReadingDate: latestReadingDate ?? this.latestReadingDate,
      estimatedBillLkr: estimatedBillLkr ?? this.estimatedBillLkr,
      forecastMinKwh: forecastMinKwh ?? this.forecastMinKwh,
      forecastMaxKwh: forecastMaxKwh ?? this.forecastMaxKwh,
      averageUsageKwh: averageUsageKwh ?? this.averageUsageKwh,
      highestMonth: highestMonth ?? this.highestMonth,
      highestMonthUsageKwh: highestMonthUsageKwh ?? this.highestMonthUsageKwh,
      tariffPlan: tariffPlan ?? this.tariffPlan,
      lastUpdated: lastUpdated ?? this.lastUpdated,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'meterId': meterId,
      'name': name,
      'email': email,
      'phone': phone,
      'address': address,
      'area': area,
      'avatarInitials': avatarInitials,
      'meterStatus': meterStatus,
      'isMeterActive': isMeterActive,
      'currentUsageKwh': currentUsageKwh,
      'usageChangePercent': usageChangePercent,
      'latestReadingKwh': latestReadingKwh,
      'latestReadingDate': latestReadingDate,
      'estimatedBillLkr': estimatedBillLkr,
      'forecastMinKwh': forecastMinKwh,
      'forecastMaxKwh': forecastMaxKwh,
      'averageUsageKwh': averageUsageKwh,
      'highestMonth': highestMonth,
      'highestMonthUsageKwh': highestMonthUsageKwh,
      'tariffPlan': tariffPlan,
      'lastUpdated': lastUpdated.toIso8601String(),
    };
  }

  factory CustomerModel.fromMap(Map<String, dynamic> map, String docId) {
    return CustomerModel(
      id: docId,
      meterId: map['meterId'] ?? docId,
      name: map['name'] ?? '',
      email: map['email'] ?? '',
      phone: map['phone'] ?? '',
      address: map['address'] ?? '',
      area: map['area'] ?? '',
      avatarInitials: map['avatarInitials'] ?? 'TW',
      meterStatus: map['meterStatus'] ?? 'Meter active',
      isMeterActive: map['isMeterActive'] ?? true,
      currentUsageKwh: (map['currentUsageKwh'] as num?)?.toInt() ?? 312,
      usageChangePercent: (map['usageChangePercent'] as num?)?.toDouble() ?? -8.0,
      latestReadingKwh: (map['latestReadingKwh'] as num?)?.toInt() ?? 15700,
      latestReadingDate: map['latestReadingDate'] ?? '01 Oct',
      estimatedBillLkr: (map['estimatedBillLkr'] as num?)?.toDouble() ?? 8100.0,
      forecastMinKwh: (map['forecastMinKwh'] as num?)?.toInt() ?? 328,
      forecastMaxKwh: (map['forecastMaxKwh'] as num?)?.toInt() ?? 345,
      averageUsageKwh: (map['averageUsageKwh'] as num?)?.toInt() ?? 311,
      highestMonth: map['highestMonth'] ?? 'September',
      highestMonthUsageKwh: (map['highestMonthUsageKwh'] as num?)?.toInt() ?? 339,
      tariffPlan: map['tariffPlan'] ?? 'Domestic General',
      lastUpdated: _parseDateTime(map['lastUpdated']),
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
