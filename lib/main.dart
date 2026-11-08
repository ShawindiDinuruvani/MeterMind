import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'firebase_options.dart';

import 'admin/admin_dashboard.dart';
import 'models/user_model.dart';
import 'screens/customer_dashboard.dart';
import 'screens/login_screen.dart';
import 'screens/main_navigation_screen.dart';
import 'services/auth_service.dart';
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
        final user = AuthService.instance.currentUser;

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
