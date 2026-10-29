
import 'package:flutter/material.dart';

class OutageManagementPage extends StatefulWidget {
  const OutageManagementPage({super.key});

  @override
  State<OutageManagementPage> createState() =>
      _OutageManagementPageState();
}

class _OutageManagementPageState extends State<OutageManagementPage> {
  static const yellow = Color(0xFFF5C542);
  static const ink = Color(0xFF202523);
  static const soft = Color(0xFFF4F5F0);
  static const muted = Color(0xFF626B66);
  static const line = Color(0xFFDEE3DB);
  static const green = Color(0xFF237548);
  static const amber = Color(0xFF936715);
  static const red = Color(0xFFB94338);

  String selectedStatus = 'All';
  String searchText = '';

  final List<Map<String, String>> reports = [
    {
      'id': 'OUT-1001',
      'location': 'Homagama',
      'reportedBy': 'Nimal Perera',
      'time': '14:32',
      'details': 'Power interruption reported in the area.',
      'status': 'Pending',
    },
    {
      'id': 'OUT-1002',
      'location': 'Maharagama',
      'reportedBy': 'Amali Fernando',
      'time': '12:15',
      'details': 'Multiple households reported no electricity.',
      'status': 'Investigating',
    },
    {
      'id': 'OUT-1003',
      'location': 'Kottawa',
      'reportedBy': 'Saman Kumara',
      'time': '09:40',
      'details': 'Electricity supply has been restored.',
      'status': 'Resolved',
    },
    {
      'id': 'OUT-1004',
      'location': 'Pannipitiya',
      'reportedBy': 'Kamal Silva',
      'time': '08:25',
      'details': 'Unexpected power interruption reported.',
      'status': 'Pending',
    },
  ];

  Color statusColor(String status) {
    switch (status) {
      case 'Resolved':
        return green;
      case 'Investigating':
        return const Color(0xFF306F94);
      default:
        return amber;
    }
  }

  Color statusBackground(String status) {
    switch (status) {
      case 'Resolved':
        return const Color(0xFFE7F2E9);
      case 'Investigating':
        return const Color(0xFFE8F1F7);
      default:
        return const Color(0xFFFFF5D9);
    }
  }

  void updateStatus(Map<String, String> report, String status) {
    setState(() {
      report['status'] = status;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          '${report['id']} changed to $status (demo only)',
        ),
      ),
    );
  }

  void showReportDetails(Map<String, String> report) {
    showDialog(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(21),
          ),
          title: Text(
            report['id']!,
            style: const TextStyle(
              color: ink,
              fontWeight: FontWeight.w800,
            ),
          ),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _detailRow('Location', report['location']!),
                _detailRow('Reported by', report['reportedBy']!),
                _detailRow('Time', report['time']!),
                _detailRow('Status', report['status']!),
                const SizedBox(height: 8),
                const Text(
                  'Description',
                  style: TextStyle(
                    color: muted,
                    fontSize: 12,
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  report['details']!,
                  style: const TextStyle(
                    color: ink,
                    fontSize: 13,
                  ),
                ),
                const SizedBox(height: 12),
                const Text(
                  'Reports are unverified until confirmed.',
                  style: TextStyle(
                    color: amber,
                    fontSize: 11,
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: const Text(
                'Close',
                style: TextStyle(color: ink),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _detailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 11),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 90,
            child: Text(
              label,
              style: const TextStyle(
                color: muted,
                fontSize: 12,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                color: ink,
                fontSize: 13,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final filteredReports = reports.where((report) {
      final query = searchText.toLowerCase();

      final matchesSearch =
          report['id']!.toLowerCase().contains(query) ||
          report['location']!.toLowerCase().contains(query) ||
          report['reportedBy']!.toLowerCase().contains(query);

      final matchesStatus =
          selectedStatus == 'All' ||
          report['status'] == selectedStatus;

      return matchesSearch && matchesStatus;
    }).toList();

    final pendingCount = reports
        .where((report) => report['status'] == 'Pending')
        .length;

    final investigatingCount = reports
        .where((report) => report['status'] == 'Investigating')
        .length;

    return Scaffold(
      backgroundColor: soft,
      appBar: AppBar(
        backgroundColor: soft,
        foregroundColor: ink,
        title: const Text(
          'Outage Management',
          style: TextStyle(
            fontWeight: FontWeight.w800,
          ),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(19, 15, 19, 30),
        children: [
          const Text(
            'OUTAGE OPERATIONS',
            style: TextStyle(
              color: muted,
              fontSize: 11,
              fontWeight: FontWeight.w700,
              letterSpacing: 2,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Outage reports.',
            style: TextStyle(
              color: ink,
              fontSize: 28,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 6),
          const Text(
            'Review and monitor reported power interruptions.',
            style: TextStyle(
              color: muted,
              fontSize: 13,
            ),
          ),
          const SizedBox(height: 18),

          // Dark Summary Card
          Container(
            padding: const EdgeInsets.all(23),
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
                  'Total outage reports',
                  style: TextStyle(
                    color: Color(0xFFC5D0C3),
                    fontSize: 13,
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  '${reports.length}',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 45,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  '$pendingCount pending · '
                  '$investigatingCount investigating',
                  style: const TextStyle(
                    color: Color(0xFFC5D0C3),
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 18),

          // Search
          TextField(
            decoration: InputDecoration(
              hintText: 'Search outage reports...',
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
            onChanged: (value) {
              setState(() {
                searchText = value;
              });
            },
          ),

          const SizedBox(height: 12),

          // Status Filter
          DropdownButtonFormField<String>(
            initialValue: selectedStatus,
            decoration: InputDecoration(
              labelText: 'Filter by Status',
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
            items: [
              'All',
              'Pending',
              'Investigating',
              'Resolved',
            ].map((status) {
              return DropdownMenuItem(
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

          const SizedBox(height: 23),

          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Reported Outages',
                style: TextStyle(
                  color: ink,
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                ),
              ),
              Text(
                '${filteredReports.length} reports',
                style: const TextStyle(
                  color: muted,
                  fontSize: 12,
                ),
              ),
            ],
          ),

          const SizedBox(height: 12),

          if (filteredReports.isEmpty)
            Container(
              padding: const EdgeInsets.all(25),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(21),
                border: Border.all(color: line),
              ),
              child: const Center(
                child: Text('No outage reports found'),
              ),
            )
          else
            ...filteredReports.map((report) {
              final status = report['status']!;

              return Container(
                margin: const EdgeInsets.only(bottom: 12),
                padding: const EdgeInsets.all(16),
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
                            color: const Color(0xFFFFF5D9),
                            borderRadius: BorderRadius.circular(13),
                          ),
                          child: const Icon(
                            Icons.bolt_outlined,
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
                                report['location']!,
                                style: const TextStyle(
                                  color: ink,
                                  fontSize: 15,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                '${report['id']} · ${report['time']}',
                                style: const TextStyle(
                                  color: muted,
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                        ),
                        PopupMenuButton<String>(
                          icon: const Icon(Icons.more_vert),
                          onSelected: (action) {
                            if (action == 'details') {
                              showReportDetails(report);
                            } else {
                              updateStatus(report, action);
                            }
                          },
                          itemBuilder: (_) => const [
                            PopupMenuItem(
                              value: 'details',
                              child: Text('View Details'),
                            ),
                            PopupMenuItem(
                              value: 'Pending',
                              child: Text('Mark Pending'),
                            ),
                            PopupMenuItem(
                              value: 'Investigating',
                              child: Text('Mark Investigating'),
                            ),
                            PopupMenuItem(
                              value: 'Resolved',
                              child: Text('Mark Resolved'),
                            ),
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(height: 13),
                    const Divider(color: line, height: 1),
                    const SizedBox(height: 13),
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            'Reported by ${report['reportedBy']}',
                            style: const TextStyle(
                              color: muted,
                              fontSize: 12,
                            ),
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: statusBackground(status),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            status,
                            style: TextStyle(
                              color: statusColor(status),
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    TextButton(
                      onPressed: () => showReportDetails(report),
                      child: const Text(
                        'View Report Details',
                        style: TextStyle(
                          color: ink,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ],
                ),
              );
            }),

          const SizedBox(height: 15),
          const Center(
            child: Text(
              'Demo outage reports · Not verified live data',
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
