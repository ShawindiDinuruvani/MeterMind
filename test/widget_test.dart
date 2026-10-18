import 'package:flutter_test/flutter_test.dart';
import 'package:metermind/models/assignment_model.dart';
import 'package:metermind/models/reading_model.dart';
import 'package:metermind/models/reader_model.dart';
import 'package:metermind/services/ai_service.dart';

void main() {
  group('AIService Unit Tests', () {
    final aiService = AIService();

    test('Detects negative consumption as critical anomaly', () {
      final result = aiService.analyzeReading(
        currentReading: 15600,
        previousReading: 15700,
        historicalAverageUsage: 312,
      );

      expect(result.isAnomaly, isTrue);
      expect(result.level, 'CRITICAL');
      expect(result.title, contains('Negative Consumption'));
      expect(result.possibleCauses.isNotEmpty, isTrue);
    });

    test('Detects usage surge above 1000 kWh or +80% as anomaly', () {
      final result = aiService.analyzeReading(
        currentReading: 16900,
        previousReading: 15700, // 1200 kWh consumption vs 312 baseline (+284%)
        historicalAverageUsage: 312,
      );

      expect(result.isAnomaly, isTrue);
      expect(result.title, contains('Surge Alert'));
      expect(result.deviationPercentage, greaterThan(80.0));
    });

    test('Approves normal consumption range', () {
      final result = aiService.analyzeReading(
        currentReading: 16012,
        previousReading: 15700, // 312 kWh consumption exactly at baseline
        historicalAverageUsage: 312,
      );

      expect(result.isAnomaly, isFalse);
      expect(result.level, 'NORMAL');
      expect(result.title, 'Consumption Verified');
    });

    test('Simulates AI Meter OCR digit extraction', () async {
      final ocrResult = await aiService.scanMeterOcr(
        baselinePreviousReading: 15700,
      );

      expect(ocrResult.detectedReading, greaterThan(15700));
      expect(ocrResult.confidence, greaterThan(0.95));
      expect(ocrResult.meterType, contains('CEB Standard'));
    });

    test('AI Field Copilot answers error code questions', () {
      final answer = aiService.getCopilotAnswer('What does Err-01 mean?');
      expect(answer, contains('Reverse energy flow'));
    });
  });

  group('Models Unit Tests', () {
    test('AssignmentModel completion calculation', () {
      final assignment = AssignmentModel(
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
      );

      expect(assignment.isCompleted, isFalse);
      final completed = assignment.copyWith(status: 'Completed');
      expect(completed.isCompleted, isTrue);
    });

    test('ReaderModel completion percentage calculation', () {
      final reader = ReaderModel(
        id: 'MR001',
        name: 'Nimal Perera',
        employeeCode: 'MR001',
        area: 'Homagama',
        email: 'nimal.perera@metermind.lk',
        assignedCount: 40,
        completedCount: 28,
        pendingCount: 12,
      );

      expect(reader.completionPercentage, 70.0);
    });

    test('ReadingModel serialization', () {
      final reading = ReadingModel(
        id: 'R-01',
        meterId: 'MM-04218',
        customerName: 'Tharusha Wakwella',
        readerId: 'MR001',
        readerName: 'Nimal Perera',
        previousReading: 15700,
        currentReading: 15820,
        units: 120,
        date: '04 Oct 2026',
        timestamp: DateTime(2026, 10, 4, 14, 30),
      );

      final map = reading.toMap();
      expect(map['units'], 120);
      expect(map['meterId'], 'MM-04218');

      final fromMap = ReadingModel.fromMap(map, 'R-01');
      expect(fromMap.currentReading, 15820);
    });
  });
}
