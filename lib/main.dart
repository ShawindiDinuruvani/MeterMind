import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'services/firebase_service.dart';
import 'theme/app_theme.dart';
import 'screens/main_navigation_screen.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();

  // Set preferred system overlay style
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
    ),
  );

  // Run the app immediately so the UI renders instantly without any blank screen
  runApp(const MeterMindApp());

  // Initialize Firebase in the background (with local offline fallback)
  FirebaseService().initialize();
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
      _themeMode = _themeMode == ThemeMode.light ? ThemeMode.dark : ThemeMode.light;
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
      home: MainNavigationScreen(
        onToggleTheme: _toggleTheme,
        isDarkTheme: isDark,
      ),
    );
  }
}
