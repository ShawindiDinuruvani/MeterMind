import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import '../models/user_model.dart';

class AuthService extends ChangeNotifier {
  static final AuthService instance = AuthService._internal();
  factory AuthService() => instance;
  AuthService._internal() {
    _initDemoUsers();
  }

  UserModel? _currentUser;
  UserModel? get currentUser => _currentUser;
  bool get isAuthenticated => _currentUser != null;

  final List<UserModel> _localUsers = [];

  void _initDemoUsers() {
    _localUsers.addAll([
      UserModel(
        id: 'DEMO-CUSTOMER',
        name: 'Tharusha Wakwella',
        email: 'demo@example.com',
        role: UserRole.customer,
        meterId: 'MM-04218',
        area: 'Homagama',
        phone: '+94 77 421 8000',
        status: 'Active',
      ),
      UserModel(
        id: 'DEMO-CUSTOMER-2',
        name: 'Tharusha Wakwella',
        email: 'tharusha@metermind.lk',
        role: UserRole.customer,
        meterId: 'MM-04218',
        area: 'Homagama',
        phone: '+94 77 421 8000',
        status: 'Active',
      ),
      UserModel(
        id: 'DEMO-READER',
        name: 'Nimal Perera',
        email: 'nimal.perera@metermind.lk',
        role: UserRole.reader,
        employeeCode: 'MR001',
        area: 'Homagama',
        phone: '+94 71 832 1099',
        status: 'Active',
      ),
      UserModel(
        id: 'DEMO-ADMIN',
        name: 'Senaka De Silva',
        email: 'admin@metermind.lk',
        role: UserRole.admin,
        employeeCode: 'ADM-01',
        area: 'Operations HQ',
        phone: '+94 11 289 0000',
        status: 'Active',
      ),
    ]);
  }

  /// Sign in with email and password, automatically determining user role
  Future<UserModel> signInWithEmailAndPassword({
    required String email,
    required String password,
  }) async {
    final cleanEmail = email.trim().toLowerCase();

    // 1. Try Firebase Authentication if online
    try {
      await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: cleanEmail,
        password: password,
      );

      // Try reading user profile from Firestore 'users' collection
      final query = await FirebaseFirestore.instance
          .collection('users')
          .where('email', isEqualTo: cleanEmail)
          .limit(1)
          .get();

      if (query.docs.isNotEmpty) {
        final doc = query.docs.first;
        final user = UserModel.fromMap(doc.data(), doc.id);
        _currentUser = user;
        notifyListeners();
        return user;
      }
    } catch (_) {
      // Continue to local/demo resolution for offline resilience
    }

    // 2. Check local/demo users
    final match = _localUsers.firstWhere(
      (u) => u.email.toLowerCase() == cleanEmail,
      orElse: () {
        // If unknown email, infer role from email or domain
        UserRole inferredRole = UserRole.customer;
        if (cleanEmail.contains('admin')) {
          inferredRole = UserRole.admin;
        } else if (cleanEmail.contains('reader') || cleanEmail.contains('field')) {
          inferredRole = UserRole.reader;
        }

        final newUser = UserModel(
          id: 'USER-${DateTime.now().millisecondsSinceEpoch}',
          name: cleanEmail.split('@').first.replaceAll('.', ' ').toUpperCase(),
          email: cleanEmail,
          role: inferredRole,
          area: 'Homagama',
        );
        _localUsers.add(newUser);
        return newUser;
      },
    );

    _currentUser = match;
    notifyListeners();
    return match;
  }

  /// Register a new user with specific role and profile attributes
  Future<UserModel> registerUser({
    required String name,
    required String email,
    required String password,
    required UserRole role,
    String? meterId,
    String? area,
    String? employeeCode,
    String? phone,
  }) async {
    final cleanEmail = email.trim().toLowerCase();

    String generatedId = 'USER-${DateTime.now().millisecondsSinceEpoch}';

    // 1. Attempt Firebase Auth & Firestore write
    try {
      final credential = await FirebaseAuth.instance
          .createUserWithEmailAndPassword(
        email: cleanEmail,
        password: password,
      );

      if (credential.user != null) {
        generatedId = credential.user!.uid;
        await credential.user!.updateDisplayName(name);

        await FirebaseFirestore.instance.collection('users').doc(generatedId).set({
          'name': name.trim(),
          'email': cleanEmail,
          'role': role.name,
          'status': 'Active',
          if (meterId != null && meterId.isNotEmpty) 'meterId': meterId.trim(),
          if (employeeCode != null && employeeCode.isNotEmpty)
            'employeeCode': employeeCode.trim(),
          if (area != null && area.isNotEmpty) 'area': area.trim(),
          if (phone != null && phone.isNotEmpty) 'phone': phone.trim(),
          'createdAt': FieldValue.serverTimestamp(),
        });
      }
    } catch (_) {
      // Handled via local storage fallback below
    }

    // 2. Save into local cache
    final newUser = UserModel(
      id: generatedId,
      name: name.trim(),
      email: cleanEmail,
      role: role,
      status: 'Active',
      meterId: meterId?.trim(),
      employeeCode: employeeCode?.trim(),
      area: (area != null && area.isNotEmpty) ? area.trim() : 'Homagama',
      phone: phone?.trim(),
      createdAt: DateTime.now(),
    );

    // Remove old matching if exists and add new
    _localUsers.removeWhere((u) => u.email.toLowerCase() == cleanEmail);
    _localUsers.add(newUser);

    _currentUser = newUser;
    notifyListeners();
    return newUser;
  }

  /// One-tap demo login for rapid testing of each role
  void quickDemoLogin(UserRole role) {
    switch (role) {
      case UserRole.customer:
        _currentUser = _localUsers.firstWhere(
          (u) => u.role == UserRole.customer,
          orElse: () => UserModel(
            id: 'DEMO-CUSTOMER',
            name: 'Tharusha Wakwella',
            email: 'demo@example.com',
            role: UserRole.customer,
            meterId: 'MM-04218',
            area: 'Homagama',
          ),
        );
        break;
      case UserRole.reader:
        _currentUser = _localUsers.firstWhere(
          (u) => u.role == UserRole.reader,
          orElse: () => UserModel(
            id: 'DEMO-READER',
            name: 'Nimal Perera',
            email: 'nimal.perera@metermind.lk',
            role: UserRole.reader,
            employeeCode: 'MR001',
            area: 'Homagama',
          ),
        );
        break;
      case UserRole.admin:
        _currentUser = _localUsers.firstWhere(
          (u) => u.role == UserRole.admin,
          orElse: () => UserModel(
            id: 'DEMO-ADMIN',
            name: 'Senaka De Silva',
            email: 'admin@metermind.lk',
            role: UserRole.admin,
            employeeCode: 'ADM-01',
            area: 'Operations HQ',
          ),
        );
        break;
    }
    notifyListeners();
  }

  /// Sign out current user
  Future<void> signOut() async {
    try {
      await FirebaseAuth.instance.signOut();
    } catch (_) {}
    _currentUser = null;
    notifyListeners();
  }
}

