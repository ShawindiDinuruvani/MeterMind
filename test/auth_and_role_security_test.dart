import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:metermind/main.dart';
import 'package:metermind/models/user_model.dart';
import 'package:metermind/screens/login_screen.dart';
import 'package:metermind/services/auth_service.dart';

void main() {
  group('LoginScreen & Role Enforcement Tests', () {
    testWidgets('LoginScreen shows shared form without demo buttons or role selectors', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: LoginScreen(),
        ),
      );
      await tester.pumpAndSettle();

      // Email and Password sign in
      expect(find.text('Email address'), findsOneWidget);
      expect(find.text('Password'), findsOneWidget);
      expect(find.text('Sign In'), findsNWidgets(2)); // Tab and Button
      expect(find.text('Register as Customer'), findsOneWidget);

      // Verify NO demo buttons or public role chips
      expect(find.textContaining('QUICK DEMO ACCESS'), findsNothing);
      expect(find.text('Field Officer'), findsNothing);
      expect(find.text('Admin'), findsNothing);
    });

    testWidgets('Switching to Register as Customer shows customer-only registration form', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: LoginScreen(),
        ),
      );
      await tester.pumpAndSettle();

      // Tap 'Register as Customer'
      await tester.tap(find.text('Register as Customer'));
      await tester.pumpAndSettle();

      // Customer fields present
      expect(find.text('Full Name *'), findsOneWidget);
      expect(find.text('Electricity Meter Number *'), findsOneWidget);
      expect(find.text('Area / Town'), findsOneWidget);
      expect(find.text('Create Customer Account'), findsOneWidget);

      // Staff fields absent from public registration
      expect(find.text('Account Role'), findsNothing);
      expect(find.text('Employee Code'), findsNothing);
      expect(find.text('Department'), findsNothing);
    });

    test('Anonymous, Customer, and Reader cannot invoke createMeterReaderAsAdmin', () async {
      final auth = AuthService.instance;

      // 1. Anonymous / signed out
      await auth.signOut();
      expect(
        () => auth.createMeterReaderAsAdmin(
          name: 'Reader 1',
          email: 'reader1@metermind.lk',
          employeeCode: 'MR-001',
          area: 'Homagama',
        ),
        throwsA(isA<Exception>()),
      );

      // 2. Customer user
      auth.setCurrentUserForTesting(
        UserModel(
          id: 'cust-1',
          name: 'Customer One',
          email: 'cust@metermind.lk',
          role: UserRole.customer,
          status: 'Active',
          createdAt: DateTime.now(),
        ),
      );
      expect(
        () => auth.createMeterReaderAsAdmin(
          name: 'Reader 2',
          email: 'reader2@metermind.lk',
          employeeCode: 'MR-002',
          area: 'Homagama',
        ),
        throwsA(isA<Exception>()),
      );

      // 3. Meter Reader user cannot create other readers
      auth.setCurrentUserForTesting(
        UserModel(
          id: 'reader-1',
          name: 'Reader One',
          email: 'reader1@metermind.lk',
          role: UserRole.reader,
          status: 'Active',
          createdAt: DateTime.now(),
        ),
      );
      expect(
        () => auth.createMeterReaderAsAdmin(
          name: 'Reader 3',
          email: 'reader3@metermind.lk',
          employeeCode: 'MR-003',
          area: 'Homagama',
        ),
        throwsA(isA<Exception>()),
      );
    });

    testWidgets('AuthGate displays LoginScreen when unauthenticated', (tester) async {
      final auth = AuthService.instance;
      auth.setCurrentUserForTesting(null);

      await tester.pumpWidget(
        MaterialApp(
          home: AuthGate(
            onToggleTheme: () {},
            isDarkTheme: false,
          ),
        ),
      );
      await tester.pumpAndSettle();
      expect(find.byType(LoginScreen), findsOneWidget);
    });

    test('AuthService maintains trusted role model and session state across reloads', () {
      final auth = AuthService.instance;

      // 1. Customer role
      final customer = UserModel(
        id: 'cust-101',
        name: 'Kamal Perera',
        email: 'kamal@metermind.lk',
        role: UserRole.customer,
        meterId: 'MM-999',
        status: 'Active',
        createdAt: DateTime.now(),
      );
      auth.setCurrentUserForTesting(customer);
      expect(auth.isAuthenticated, isTrue);
      expect(auth.currentUser?.role, UserRole.customer);
      expect(auth.currentUser?.name, 'Kamal Perera');

      // 2. Meter Reader role
      final reader = UserModel(
        id: 'reader-101',
        name: 'Sunil Silva',
        email: 'sunil.reader@metermind.lk',
        role: UserRole.reader,
        employeeCode: 'MR-101',
        status: 'Active',
        createdAt: DateTime.now(),
      );
      auth.setCurrentUserForTesting(reader);
      expect(auth.isAuthenticated, isTrue);
      expect(auth.currentUser?.role, UserRole.reader);
      expect(auth.currentUser?.employeeCode, 'MR-101');

      // 3. Admin role
      final admin = UserModel(
        id: 'admin-101',
        name: 'System Admin',
        email: 'admin@metermind.lk',
        role: UserRole.admin,
        status: 'Active',
        createdAt: DateTime.now(),
      );
      auth.setCurrentUserForTesting(admin);
      expect(auth.isAuthenticated, isTrue);
      expect(auth.currentUser?.role, UserRole.admin);

      // Clean up testing state
      auth.setCurrentUserForTesting(null);
      expect(auth.isAuthenticated, isFalse);
      expect(auth.currentUser, isNull);
    });
  });
}
