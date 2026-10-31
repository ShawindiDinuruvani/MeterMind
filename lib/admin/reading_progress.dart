import 'package:flutter/material.dart';
import '../services/admin_backend_service.dart';

class ReadingProgressPage extends StatefulWidget {
  const ReadingProgressPage({super.key});

  @override
  State<ReadingProgressPage> createState() =>
      _ReadingProgressPageState();
}

class _ReadingProgressPageState extends State<ReadingProgressPage> {
  static const Color yellow = Color(0xFFF5C542);
  static const Color ink = Color(0xFF202523);
  static const Color soft = Color(0xFFF4F5F0);
  static const Color muted = Color(0xFF626B66);
  static const Color line = Color(0xFFDEE3DB);
  static const Color green = Color(0xFF237548);
  static const Color amber = Color(0xFF936715);

  final AdminBackendService _backendService = AdminBackendService();

  String searchText = '';
  String selectedStatus = 'All';

  String getStatus(int completed, int total) {
    if (total > 0 && completed >= total) return 'Completed';
    if (completed == 0) return 'Pending';
    return 'In Progress';
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
      stream: _backendService.getReadingProgress(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Scaffold(
            backgroundColor: soft,
            appBar: AppBar(
              title: const Text(
                'Reading Progress',
                style: TextStyle(fontWeight: FontWeight.w800),
              ),
              backgroundColor: soft,
              foregroundColor: ink,
              elevation: 0,
            ),
            body: const Center(
              child: CircularProgressIndicator(color: yellow),
            ),
          );
        }

        if (snapshot.hasError) {
          return Scaffold(
            backgroundColor: soft,
            appBar: AppBar(
              title: const Text('Reading Progress'),
              backgroundColor: soft,
              foregroundColor: ink,
            ),
            body: const Center(
              child: Padding(
                padding: EdgeInsets.all(24),
                child: Text(
                  'Unable to load reading progress. Please try again.',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: muted),
                ),
              ),
            ),
          );
        }

        final readings = (snapshot.data as List?) ?? [];

        final totalMeters = readings.fold<int>(
          0,
          (sum, item) =>
              sum + ((item['total'] as num?)?.toInt() ?? 0),
        );

        final completedMeters = readings.fold<int>(
          0,
          (sum, item) =>
              sum + ((item['completed'] as num?)?.toInt() ?? 0),
        );

        final pendingMeters =
            (totalMeters - completedMeters).clamp(0, totalMeters);

        final overallProgress = totalMeters == 0
            ? 0.0
            : (completedMeters / totalMeters).clamp(0.0, 1.0);

        final filteredReadings = readings.where((item) {
          final reader =
              (item['reader'] ?? '').toString().toLowerCase();
          final area =
              (item['area'] ?? '').toString().toLowerCase();
          final query = searchText.toLowerCase();

          final completed =
              (item['completed'] as num?)?.toInt() ?? 0;
          final total = (item['total'] as num?)?.toInt() ?? 0;

          final status = getStatus(completed, total);

          final matchesSearch =
              reader.contains(query) || area.contains(query);

          final matchesStatus =
              selectedStatus == 'All' || status == selectedStatus;

          return matchesSearch && matchesStatus;
        }).toList();

        return Scaffold(
          backgroundColor: soft,
          appBar: AppBar(
            title: const Text(
              'Reading Progress',
              style: TextStyle(
                fontWeight: FontWeight.w800,
                letterSpacing: -0.5,
              ),
            ),
            backgroundColor: soft,
            foregroundColor: ink,
            elevation: 0,
          ),
          body: ListView(
            padding: const EdgeInsets.fromLTRB(19, 15, 19, 30),
            children: [
              const Text(
                'SUPERVISOR WORKSPACE',
                style: TextStyle(
                  color: muted,
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 2,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Reading progress.',
                style: TextStyle(
                  color: ink,
                  fontSize: 28,
                  fontWeight: FontWeight.w800,
                  letterSpacing: -1,
                ),
              ),
              const SizedBox(height: 5),
              const Text(
                'Monitor meter reading completion by area (Live Firestore).',
                style: TextStyle(
                  color: muted,
                  fontSize: 13,
                ),
              ),
              const SizedBox(height: 18),

              // Overall Progress Card
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
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Overall reading completion',
                      style: TextStyle(
                        color: Color(0xFFC5D0C3),
                        fontSize: 13,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      '${(overallProgress * 100).round()}%',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 45,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 15),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(10),
                      child: LinearProgressIndicator(
                        value: overallProgress,
                        minHeight: 9,
                        backgroundColor: const Color(0xFF566057),
                        valueColor:
                            const AlwaysStoppedAnimation<Color>(yellow),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      '$completedMeters completed · $pendingMeters pending',
                      style: const TextStyle(
                        color: Color(0xFFC5D0C3),
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 13),

              // Summary Cards
              Row(
                children: [
                  Expanded(
                    child: _summaryCard(
                      'Total Meters',
                      '$totalMeters',
                      Icons.electric_meter_outlined,
                    ),
                  ),
                  const SizedBox(width: 11),
                  Expanded(
                    child: _summaryCard(
                      'Completed',
                      '$completedMeters',
                      Icons.check_circle_outline,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 11),
              Row(
                children: [
                  Expanded(
                    child: _summaryCard(
                      'Pending',
                      '$pendingMeters',
                      Icons.schedule_outlined,
                    ),
                  ),
                  const SizedBox(width: 11),
                  Expanded(
                    child: _summaryCard(
                      'Readers',
                      '${readings.length}',
                      Icons.badge_outlined,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 24),

              // Search
              TextField(
                onChanged: (value) {
                  setState(() => searchText = value);
                },
                decoration: InputDecoration(
                  hintText: 'Search reader or area...',
                  prefixIcon: const Icon(
                    Icons.search,
                    color: muted,
                  ),
                  filled: true,
                  fillColor: Colors.white,
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: const BorderSide(color: line),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: const BorderSide(
                      color: yellow,
                      width: 2,
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 12),

              // Status Filter
              DropdownButtonFormField<String>(
                value: selectedStatus,
                decoration: InputDecoration(
                  labelText: 'Filter by Status',
                  filled: true,
                  fillColor: Colors.white,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
                items: [
                  'All',
                  'Pending',
                  'In Progress',
                  'Completed',
                ].map((status) {
                  return DropdownMenuItem<String>(
                    value: status,
                    child: Text(status),
                  );
                }).toList(),
                onChanged: (value) {
                  if (value != null) {
                    setState(() => selectedStatus = value);
                  }
                },
              ),

              const SizedBox(height: 24),

              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Reader Progress',
                    style: TextStyle(
                      color: ink,
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  Text(
                    '${filteredReadings.length} readers',
                    style: const TextStyle(
                      color: muted,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 12),

              if (filteredReadings.isEmpty)
                Container(
                  padding: const EdgeInsets.all(28),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(21),
                    border: Border.all(color: line),
                  ),
                  child: const Center(
                    child: Text(
                      'No reading records found',
                      style: TextStyle(color: muted),
                    ),
                  ),
                ),

              ...filteredReadings.map((item) {
                final total =
                    (item['total'] as num?)?.toInt() ?? 0;
                final completed =
                    (item['completed'] as num?)?.toInt() ?? 0;

                final progress = total == 0
                    ? 0.0
                    : (completed / total).clamp(0.0, 1.0);

                final status = getStatus(completed, total);

                final statusColor = status == 'Completed'
                    ? green
                    : status == 'In Progress'
                        ? amber
                        : muted;

                return Container(
                  margin: const EdgeInsets.only(bottom: 12),
                  padding: const EdgeInsets.all(17),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(21),
                    border: Border.all(color: line),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            width: 44,
                            height: 44,
                            decoration: BoxDecoration(
                              color: const Color(0xFFF0F1E9),
                              borderRadius: BorderRadius.circular(13),
                            ),
                            child: const Icon(
                              Icons.badge_outlined,
                              color: ink,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment:
                                  CrossAxisAlignment.start,
                              children: [
                                Text(
                                  (item['reader'] ?? 'Unknown Reader')
                                      .toString(),
                                  style: const TextStyle(
                                    color: ink,
                                    fontSize: 15,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  (item['area'] ?? 'Unknown Area')
                                      .toString(),
                                  style: const TextStyle(
                                    color: muted,
                                    fontSize: 12,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      Row(
                        mainAxisAlignment:
                            MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            '$completed / $total readings',
                            style: const TextStyle(
                              color: ink,
                              fontWeight: FontWeight.w700,
                              fontSize: 13,
                            ),
                          ),
                          Text(
                            '${(progress * 100).round()}%',
                            style: const TextStyle(
                              color: ink,
                              fontWeight: FontWeight.w700,
                              fontSize: 13,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 9),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: LinearProgressIndicator(
                          value: progress,
                          minHeight: 8,
                          backgroundColor: const Color(0xFFE7E9E3),
                          valueColor:
                              const AlwaysStoppedAnimation<Color>(
                            yellow,
                          ),
                        ),
                      ),
                      const SizedBox(height: 14),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 11,
                          vertical: 7,
                        ),
                        decoration: BoxDecoration(
                          color: statusColor.withValues(alpha: 0.10),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          status,
                          style: TextStyle(
                            color: statusColor,
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              }),

              const SizedBox(height: 12),
              const Center(
                child: Text(
                  'Live Firestore synchronization active',
                  style: TextStyle(
                    color: muted,
                    fontSize: 11,
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _summaryCard(
    String title,
    String value,
    IconData icon,
  ) {
    return Container(
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(21),
        border: Border.all(color: line),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: ink, size: 24),
          const SizedBox(height: 10),
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
              fontSize: 23,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}