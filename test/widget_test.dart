import 'package:flutter_test/flutter_test.dart';
import 'package:metermind/main.dart';

void main() {
  testWidgets('navigation opens outage, recommendations, and profile pages', (
    tester,
  ) async {
    await tester.pumpWidget(const MyApp());

    expect(find.text('Outage intelligence.'), findsOneWidget);

    await tester.tap(find.text('Recommendations'));
    await tester.pumpAndSettle();
    expect(find.text('Use less.\nKnow why.'), findsOneWidget);
    expect(find.text('Start with your biggest appliances.'), findsOneWidget);

    await tester.tap(find.text('Profile'));
    await tester.pumpAndSettle();
    expect(find.text('Your workspace.'), findsOneWidget);
    expect(find.text('Tharusha Wakwella'), findsOneWidget);

    await tester.tap(find.text('Outages'));
    await tester.pumpAndSettle();
    expect(find.text('Outage intelligence.'), findsOneWidget);
  });
}
