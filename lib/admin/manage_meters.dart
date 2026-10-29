import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../services/admin_backend_service.dart';

class ManageMetersPage extends StatefulWidget {
  const ManageMetersPage({super.key});

  @override
  State<ManageMetersPage> createState() => _ManageMetersPageState();
}

class _ManageMetersPageState extends State<ManageMetersPage> {
  static const Color yellow = Color(0xFFF5C542);
  static const Color ink = Color(0xFF202523);
  static const Color soft = Color(0xFFF4F5F0);
  static const Color muted = Color(0xFF626B66);
  static const Color line = Color(0xFFDEE3DB);
  static const Color green = Color(0xFF237548);
  static const Color red = Color(0xFFB94338);

  final AdminBackendService _backendService = AdminBackendService();

  String searchText = '';
  String selectedStatus = 'All';

  void showMeterDetails(Map<String, dynamic> meter) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(21),
        ),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(9),
              decoration: BoxDecoration(
                color: yellow,
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(
                Icons.electric_meter_outlined,
                color: ink,
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                meter['id'] ?? 'N/A',
                style: const TextStyle(
                  color: ink,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'METER INFORMATION',
              style: TextStyle(
                color: muted,
                fontSize: 11,
                letterSpacing: 1.5,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 15),
            _detailRow('Customer', meter['customer'] ?? 'N/A'),
            _detailRow('Location', meter['location'] ?? 'N/A'),
            _detailRow('Reading', meter['reading'] ?? 'N/A'),
            _detailRow('Status', meter['status'] ?? 'N/A'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text(
              'Close',
              style: TextStyle(
                color: ink,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _detailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 80,
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
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: soft,
      appBar: AppBar(
        title: const Text(
          'Manage Meters',
          style: TextStyle(
            fontWeight: FontWeight.w800,
            letterSpacing: -0.5,
          ),
        ),
        backgroundColor: soft,
        foregroundColor: ink,
        elevation: 0,
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: _backendService.getMeters(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator(color: yellow));
          }

          final docs = snapshot.data?.docs ?? [];
          final meters = docs.map((doc) {
            final data = doc.data() as Map<String, dynamic>;
            return {
              'docId': doc.id,
              'id': data['id'] ?? doc.id,
              'customer': data['customer'] ?? 'Unknown',
              'location': data['location'] ?? 'Unknown',
              'reading': data['reading'] ?? '0 kWh',
              'status': data['status'] ?? 'Active',
            };
          }).toList();

          final filteredMeters = meters.where((meter) {
            final query = searchText.toLowerCase();

            final matchesSearch =
                meter['id']!.toLowerCase().contains(query) ||
                meter['customer']!.toLowerCase().contains(query) ||
                meter['location']!.toLowerCase().contains(query);

            final matchesStatus =
                selectedStatus == 'All' ||
                meter['status'] == selectedStatus;

            return matchesSearch && matchesStatus;
          }).toList();

          final activeCount =
              meters.where((meter) => meter['status'] == 'Active').length;

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
                'Your meters.',
                style: TextStyle(
                  color: ink,
                  fontSize: 28,
                  fontWeight: FontWeight.w800,
                  letterSpacing: -1,
                ),
              ),
              const SizedBox(height: 5),
              const Text(
                'Monitor and manage electricity meters.',
                style: TextStyle(
                  color: muted,
                  fontSize: 13,
                ),
              ),
              const SizedBox(height: 18),

              // Dark Glass Summary Card
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
                      'Total registered meters',
                      style: TextStyle(
                        color: Color(0xFFC5D0C3),
                        fontSize: 13,
                      ),
                    ),
                    const SizedBox(height: 9),
                    Text(
                      '${meters.length}',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 45,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 9),
                    Row(
                      children: [
                        const Icon(
                          Icons.check_circle_outline,
                          color: yellow,
                          size: 17,
                        ),
                        const SizedBox(width: 7),
                        Flexible(
                          child: Text(
                            '$activeCount active · '
                            '${meters.length - activeCount} inactive',
                            style: const TextStyle(
                              color: Color(0xFFC5D0C3),
                              fontSize: 12,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              // Search Field
              TextField(
                style: const TextStyle(color: ink),
                decoration: InputDecoration(
                  hintText: 'Search meters...',
                  hintStyle: const TextStyle(color: muted),
                  prefixIcon: const Icon(
                    Icons.search,
                    color: muted,
                  ),
                  filled: true,
                  fillColor: Colors.white,
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 15,
                    vertical: 15,
                  ),
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

              const SizedBox(height: 13),

              // Status Filter
              DropdownButtonFormField<String>(
                value: selectedStatus,
                decoration: InputDecoration(
                  labelText: 'Filter by Status',
                  labelStyle: const TextStyle(color: muted),
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
                items: ['All', 'Active', 'Inactive']
                    .map(
                      (status) => DropdownMenuItem(
                        value: status,
                        child: Text(status),
                      ),
                    )
                    .toList(),
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
                    'Meter Directory',
                    style: TextStyle(
                      color: ink,
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  Text(
                    '${filteredMeters.length} meters',
                    style: const TextStyle(
                      color: muted,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 12),

              if (filteredMeters.isEmpty)
                Container(
                  padding: const EdgeInsets.all(28),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(21),
                    border: Border.all(color: line),
                  ),
                  child: const Center(
                    child: Text(
                      'No meters found',
                      style: TextStyle(color: muted),
                    ),
                  ),
                )
              else
                ...filteredMeters.map((meter) {
                  final isActive = meter['status'] == 'Active';

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
                                color: const Color(0xFFF0F1E9),
                                borderRadius: BorderRadius.circular(13),
                              ),
                              child: const Icon(
                                Icons.electric_meter_outlined,
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
                                    meter['id']!,
                                    style: const TextStyle(
                                      color: ink,
                                      fontSize: 15,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    meter['customer']!,
                                    overflow: TextOverflow.ellipsis,
                                    style: const TextStyle(
                                      color: muted,
                                      fontSize: 12,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            PopupMenuButton<String>(
                              tooltip: 'Meter actions',
                              icon: const Icon(
                                Icons.more_vert,
                                color: ink,
                              ),
                              onSelected: (action) async {
                                if (action == 'details') {
                                  showMeterDetails(meter);
                                } else if (action == 'status') {
                                  final newStatus =
                                      isActive ? 'Inactive' : 'Active';
                                  await _backendService.updateMeterStatus(
                                    meter['docId']!,
                                    newStatus,
                                  );

                                  ScaffoldMessenger.of(context)
                                      .showSnackBar(
                                    SnackBar(
                                      content: Text(
                                        '${meter['id']} status updated to $newStatus.',
                                      ),
                                    ),
                                  );
                                }
                              },
                              itemBuilder: (context) => [
                                const PopupMenuItem<String>(
                                  value: 'details',
                                  child: Text('View Details'),
                                ),
                                PopupMenuItem<String>(
                                  value: 'status',
                                  child: Text(
                                    isActive
                                        ? 'Deactivate Meter'
                                        : 'Activate Meter',
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                        const SizedBox(height: 13),
                        const Divider(
                          color: line,
                          height: 1,
                        ),
                        const SizedBox(height: 13),
                        Row(
                          children: [
                            const Icon(
                              Icons.location_on_outlined,
                              size: 17,
                              color: muted,
                            ),
                            const SizedBox(width: 5),
                            Expanded(
                              child: Text(
                                meter['location']!,
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
                                color: isActive
                                    ? const Color(0xFFE7F2E9)
                                    : const Color(0xFFFBECE8),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Text(
                                meter['status']!,
                                style: TextStyle(
                                  color: isActive ? green : red,
                                  fontSize: 11,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Row(
                          mainAxisAlignment:
                              MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Reading: ${meter['reading']}',
                              style: const TextStyle(
                                color: ink,
                                fontSize: 13,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            TextButton(
                              onPressed: () => showMeterDetails(meter),
                              child: const Text(
                                'View Details',
                                style: TextStyle(
                                  color: Color(0xFF7B5B00),
                                  fontSize: 12,
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

              const SizedBox(height: 12),
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