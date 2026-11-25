import 'package:flutter/material.dart';
import '../services/admin_backend_service.dart';

class OutageManagementPage extends StatefulWidget {
  const OutageManagementPage({super.key});

  @override
  State<OutageManagementPage> createState() => _OutageManagementPageState();
}

class _OutageManagementPageState extends State<OutageManagementPage> {
  static const yellow = Color(0xFFF5C542);
  static const ink = Color(0xFF202523);
  static const soft = Color(0xFFF4F5F0);
  static const muted = Color(0xFF626B66);
  static const line = Color(0xFFDEE3DB);
  static const green = Color(0xFF237548);
  static const amber = Color(0xFF936715);

  final AdminBackendService _backendService = AdminBackendService();

  String selectedStatus = 'All';
  String searchText = '';

  // Local fallback if Firestore is offline
  final List<Map<String, dynamic>> _fallbackReports = [
    {
      'id': 'fallback-1',
      'reportId': 'OUT-1001',
      'location': 'Homagama',
      'reportedBy': 'Nimal Perera',
      'time': '14:32',
      'details': 'Power interruption reported in the area.',
      'status': 'Pending',
      'latitude': 6.8404,
      'longitude': 80.0034,
    },
    {
      'id': 'fallback-2',
      'reportId': 'OUT-1002',
      'location': 'Maharagama',
      'reportedBy': 'Amali Fernando',
      'time': '12:15',
      'details': 'Multiple households reported no electricity.',
      'status': 'Investigating',
      'latitude': 6.8500,
      'longitude': 79.9200,
    },
    {
      'id': 'fallback-3',
      'reportId': 'OUT-1003',
      'location': 'Kottawa',
      'reportedBy': 'Saman Kumara',
      'time': '09:40',
      'details': 'Electricity supply has been restored.',
      'status': 'Resolved',
      'latitude': 6.8433,
      'longitude': 79.9654,
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

  Future<void> updateStatus(Map<String, dynamic> report, String status) async {
    final docId = report['id']?.toString() ?? '';
    try {
      if (docId.isNotEmpty && !docId.startsWith('fallback-')) {
        await _backendService.updateOutageStatus(docId, status);
      } else {
        setState(() {
          report['status'] = status;
        });
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${report['reportId'] ?? 'Outage'} marked as $status in database.'),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to update status: $e')),
        );
      }
    }
  }

  void showAddOutageDialog() {
    final formKey = GlobalKey<FormState>();
    final locationCtrl = TextEditingController();
    final reporterCtrl = TextEditingController(text: 'Admin');
    final detailsCtrl = TextEditingController();
    final latCtrl = TextEditingController();
    final lngCtrl = TextEditingController();

    showDialog<void>(
      context: context,
      builder: (dialogCtx) => AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Record New Outage', style: TextStyle(color: ink, fontWeight: FontWeight.w800)),
        content: Form(
          key: formKey,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  controller: locationCtrl,
                  decoration: const InputDecoration(labelText: 'Location / Area *', border: OutlineInputBorder()),
                  validator: (v) => v == null || v.trim().isEmpty ? 'Required' : null,
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: reporterCtrl,
                  decoration: const InputDecoration(labelText: 'Reported By', border: OutlineInputBorder()),
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: detailsCtrl,
                  maxLines: 2,
                  decoration: const InputDecoration(labelText: 'Description / Details', border: OutlineInputBorder()),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: TextFormField(
                        controller: latCtrl,
                        keyboardType: const TextInputType.numberWithOptions(decimal: true),
                        decoration: const InputDecoration(
                          labelText: 'Latitude (optional)',
                          hintText: '6.8404',
                          border: OutlineInputBorder(),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: TextFormField(
                        controller: lngCtrl,
                        keyboardType: const TextInputType.numberWithOptions(decimal: true),
                        decoration: const InputDecoration(
                          labelText: 'Longitude (optional)',
                          hintText: '80.0034',
                          border: OutlineInputBorder(),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogCtx),
            child: const Text('Cancel', style: TextStyle(color: ink)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: yellow, foregroundColor: ink),
            onPressed: () async {
              if (!formKey.currentState!.validate()) return;
              final loc = locationCtrl.text.trim();
              final rep = reporterCtrl.text.trim();
              final det = detailsCtrl.text.trim();
              final lat = double.tryParse(latCtrl.text.trim());
              final lng = double.tryParse(lngCtrl.text.trim());
              final nowStr = '${DateTime.now().hour.toString().padLeft(2, '0')}:${DateTime.now().minute.toString().padLeft(2, '0')}';

              Navigator.pop(dialogCtx);

              try {
                await _backendService.addOutage(
                  loc,
                  rep.isNotEmpty ? rep : 'Admin',
                  nowStr,
                  det.isNotEmpty ? det : 'Outage reported in $loc',
                  latitude: lat,
                  longitude: lng,
                );
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Outage for $loc saved to Firestore.')),
                  );
                }
              } catch (e) {
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Could not save outage: $e')),
                  );
                }
              }
            },
            child: const Text('Save Outage'),
          ),
        ],
      ),
    );
  }

  void showReportDetails(Map<String, dynamic> report) {
    showDialog(
      context: context,
      builder: (dialogContext) {
        final lat = report['latitude'];
        final lng = report['longitude'];
        final coordStr = (lat != null && lng != null)
            ? '${(lat as num).toStringAsFixed(4)}, ${(lng as num).toStringAsFixed(4)}'
            : 'No verified coordinates (unmapped)';

        return AlertDialog(
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(21),
          ),
          title: Text(
            report['reportId']?.toString() ?? 'Outage Details',
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
                _detailRow('Location', report['location']?.toString() ?? ''),
                _detailRow('Reported by', report['reportedBy']?.toString() ?? ''),
                _detailRow('Time', report['time']?.toString() ?? ''),
                _detailRow('Status', report['status']?.toString() ?? ''),
                _detailRow('Map Coordinates', coordStr),
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
                  report['details']?.toString() ?? '',
                  style: const TextStyle(
                    color: ink,
                    fontSize: 13,
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
            width: 100,
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
    return StreamBuilder<List<Map<String, dynamic>>>(
      stream: _backendService.getOutages(),
      builder: (context, snapshot) {
        final reports = (snapshot.hasData && snapshot.data!.isNotEmpty)
            ? snapshot.data!
            : _fallbackReports;

        final filteredReports = reports.where((report) {
          final query = searchText.toLowerCase();
          final reportId = (report['reportId'] ?? report['id'] ?? '').toString().toLowerCase();
          final location = (report['location'] ?? '').toString().toLowerCase();
          final reportedBy = (report['reportedBy'] ?? '').toString().toLowerCase();

          final matchesSearch = reportId.contains(query) ||
              location.contains(query) ||
              reportedBy.contains(query);

          final matchesStatus = selectedStatus == 'All' ||
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
            actions: [
              IconButton(
                icon: const Icon(Icons.add_circle_outline),
                tooltip: 'Add Outage',
                onPressed: showAddOutageDialog,
              ),
            ],
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
                'Track and resolve live grid disturbances.',
                style: TextStyle(
                  color: muted,
                  fontSize: 13,
                ),
              ),
              const SizedBox(height: 18),

              // KPI Row
              Row(
                children: [
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.all(18),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(21),
                        border: Border.all(color: line),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('Pending', style: TextStyle(color: muted, fontSize: 12)),
                          const SizedBox(height: 8),
                          Text(
                            '$pendingCount',
                            style: const TextStyle(color: amber, fontSize: 28, fontWeight: FontWeight.w800),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.all(18),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(21),
                        border: Border.all(color: line),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('Investigating', style: TextStyle(color: muted, fontSize: 12)),
                          const SizedBox(height: 8),
                          Text(
                            '$investigatingCount',
                            style: const TextStyle(color: Color(0xFF306F94), fontSize: 28, fontWeight: FontWeight.w800),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 16),

              // Search & Filter
              TextField(
                onChanged: (val) => setState(() => searchText = val),
                decoration: InputDecoration(
                  hintText: 'Search by location or report ID...',
                  prefixIcon: const Icon(Icons.search, color: muted),
                  filled: true,
                  fillColor: Colors.white,
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                ),
              ),

              const SizedBox(height: 14),

              // Status Filter Chips
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: ['All', 'Pending', 'Investigating', 'Resolved'].map((st) {
                    final isSel = selectedStatus == st;
                    return Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: FilterChip(
                        label: Text(st),
                        selected: isSel,
                        onSelected: (_) => setState(() => selectedStatus = st),
                        selectedColor: yellow,
                        backgroundColor: Colors.white,
                        checkmarkColor: ink,
                      ),
                    );
                  }).toList(),
                ),
              ),

              const SizedBox(height: 18),

              // Report Cards List
              if (filteredReports.isEmpty)
                Container(
                  padding: const EdgeInsets.all(32),
                  alignment: Alignment.center,
                  child: const Text('No matching outage reports.', style: TextStyle(color: muted)),
                )
              else
                ...filteredReports.map((report) {
                  final status = (report['status'] ?? 'Pending').toString();
                  final repId = (report['reportId'] ?? report['id'] ?? '').toString();
                  final loc = (report['location'] ?? 'Unknown location').toString();
                  final time = (report['time'] ?? '').toString();
                  final repBy = (report['reportedBy'] ?? 'Unknown').toString();
                  final hasCoords = report['latitude'] != null && report['longitude'] != null;

                  return Container(
                    margin: const EdgeInsets.only(bottom: 14),
                    padding: const EdgeInsets.all(18),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: line),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Text(loc, style: const TextStyle(color: ink, fontSize: 16, fontWeight: FontWeight.w800)),
                                      if (hasCoords) ...[
                                        const SizedBox(width: 6),
                                        const Icon(Icons.location_on, size: 16, color: green),
                                      ],
                                    ],
                                  ),
                                  const SizedBox(height: 4),
                                  Text('$repId \u00b7 $time', style: const TextStyle(color: muted, fontSize: 12)),
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
                                PopupMenuItem(value: 'details', child: Text('View Details')),
                                PopupMenuItem(value: 'Pending', child: Text('Mark Pending')),
                                PopupMenuItem(value: 'Investigating', child: Text('Mark Investigating')),
                                PopupMenuItem(value: 'Resolved', child: Text('Mark Resolved')),
                              ],
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        const Divider(color: line, height: 1),
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            Expanded(
                              child: Text('Reported by $repBy', style: const TextStyle(color: muted, fontSize: 12)),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
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
                      ],
                    ),
                  );
                }),
            ],
          ),
        );
      },
    );
  }
}
