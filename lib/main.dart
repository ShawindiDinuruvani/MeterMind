import 'package:flutter/material.dart';

import 'screens/outage_page.dart';
import 'screens/profile_page.dart';
import 'screens/recommendation_page.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    const darkGreen = Color(0xFF173B32);

    return MaterialApp(
      title: 'MeterMind',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: darkGreen,
          primary: darkGreen,
          surface: const Color(0xFFF4F5F0),
        ),
        scaffoldBackgroundColor: const Color(0xFFF4F5F0),
      ),
      home: const MeterMindShell(),
    );
  }
}

class MeterMindShell extends StatefulWidget {
  const MeterMindShell({super.key});

  @override
  State<MeterMindShell> createState() => _MeterMindShellState();
}

class _MeterMindShellState extends State<MeterMindShell> {
  int _selectedIndex = 0;

  static const _pages = [
    OutagePage(),
    RecommendationPage(),
    ProfilePage(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(index: _selectedIndex, children: _pages),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _selectedIndex,
        onDestinationSelected: (index) {
          setState(() => _selectedIndex = index);
        },
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.track_changes_outlined),
            label: 'Outages',
          ),
          NavigationDestination(
            icon: Icon(Icons.route_outlined),
            label: 'Recommendations',
          ),
          NavigationDestination(
            icon: Icon(Icons.circle_outlined),
            label: 'Profile',
          ),
        ],
      ),
    );
  }
}
