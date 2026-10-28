
import 'package:flutter/material.dart';
import 'manage_users.dart';
import 'manage_meters.dart';

// MeterMind Smart Energy Glass Colors
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

// Run Admin Dashboard independently
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
          centerTitle: false,
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
            height: 68,
            backgroundColor: Colors.white,
            indicatorColor: Color(0x33F5C542),
            selectedIndex: selectedIndex,
            labelBehavior:
                NavigationDestinationLabelBehavior.alwaysShow,
            onDestinationSelected: (index) {
              setState(() {
                selectedIndex = index;
              });
            },
            destinations: const [
              NavigationDestination(
                icon: Icon(Icons.dashboard_outlined),
                selectedIcon: Icon(
                  Icons.dashboard_rounded,
                  color: MMColors.ink,
                ),
                label: 'Dashboard',
              ),
              NavigationDestination(
                icon: Icon(Icons.people_outline),
                selectedIcon: Icon(
                  Icons.people,
                  color: MMColors.ink,
                ),
                label: 'Users',
              ),
              NavigationDestination(
                icon: Icon(Icons.electric_meter_outlined),
                selectedIcon: Icon(
                  Icons.electric_meter,
                  color: MMColors.ink,
                ),
                label: 'Meters',
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class DashboardHome extends StatelessWidget {
  const DashboardHome({super.key});

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
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text(
                    'Notifications will be available soon.',
                  ),
                ),
              );
            },
            icon: const Icon(
              Icons.notifications_none_rounded,
            ),
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
            'Homagama district · Demo overview',
            style: TextStyle(
              color: MMColors.muted,
              fontSize: 13,
            ),
          ),
          const SizedBox(height: 18),

          // Dark Glass Coverage Card
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
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  "Today's reading coverage",
                  style: TextStyle(
                    color: Color(0xFFC5D0C3),
                    fontSize: 13,
                  ),
                ),
                const SizedBox(height: 10),
                const Row(
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
                const SizedBox(height: 14),
                ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: const LinearProgressIndicator(
                    value: 0.76,
                    minHeight: 8,
                    backgroundColor: Color(0xFF566057),
                    valueColor: AlwaysStoppedAnimation<Color>(
                      MMColors.yellow,
                    ),
                  ),
                ),
                const SizedBox(height: 17),
                const Row(
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

          // Statistics Grid
          const Row(
            children: [
              Expanded(
                child: _StatCard(
                  title: 'Customers',
                  value: '2,400',
                  icon: Icons.people_outline,
                ),
              ),
              SizedBox(width: 11),
              Expanded(
                child: _StatCard(
                  title: 'Active meters',
                  value: '2,400',
                  icon: Icons.electric_meter_outlined,
                ),
              ),
            ],
          ),
          const SizedBox(height: 11),
          const Row(
            children: [
              Expanded(
                child: _StatCard(
                  title: 'Active readers',
                  value: '18',
                  icon: Icons.badge_outlined,
                ),
              ),
              SizedBox(width: 11),
              Expanded(
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
                    crossAxisAlignment:
                        CrossAxisAlignment.start,
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
          const Text(
            'Quick Actions',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w800,
              color: MMColors.ink,
            ),
          ),
          const SizedBox(height: 12),

          // Working navigation to existing pages
          _ActionButton(
            title: 'Manage Users',
            icon: Icons.people_outline,
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const ManageUsersPage(),
                ),
              );
            },
          ),
          const SizedBox(height: 10),
          _ActionButton(
            title: 'Manage Meters',
            icon: Icons.electric_meter_outlined,
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const ManageMetersPage(),
                ),
              );
            },
          ),

          const SizedBox(height: 24),
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
                Divider(color: MMColors.line, height: 1),
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
              'Demo data · Backend not connected',
              style: TextStyle(
                color: MMColors.muted,
                fontSize: 11,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

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
          Icon(icon, color: MMColors.ink, size: 24),
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
