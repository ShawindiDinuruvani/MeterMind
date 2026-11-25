import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart' hide FirebaseService;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'firebase_options.dart';

import 'admin/admin_dashboard.dart';
import 'models/user_model.dart';
import 'screens/customer_dashboard.dart';
import 'screens/login_screen.dart';
import 'screens/main_navigation_screen.dart';
import 'services/auth_service.dart';
import 'services/firebase_service.dart';
import 'theme/app_theme.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Firebase safely for all platforms
  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
  } catch (e) {
    debugPrint('Firebase initialization note: $e');
  }

  // Connect to Firebase Emulators when opt-in emulator flag is set
  const bool useEmulator = bool.fromEnvironment('USE_FIREBASE_EMULATOR', defaultValue: false);
  if (useEmulator) {
    try {
      await FirebaseAuth.instance.useAuthEmulator('localhost', 9099);
      FirebaseFirestore.instance.useFirestoreEmulator('localhost', 8080);
      debugPrint('Connected to Firebase Emulators (Auth: 9099, Firestore: 8080)');
    } catch (e) {
      debugPrint('Firebase emulator connection note: $e');
    }
  }

  // Initialize Reader Firebase & local cache service
  await FirebaseService().initialize();

  // Initialize Auth state listener for session persistence across refreshes
  await AuthService.instance.initialize();

  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
    ),
  );

  runApp(const MeterMindApp());
}

class MeterMindApp extends StatefulWidget {
  const MeterMindApp({super.key});

  @override
  State<MeterMindApp> createState() => _MeterMindAppState();
}

class _MeterMindAppState extends State<MeterMindApp> {
  ThemeMode _themeMode = ThemeMode.light;

  void _toggleTheme() {
    setState(() {
      _themeMode = _themeMode == ThemeMode.light
          ? ThemeMode.dark
          : ThemeMode.light;
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDark = _themeMode == ThemeMode.dark;

    return MaterialApp(
      title: 'MeterMind · Smart Energy',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme(),
      darkTheme: AppTheme.darkTheme(),
      themeMode: _themeMode,
      home: AuthGate(
        onToggleTheme: _toggleTheme,
        isDarkTheme: isDark,
      ),
    );
  }
}

/// Authentication & Role Router Gate
/// Determines whether the user is logged in, and routes them to the right dashboard:
/// Customer -> CustomerDashboard
/// Meter Reader -> MainNavigationScreen
/// Admin -> AdminDashboard
/// Shows clear retry and sign-out options if role is missing or loading fails.
class AuthGate extends StatelessWidget {
  final VoidCallback onToggleTheme;
  final bool isDarkTheme;

  const AuthGate({
    super.key,
    required this.onToggleTheme,
    required this.isDarkTheme,
  });

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: AuthService.instance,
      builder: (context, _) {
        final auth = AuthService.instance;
        final user = auth.currentUser;

        // If an account has an error or missing role after sign-in
        if (auth.initError != null) {
          return Scaffold(
            backgroundColor: const Color(0xFFF4F5F0),
            body: SafeArea(
              child: Center(
                child: Padding(
                  padding: const EdgeInsets.all(28),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.shield_outlined, size: 54, color: Color(0xFFBE443B)),
                      const SizedBox(height: 16),
                      const Text(
                        'Role Verification Required',
                        style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800),
                      ),
                      const SizedBox(height: 10),
                      Text(
                        auth.initError!,
                        textAlign: TextAlign.center,
                        style: const TextStyle(fontSize: 13, color: Color(0xFF65716A), height: 1.4),
                      ),
                      const SizedBox(height: 24),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          OutlinedButton(
                            onPressed: () => auth.reloadProfile(),
                            child: const Text('Retry'),
                          ),
                          const SizedBox(width: 14),
                          ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFFF5C542),
                              foregroundColor: const Color(0xFF202523),
                            ),
                            onPressed: () => auth.signOut(),
                            child: const Text('Sign Out'),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        }

        if (user == null) {
          return LoginScreen(
            onToggleTheme: onToggleTheme,
            isDarkTheme: isDarkTheme,
          );
        }

        switch (user.role) {
          case UserRole.customer:
            return CustomerDashboard(
              onToggleTheme: onToggleTheme,
              isDarkTheme: isDarkTheme,
            );
          case UserRole.reader:
            return MainNavigationScreen(
              onToggleTheme: onToggleTheme,
              isDarkTheme: isDarkTheme,
            );
          case UserRole.admin:
            return AdminDashboard(
              onToggleTheme: onToggleTheme,
              isDarkTheme: isDarkTheme,
            );
        }
      },
    );
  }
}
