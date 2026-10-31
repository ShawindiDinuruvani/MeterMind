import 'package:flutter/material.dart';
import '../services/admin_backend_service.dart';

class MeterReaderAssignmentsPage extends StatefulWidget {
  const MeterReaderAssignmentsPage({super.key});

  @override
  State<MeterReaderAssignmentsPage> createState() =>
      _MeterReaderAssignmentsPageState();
}

class _MeterReaderAssignmentsPageState
    extends State<MeterReaderAssignmentsPage> {
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
            onPressed: () async {
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

              try {
                await _backendService.addMeterAssignment(
                  reader,
                  route,
                  meterCount,
                );

                if (dialogContext.mounted) {
                  Navigator.pop(dialogContext);
                }

                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text(
                        'Route assignment added successfully!',
                      ),
                    ),
                  );
                }
              } catch (e) {
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        'Failed to add assignment: $e',
                      ),
                    ),
                  );
                }
              }
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
        elevation: 0,
      ),
      body: StreamBuilder<List<dynamic>>(
        stream: _backendService.getMeterAssignments(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(
              child: Text('Error: ${snapshot.error}'),
            );
          }

          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(
                color: yellow,
              ),
            );
          }

          final assignments = snapshot.data ?? [];

          final filtered = assignments.where((rawItem) {
            final item = Map<String, dynamic>.from(
              rawItem as Map,
            );

            final reader =
                (item['reader'] ?? '').toString().toLowerCase();

            final route =
                (item['route'] ?? '').toString().toLowerCase();

            final status =
                (item['status'] ?? 'Pending').toString();

            final query = searchText.toLowerCase();

            final matchesSearch =
                reader.contains(query) || route.contains(query);

            final matchesStatus =
                selectedStatus == 'All' ||
                status == selectedStatus;

            return matchesSearch && matchesStatus;
          }).toList();

          final completedCount = assignments.where((rawItem) {
            final item = Map<String, dynamic>.from(
              rawItem as Map,
            );

            return item['status'] == 'Completed';
          }).length;

          return ListView(
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

              // Assignment Summary
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

              // Assign New Route
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

              // Search
              TextField(
                onChanged: (value) {
                  setState(() {
                    searchText = value;
                  });
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
                    setState(() {
                      selectedStatus = value;
                    });
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
                )
              else
                ...filtered.map((rawItem) {
                  final item = Map<String, dynamic>.from(
                    rawItem as Map,
                  );

                  final total =
                      (item['meters'] as num?)?.toInt() ?? 0;

                  final completed =
                      (item['completed'] as num?)?.toInt() ?? 0;

                  final progress = total > 0
                      ? (completed / total).clamp(0.0, 1.0)
                      : 0.0;

                  final status =
                      (item['status'] ?? 'Pending').toString();

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
                              padding: const EdgeInsets.all(11),
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
                              child: Text(
                                (item['reader'] ?? 'Unknown reader')
                                    .toString(),
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
                          (item['route'] ?? 'Unknown route')
                              .toString(),
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
                  'Live Firebase Connected',
                  style: TextStyle(
                    color: green,
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
