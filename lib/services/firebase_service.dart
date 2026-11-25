import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import '../firebase_options.dart';
import '../models/assignment_model.dart';
import '../models/reading_model.dart';
import '../models/reader_model.dart';
import '../models/user_model.dart';
import 'auth_service.dart';
import 'customer_firebase_service.dart';

class FirebaseService {
  static final FirebaseService _instance = FirebaseService._internal();
  factory FirebaseService() => _instance;
  FirebaseService._internal() {
    _loadLocalCache();
  }

  FirebaseFirestore? _firestore;
  bool _initialized = false;
  bool _useLocalFallback = true; // Default to true until Firebase confirms connection

  // In-memory fallback state to ensure instantaneous, 100% reliable local/offline operation
  ReaderModel _localReader = ReaderModel(
    id: 'MR001',
    name: 'Nimal Perera',
    employeeCode: 'MR001',
    area: 'Homagama',
    email: 'nimal.perera@metermind.lk',
    assignedCount: 40,
    completedCount: 28,
    pendingCount: 12,
  );

  final List<AssignmentModel> _localAssignments = [
    AssignmentModel(
      id: 'MM-04218',
      meterId: 'MM-04218',
      customerName: 'Tharusha Wakwella',
      address: '24 Temple Road, Homagama',
      area: 'Homagama',
      previousReading: 15700,
      previousReadingDate: '01 Oct 2026',
      dueDate: '04 Oct 2026',
      status: 'Pending',
      latitude: 6.8404,
      longitude: 80.0034,
      averageMonthlyUsage: 312,
      sequence: 1,
    ),
    AssignmentModel(
      id: 'MM-02816',
      meterId: 'MM-02816',
      customerName: 'S. Fernando',
      address: '18 Station Road, Homagama',
      area: 'Homagama',
      previousReading: 12450,
      previousReadingDate: '01 Oct 2026',
      dueDate: '04 Oct 2026',
      status: 'Pending',
      latitude: 6.8420,
      longitude: 80.0080,
      averageMonthlyUsage: 295,
      sequence: 2,
    ),
    AssignmentModel(
      id: 'MM-01825',
      meterId: 'MM-01825',
      customerName: 'D. Jayasinghe',
      address: '7 High Level Road, Homagama',
      area: 'Homagama',
      previousReading: 21980,
      previousReadingDate: '01 Oct 2026',
      dueDate: '04 Oct 2026',
      status: 'Completed',
      latitude: 6.8375,
      longitude: 79.9980,
      averageMonthlyUsage: 340,
      sequence: 3,
    ),
    AssignmentModel(
      id: 'MM-05120',
      meterId: 'MM-05120',
      customerName: 'K. Bandara',
      address: '42 Sunethra Devi Road, Homagama',
      area: 'Homagama',
      previousReading: 9840,
      previousReadingDate: '01 Oct 2026',
      dueDate: '04 Oct 2026',
      status: 'Pending',
      latitude: 6.8445,
      longitude: 80.0055,
      averageMonthlyUsage: 280,
      sequence: 4,
    ),
    AssignmentModel(
      id: 'MM-06331',
      meterId: 'MM-06331',
      customerName: 'M. Perera',
      address: '11 Lake View Gardens, Homagama',
      area: 'Homagama',
      previousReading: 18200,
      previousReadingDate: '01 Oct 2026',
      dueDate: '04 Oct 2026',
      status: 'Pending',
      latitude: 6.8350,
      longitude: 80.0120,
      averageMonthlyUsage: 310,
      sequence: 5,
    ),
  ];

  final List<ReadingModel> _localReadings = [
    ReadingModel(
      id: 'R-001',
      meterId: 'MM-04218',
      customerName: 'Tharusha Wakwella',
      readerId: 'MR001',
      readerName: 'Nimal Perera',
      previousReading: 15388,
      currentReading: 15700,
      units: 312,
      date: '01 Oct 2026',
      timestamp: DateTime(2026, 10, 1, 10, 30),
      status: 'Verified',
      note: 'Routine monthly reading. Seal intact.',
      aiConfidence: 0.99,
    ),
    ReadingModel(
      id: 'R-002',
      meterId: 'MM-04218',
      customerName: 'Tharusha Wakwella',
      readerId: 'MR001',
      readerName: 'Nimal Perera',
      previousReading: 15049,
      currentReading: 15388,
      units: 339,
      date: '01 Sep 2026',
      timestamp: DateTime(2026, 9, 1, 11, 15),
      status: 'Verified',
      note: 'Normal cycle.',
      aiConfidence: 0.98,
    ),
    ReadingModel(
      id: 'R-003',
      meterId: 'MM-04218',
      customerName: 'Tharusha Wakwella',
      readerId: 'MR001',
      readerName: 'Nimal Perera',
      previousReading: 14763,
      currentReading: 15049,
      units: 286,
      date: '01 Aug 2026',
      timestamp: DateTime(2026, 8, 1, 9, 45),
      status: 'Verified',
      note: 'Normal cycle.',
      aiConfidence: 0.99,
    ),
  ];

  final _readerStreamController = StreamController<ReaderModel>.broadcast();
  final _assignmentsStreamController = StreamController<List<AssignmentModel>>.broadcast();
  final _readingsStreamController = StreamController<List<ReadingModel>>.broadcast();

  bool get isUsingLocalFallback => _useLocalFallback;
  ReaderModel get currentReader => _localReader;
  List<AssignmentModel> get currentAssignments => List.unmodifiable(_localAssignments);
  List<ReadingModel> get currentReadings => List.unmodifiable(_localReadings);

  File _getCacheFile() {
    return File('${Directory.systemTemp.path}/metermind_readings_cache.json');
  }

  void _loadLocalCache() {
    if (kIsWeb) return;
    try {
      final file = _getCacheFile();
      if (file.existsSync()) {
        final content = file.readAsStringSync();
        if (content.isNotEmpty) {
          final List<dynamic> jsonList = jsonDecode(content);
          for (var item in jsonList) {
            final reading = ReadingModel.fromMap(
              Map<String, dynamic>.from(item as Map),
              item['id']?.toString() ?? '',
            );
            final rIdx = _localReadings.indexWhere((r) => r.id == reading.id);
            if (rIdx == -1) {
              _localReadings.insert(0, reading);
            } else {
              _localReadings[rIdx] = reading;
            }
            final aIdx = _localAssignments.indexWhere((a) => a.meterId == reading.meterId);
            if (aIdx != -1 && _localAssignments[aIdx].status != 'Completed') {
              _localAssignments[aIdx] = _localAssignments[aIdx].copyWith(status: 'Completed');
              final newComp = _localReader.completedCount + 1;
              _localReader = _localReader.copyWith(
                completedCount: newComp,
                pendingCount: (_localReader.assignedCount - newComp).clamp(0, _localReader.assignedCount),
              );
            }
          }
        }
      }
    } catch (_) {}
  }

  void _saveLocalCache() {
    if (kIsWeb) return;
    try {
      final file = _getCacheFile();
      final data = jsonEncode(_localReadings.map((r) => r.toMap()).toList());
      file.writeAsStringSync(data);
    } catch (_) {}
  }

  @visibleForTesting
  void resetForTesting() {
    _localReader = ReaderModel(
      id: 'MR001',
      name: 'Nimal Perera',
      employeeCode: 'MR001',
      area: 'Homagama',
      email: 'nimal.perera@metermind.lk',
      assignedCount: 40,
      completedCount: 28,
      pendingCount: 12,
    );
    _localAssignments.clear();
    _localAssignments.addAll([
      AssignmentModel(
        id: 'MM-04218',
        meterId: 'MM-04218',
        customerName: 'Tharusha Wakwella',
        address: '24 Temple Road, Homagama',
        area: 'Homagama',
        previousReading: 15700,
        previousReadingDate: '01 Oct 2026',
        dueDate: '04 Oct 2026',
        status: 'Pending',
        latitude: 6.8404,
        longitude: 80.0034,
        averageMonthlyUsage: 312,
        sequence: 1,
      ),
      AssignmentModel(
        id: 'MM-02816',
        meterId: 'MM-02816',
        customerName: 'S. Fernando',
        address: '18 Station Road, Homagama',
        area: 'Homagama',
        previousReading: 12450,
        previousReadingDate: '01 Oct 2026',
        dueDate: '04 Oct 2026',
        status: 'Pending',
        latitude: 6.8420,
        longitude: 80.0080,
        averageMonthlyUsage: 295,
        sequence: 2,
      ),
      AssignmentModel(
        id: 'MM-01825',
        meterId: 'MM-01825',
        customerName: 'D. Jayasinghe',
        address: '7 High Level Road, Homagama',
        area: 'Homagama',
        previousReading: 21980,
        previousReadingDate: '01 Oct 2026',
        dueDate: '04 Oct 2026',
        status: 'Completed',
        latitude: 6.8375,
        longitude: 79.9980,
        averageMonthlyUsage: 340,
        sequence: 3,
      ),
      AssignmentModel(
        id: 'MM-05120',
        meterId: 'MM-05120',
        customerName: 'K. Bandara',
        address: '42 Sunethra Devi Road, Homagama',
        area: 'Homagama',
        previousReading: 9840,
        previousReadingDate: '01 Oct 2026',
        dueDate: '04 Oct 2026',
        status: 'Pending',
        latitude: 6.8445,
        longitude: 80.0055,
        averageMonthlyUsage: 280,
        sequence: 4,
      ),
      AssignmentModel(
        id: 'MM-06331',
        meterId: 'MM-06331',
        customerName: 'M. Perera',
        address: '11 Lake View Gardens, Homagama',
        area: 'Homagama',
        previousReading: 18200,
        previousReadingDate: '01 Oct 2026',
        dueDate: '04 Oct 2026',
        status: 'Pending',
        latitude: 6.8350,
        longitude: 80.0120,
        averageMonthlyUsage: 310,
        sequence: 5,
      ),
    ]);
    _localReadings.clear();
    _localReadings.addAll([
      ReadingModel(
        id: 'R-001',
        meterId: 'MM-04218',
        customerName: 'Tharusha Wakwella',
        readerId: 'MR001',
        readerName: 'Nimal Perera',
        previousReading: 15388,
        currentReading: 15700,
        units: 312,
        date: '01 Oct 2026',
        timestamp: DateTime(2026, 10, 1, 10, 30),
        status: 'Verified',
        note: 'Routine monthly reading. Seal intact.',
        aiConfidence: 0.99,
      ),
      ReadingModel(
        id: 'R-002',
        meterId: 'MM-04218',
        customerName: 'Tharusha Wakwella',
        readerId: 'MR001',
        readerName: 'Nimal Perera',
        previousReading: 15049,
        currentReading: 15388,
        units: 339,
        date: '01 Sep 2026',
        timestamp: DateTime(2026, 9, 1, 11, 15),
        status: 'Verified',
        note: 'Normal cycle.',
        aiConfidence: 0.98,
      ),
      ReadingModel(
        id: 'R-003',
        meterId: 'MM-04218',
        customerName: 'Tharusha Wakwella',
        readerId: 'MR001',
        readerName: 'Nimal Perera',
        previousReading: 14763,
        currentReading: 15049,
        units: 286,
        date: '01 Aug 2026',
        timestamp: DateTime(2026, 8, 1, 9, 45),
        status: 'Verified',
        note: 'Normal cycle.',
        aiConfidence: 0.99,
      ),
    ]);
    try {
      final file = _getCacheFile();
      if (file.existsSync()) {
        file.deleteSync();
      }
    } catch (_) {}
  }

  Future<void> initialize() async {
    if (_initialized) return;

    try {
      // Connect to Firebase with a strict 3-second safety timeout so it never blocks UI
      await Future.any([
        _connectFirebase(),
        Future.delayed(const Duration(seconds: 3)),
      ]);
    } catch (e) {
      if (kDebugMode) {
        print('Firebase init note: $e');
      }
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

      // Persistence is only supported on mobile/desktop, not web
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
    } catch (e) {
      _useLocalFallback = true;
    }
  }

  void _emitLocalStreams() {
    if (!_readerStreamController.isClosed) {
      _readerStreamController.add(_localReader);
    }
    if (!_assignmentsStreamController.isClosed) {
      _assignmentsStreamController.add(List.unmodifiable(_localAssignments));
    }
    if (!_readingsStreamController.isClosed) {
      _readingsStreamController.add(List.unmodifiable(_localReadings));
    }
  }

  Future<void> _checkAndSeedFirestore() async {
    if (_firestore == null) return;
    try {
      final readerDoc = await _firestore!
          .collection('meter_readers')
          .doc('MR001')
          .get()
          .timeout(const Duration(seconds: 2));

      if (!readerDoc.exists) {
        // Seed Reader
        await _firestore!.collection('meter_readers').doc('MR001').set(_localReader.toMap());

        // Seed Assignments
        for (var a in _localAssignments) {
          await _firestore!.collection('assignments').doc(a.id).set(a.toMap());
        }

        // Seed Readings
        for (var r in _localReadings) {
          await _firestore!.collection('readings').doc(r.id).set(r.toMap());
        }
      }
    } catch (e) {
      if (kDebugMode) {
        print('Firestore seed offline check: $e');
      }
    }
  }

  // Streams with immediate yield of in-memory data
  Stream<ReaderModel> streamReaderProfile() async* {
    final currentUser = AuthService.instance.currentUser;
    if (currentUser != null && currentUser.role == UserRole.reader) {
      _localReader = _localReader.copyWith(
        id: currentUser.employeeCode ?? currentUser.id,
        name: currentUser.name.isNotEmpty ? currentUser.name : _localReader.name,
        employeeCode: currentUser.employeeCode ?? _localReader.employeeCode,
        area: currentUser.area ?? _localReader.area,
        email: currentUser.email,
      );
    }
    yield _localReader;

    final readerDocId = _localReader.employeeCode.isNotEmpty ? _localReader.employeeCode : 'MR001';

    if (!_useLocalFallback && _firestore != null) {
      yield* _firestore!.collection('meter_readers').doc(readerDocId).snapshots().map((doc) {
        if (doc.exists && doc.data() != null) {
          _localReader = ReaderModel.fromMap(doc.data()!, doc.id);
          return _localReader;
        }
        return _localReader;
      }).handleError((_) => _localReader);
    } else {
      yield* _readerStreamController.stream;
    }
  }

  Stream<List<AssignmentModel>> streamAssignments() async* {
    yield List.unmodifiable(_localAssignments);
    if (!_useLocalFallback && _firestore != null) {
      yield* _firestore!
          .collection('assignments')
          .orderBy('sequence')
          .snapshots()
          .map<List<AssignmentModel>>((snap) {
        if (snap.docs.isEmpty) return _localAssignments;
        _localAssignments.clear();
        _localAssignments.addAll(
          snap.docs.map((d) => AssignmentModel.fromMap(d.data(), d.id)),
        );
        return List<AssignmentModel>.unmodifiable(_localAssignments);
      }).handleError((_) => _localAssignments);
    } else {
      yield* _assignmentsStreamController.stream;
    }
  }

  Stream<List<ReadingModel>> streamReadings({String? meterId}) async* {
    if (meterId != null) {
      yield List.unmodifiable(_localReadings.where((r) => r.meterId == meterId).toList());
    } else {
      yield List.unmodifiable(_localReadings);
    }

    if (!_useLocalFallback && _firestore != null) {
      Query<Map<String, dynamic>> query = _firestore!.collection('readings');
      if (meterId != null) {
        query = query.where('meterId', isEqualTo: meterId);
      }

      yield* query.snapshots().map<List<ReadingModel>>((snap) {
        if (snap.docs.isEmpty) {
          return meterId != null
              ? _localReadings.where((r) => r.meterId == meterId).toList()
              : _localReadings;
        }
        final list = snap.docs.map((d) => ReadingModel.fromMap(d.data(), d.id)).toList();
        list.sort((a, b) => b.timestamp.compareTo(a.timestamp));
        // Keep _localReadings in sync with Firestore
        for (var item in list) {
          final idx = _localReadings.indexWhere((r) => r.id == item.id);
          if (idx == -1) {
            _localReadings.add(item);
          } else {
            _localReadings[idx] = item;
          }
        }
        _localReadings.sort((a, b) => b.timestamp.compareTo(a.timestamp));
        return list;
      }).handleError((_) => _localReadings);
    } else {
      yield* _readingsStreamController.stream.map((list) {
        if (meterId != null) {
          return list.where((r) => r.meterId == meterId).toList();
        }
        return list;
      });
    }
  }

  // Submit Reading
  Future<bool> submitReading(ReadingModel reading, {String? assignmentId}) async {
    final currentUser = AuthService.instance.currentUser;
    final currentReaderId = reading.readerId.isNotEmpty
        ? reading.readerId
        : (currentUser?.employeeCode ?? _localReader.employeeCode);

    // Resolve the exact assignment document ID in Firestore
    final resolvedAssignmentId = assignmentId ??
        _localAssignments.cast<AssignmentModel?>().firstWhere(
          (a) => a?.meterId == reading.meterId,
          orElse: () => null,
        )?.id ?? reading.meterId;

    final assignIdx = _localAssignments.indexWhere(
      (a) => a.id == resolvedAssignmentId || a.meterId == reading.meterId,
    );
    final bool alreadyCompleted = assignIdx != -1 && _localAssignments[assignIdx].status == 'Completed';

    // 1. Attempt Firestore commit if connected
    if (!_useLocalFallback && _firestore != null) {
      try {
        final batch = _firestore!.batch();

        // Save reading document
        final readingRef = _firestore!.collection('readings').doc(reading.id);
        batch.set(readingRef, reading.toMap());

        // Complete the correct assignment document in Firestore
        final assignmentRef = _firestore!.collection('assignments').doc(resolvedAssignmentId);
        batch.update(assignmentRef, {
          'status': 'Completed',
          'completedReading': reading.currentReading,
          'completedAt': FieldValue.serverTimestamp(),
        });

        // Only increment reader completed count if not already completed (prevents double count on retry)
        if (!alreadyCompleted) {
          final readerRef = _firestore!.collection('meter_readers').doc(currentReaderId);
          batch.set(readerRef, {
            'completedCount': FieldValue.increment(1),
            'pendingCount': FieldValue.increment(-1),
          }, SetOptions(merge: true));
        }

        if (reading.isAnomaly) {
          final anomalyRef = _firestore!.collection('anomalies').doc('ANOM-${reading.id}');
          batch.set(anomalyRef, {
            'readingId': reading.id,
            'meterId': reading.meterId,
            'customerName': reading.customerName,
            'readerId': reading.readerId,
            'currentReading': reading.currentReading,
            'previousReading': reading.previousReading,
            'units': reading.units,
            'reason': reading.anomalyReason ?? 'Abnormal consumption surge',
            'timestamp': FieldValue.serverTimestamp(),
            'status': 'New',
          });
        }

        await batch.commit().timeout(const Duration(seconds: 4));
      } catch (e) {
        if (kDebugMode) {
          print('Firestore submission error: $e');
        }
        // Save failed or unconfirmed: return false so UI tells reader and keeps input
        return false;
      }
    }

    // 2. Confirmed save: Update local cache & streams (idempotent, no duplicates)
    final existingIdx = _localReadings.indexWhere((r) => r.id == reading.id || (r.meterId == reading.meterId && r.currentReading == reading.currentReading));
    if (existingIdx != -1) {
      _localReadings[existingIdx] = reading;
    } else {
      _localReadings.insert(0, reading);
    }

    if (assignIdx != -1) {
      _localAssignments[assignIdx] = _localAssignments[assignIdx].copyWith(status: 'Completed');
    }

    if (!alreadyCompleted) {
      final newCompleted = _localReader.completedCount + 1;
      final newPending = (_localReader.assignedCount - newCompleted).clamp(0, _localReader.assignedCount);
      _localReader = _localReader.copyWith(
        completedCount: newCompleted,
        pendingCount: newPending,
      );
    }

    _saveLocalCache();
    _emitLocalStreams();

    // Notify Customer backend in real-time
    CustomerFirebaseService().notifyReadingSubmitted(reading);

    return true;
  }

  // Get current assignment
  AssignmentModel? getAssignment(String meterId) {
    try {
      return _localAssignments.firstWhere((a) => a.meterId == meterId);
    } catch (_) {
      return null;
    }
  }
}
