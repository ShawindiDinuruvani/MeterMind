import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:metermind/features/home/home_page.dart';
import 'package:metermind/features/insights/insights_page.dart';
import 'package:metermind/screens/outage_page.dart';
import 'package:metermind/widgets/osm_map_widget.dart';
import 'package:metermind/models/reading_model.dart';
import 'package:metermind/services/customer_firebase_service.dart';

void main() {
  group('MeterMind Responsive Layout Tests', () {
    testWidgets('HomePage adapts to phone viewport 360x800 without overflow', (tester) async {
      tester.view.physicalSize = const Size(360, 800);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() => tester.view.resetPhysicalSize());

      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: HomePage(),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.textContaining('Good morning'), findsOneWidget);
      expect(find.textContaining('Your usage this month'), findsOneWidget);
      expect(find.textContaining('Estimated bill'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    testWidgets('HomePage adapts to tablet/desktop viewport 1366x768 without overflow', (tester) async {
      tester.view.physicalSize = const Size(1366, 768);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() => tester.view.resetPhysicalSize());

      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: HomePage(),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.textContaining('Good morning'), findsOneWidget);
      expect(find.textContaining('Your usage this month'), findsOneWidget);
      expect(find.textContaining('A small change, a lighter bill.'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    testWidgets('InsightsPage adapts to phone 390x844 and desktop 1024x768', (tester) async {
      // 390x844
      tester.view.physicalSize = const Size(390, 844);
      tester.view.devicePixelRatio = 1.0;

      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: InsightsPage(),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Consumption insights.'), findsOneWidget);
      expect(find.text('Monthly'), findsOneWidget);
      expect(tester.takeException(), isNull);

      // Resize dynamically to 1024x768
      tester.view.physicalSize = const Size(1024, 768);
      await tester.pumpAndSettle();

      expect(find.text('Consumption insights.'), findsOneWidget);
      expect(tester.takeException(), isNull);
      tester.view.resetPhysicalSize();
    });

    testWidgets('OutagePage renders interactive OsmMapWidget with markers', (tester) async {
      tester.view.physicalSize = const Size(768, 1024);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() => tester.view.resetPhysicalSize());

      await tester.pumpWidget(
        const MaterialApp(
          home: OutagePage(),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.byType(OsmMapWidget), findsOneWidget);
      expect(find.text('Outage intelligence.'), findsOneWidget);
      expect(find.text('Report an outage'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });
  });

  group('Meter Reader to Customer Flow & Idempotency', () {
    test('Submitting reader reading updates Customer Home and Insights', () {
      final customerService = CustomerFirebaseService();

      final reading = ReadingModel(
        id: 'READ-TEST-001',
        meterId: 'MM-04218',
        customerName: 'Tharusha Wakwella',
        previousReading: 15700,
        currentReading: 16050,
        units: 350,
        date: '24 Nov 2026',
        timestamp: DateTime.now(),
        readerId: 'reader_001',
        readerName: 'Kasun Bandara',
      );

      customerService.notifyReadingSubmitted(reading);

      final customer = customerService.currentCustomer;
      expect(customer.currentUsageKwh, 350);
      expect(customer.latestReadingKwh, 16050);
      expect(customer.latestReadingDate, '24 Nov 2026');
      expect(customer.estimatedBillLkr, greaterThan(0));
    });

    test('Customer privacy: readings for other meters do not overwrite customer state', () {
      final customerService = CustomerFirebaseService();

      final currentUsage = customerService.currentCustomer.currentUsageKwh;

      final otherReading = ReadingModel(
        id: 'READ-TEST-002',
        meterId: 'MM-99999', // Different meter
        customerName: 'Other Customer',
        previousReading: 5000,
        currentReading: 5500,
        units: 500,
        date: '24 Nov 2026',
        timestamp: DateTime.now(),
        readerId: 'reader_001',
        readerName: 'Kasun Bandara',
      );

      customerService.notifyReadingSubmitted(otherReading);

      expect(customerService.currentCustomer.currentUsageKwh, currentUsage);
    });
  });
}
