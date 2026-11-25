import 'package:flutter_test/flutter_test.dart';
import 'package:metermind/models/reading_model.dart';
import 'package:metermind/models/user_model.dart';
import 'package:metermind/services/auth_service.dart';
import 'package:metermind/services/firebase_service.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('Meter Reader Submission & History Tests', () {
    late FirebaseService service;

    setUp(() {
      service = FirebaseService();
      service.resetForTesting();
    });

    test('1. Successful submission marks assignment Completed and updates reader stats', () async {
      final initialReader = service.currentReader;
      final initialCompleted = initialReader.completedCount;
      final initialPending = initialReader.pendingCount;

      final reading = ReadingModel(
        id: 'TEST-READ-001',
        meterId: 'MM-02816',
        customerName: 'S. Fernando',
        readerId: 'MR001',
        readerName: 'Nimal Perera',
        previousReading: 12450,
        currentReading: 12600,
        units: 150,
        date: '04 Oct 2026, 14:00',
        timestamp: DateTime(2026, 10, 4, 14, 0),
        status: 'Submitted',
      );

      final success = await service.submitReading(reading, assignmentId: 'MM-02816');
      expect(success, isTrue);

      // Verify assignment completed
      final assignment = service.getAssignment('MM-02816');
      expect(assignment, isNotNull);
      expect(assignment!.status, 'Completed');
      expect(assignment.isCompleted, isTrue);

      // Verify reader counts incremented once
      expect(service.currentReader.completedCount, initialCompleted + 1);
      expect(service.currentReader.pendingCount, initialPending - 1);

      // Verify reading appears in history stream
      final history = await service.streamReadings(meterId: 'MM-02816').first;
      expect(history.any((r) => r.id == 'TEST-READ-001' && r.currentReading == 12600), isTrue);
    });

    test('2. Retrying the same submission does NOT create duplicates or double count', () async {
      final readerBefore = service.currentReader;
      final completedCountBefore = readerBefore.completedCount;

      final retryReading = ReadingModel(
        id: 'TEST-READ-RETRY',
        meterId: 'MM-05120',
        customerName: 'K. Bandara',
        readerId: 'MR001',
        readerName: 'Nimal Perera',
        previousReading: 9840,
        currentReading: 10000,
        units: 160,
        date: '04 Oct 2026, 14:15',
        timestamp: DateTime(2026, 10, 4, 14, 15),
        status: 'Submitted',
      );

      // First submission
      final firstSubmit = await service.submitReading(retryReading, assignmentId: 'MM-05120');
      expect(firstSubmit, isTrue);
      expect(service.currentReader.completedCount, completedCountBefore + 1);

      final historyAfterFirst = await service.streamReadings(meterId: 'MM-05120').first;
      final countFirst = historyAfterFirst.where((r) => r.id == 'TEST-READ-RETRY').length;
      expect(countFirst, 1);

      // Retry exact same submission (e.g. user retrying after network flutter or double click)
      final retrySubmit = await service.submitReading(retryReading, assignmentId: 'MM-05120');
      expect(retrySubmit, isTrue);

      // Completed count must NOT increment a second time
      expect(service.currentReader.completedCount, completedCountBefore + 1);

      // History must NOT contain a duplicate
      final historyAfterRetry = await service.streamReadings(meterId: 'MM-05120').first;
      final countRetry = historyAfterRetry.where((r) => r.id == 'TEST-READ-RETRY').length;
      expect(countRetry, 1);
    });

    test('3. Signed-in reader is dynamically identified from AuthService', () async {
      // Simulate reader logging in as MR002
      AuthService.instance.setCurrentUserForTesting(
        UserModel(
          id: 'reader_sunil_002',
          name: 'Sunil Shantha',
          email: 'sunil.reader@metermind.lk',
          role: UserRole.reader,
          employeeCode: 'MR002',
          area: 'Homagama South',
        ),
      );

      final currentUser = AuthService.instance.currentUser;
      expect(currentUser, isNotNull);
      expect(currentUser!.role, UserRole.reader);
      expect(currentUser.employeeCode, 'MR002');
      expect(currentUser.name, 'Sunil Shantha');

      // The reader profile stream should reflect Sunil Shantha
      final readerProfile = await service.streamReaderProfile().first;
      expect(readerProfile.name, 'Sunil Shantha');
      expect(readerProfile.employeeCode, 'MR002');
      expect(readerProfile.area, 'Homagama South');
    });

    test('4. History loads saved reading and retains status across service access', () async {
      final savedReading = ReadingModel(
        id: 'TEST-RESTART-PERSIST',
        meterId: 'MM-06331',
        customerName: 'M. Perera',
        readerId: 'MR001',
        readerName: 'Nimal Perera',
        previousReading: 18200,
        currentReading: 18450,
        units: 250,
        date: '04 Oct 2026, 15:30',
        timestamp: DateTime(2026, 10, 4, 15, 30),
        status: 'Submitted',
      );

      await service.submitReading(savedReading, assignmentId: 'MM-06331');

      // Verify it's present in current readings
      expect(service.currentReadings.any((r) => r.id == 'TEST-RESTART-PERSIST'), isTrue);

      // Simulate app restart / service reinitialization
      final reloadedService = FirebaseService();
      await reloadedService.initialize();

      final reloadedHistory = await reloadedService.streamReadings(meterId: 'MM-06331').first;
      final found = reloadedHistory.firstWhere((r) => r.id == 'TEST-RESTART-PERSIST');
      expect(found.currentReading, 18450);
      expect(found.units, 250);
      expect(found.status, 'Submitted');

      // The assignment should also remain Completed
      final reloadedAssignment = reloadedService.getAssignment('MM-06331');
      expect(reloadedAssignment?.status, 'Completed');
    });
  });
}
