
import 'package:flutter/material.dart';

class MeterReaderAssignmentsPage extends StatefulWidget {
  const MeterReaderAssignmentsPage({super.key});

  @override
  State<MeterReaderAssignmentsPage> createState() =>
      _MeterReaderAssignmentsPageState();
}

class _MeterReaderAssignmentsPageState
    extends State<MeterReaderAssignmentsPage> {
  static const yellow = Color(0xFFF5C542);
  static const ink = Color(0xFF202523);
  static const soft = Color(0xFFF4F5F0);
  static const muted = Color(0xFF626B66);
  static const line = Color(0xFFDEE3DB);
  static const green = Color(0xFF237548);
  static const amber = Color(0xFF936715);

  String searchText = '';
  String selectedStatus = 'All';

  final List<Map<String, dynamic>> assignments = [
    {
      'reader': 'Nimal Perera',
      'route': 'Homagama North',
      'meters': 40,
      'completed': 28,
      'status': 'In Progress',
    },
    {
      'reader': 'Kamal Silva',
      'route': 'Homagama South',
      'meters': 35,
      'completed': 35,
      'status': 'Completed',
    },
    {
      'reader': 'Saman Kumara',
      'route': 'Maharagama',
      'meters': 30,
      'completed': 0,
      'status': 'Pending',
    },
  ];

  void showAssignRouteDialog() {
    final readerController = TextEditingController();
    final routeController = TextEditingController();
    final metersController = TextEditingController();

    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(21),
        ),
        title: const Text(
          'Assign New Route',
          style: TextStyle(
            color: ink,
            fontWeight: FontWeight.w800,
          ),
        ),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: readerController,
                decoration: const InputDecoration(
                  labelText: 'Meter Reader Name',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: routeController,
                decoration: const InputDecoration(
                  labelText: 'Route / Area',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: metersController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'Number of Meters',
                  border: OutlineInputBorder(),
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text(
              'Cancel',
              style: TextStyle(color: muted),
            ),
          ),
          FilledButton(
            style: FilledButton.styleFrom(
              backgroundColor: yellow,
              foregroundColor: ink,
            ),
            onPressed: () {
              final reader = readerController.text.trim();
              final route = routeController.text.trim();
              final meterCount =
                  int.tryParse(metersController.text.trim());

              if (reader.isEmpty ||
                  route.isEmpty ||
                  meterCount == null ||
                  meterCount <= 0) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text(
                      'Please enter valid assignment details.',
                    ),
                  ),
                );
                return;
              }

              setState(() {
                assignments.add({
                  'reader': reader,
                  'route': route,
                  'meters': meterCount,
                  'completed': 0,
                  'status': 'Pending',
                });
              });

              Navigator.pop(dialogContext);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text(
                    'Demo route assignment added.',
                  ),
                ),
              );
            },
            child: const Text('Assign Route'),
          ),
        ],
      ),
    ).then((_) {
      readerController.dispose();
      routeController.dispose();
      metersController.dispose();
    });
  }

  @override
  Widget build(BuildContext context) {
    final filtered = assignments.where((item) {
      final query = searchText.toLowerCase();

      final matchesSearch =
          (item['reader'] as String)
                  .toLowerCase()
                  .contains(query) ||
              (item['route'] as String)
                  .toLowerCase()
                  .contains(query);

      final matchesStatus =
          selectedStatus == 'All' ||
          item['status'] == selectedStatus;

      return matchesSearch && matchesStatus;
    }).toList();

    final completedCount = assignments
        .where((item) => item['status'] == 'Completed')
        .length;

    return Scaffold(
      backgroundColor: soft,
      appBar: AppBar(
        title: const Text(
          'Reader Assignments',
          style: TextStyle(
            fontWeight: FontWeight.w800,
          ),
        ),
        backgroundColor: soft,
        foregroundColor: ink,
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
            'Route assignments.',
            style: TextStyle(
              color: ink,
              fontSize: 27,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 5),
          const Text(
            'Assign routes and monitor meter readers.',
            style: TextStyle(
              color: muted,
              fontSize: 13,
            ),
          ),
          const SizedBox(height: 18),

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
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Total route assignments',
                  style: TextStyle(
                    color: Color(0xFFC5D0C3),
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  '${assignments.length}',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 45,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  '$completedCount completed · '
                  '${assignments.length - completedCount} remaining',
                  style: const TextStyle(
                    color: Color(0xFFC5D0C3),
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 18),

          SizedBox(
            width: double.infinity,
            child: FilledButton.icon(
              onPressed: showAssignRouteDialog,
              style: FilledButton.styleFrom(
                backgroundColor: yellow,
                foregroundColor: ink,
                padding: const EdgeInsets.symmetric(
                  vertical: 15,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
              icon: const Icon(Icons.add_road),
              label: const Text(
                'Assign New Route',
                style: TextStyle(
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ),

          const SizedBox(height: 20),

          TextField(
            onChanged: (value) {
              setState(() => searchText = value);
            },
            decoration: InputDecoration(
              hintText: 'Search readers or routes...',
              prefixIcon: const Icon(Icons.search),
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

          DropdownButtonFormField<String>(
            initialValue: selectedStatus,
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
              return DropdownMenuItem(
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
                'Assigned Routes',
                style: TextStyle(
                  color: ink,
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                ),
              ),
              Text(
                '${filtered.length} routes',
                style: const TextStyle(
                  color: muted,
                  fontSize: 12,
                ),
              ),
            ],
          ),

          const SizedBox(height: 12),

          if (filtered.isEmpty)
            const Padding(
              padding: EdgeInsets.all(30),
              child: Center(
                child: Text('No assignments found'),
              ),
            ),

          ...filtered.map((item) {
            final total = item['meters'] as int;
            final completed = item['completed'] as int;
            final progress =
                total > 0 ? completed / total : 0.0;
            final status = item['status'] as String;

            final statusColor =
                status == 'Completed'
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
                        padding: const EdgeInsets.all(11),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF0F1E9),
                          borderRadius:
                              BorderRadius.circular(13),
                        ),
                        child: const Icon(
                          Icons.badge_outlined,
                          color: ink,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          item['reader'] as String,
                          style: const TextStyle(
                            color: ink,
                            fontSize: 15,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 13),
                  Text(
                    item['route'] as String,
                    style: const TextStyle(
                      color: muted,
                      fontSize: 13,
                    ),
                  ),
                  const SizedBox(height: 13),
                  Row(
                    mainAxisAlignment:
                        MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        '$completed / $total meters',
                        style: const TextStyle(
                          color: ink,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      Text(
                        '${(progress * 100).round()}%',
                        style: const TextStyle(
                          color: ink,
                          fontWeight: FontWeight.w700,
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
                      backgroundColor:
                          const Color(0xFFE7E9E3),
                      valueColor:
                          const AlwaysStoppedAnimation<Color>(
                        yellow,
                      ),
                    ),
                  ),
                  const SizedBox(height: 14),
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 11,
                        vertical: 7,
                      ),
                      decoration: BoxDecoration(
                        color: statusColor.withValues(
                          alpha: 0.10,
                        ),
                        borderRadius:
                            BorderRadius.circular(20),
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
                  ),
                ],
              ),
            );
          }),

          const SizedBox(height: 10),
          const Center(
            child: Text(
              'Demo assignments · Backend not connected',
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
}
