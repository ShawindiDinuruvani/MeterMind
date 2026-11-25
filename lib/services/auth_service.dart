import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import '../models/user_model.dart';
import '../firebase_options.dart';

class AuthService extends ChangeNotifier {
  static final AuthService instance = AuthService._internal();
  factory AuthService() => instance;
  AuthService._internal();

  UserModel? _currentUser;
  UserModel? get currentUser => _currentUser;
  bool get isAuthenticated => _currentUser != null;

  bool _initialized = false;
  bool _isLoading = false;
  bool get isLoading => _isLoading;

  String? _initError;
  String? get initError => _initError;

  /// Initialize Auth state listener to persist session across restarts/refreshes
  Future<void> initialize() async {
    if (_initialized) return;
    _initialized = true;

    try {
      final auth = FirebaseAuth.instance;
      auth.authStateChanges().listen((User? firebaseUser) async {
        if (firebaseUser == null) {
          _currentUser = null;
          notifyListeners();
        } else {
          await _loadUserProfile(firebaseUser);
        }
      });

      // If user is already cached in Firebase Auth
      final current = auth.currentUser;
      if (current != null) {
        await _loadUserProfile(current);
      }
    } catch (e) {
      debugPrint('AuthService initialization error: $e');
    }
  }

  /// Load user profile from Firestore by UID
  Future<void> _loadUserProfile(User firebaseUser) async {
    try {
      final doc = await FirebaseFirestore.instance
          .collection('users')
          .doc(firebaseUser.uid)
          .get();

      if (doc.exists && doc.data() != null) {
        _currentUser = UserModel.fromMap(doc.data()!, doc.id);
        _initError = null;
      } else {
        // Fallback: check query by email if doc UID is not standard
        final query = await FirebaseFirestore.instance
            .collection('users')
            .where('email', isEqualTo: firebaseUser.email?.toLowerCase())
            .limit(1)
            .get();

        if (query.docs.isNotEmpty) {
          final first = query.docs.first;
          _currentUser = UserModel.fromMap(first.data(), first.id);
          _initError = null;
        } else {
          // No profile found for this authenticated user
          _initError = 'Your account has no assigned role. Please contact support or sign out.';
          _currentUser = null;
        }
      }
    } catch (e) {
      _initError = 'Could not load your user profile: $e';
      _currentUser = null;
    }
    notifyListeners();
  }

  /// Shared Email & Password Sign In
  /// Authenticates with Firebase Auth and reads the trusted Firestore role
  Future<UserModel> signInWithEmailAndPassword({
    required String email,
    required String password,
  }) async {
    final cleanEmail = email.trim().toLowerCase();
    _initError = null;
    _isLoading = true;
    notifyListeners();

    try {
      final credential = await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: cleanEmail,
        password: password,
      );

      final firebaseUser = credential.user;
      if (firebaseUser == null) {
        throw FirebaseAuthException(
          code: 'user-not-found',
          message: 'No user account found.',
        );
      }

      // Read profile from Firestore by UID
      final userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(firebaseUser.uid)
          .get();

      if (userDoc.exists && userDoc.data() != null) {
        final user = UserModel.fromMap(userDoc.data()!, userDoc.id);
        _currentUser = user;
        return user;
      }

      // Secondary lookup by email
      final query = await FirebaseFirestore.instance
          .collection('users')
          .where('email', isEqualTo: cleanEmail)
          .limit(1)
          .get();

      if (query.docs.isNotEmpty) {
        final user = UserModel.fromMap(query.docs.first.data(), query.docs.first.id);
        _currentUser = user;
        return user;
      }

      // Role missing error
      await FirebaseAuth.instance.signOut();
      throw Exception('No role assigned to this account. Contact system administrator.');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Public Customer Registration
  /// MUST ALWAYS assign UserRole.customer. Client cannot self-assign Admin or Reader.
  Future<UserModel> registerCustomer({
    required String name,
    required String email,
    required String password,
    required String meterId,
    required String area,
    String? phone,
  }) async {
    final cleanEmail = email.trim().toLowerCase();

    // Enforce role strictly as customer
    const role = UserRole.customer;

    final credential = await FirebaseAuth.instance.createUserWithEmailAndPassword(
      email: cleanEmail,
      password: password,
    );

    final user = credential.user;
    if (user == null) {
      throw Exception('Failed to create account.');
    }

    final uid = user.uid;
    await user.updateDisplayName(name.trim());

    final userData = {
      'name': name.trim(),
      'email': cleanEmail,
      'role': role.name,
      'status': 'Active',
      'meterId': meterId.trim(),
      'area': area.trim(),
      if (phone != null && phone.trim().isNotEmpty) 'phone': phone.trim(),
      'createdAt': FieldValue.serverTimestamp(),
    };

    // Store in users collection keyed by auth UID
    await FirebaseFirestore.instance.collection('users').doc(uid).set(userData);

    // Also populate customers collection for the meter
    await FirebaseFirestore.instance.collection('customers').doc(meterId.trim()).set({
      'id': meterId.trim(),
      'meterId': meterId.trim(),
      'name': name.trim(),
      'email': cleanEmail,
      'phone': phone?.trim() ?? '',
      'area': area.trim(),
      'meterStatus': 'Meter active',
      'isMeterActive': true,
      'currentUsageKwh': 0,
      'usageChangePercent': 0.0,
      'latestReadingKwh': 0,
      'latestReadingDate': 'Pending',
      'estimatedBillLkr': 0.0,
      'forecastMinKwh': 0,
      'forecastMaxKwh': 0,
    }, SetOptions(merge: true));

    final newUser = UserModel(
      id: uid,
      name: name.trim(),
      email: cleanEmail,
      role: role,
      status: 'Active',
      meterId: meterId.trim(),
      area: area.trim(),
      phone: phone?.trim(),
      createdAt: DateTime.now(),
    );

    _currentUser = newUser;
    notifyListeners();
    return newUser;
  }

  /// Admin operation: Create Meter Reader Account
  /// Uses a secondary Firebase App instance so the currently logged-in Admin is NOT signed out.
  /// Gives the reader a private way to set their password via Firebase password setup/reset email.
  Future<UserModel> createMeterReaderAsAdmin({
    required String name,
    required String email,
    String? password,
    required String employeeCode,
    required String area,
    String? phone,
    bool sendPasswordSetupEmail = true,
  }) async {
    // 1. Authorization check: current caller must be Admin
    if (_currentUser == null || _currentUser!.role != UserRole.admin) {
      throw Exception('Unauthorized: Only an Administrator can create Meter Reader accounts.');
    }

    final cleanEmail = email.trim().toLowerCase();

    // Check if user with this email already exists in Firestore
    final existing = await FirebaseFirestore.instance
        .collection('users')
        .where('email', isEqualTo: cleanEmail)
        .limit(1)
        .get();

    if (existing.docs.isNotEmpty) {
      throw Exception('An account with email $cleanEmail already exists.');
    }

    // Determine initial password (use provided or generate strong temporary secret)
    final initialPassword = (password != null && password.trim().length >= 6)
        ? password.trim()
        : 'MR-${DateTime.now().millisecondsSinceEpoch}!Mm9';

    // 2. Initialize secondary FirebaseApp to create the reader user without overriding current admin session
    final appName = 'AdminReaderCreator_${DateTime.now().millisecondsSinceEpoch}';
    FirebaseApp? secondaryApp;
    try {
      secondaryApp = await Firebase.initializeApp(
        name: appName,
        options: DefaultFirebaseOptions.currentPlatform,
      );

      final secondaryAuth = FirebaseAuth.instanceFor(app: secondaryApp);
      if (const bool.fromEnvironment('USE_FIREBASE_EMULATOR', defaultValue: false)) {
        try {
          await secondaryAuth.useAuthEmulator('localhost', 9099);
        } catch (e) {
          debugPrint('Secondary auth emulator connection note: $e');
        }
      }
      final credential = await secondaryAuth.createUserWithEmailAndPassword(
        email: cleanEmail,
        password: initialPassword,
      );

      final newUid = credential.user!.uid;
      await credential.user!.updateDisplayName(name.trim());

      // If requested, send password setup email directly to reader's email address
      if (sendPasswordSetupEmail) {
        try {
          await FirebaseAuth.instance.sendPasswordResetEmail(email: cleanEmail);
        } catch (e) {
          debugPrint('Password setup email dispatch note: $e');
        }
      }

      // Sign out secondary app immediately
      await secondaryAuth.signOut();

      // 3. Write Meter Reader profile to Firestore
      final readerData = {
        'name': name.trim(),
        'email': cleanEmail,
        'role': UserRole.reader.name,
        'status': 'Active',
        'employeeCode': employeeCode.trim(),
        'area': area.trim(),
        if (phone != null && phone.trim().isNotEmpty) 'phone': phone.trim(),
        'assignedCount': 0,
        'completedCount': 0,
        'pendingCount': 0,
        'createdAt': FieldValue.serverTimestamp(),
      };

      await FirebaseFirestore.instance.collection('users').doc(newUid).set(readerData);

      // Also register into readers collection
      await FirebaseFirestore.instance.collection('readers').doc(newUid).set(readerData, SetOptions(merge: true));

      return UserModel(
        id: newUid,
        name: name.trim(),
        email: cleanEmail,
        role: UserRole.reader,
        employeeCode: employeeCode.trim(),
        area: area.trim(),
        phone: phone?.trim(),
        status: 'Active',
        createdAt: DateTime.now(),
      );
    } finally {
      if (secondaryApp != null) {
        await secondaryApp.delete();
      }
    }
  }

  /// Sign out current user
  Future<void> signOut() async {
    try {
      await FirebaseAuth.instance.signOut();
    } catch (_) {}
    _currentUser = null;
    _initError = null;
    notifyListeners();
  }

  /// Reload current profile from Firestore
  Future<void> reloadProfile() async {
    final current = FirebaseAuth.instance.currentUser;
    if (current != null) {
      await _loadUserProfile(current);
    }
  }

  /// Sets current user for testing purposes
  @visibleForTesting
  void setCurrentUserForTesting(UserModel? user) {
    _currentUser = user;
    notifyListeners();
  }
}
