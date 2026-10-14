// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:metermind/main.dart';

void main() {
  testWidgets('App loads with Home page', (WidgetTester tester) async {
    await tester.pumpWidget(const MeterMindApp());

    // Verify home page loads with key elements
    expect(find.textContaining('Good morning'), findsOneWidget);
    expect(find.textContaining('Tharusha'), findsOneWidget);
    expect(find.textContaining('MM-04218'), findsOneWidget);
  });

  testWidgets('Bottom navigation switches to Insights', (WidgetTester tester) async {
    await tester.pumpWidget(const MeterMindApp());

    // Tap Insights tab
    await tester.tap(find.byIcon(Icons.bar_chart_rounded));
    await tester.pumpAndSettle();

    // Verify insights page loads
    expect(find.text('Consumption insights.'), findsOneWidget);
    expect(find.text('Readings become a clearer picture.'), findsOneWidget);
  });

  testWidgets('Insights period tabs work', (WidgetTester tester) async {
    await tester.pumpWidget(const MeterMindApp());

    // Navigate to Insights
    await tester.tap(find.byIcon(Icons.bar_chart_rounded));
    await tester.pumpAndSettle();

    // Tap Weekly tab
    await tester.tap(find.text('Weekly'));
    await tester.pumpAndSettle();

    // Verify weekly content
    expect(find.text('Weekly usage'), findsOneWidget);
  });
}