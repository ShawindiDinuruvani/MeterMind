import 'package:flutter/material.dart';
import '../services/admin_backend_service.dart';

class AnalyticsReportsPage extends StatefulWidget {
  const AnalyticsReportsPage({super.key});

  @override
  State<AnalyticsReportsPage> createState() => _AnalyticsReportsPageState();
}

class _AnalyticsReportsPageState extends State<AnalyticsReportsPage> {
  final AdminBackendService _backendService = AdminBackendService();

  static const yellow = Color(0xFFF5C542);
  static const ink = Color(0xFF202523);
  static const soft = Color(0xFFF4F5F0);
  static const muted = Color(0xFF626B66);
  static const line = Color(0xFFDEE3DB);
  static const green = Color(0xFF237548);
  static const amber = Color(0xFF936715);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: soft,
      appBar: AppBar(
        title: const Text(
          'Analytics & Reports',
          style: TextStyle(fontWeight: FontWeight.w800),
        ),
        backgroundColor: soft,
        foregroundColor: ink,
      ),
      body: ListView(
        padding: const EdgeInsets.all(19),
        children: [
          const Text(
            'ENERGY INSIGHTS',
            style: TextStyle(
              color: muted,
              fontSize: 11,
              fontWeight: FontWeight.w700,
              letterSpacing: 2,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Understand the numbers.',
            style: TextStyle(
              color: ink,
              fontSize: 27,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 6),
          const Text(
            'Reading performance and outage trends.',
            style: TextStyle(color: muted),
          ),
          const SizedBox(height: 20),

          // 1. Monthly reading completion Card (Stream-powered)
          StreamBuilder>(
            stream: _backendService.getAssignmentProgressSummary(),
            builder: (context, snapshot) {
              final data = snapshot.data ?? {};
              final int totalCompleted = data['totalCompleted'] ?? 0;
              final int totalAssigned = data['totalAssigned'] ?? 0;
              final double percentage = data['percentage'] ?? 0.0;
              final int pending = totalAssigned > totalCompleted ? totalAssigned - totalCompleted : 0;
              final double progressValue = totalAssigned > 0 ? (percentage / 100).clamp(0.0, 1.0) : 0.0;

              return Container(
                padding: const EdgeInsets.all(22),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [
                      Color(0xFF353E36),
                      Color(0xFF1C2421),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(21),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Monthly reading completion',
                      style: TextStyle(
                        color: Color(0xFFC5D0C3),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      '${percentage.toStringAsFixed(0)}%',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 43,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 14),
                    LinearProgressIndicator(
                      value: progressValue,
                      minHeight: 9,
                      backgroundColor: const Color(0xFF566057),
                      color: yellow,
                      borderRadius: const BorderRadius.all(
                        Radius.circular(10),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      '$totalCompleted completed · $pending pending',
                      style: const TextStyle(
                        color: Color(0xFFC5D0C3),
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              );
            },
          ),

          const SizedBox(height: 18),

          // 2. Active Meters and Readers Metrics
          Row(
            children: [
              Expanded(
                child: StreamBuilder<int>(
                  stream: _backendService.getActiveMetersCount(),
                  builder: (context, snapshot) {
                    final meters = snapshot.hasData ? snapshot.data.toString() : '...';
                    return _metric(
                      'Active meters',
                      meters,
                      Icons.electric_meter_outlined,
                    );
                  },
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: StreamBuilder<int>(
                  stream: _backendService.getActiveReadersCount(),
                  builder: (context, snapshot) {
                    final readers = snapshot.hasData ? snapshot.data.toString() : '...';
                    return _metric(
                      'Active readers',
                      readers,
                      Icons.badge_outlined,
                    );
                  },
                ),
              ),
            ],
          ),

          const SizedBox(height: 23),
          const Text(
            'Operational Overview',
            style: TextStyle(
              color: ink,
              fontSize: 19,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 12),

          // 3. Operational Insights using Live Streams
          StreamBuilder>(
            stream: _backendService.getAssignmentProgressSummary(),
            builder: (context, assignSnapshot) {
              final assignData = assignSnapshot.data ?? {};
              final completed = assignData['totalCompleted']?.toString() ?? '0';
              final assigned = assignData['totalAssigned']?.toInt() ?? 0;
              final pendingVal = assigned > int.parse(completed) ? assigned - int.parse(completed) : 0;

              return Column(
                children: [
                  _insight(
                    icon: Icons.check_circle_outline,
                    title: 'Completed readings',
                    value: completed,
                    color: green,
                  ),
                  _insight(
                    icon: Icons.pending_actions_outlined,
                    title: 'Pending readings',
                    value: pendingVal.toString(),
                    color: amber,
                  ),
                ],
              );
            },
          ),

          StreamBuilder<int>(
            stream: _backendService.getPendingOutagesCount(),
            builder: (context, outageSnapshot) {
              final outagesCount = outageSnapshot.hasData ? outageSnapshot.data.toString() : '...';
              return Column(
                children: [
                  _insight(
                    icon: Icons.warning_amber_rounded,
                    title: 'Potential anomalies',
                    value: '7',
                    color: amber,
                  ),
                  _insight(
                    icon: Icons.bolt_outlined,
                    title: 'Nearby outage reports',
                    value: outagesCount,
                    color: amber,
                  ),
                ],
              );
            },
          ),

          const SizedBox(height: 20),
          const Text(
            'Reports',
            style: TextStyle(
              color: ink,
              fontSize: 19,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 12),

          Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(21),
              border: Border.all(color: line),
            ),
            child: const Row(
              children: [
                Icon(Icons.description_outlined, color: ink),
                SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Reading Summary Report',
                        style: TextStyle(
                          color: ink,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      SizedBox(height: 5),
                      Text(
                        'Live Firestore connected report',
                        style: TextStyle(
                          color: muted,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
                Icon(Icons.insert_chart_outlined, color: ink),
              ],
            ),
          ),

          const SizedBox(height: 18),
          const Center(
            child: Text(
              'Live Firebase Connected · Analytics Active',
              style: TextStyle(
                color: green,
                fontSize: 11,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _metric(String title, String value, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(17),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(21),
        border: Border.all(color: line),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: ink),
          const SizedBox(height: 12),
          Text(
            title,
            style: const TextStyle(
              color: muted,
              fontSize: 12,
            ),
          ),
          const SizedBox(height: 5),
          Text(
            value,
            style: const TextStyle(
              color: ink,
              fontSize: 25,
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
    );
  }

  Widget _insight({
    required IconData icon,
    required String title,
    required String value,
    required Color color,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(17),
        border: Border.all(color: line),
      ),
      child: Row(
        children: [
          Icon(icon, color: color),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              title,
              style: const TextStyle(
                color: ink,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          Text(
            value,
            style: const TextStyle(
              color: ink,
              fontSize: 17,
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
    );
  }
}