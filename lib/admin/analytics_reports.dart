
import 'package:flutter/material.dart';

class AnalyticsReportsPage extends StatelessWidget {
  const AnalyticsReportsPage({super.key});

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

          Container(
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
            child: const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Monthly reading completion',
                  style: TextStyle(
                    color: Color(0xFFC5D0C3),
                  ),
                ),
                SizedBox(height: 12),
                Text(
                  '76%',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 43,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                SizedBox(height: 14),
                LinearProgressIndicator(
                  value: 0.76,
                  minHeight: 9,
                  backgroundColor: Color(0xFF566057),
                  color: yellow,
                  borderRadius: BorderRadius.all(
                    Radius.circular(10),
                  ),
                ),
                SizedBox(height: 12),
                Text(
                  '1,824 completed · 576 pending',
                  style: TextStyle(
                    color: Color(0xFFC5D0C3),
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 18),

          Row(
            children: [
              Expanded(
                child: _metric(
                  'Active meters',
                  '2,400',
                  Icons.electric_meter_outlined,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _metric(
                  'Active readers',
                  '18',
                  Icons.badge_outlined,
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

          _insight(
            icon: Icons.check_circle_outline,
            title: 'Completed readings',
            value: '1,824',
            color: green,
          ),
          _insight(
            icon: Icons.pending_actions_outlined,
            title: 'Pending readings',
            value: '576',
            color: amber,
          ),
          _insight(
            icon: Icons.warning_amber_rounded,
            title: 'Potential anomalies',
            value: '7',
            color: amber,
          ),
          _insight(
            icon: Icons.bolt_outlined,
            title: 'Nearby outage reports',
            value: '12',
            color: amber,
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
                    crossAxisAlignment:
                        CrossAxisAlignment.start,
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
                        'Report preview · Demo data',
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
              'Illustrative analytics · Backend not connected',
              style: TextStyle(
                color: muted,
                fontSize: 11,
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
