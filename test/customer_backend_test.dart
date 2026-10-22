import 'package:flutter_test/flutter_test.dart';
import 'package:metermind/models/customer_model.dart';
import 'package:metermind/models/outage_report_model.dart';
import 'package:metermind/models/reading_model.dart';
import 'package:metermind/services/customer_firebase_service.dart';

void main() {
  group('Customer Backend Models Tests', () {
    test('CustomerModel serialization and deserialization', () {
      final customer = CustomerModel(
        id: 'MM-04218',
        meterId: 'MM-04218',
        name: 'Tharusha Wakwella',
        email: 'demo@example.com',
        phone: '+94 77 421 8000',
        address: '24 Temple Road',
        area: 'Homagama',
        avatarInitials: 'TW',
        currentUsageKwh: 312,
        estimatedBillLkr: 8100.0,
      );

      final map = customer.toMap();
      expect(map['name'], 'Tharusha Wakwella');
      expect(map['meterId'], 'MM-04218');
      expect(map['currentUsageKwh'], 312);
      expect(map['estimatedBillLkr'], 8100.0);

      final parsed = CustomerModel.fromMap(map, 'MM-04218');
      expect(parsed.name, 'Tharusha Wakwella');
      expect(parsed.currentUsageKwh, 312);
      expect(parsed.estimatedBillLkr, 8100.0);
    });

    test('OutageReportModel serialization', () {
      final outage = OutageReportModel(
        id: 'OUT-001',
        area: 'Homagama',
        reportCount: 12,
        status: 'Unverified',
        isHotspot: true,
        latitude: 6.8404,
        longitude: 80.0034,
        description: 'Potential Outage Hotspot · approx. 600 m radius',
      );

      final map = outage.toMap();
      expect(map['area'], 'Homagama');
      expect(map['reportCount'], 12);
      expect(map['isHotspot'], isTrue);

      final parsed = OutageReportModel.fromMap(map, 'OUT-001');
      expect(parsed.area, 'Homagama');
      expect(parsed.reportCount, 12);
      expect(parsed.isHotspot, isTrue);
    });
  });

  group('CustomerFirebaseService Calculations & Business Logic Tests', () {
    final service = CustomerFirebaseService();

    test('CEB Domestic Tariff calculates Rs. 8,100 for 312 units', () {
      final bill = service.calculateEstimatedBill(312);
      expect(bill, 8100.0);
    });

    test('Next month forecast range calculation returns valid span', () {
      final forecast = service.calculateForecast([312, 339, 286, 310, 280]);
      expect(forecast['min'], greaterThanOrEqualTo(320));
      expect(forecast['max'], greaterThanOrEqualTo(forecast['min']!));
    });

    test('Customer streams emit valid initial prototype data', () async {
      final customer = await service.streamCustomerProfile().first;
      expect(customer.name, 'Tharusha Wakwella');
      expect(customer.meterId, 'MM-04218');
      expect(customer.currentUsageKwh, 312);
      expect(customer.meterStatus, 'Meter active');

      final monthlyUsage = await service.streamUsageHistory(periodType: 'monthly').first;
      expect(monthlyUsage.length, 5);
      expect(monthlyUsage.last.label, 'Oct');
      expect(monthlyUsage.last.kwh, 312);

      final outages = await service.streamOutageReports().first;
      expect(outages.any((o) => o.area == 'Homagama' && o.reportCount >= 12), isTrue);

      final recs = await service.streamRecommendations().first;
      expect(recs.any((r) => r.title.contains('biggest appliances')), isTrue);
    });

    test('Customer reporting an outage increments report count', () async {
      final initialHomagama = service.currentOutages.firstWhere((o) => o.area == 'Homagama');
      final initialCount = initialHomagama.reportCount;

      await service.reportOutage(
        area: 'Homagama',
        description: 'Total blackout on Temple Road.',
      );

      final updated = service.currentOutages.firstWhere((o) => o.area == 'Homagama');
      expect(updated.reportCount, initialCount + 1);
    });

    test('Saving a recommendation updates its state', () async {
      await service.toggleSaveRecommendation(
        recommendationId: 'REC-002',
        isSaved: true,
      );

      final rec = service.currentRecommendations.firstWhere((r) => r.id == 'REC-002');
      expect(rec.isSaved, isTrue);
    });

    test('Syncs reading submission and dynamically recalculates customer bill', () {
      final newReading = ReadingModel(
        id: 'R-NEW',
        meterId: 'MM-04218',
        customerName: 'Tharusha Wakwella',
        readerId: 'MR001',
        readerName: 'Nimal Perera',
        previousReading: 15700,
        currentReading: 16012,
        units: 312,
        date: '02 Oct 2026',
        timestamp: DateTime.now(),
      );

      service.notifyReadingSubmitted(newReading);

      expect(service.currentCustomer.latestReadingKwh, 16012);
      expect(service.currentCustomer.currentUsageKwh, 312);
      expect(service.currentCustomer.estimatedBillLkr, 8100.0);
    });
  });
}
