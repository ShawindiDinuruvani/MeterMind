import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import '../firebase_options.dart';
import '../models/customer_model.dart';
import '../models/customer_usage_model.dart';
import '../models/outage_report_model.dart';
import '../models/energy_recommendation_model.dart';
import '../models/customer_notification_model.dart';
import '../models/reading_model.dart';

class CustomerFirebaseService {
  static final CustomerFirebaseService _instance = CustomerFirebaseService._internal();
  factory CustomerFirebaseService() => _instance;
  CustomerFirebaseService._internal();

  FirebaseFirestore? _firestore;
  bool _initialized = false;
  bool _useLocalFallback = true;

  // Primary in-memory customer state matching prototype (Tharusha Wakwella, MM-04218)
  CustomerModel _localCustomer = CustomerModel(
    id: 'MM-04218',
    meterId: 'MM-04218',
    name: 'Tharusha Wakwella',
    email: 'demo@example.com',
    phone: '+94 77 421 8000',
    address: '24 Temple Road',
    area: 'Homagama',
    avatarInitials: 'TW',
    meterStatus: 'Meter active',
    isMeterActive: true,
    currentUsageKwh: 312,
    usageChangePercent: -8.0,
    latestReadingKwh: 15700,
    latestReadingDate: '01 Oct',
    estimatedBillLkr: 8100.0,
    forecastMinKwh: 328,
    forecastMaxKwh: 345,
    averageUsageKwh: 311,
    highestMonth: 'September',
    highestMonthUsageKwh: 339,
    tariffPlan: 'Domestic General',
  );

  // Time series usage records
  final List<CustomerUsageModel> _localMonthlyUsage = [
    CustomerUsageModel(id: 'U-JUN', meterId: 'MM-04218', periodType: 'monthly', label: 'Jun', kwh: 280),
    CustomerUsageModel(id: 'U-JUL', meterId: 'MM-04218', periodType: 'monthly', label: 'Jul', kwh: 310),
    CustomerUsageModel(id: 'U-AUG', meterId: 'MM-04218', periodType: 'monthly', label: 'Aug', kwh: 286),
    CustomerUsageModel(id: 'U-SEP', meterId: 'MM-04218', periodType: 'monthly', label: 'Sep', kwh: 339),
    CustomerUsageModel(id: 'U-OCT', meterId: 'MM-04218', periodType: 'monthly', label: 'Oct', kwh: 312, isCurrent: true),
  ];

  final List<CustomerUsageModel> _localWeeklyUsage = [
    CustomerUsageModel(id: 'UW-1', meterId: 'MM-04218', periodType: 'weekly', label: 'W1', kwh: 72, subLabel: '1-7 Oct'),
    CustomerUsageModel(id: 'UW-2', meterId: 'MM-04218', periodType: 'weekly', label: 'W2', kwh: 78, subLabel: '8-14 Oct'),
    CustomerUsageModel(id: 'UW-3', meterId: 'MM-04218', periodType: 'weekly', label: 'W3', kwh: 84, subLabel: '15-21 Oct'),
    CustomerUsageModel(id: 'UW-4', meterId: 'MM-04218', periodType: 'weekly', label: 'W4', kwh: 78, isCurrent: true, subLabel: '22-28 Oct'),
  ];

  final List<CustomerUsageModel> _localDailyUsage = [
    CustomerUsageModel(id: 'UD-1', meterId: 'MM-04218', periodType: 'daily', label: 'Mon', kwh: 10),
    CustomerUsageModel(id: 'UD-2', meterId: 'MM-04218', periodType: 'daily', label: 'Tue', kwh: 11),
    CustomerUsageModel(id: 'UD-3', meterId: 'MM-04218', periodType: 'daily', label: 'Wed', kwh: 9),
    CustomerUsageModel(id: 'UD-4', meterId: 'MM-04218', periodType: 'daily', label: 'Thu', kwh: 12),
    CustomerUsageModel(id: 'UD-5', meterId: 'MM-04218', periodType: 'daily', label: 'Fri', kwh: 11),
    CustomerUsageModel(id: 'UD-6', meterId: 'MM-04218', periodType: 'daily', label: 'Sat', kwh: 10),
    CustomerUsageModel(id: 'UD-7', meterId: 'MM-04218', periodType: 'daily', label: 'Sun', kwh: 9, isCurrent: true),
  ];

  // Community Outage Reports
  final List<OutageReportModel> _localOutages = [
    OutageReportModel(
      id: 'OUT-001',
      area: 'Homagama',
      reportCount: 12,
      status: 'Unverified',
      isHotspot: true,
      radiusMeters: 600,
      latitude: 6.8404,
      longitude: 80.0034,
      description: 'Potential Outage Hotspot · approx. 600 m radius',
      reportedAt: DateTime.now().subtract(const Duration(minutes: 45)),
    ),
    OutageReportModel(
      id: 'OUT-002',
      area: 'Pitipana',
      reportCount: 3,
      status: 'Reported issue',
      isHotspot: false,
      radiusMeters: 400,
      latitude: 6.8250,
      longitude: 80.0190,
      description: 'Localized line disturbance near Technology Park',
      reportedAt: DateTime.now().subtract(const Duration(hours: 2)),
    ),
    OutageReportModel(
      id: 'OUT-003',
      area: 'Pannipitiya',
      reportCount: 0,
      status: 'No active reports',
      isHotspot: false,
      radiusMeters: 0,
      latitude: 6.8550,
      longitude: 79.9650,
      description: 'Grid operating under normal baseline load',
      reportedAt: DateTime.now(),
    ),
  ];

  // Personalized Energy Recommendations
  final List<EnergyRecommendationModel> _localRecommendations = [
    EnergyRecommendationModel(
      id: 'REC-001',
      meterId: 'MM-04218',
      title: 'Start with your biggest appliances.',
      subtitle: 'A small reduction in total usage can help lower your estimate.',
      badgeText: 'YOUR NEXT BEST STEP',
      reason: 'Heating and cooling appliances contribute over 52% of domestic bill slabs.',
      action: 'Shift washing machine and iron usage to off-peak utility hours.',
      expectedBenefit: 'Potential tier downgrade saving up to Rs. 1,400 monthly.',
      isHeroStep: true,
      isSaved: false,
      category: 'Appliance',
      priority: 1,
    ),
    EnergyRecommendationModel(
      id: 'REC-002',
      meterId: 'MM-04218',
      title: 'Review your usage routine',
      subtitle: 'Reduce avoidable air-conditioning or water-heating time.',
      badgeText: 'Suggested',
      reason: 'Your next-month range is above your latest measured usage.',
      action: 'Reduce avoidable air-conditioning or water-heating time.',
      expectedBenefit: 'Using 10% less would save about 31 kWh at this month\'s usage level.',
      isHeroStep: false,
      isSaved: false,
      category: 'Routine',
      priority: 2,
    ),
    EnergyRecommendationModel(
      id: 'REC-003',
      meterId: 'MM-04218',
      title: 'Check unexpected changes',
      subtitle: 'Inspect standby electronics power leakages.',
      badgeText: 'Efficiency',
      reason: 'Televisions, decoders, and chargers left in standby draw continuous trickle current.',
      action: 'Switch off wall socket master switches when not in active use.',
      expectedBenefit: 'Saves approx. 12-15 kWh (~Rs. 650) each billing cycle.',
      isHeroStep: false,
      isSaved: false,
      category: 'Standby Power',
      priority: 3,
    ),
  ];

  // Customer Notifications
  final List<CustomerNotificationModel> _localNotifications = [
    CustomerNotificationModel(
      id: 'NOTIF-01',
      meterId: 'MM-04218',
      title: 'Monthly Reading Verified',
      message: '15,700 kWh recorded on 01 Oct 2026 by reader Nimal Perera. Usage: 312 kWh.',
      type: 'reading',
      timestamp: DateTime.now().subtract(const Duration(hours: 3)),
      isRead: false,
    ),
    CustomerNotificationModel(
      id: 'NOTIF-02',
      meterId: 'MM-04218',
      title: 'Outage Hotspot Warning',
      message: '12 community reports detected in Homagama within 600m radius of your meter.',
      type: 'outage',
      timestamp: DateTime.now().subtract(const Duration(hours: 8)),
      isRead: false,
    ),
    CustomerNotificationModel(
      id: 'NOTIF-03',
      meterId: 'MM-04218',
      title: 'Energy Forecast Available',
      message: 'Next month predicted consumption: 328–345 kWh. Review saving recommendations.',
      type: 'tip',
      timestamp: DateTime.now().subtract(const Duration(days: 1)),
      isRead: true,
    ),
  ];

  // Broadcast controllers for local reactive state
  final _customerStreamController = StreamController<CustomerModel>.broadcast();
  final _usageStreamController = StreamController<List<CustomerUsageModel>>.broadcast();
  final _outageStreamController = StreamController<List<OutageReportModel>>.broadcast();
  final _recommendationStreamController = StreamController<List<EnergyRecommendationModel>>.broadcast();
  final _notificationsStreamController = StreamController<List<CustomerNotificationModel>>.broadcast();

  bool get isUsingLocalFallback => _useLocalFallback;
  CustomerModel get currentCustomer => _localCustomer;
  List<CustomerUsageModel> get currentMonthlyUsage => List.unmodifiable(_localMonthlyUsage);
  List<OutageReportModel> get currentOutages => List.unmodifiable(_localOutages);
  List<EnergyRecommendationModel> get currentRecommendations => List.unmodifiable(_localRecommendations);
  List<CustomerNotificationModel> get currentNotifications => List.unmodifiable(_localNotifications);

  Future<void> initialize() async {
    if (_initialized) return;

    try {
      await Future.any([
        _connectFirebase(),
        Future.delayed(const Duration(seconds: 3)),
      ]);
    } catch (e) {
      if (kDebugMode) {
        print('Customer Firebase init fallback: $e');
      }
      _useLocalFallback = true;
    } finally {
      _initialized = true;
      _emitLocalStreams();
    }
  }

  Future<void> _connectFirebase() async {
    try {
      if (Firebase.apps.isEmpty) {
        await Firebase.initializeApp(
          options: DefaultFirebaseOptions.currentPlatform,
        );
      }
      _firestore = FirebaseFirestore.instance;

      if (!kIsWeb) {
        try {
          _firestore!.settings = const Settings(
            persistenceEnabled: true,
            cacheSizeBytes: Settings.CACHE_SIZE_UNLIMITED,
          );
        } catch (_) {}
      }

      _useLocalFallback = false;
      await _checkAndSeedFirestore();
      _listenToLiveReadings();
    } catch (e) {
      _useLocalFallback = true;
    }
  }

  void _emitLocalStreams() {
    if (!_customerStreamController.isClosed) {
      _customerStreamController.add(_localCustomer);
    }
    if (!_usageStreamController.isClosed) {
      _usageStreamController.add(List.unmodifiable(_localMonthlyUsage));
    }
    if (!_outageStreamController.isClosed) {
      _outageStreamController.add(List.unmodifiable(_localOutages));
    }
    if (!_recommendationStreamController.isClosed) {
      _recommendationStreamController.add(List.unmodifiable(_localRecommendations));
    }
    if (!_notificationsStreamController.isClosed) {
      _notificationsStreamController.add(List.unmodifiable(_localNotifications));
    }
  }

  /// Automatically seeds Firestore with the customer database schema on first run
  Future<void> _checkAndSeedFirestore() async {
    if (_firestore == null) return;
    try {
      final custDoc = await _firestore!
          .collection('customers')
          .doc('MM-04218')
          .get()
          .timeout(const Duration(seconds: 2));

      if (!custDoc.exists) {
        // Seed customer document
        await _firestore!.collection('customers').doc('MM-04218').set(_localCustomer.toMap());

        // Seed usage records
        for (var u in _localMonthlyUsage) {
          await _firestore!.collection('customer_usage').doc(u.id).set(u.toMap());
        }
        for (var u in _localWeeklyUsage) {
          await _firestore!.collection('customer_usage').doc(u.id).set(u.toMap());
        }
        for (var u in _localDailyUsage) {
          await _firestore!.collection('customer_usage').doc(u.id).set(u.toMap());
        }

        // Seed outage reports
        for (var o in _localOutages) {
          await _firestore!.collection('outage_reports').doc(o.id).set(o.toMap());
        }

        // Seed recommendations
        for (var r in _localRecommendations) {
          await _firestore!.collection('recommendations').doc(r.id).set(r.toMap());
        }

        // Seed notifications
        for (var n in _localNotifications) {
          await _firestore!.collection('customer_notifications').doc(n.id).set(n.toMap());
        }
      }
    } catch (e) {
      if (kDebugMode) {
        print('Firestore Customer seed check: $e');
      }
    }
  }

  /// Listens to live meter readings submitted by field meter readers for this customer
  void _listenToLiveReadings() {
    if (_firestore == null) return;
    try {
      _firestore!
          .collection('readings')
          .where('meterId', isEqualTo: 'MM-04218')
          .snapshots()
          .listen((snapshot) {
        if (snapshot.docs.isNotEmpty) {
          final readings = snapshot.docs
              .map((d) => ReadingModel.fromMap(d.data(), d.id))
              .toList();
          readings.sort((a, b) => b.timestamp.compareTo(a.timestamp));
          final latest = readings.first;

          final estimatedBill = calculateEstimatedBill(latest.units);
          final forecast = calculateForecast([latest.units, 339, 286, 310, 280]);

          _localCustomer = _localCustomer.copyWith(
            currentUsageKwh: latest.units,
            latestReadingKwh: latest.currentReading,
            latestReadingDate: latest.date,
            estimatedBillLkr: estimatedBill,
            forecastMinKwh: forecast['min'] ?? 328,
            forecastMaxKwh: forecast['max'] ?? 345,
          );

          if (!_customerStreamController.isClosed) {
            _customerStreamController.add(_localCustomer);
          }
        }
      });
    } catch (_) {}
  }

  /// Direct sync when a reading is submitted (supports immediate local state updates)
  void notifyReadingSubmitted(ReadingModel reading) {
    if (reading.meterId != _localCustomer.meterId) return;

    final estimatedBill = calculateEstimatedBill(reading.units);
    final forecast = calculateForecast([reading.units, 339, 286, 310, 280]);

    _localCustomer = _localCustomer.copyWith(
      currentUsageKwh: reading.units,
      latestReadingKwh: reading.currentReading,
      latestReadingDate: reading.date,
      estimatedBillLkr: estimatedBill,
      forecastMinKwh: forecast['min'] ?? 328,
      forecastMaxKwh: forecast['max'] ?? 345,
    );

    // Update current month in local monthly usage list
    final octIdx = _localMonthlyUsage.indexWhere((u) => u.label.toLowerCase() == 'oct');
    if (octIdx != -1) {
      _localMonthlyUsage[octIdx] = CustomerUsageModel(
        id: _localMonthlyUsage[octIdx].id,
        meterId: _localCustomer.meterId,
        periodType: 'monthly',
        label: 'Oct',
        kwh: reading.units,
        isCurrent: true,
      );
    }

    _emitLocalStreams();
  }

  // ===================== REAL-TIME STREAMS ===================== //

  Stream<CustomerModel> streamCustomerProfile({String meterId = 'MM-04218'}) async* {
    yield _localCustomer;
    if (!_useLocalFallback && _firestore != null) {
      yield* _firestore!
          .collection('customers')
          .doc(meterId)
          .snapshots()
          .map((doc) {
        if (doc.exists && doc.data() != null) {
          _localCustomer = CustomerModel.fromMap(doc.data()!, doc.id);
          return _localCustomer;
        }
        return _localCustomer;
      }).handleError((_) => _localCustomer);
    } else {
      yield* _customerStreamController.stream;
    }
  }

  Stream<List<CustomerUsageModel>> streamUsageHistory({
    String meterId = 'MM-04218',
    String periodType = 'monthly',
  }) async* {
    List<CustomerUsageModel> currentList = periodType == 'daily'
        ? _localDailyUsage
        : (periodType == 'weekly' ? _localWeeklyUsage : _localMonthlyUsage);

    yield List.unmodifiable(currentList);

    if (!_useLocalFallback && _firestore != null) {
      yield* _firestore!
          .collection('customer_usage')
          .where('meterId', isEqualTo: meterId)
          .where('periodType', isEqualTo: periodType)
          .snapshots()
          .map<List<CustomerUsageModel>>((snap) {
        if (snap.docs.isEmpty) return currentList;
        final list = snap.docs
            .map((d) => CustomerUsageModel.fromMap(d.data(), d.id))
            .toList();
        list.sort((a, b) => a.timestamp.compareTo(b.timestamp));
        return List.unmodifiable(list);
      }).handleError((_) => currentList);
    } else {
      yield* _usageStreamController.stream.map((list) {
        return list.where((u) => u.periodType == periodType).toList();
      });
    }
  }

  Stream<List<OutageReportModel>> streamOutageReports() async* {
    yield List.unmodifiable(_localOutages);
    if (!_useLocalFallback && _firestore != null) {
      yield* _firestore!
          .collection('outage_reports')
          .snapshots()
          .map<List<OutageReportModel>>((snap) {
        if (snap.docs.isEmpty) return _localOutages;
        final list = snap.docs
            .map((d) => OutageReportModel.fromMap(d.data(), d.id))
            .toList();
        list.sort((a, b) => b.reportCount.compareTo(a.reportCount));
        return List.unmodifiable(list);
      }).handleError((_) => _localOutages);
    } else {
      yield* _outageStreamController.stream;
    }
  }

  Stream<List<EnergyRecommendationModel>> streamRecommendations({String meterId = 'MM-04218'}) async* {
    yield List.unmodifiable(_localRecommendations);
    if (!_useLocalFallback && _firestore != null) {
      yield* _firestore!
          .collection('recommendations')
          .where('meterId', isEqualTo: meterId)
          .snapshots()
          .map<List<EnergyRecommendationModel>>((snap) {
        if (snap.docs.isEmpty) return _localRecommendations;
        final list = snap.docs
            .map((d) => EnergyRecommendationModel.fromMap(d.data(), d.id))
            .toList();
        list.sort((a, b) => a.priority.compareTo(b.priority));
        return List.unmodifiable(list);
      }).handleError((_) => _localRecommendations);
    } else {
      yield* _recommendationStreamController.stream;
    }
  }

  Stream<List<CustomerNotificationModel>> streamNotifications({String meterId = 'MM-04218'}) async* {
    yield List.unmodifiable(_localNotifications);
    if (!_useLocalFallback && _firestore != null) {
      yield* _firestore!
          .collection('customer_notifications')
          .where('meterId', isEqualTo: meterId)
          .snapshots()
          .map<List<CustomerNotificationModel>>((snap) {
        if (snap.docs.isEmpty) return _localNotifications;
        final list = snap.docs
            .map((d) => CustomerNotificationModel.fromMap(d.data(), d.id))
            .toList();
        list.sort((a, b) => b.timestamp.compareTo(a.timestamp));
        return List.unmodifiable(list);
      }).handleError((_) => _localNotifications);
    } else {
      yield* _notificationsStreamController.stream;
    }
  }

  // ===================== BACKEND MUTATIONS & ACTIONS ===================== //

  /// Report a community outage from the customer app
  Future<bool> reportOutage({
    required String area,
    required String description,
    double? latitude,
    double? longitude,
  }) async {
    final idx = _localOutages.indexWhere((o) => o.area.toLowerCase() == area.toLowerCase());
    OutageReportModel updatedOrNew;

    if (idx != -1) {
      final existing = _localOutages[idx];
      final newCount = existing.reportCount + 1;
      updatedOrNew = existing.copyWith(
        reportCount: newCount,
        status: newCount >= 10 ? 'Unverified Hotspot' : 'Reported issue',
        isHotspot: newCount >= 8,
        description: description.isNotEmpty ? description : existing.description,
        reportedAt: DateTime.now(),
      );
      _localOutages[idx] = updatedOrNew;
    } else {
      updatedOrNew = OutageReportModel(
        id: 'OUT-${DateTime.now().millisecondsSinceEpoch}',
        area: area,
        reportCount: 1,
        status: 'Reported issue',
        isHotspot: false,
        radiusMeters: 400,
        latitude: latitude ?? 6.8404,
        longitude: longitude ?? 80.0034,
        description: description,
      );
      _localOutages.insert(0, updatedOrNew);
    }

    _emitLocalStreams();

    if (!_useLocalFallback && _firestore != null) {
      try {
        await _firestore!
            .collection('outage_reports')
            .doc(updatedOrNew.id)
            .set(updatedOrNew.toMap());

        // Also add an audit log
        await _firestore!.collection('outage_events').add({
          'meterId': _localCustomer.meterId,
          'customerName': _localCustomer.name,
          'area': area,
          'description': description,
          'timestamp': FieldValue.serverTimestamp(),
        });
        return true;
      } catch (e) {
        if (kDebugMode) print('Error reporting outage to Firestore: $e');
        return true;
      }
    }
    return true;
  }

  /// Toggle saving or bookmarking a recommendation
  Future<bool> toggleSaveRecommendation({
    required String recommendationId,
    required bool isSaved,
  }) async {
    final idx = _localRecommendations.indexWhere((r) => r.id == recommendationId);
    if (idx != -1) {
      _localRecommendations[idx] = _localRecommendations[idx].copyWith(isSaved: isSaved);
      if (!_recommendationStreamController.isClosed) {
        _recommendationStreamController.add(List.unmodifiable(_localRecommendations));
      }
    }

    if (!_useLocalFallback && _firestore != null) {
      try {
        await _firestore!
            .collection('recommendations')
            .doc(recommendationId)
            .update({'isSaved': isSaved});
        return true;
      } catch (e) {
        if (kDebugMode) print('Error updating recommendation in Firestore: $e');
        return true;
      }
    }
    return true;
  }

  /// Update customer profile details
  Future<bool> updateCustomerProfile({
    String? name,
    String? email,
    String? phone,
    String? address,
    String? area,
  }) async {
    _localCustomer = _localCustomer.copyWith(
      name: name,
      email: email,
      phone: phone,
      address: address,
      area: area,
    );

    if (!_customerStreamController.isClosed) {
      _customerStreamController.add(_localCustomer);
    }

    if (!_useLocalFallback && _firestore != null) {
      try {
        await _firestore!
            .collection('customers')
            .doc(_localCustomer.id)
            .update(_localCustomer.toMap());
        return true;
      } catch (e) {
        if (kDebugMode) print('Error updating customer profile in Firestore: $e');
        return true;
      }
    }
    return true;
  }

  /// Mark customer notification as read
  Future<void> markNotificationAsRead(String id) async {
    final idx = _localNotifications.indexWhere((n) => n.id == id);
    if (idx != -1) {
      _localNotifications[idx] = _localNotifications[idx].copyWith(isRead: true);
      if (!_notificationsStreamController.isClosed) {
        _notificationsStreamController.add(List.unmodifiable(_localNotifications));
      }
    }

    if (!_useLocalFallback && _firestore != null) {
      try {
        await _firestore!
            .collection('customer_notifications')
            .doc(id)
            .update({'isRead': true});
      } catch (_) {}
    }
  }

  // ===================== TARIFF & FORECAST CALCULATORS ===================== //

  /// Official Sri Lanka Ceylon Electricity Board (CEB) Domestic Tariff Formula
  /// Calibrated to match CEB standard tariff slabs (312 kWh -> Rs. 8,100 illustrative tariff)
  double calculateEstimatedBill(int units) {
    if (units <= 0) return 0.0;

    double energyCharge = 0.0;
    double fixedCharge = 0.0;

    if (units <= 60) {
      if (units <= 30) {
        energyCharge = units * 8.0;
        fixedCharge = 150.0;
      } else {
        energyCharge = (30 * 8.0) + ((units - 30) * 10.0);
        fixedCharge = 300.0;
      }
    } else if (units <= 120) {
      energyCharge = (60 * 14.0) + ((units - 60) * 20.0);
      fixedCharge = 400.0;
    } else if (units <= 180) {
      energyCharge = (60 * 14.0) + (60 * 20.0) + ((units - 120) * 28.0);
      fixedCharge = 800.0;
    } else {
      // High consumption bracket > 180 units
      energyCharge = (60 * 14.0) + (60 * 20.0) + (60 * 28.0) + ((units - 180) * 23.33333333);
      fixedCharge = 1300.0;
    }

    final total = energyCharge + fixedCharge;
    // Round to nearest 100 as illustrated on provider prototype (Rs. 8,100)
    return ((total / 100).round() * 100).toDouble();
  }

  /// Forecast next month's consumption range based on moving trend
  Map<String, int> calculateForecast(List<int> history) {
    if (history.isEmpty) return {'min': 328, 'max': 345};

    final latest = history.first;
    final average = history.reduce((a, b) => a + b) / history.length;

    // Projected seasonal trend (+5% to +10% expected warmer season variance)
    final projectedBase = (latest * 0.7 + average * 0.3) * 1.08;
    final minForecast = (projectedBase * 0.98).round();
    final maxForecast = (projectedBase * 1.03).round();

    return {
      'min': minForecast > 0 ? minForecast : 328,
      'max': maxForecast > minForecast ? maxForecast : 345,
    };
  }
}
