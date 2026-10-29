import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../services/admin_backend_service.dart';

import 'manage_users.dart';
import 'manage_meters.dart';
import 'meter_reader_assignments.dart';
import 'reading_progress.dart';
import 'analytics_reports.dart';
import 'outage_management.dart';
import 'outage_map.dart';

// MeterMind - Smart Energy Glass Theme
class MMColors {
  static const yellow = Color(0xFFF5C542);
  static const ink = Color(0xFF202523);
  static const soft = Color(0xFFF4F5F0);
  static const muted = Color(0xFF626B66);
  static const line = Color(0xFFDEE3DB);
  static const green = Color(0xFF237548);
  static const red = Color(0xFFB94338);
  static const amber = Color(0xFF936715);
}

// Independent Admin App
void main() {
  runApp(const AdminApp());
}

class AdminApp extends StatelessWidget {
  const AdminApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'MeterMind Admin',
      theme: ThemeData(
        useMaterial3: true,
        scaffoldBackgroundColor: MMColors.soft,
        colorScheme: ColorScheme.fromSeed(
          seedColor: MMColors.yellow,
          primary: MMColors.ink,
          surface: Colors.white,
        ),
        appBarTheme: const AppBarTheme(
          backgroundColor: MMColors.soft,
          foregroundColor: MMColors.ink,
          elevation: 0,
        ),
        cardTheme: CardThemeData(
          color: Colors.white,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(21),
            side: const BorderSide(color: MMColors.line),
          ),
        ),
      ),
      home: const AdminDashboard(),
    );
  }
}

// Main Admin Navigation
class AdminDashboard extends StatefulWidget {
  const AdminDashboard({super.key});

  @override
  State<AdminDashboard> createState() => _AdminDashboardState();
}

class _AdminDashboardState extends State<AdminDashboard> {
  int selectedIndex = 0;

  final List<Widget> pages = const [
    DashboardHome(),
    ManageUsersPage(),
    ManageMetersPage(),
    MeterReaderAssignmentsPage(),
    ReadingProgressPage(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: MMColors.soft,
      body: IndexedStack(
        index: selectedIndex,
        children: pages,
      ),
      bottomNavigationBar: Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          border: Border(
            top: BorderSide(color: MMColors.line),
          ),
        ),
        child: SafeArea(
          top: false,
          child: NavigationBar(
            height: 72,
            backgroundColor: Colors.white,
            indicatorColor: const Color(0x33F5C542),
            selectedIndex: selectedIndex,
            labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
            onDestinationSelected: (index) {
              setState(() {
                selectedIndex = index;
              });
            },
            destinations: const [
              NavigationDestination(
                icon: Icon(Icons.dashboard_outlined),
                selectedIcon: Icon(Icons.dashboard_rounded),
                label: 'Dashboard',
              ),
              NavigationDestination(
                icon: Icon(Icons.people_outline),
                selectedIcon: Icon(Icons.people),
                label: 'Users',
              ),
              NavigationDestination(
                icon: Icon(Icons.electric_meter_outlined),
                selectedIcon: Icon(Icons.electric_meter),
                label: 'Meters',
              ),
              NavigationDestination(
                icon: Icon(Icons.assignment_outlined),
                selectedIcon: Icon(Icons.assignment),
                label: 'Routes',
              ),
              NavigationDestination(
                icon: Icon(Icons.analytics_outlined),
                selectedIcon: Icon(Icons.analytics),
                label: 'Progress',
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// Dashboard Home
class DashboardHome extends StatefulWidget {
  const DashboardHome({super.key});

  @override
  State<DashboardHome> createState() => _DashboardHomeState();
}

class _DashboardHomeState extends State<DashboardHome> {
  final AdminBackendService _backendService = AdminBackendService();

  void openPage(BuildContext context, Widget page) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => page),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: MMColors.soft,
      appBar: AppBar(
        title: Row(
          children: [
            Container(
              width: 39,
              height: 39,
              decoration: BoxDecoration(
                color: MMColors.yellow,
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(
                Icons.bolt_rounded,
                color: MMColors.ink,
                size: 28,
              ),
            ),
            const SizedBox(width: 10),
            const Text(
              'MeterMind',
              style: TextStyle(
                fontSize: 21,
                fontWeight: FontWeight.w800,
                letterSpacing: -0.6,
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            tooltip: 'Notifications',
            icon: const Icon(
              Icons.notifications_none_rounded,
            ),
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text(
                    'Notifications will be available soon.',
                  ),
                ),
              );
            },
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(19, 20, 19, 28),
        children: [
          const Text(
            'SUPERVISOR WORKSPACE',
            style: TextStyle(
              color: MMColors.muted,
              fontSize: 11,
              fontWeight: FontWeight.w700,
              letterSpacing: 2,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Energy operations.',
            style: TextStyle(
              color: MMColors.ink,
              fontSize: 28,
              fontWeight: FontWeight.w800,
              letterSpacing: -1,
            ),
          ),
          const SizedBox(height: 5),
          const Text(
            'Homagama district · Live overview',
            style: TextStyle(
              color: MMColors.muted,
              fontSize: 13,
            ),
          ),
          const SizedBox(height: 18),

          // Reading Coverage Card
          Container(
            padding: const EdgeInsets.all(23),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Color(0xFF353E36),
                  Color(0xFF1C2421),
                ],
              ),
              borderRadius: BorderRadius.circular(21),
              border: Border.all(
                color: const Color(0xFF657060),
              ),
            ),
            child: const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Today's reading coverage",
                  style: TextStyle(
                    color: Color(0xFFC5D0C3),
                    fontSize: 13,
                  ),
                ),
                SizedBox(height: 10),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      '76',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 49,
                        fontWeight: FontWeight.w700,
                        height: 1.1,
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.only(
                        left: 3,
                        bottom: 5,
                      ),
                      child: Text(
                        '%',
                        style: TextStyle(
                          color: Color(0xFFCAD3C8),
                          fontSize: 19,
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 14),
                ClipRRect(
                  borderRadius: BorderRadius.all(
                    Radius.circular(10),
                  ),
                  child: LinearProgressIndicator(
                    value: 0.76,
                    minHeight: 8,
                    backgroundColor: Color(0xFF566057),
                    valueColor: AlwaysStoppedAnimation<Color>(
                      MMColors.yellow,
                    ),
                  ),
                ),
                SizedBox(height: 17),
                Row(
                  mainAxisAlignment:
                      MainAxisAlignment.spaceBetween,
                  children: [
                    Flexible(
                      child: Text(
                        '1,824 readings received',
                        style: TextStyle(
                          color: Color(0xFFC5D0C3),
                          fontSize: 12,
                        ),
                      ),
                    ),
                    Text(
                      '576 pending',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w700,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          const SizedBox(height: 13),

          // Statistics Cards with Live Streams
          Row(
            children: [
              Expanded(
                child: StreamBuilder<int>(
                  stream: _backendService.getTotalUsersCount(),
                  builder: (context, snapshot) {
                    final count = snapshot.hasData ? snapshot.data.toString() : '...';
                    return _StatCard(
                      title: 'Customers',
                      value: count,
                      icon: Icons.people_outline,
                    );
                  },
                ),
              ),
              const SizedBox(width: 11),
              Expanded(
                child: StreamBuilder<int>(
                  stream: _backendService.getActiveMetersCount(),
                  builder: (context, snapshot) {
                    final count = snapshot.hasData ? snapshot.data.toString() : '...';
                    return _StatCard(
                      title: 'Active meters',
                      value: count,
                      icon: Icons.electric_meter_outlined,
                    );
                  },
                ),
              ),
            ],
          ),
          const SizedBox(height: 11),
          Row(
            children: [
              Expanded(
                child: StreamBuilder<int>(
                  stream: _backendService.getActiveReadersCount(),
                  builder: (context, snapshot) {
                    final count = snapshot.hasData ? snapshot.data.toString() : '...';
                    return _StatCard(
                      title: 'Active readers',
                      value: count,
                      icon: Icons.badge_outlined,
                    );
                  },
                ),
              ),
              const SizedBox(width: 11),
              const Expanded(
                child: _StatCard(
                  title: 'Needs review',
                  value: '7',
                  subtitle: 'Potential anomalies',
                  icon: Icons.error_outline,
                ),
              ),
            ],
          ),

          const SizedBox(height: 18),

          // Outage Alert
          Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(21),
              border: Border.all(color: MMColors.line),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 4,
                  height: 90,
                  decoration: BoxDecoration(
                    color: MMColors.amber,
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
                const SizedBox(width: 13),
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Potential outage hotspot',
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                          color: MMColors.ink,
                        ),
                      ),
                      SizedBox(height: 8),
                      Text(
                        'Homagama · 12 nearby reports',
                        style: TextStyle(
                          color: MMColors.muted,
                          fontSize: 13,
                        ),
                      ),
                      SizedBox(height: 9),
                      Text(
                        'Awaiting verification',
                        style: TextStyle(
                          color: MMColors.amber,
                          fontWeight: FontWeight.w700,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 24),

          // Quick Actions - All 7 Pages
          const Text(
            'Quick Actions',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w800,
              color: MMColors.ink,
            ),
          ),
          const SizedBox(height: 12),

          _ActionButton(
            title: 'Manage Users',
            icon: Icons.people_outline,
            onTap: () => openPage(
              context,
              const ManageUsersPage(),
            ),
          ),
          const SizedBox(height: 10),

          _ActionButton(
            title: 'Manage Meters',
            icon: Icons.electric_meter_outlined,
            onTap: () => openPage(
              context,
              const ManageMetersPage(),
            ),
          ),
          const SizedBox(height: 10),

          _ActionButton(
            title: 'Reader Assignments',
            icon: Icons.assignment_outlined,
            onTap: () => openPage(
              context,
              const MeterReaderAssignmentsPage(),
            ),
          ),
          const SizedBox(height: 10),

          _ActionButton(
            title: 'Reading Progress',
            icon: Icons.analytics_outlined,
            onTap: () => openPage(
              context,
              const ReadingProgressPage(),
            ),
          ),
          const SizedBox(height: 10),

          _ActionButton(
            title: 'Analytics & Reports',
            icon: Icons.bar_chart_rounded,
            onTap: () => openPage(
              context,
              const AnalyticsReportsPage(),
            ),
          ),
          const SizedBox(height: 10),

          _ActionButton(
            title: 'Outage Management',
            icon: Icons.warning_amber_rounded,
            onTap: () => openPage(
              context,
              const OutageManagementPage(),
            ),
          ),
          const SizedBox(height: 10),

          _ActionButton(
            title: 'Outage Map & Hotspots',
            icon: Icons.map_outlined,
            onTap: () => openPage(
              context,
              const OutageMapPage(),
            ),
          ),

          const SizedBox(height: 24),

          // Recent Activity
          const Text(
            'Recent Activity',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w800,
              color: MMColors.ink,
            ),
          ),
          const SizedBox(height: 12),

          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 5,
            ),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(21),
              border: Border.all(color: MMColors.line),
            ),
            child: const Column(
              children: [
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: Icon(
                    Icons.check_circle_outline,
                    color: MMColors.green,
                  ),
                  title: Text(
                    'Nimal Perera',
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  subtitle: Text('Route completion'),
                  trailing: Text(
                    '28 / 40',
                    style: TextStyle(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                Divider(
                  color: MMColors.line,
                  height: 1,
                ),
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: Icon(
                    Icons.warning_amber_rounded,
                    color: MMColors.amber,
                  ),
                  title: Text(
                    'Homagama',
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  subtitle: Text('Latest outage report'),
                  trailing: Text(
                    '14:32',
                    style: TextStyle(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 15),
          const Center(
            child: Text(
              'Live Firebase Connected',
              style: TextStyle(
                color: MMColors.green,
                fontSize: 11,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// Statistics Card
class _StatCard extends StatelessWidget {
  final String title;
  final String value;
  final String? subtitle;
  final IconData icon;

  const _StatCard({
    required this.title,
    required this.value,
    required this.icon,
    this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(21),
        border: Border.all(color: MMColors.line),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            icon,
            color: MMColors.ink,
            size: 24,
          ),
          const SizedBox(height: 10),
          Text(
            title,
            style: const TextStyle(
              color: MMColors.muted,
              fontSize: 12,
            ),
          ),
          const SizedBox(height: 5),
          Text(
            value,
            style: const TextStyle(
              color: MMColors.ink,
              fontSize: 23,
              fontWeight: FontWeight.w700,
            ),
          ),
          if (subtitle != null) ...[
            const SizedBox(height: 3),
            Text(
              subtitle!,
              style: const TextStyle(
                color: MMColors.muted,
                fontSize: 10,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

// Yellow Quick Action Button
class _ActionButton extends StatelessWidget {
  final String title;
  final IconData icon;
  final VoidCallback onTap;

  const _ActionButton({
    required this.title,
    required this.icon,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: MMColors.yellow,
      borderRadius: BorderRadius.circular(14),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: 17,
            vertical: 15,
          ),
          child: Row(
            children: [
              Icon(icon, color: MMColors.ink),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(
                    color: MMColors.ink,
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              const Icon(
                Icons.arrow_forward_rounded,
                color: MMColors.ink,
              ),
            ],
          ),
        ),
      ),
    );
  }
}