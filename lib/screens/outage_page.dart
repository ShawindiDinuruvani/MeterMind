import 'package:flutter/material.dart';

import '../models/outage_report_model.dart';
import '../services/customer_firebase_service.dart';
import '../widgets/app_header.dart';
import '../widgets/osm_map_widget.dart';

const Color _background = Color(0xFFF4F5F0);
const Color _ink = Color(0xFF17201D);
const Color _muted = Color(0xFF65716A);
const Color _hotspot = Color(0xFFBE443B);
const Color _reported = Color(0xFFA86A19);
const Color _clear = Color(0xFF237548);
const Color _yellow = Color(0xFFF7C844);

class OutagePage extends StatelessWidget {
  const OutagePage({super.key});

  Color _statusColor(String status, bool isHotspot) {
    if (isHotspot || status.toLowerCase().contains('hotspot')) return _hotspot;
    if (status.toLowerCase().contains('no active') || status.toLowerCase().contains('resolved')) return _clear;
    return _reported;
  }

  @override
  Widget build(BuildContext context) {
    final customerService = CustomerFirebaseService();

    return Scaffold(
      backgroundColor: _background,
      body: SafeArea(
        child: StreamBuilder<List<OutageReportModel>>(
          stream: customerService.streamOutageReports(),
          builder: (context, snapshot) {
            final reports = snapshot.data ?? customerService.currentOutages;

            // Generate map markers ONLY for reports that have genuine non-null coordinates
            final markers = reports
                .where((r) => r.latitude != null && r.longitude != null)
                .map((r) {
              final color = _statusColor(r.status, r.isHotspot);
              final label = r.reportCount > 0 ? '${r.reportCount}' : '\u2713';
              return OsmMarker(
                id: r.id,
                latitude: r.latitude!,
                longitude: r.longitude!,
                label: label,
                color: color,
                title: r.area,
                subtitle: r.status,
              );
            }).toList();

            final totalReports = reports.fold<int>(0, (acc, r) => acc + r.reportCount);
            final primaryReport = reports.isNotEmpty ? reports.first : null;

            return LayoutBuilder(
              builder: (context, constraints) {
                final isWide = constraints.maxWidth >= 768;
                final horizontalPadding = isWide ? 32.0 : 20.0;
                final maxContentWidth = isWide ? 960.0 : 540.0;

                return Center(
                  child: ConstrainedBox(
                    constraints: BoxConstraints(maxWidth: maxContentWidth),
                    child: SingleChildScrollView(
                      padding: EdgeInsets.fromLTRB(horizontalPadding, 10, horizontalPadding, 30),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const AppHeader(),
                          const SizedBox(height: 28),
                          const Text(
                            'YOUR ENERGY, UNDERSTOOD',
                            style: TextStyle(
                              fontSize: 11,
                              letterSpacing: 1.8,
                              color: _muted,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                          const SizedBox(height: 10),
                          const Text(
                            'Outage intelligence.',
                            style: TextStyle(
                              fontSize: 29,
                              height: 1.12,
                              fontWeight: FontWeight.w800,
                              letterSpacing: -0.8,
                              color: _ink,
                            ),
                          ),
                          const SizedBox(height: 8),
                          const Text(
                            'Community reports \u00b7 verify before acting',
                            style: TextStyle(fontSize: 14, color: _muted),
                          ),
                          const SizedBox(height: 20),

                          // Real Interactive OpenStreetMap
                          OsmMapWidget(
                            initialLat: markers.isNotEmpty ? markers.first.latitude : 6.8404,
                            initialLng: markers.isNotEmpty ? markers.first.longitude : 80.0034,
                            initialZoom: 13.0,
                            height: isWide ? 360 : 280,
                            markers: markers,
                            onMarkerTap: (marker) {
                              final matched = reports.firstWhere(
                                (r) => r.id == marker.id,
                                orElse: () => OutageReportModel(
                                  id: marker.id,
                                  area: marker.title,
                                  reportCount: 0,
                                  status: marker.subtitle,
                                  description: 'Community outage report',
                                ),
                              );
                              _showAreaDetails(context, matched);
                            },
                          ),

                          const SizedBox(height: 15),
                          const Wrap(
                            spacing: 13,
                            runSpacing: 9,
                            children: [
                              _LegendItem(color: _hotspot, label: 'Potential hotspot'),
                              _LegendItem(color: _reported, label: 'Reported issue'),
                              _LegendItem(color: _clear, label: 'No active reports'),
                            ],
                          ),
                          const SizedBox(height: 19),

                          if (primaryReport != null)
                            _AreaCard(
                              report: primaryReport,
                              onTap: () => _showAreaDetails(context, primaryReport),
                            ),

                          const SizedBox(height: 16),
                          SizedBox(
                            width: double.infinity,
                            height: 54,
                            child: ElevatedButton(
                              onPressed: () => _showReportDialog(context),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: _yellow,
                                foregroundColor: _ink,
                                elevation: 0,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(16),
                                ),
                              ),
                              child: const Text(
                                'Report an outage',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 13),
                          Container(
                            width: double.infinity,
                            padding: const EdgeInsets.all(15),
                            decoration: BoxDecoration(
                              color: const Color(0xFFEDF0E6),
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: Text(
                              '$totalReports active community reports logged. Grouped reports suggest an area issue; verify before relying on restoration times.',
                              style: const TextStyle(
                                fontSize: 13,
                                color: _muted,
                                height: 1.45,
                              ),
                            ),
                          ),
                          const SizedBox(height: 13),
                          SizedBox(
                            width: double.infinity,
                            height: 54,
                            child: OutlinedButton(
                              onPressed: () => _showReportList(context, reports),
                              style: OutlinedButton.styleFrom(
                                foregroundColor: _ink,
                                backgroundColor: Colors.white,
                                side: const BorderSide(color: Color(0xFFDDE3DA)),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(16),
                                ),
                              ),
                              child: const Text(
                                'Report list',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            );
          },
        ),
      ),
    );
  }

  void _showAreaDetails(BuildContext context, OutageReportModel report) {
    showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      backgroundColor: _background,
      builder: (sheetContext) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(24, 8, 24, 30),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '${report.area} Outage Details',
                style: const TextStyle(
                  fontSize: 23,
                  fontWeight: FontWeight.w800,
                  color: _ink,
                ),
              ),
              const SizedBox(height: 18),
              _DetailRow(
                icon: Icons.report_outlined,
                text: '${report.reportCount} community report${report.reportCount == 1 ? '' : 's'}',
              ),
              const SizedBox(height: 12),
              _DetailRow(
                icon: Icons.radar,
                text: report.description.isNotEmpty
                    ? report.description
                    : 'Approx. ${report.radiusMeters} m coverage zone',
              ),
              const SizedBox(height: 12),
              _DetailRow(
                icon: Icons.verified_outlined,
                text: 'Status: ${report.status}',
              ),
              if (report.latitude != null && report.longitude != null) ...[
                const SizedBox(height: 12),
                _DetailRow(
                  icon: Icons.my_location_outlined,
                  text: 'Coordinates: ${report.latitude!.toStringAsFixed(4)}, ${report.longitude!.toStringAsFixed(4)}',
                ),
              ],
              const SizedBox(height: 16),
              const Text(
                'Reports are reviewed and updated by administrators. Tap "Report an outage" if your power is out.',
                style: TextStyle(color: _muted, height: 1.45),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showReportDialog(BuildContext context) {
    final formKey = GlobalKey<FormState>();
    final locationController = TextEditingController();
    final detailsController = TextEditingController();
    final latController = TextEditingController();
    final lngController = TextEditingController();
    String selectedIssue = 'Power cut';

    showDialog<void>(
      context: context,
      builder: (dialogContext) => StatefulBuilder(
        builder: (dialogContext, setDialogState) => AlertDialog(
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: const Text(
            'Report an outage',
            style: TextStyle(fontWeight: FontWeight.w800, color: _ink),
          ),
          content: Form(
            key: formKey,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      'Share details of the electrical disturbance in your area.',
                      style: TextStyle(color: _muted, height: 1.4),
                    ),
                  ),
                  const SizedBox(height: 16),
                  DropdownButtonFormField<String>(
                    initialValue: selectedIssue,
                    decoration: const InputDecoration(
                      labelText: 'Issue type',
                      border: OutlineInputBorder(),
                    ),
                    items: const [
                      DropdownMenuItem(value: 'Power cut', child: Text('Power cut')),
                      DropdownMenuItem(value: 'Low voltage', child: Text('Low voltage')),
                      DropdownMenuItem(value: 'Power fluctuation', child: Text('Power fluctuation')),
                      DropdownMenuItem(value: 'Other', child: Text('Other')),
                    ],
                    onChanged: (value) {
                      if (value != null) {
                        setDialogState(() => selectedIssue = value);
                      }
                    },
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: locationController,
                    decoration: const InputDecoration(
                      labelText: 'Area / town',
                      hintText: 'e.g. Homagama',
                      border: OutlineInputBorder(),
                    ),
                    validator: (value) =>
                        value == null || value.trim().isEmpty ? 'Enter your area' : null,
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: detailsController,
                    maxLines: 2,
                    decoration: const InputDecoration(
                      labelText: 'Additional details (optional)',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: TextFormField(
                          controller: latController,
                          keyboardType: const TextInputType.numberWithOptions(decimal: true),
                          decoration: const InputDecoration(
                            labelText: 'Latitude (opt)',
                            hintText: '6.8404',
                            border: OutlineInputBorder(),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: TextFormField(
                          controller: lngController,
                          keyboardType: const TextInputType.numberWithOptions(decimal: true),
                          decoration: const InputDecoration(
                            labelText: 'Longitude (opt)',
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
              onPressed: () => Navigator.pop(dialogContext),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: _yellow,
                foregroundColor: _ink,
              ),
              onPressed: () async {
                if (!formKey.currentState!.validate()) return;
                final area = locationController.text.trim();
                final details = detailsController.text.trim();
                final lat = double.tryParse(latController.text.trim());
                final lng = double.tryParse(lngController.text.trim());

                Navigator.pop(dialogContext);

                final desc = details.isNotEmpty ? details : '$selectedIssue in $area';
                await CustomerFirebaseService().reportOutage(
                  area: area,
                  description: desc,
                  latitude: lat,
                  longitude: lng,
                );

                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Outage report for $area submitted to system.'),
                      duration: const Duration(seconds: 4),
                    ),
                  );
                }
              },
              child: const Text('Submit report'),
            ),
          ],
        ),
      ),
    ).whenComplete(() {
      locationController.dispose();
      detailsController.dispose();
      latController.dispose();
      lngController.dispose();
    });
  }

  void _showReportList(BuildContext context, List<OutageReportModel> reports) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      backgroundColor: _background,
      builder: (sheetContext) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Report list',
                style: TextStyle(
                  fontSize: 23,
                  fontWeight: FontWeight.w800,
                  color: _ink,
                ),
              ),
              const SizedBox(height: 7),
              const Text(
                'Active community outage reports and hotspots',
                style: TextStyle(color: _muted),
              ),
              const SizedBox(height: 15),
              if (reports.isEmpty)
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 24),
                  child: Center(
                    child: Text('No active outage reports found.', style: TextStyle(color: _muted)),
                  ),
                )
              else
                ...reports.map((r) {
                  final color = _statusColor(r.status, r.isHotspot);
                  final coordNote = (r.latitude != null && r.longitude != null)
                      ? 'Mapped: ${r.latitude!.toStringAsFixed(3)}, ${r.longitude!.toStringAsFixed(3)}'
                      : 'Area only (unmapped)';
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: _ReportTile(
                      color: color,
                      area: r.area,
                      subtitle: '${r.reportCount} reports \u00b7 $coordNote',
                      status: r.status,
                      onTap: () {
                        Navigator.pop(sheetContext);
                        _showAreaDetails(context, r);
                      },
                    ),
                  );
                }),
              const SizedBox(height: 12),
              const Text(
                'Community reports are updated continuously through customer and admin submissions.',
                style: TextStyle(fontSize: 12, color: _muted, height: 1.4),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _AreaCard extends StatelessWidget {
  final OutageReportModel report;
  final VoidCallback onTap;

  const _AreaCard({required this.report, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 18),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(25),
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF303A33), Color(0xFF1B2420)],
        ),
        border: Border.all(color: const Color(0xFF465047), width: 1),
        boxShadow: const [
          BoxShadow(
            color: Color(0x12000000),
            blurRadius: 12,
            offset: Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  report.area,
                  style: const TextStyle(
                    fontWeight: FontWeight.w800,
                    fontSize: 17,
                    color: Colors.white,
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.10),
                  borderRadius: BorderRadius.circular(22),
                ),
                child: Text(
                  report.status,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            '${report.reportCount} nearby reports',
            style: const TextStyle(
              fontSize: 26,
              letterSpacing: -0.5,
              color: Colors.white,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            report.description.isNotEmpty
                ? report.description
                : 'Area reports under investigation',
            style: const TextStyle(color: Colors.white70, fontSize: 14, height: 1.45),
          ),
          const SizedBox(height: 12),
          TextButton(
            onPressed: onTap,
            style: TextButton.styleFrom(
              foregroundColor: _yellow,
              padding: EdgeInsets.zero,
              minimumSize: const Size(0, 38),
              alignment: Alignment.centerLeft,
            ),
            child: const Text(
              'View area details \u2192',
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.w800),
            ),
          ),
        ],
      ),
    );
  }
}

class _LegendItem extends StatelessWidget {
  const _LegendItem({required this.color, required this.label});

  final Color color;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 9,
          height: 9,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 6),
        Text(label, style: const TextStyle(fontSize: 11, color: _muted)),
      ],
    );
  }
}

class _DetailRow extends StatelessWidget {
  const _DetailRow({required this.icon, required this.text});

  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, color: _clear, size: 21),
        const SizedBox(width: 11),
        Expanded(
          child: Text(text, style: const TextStyle(color: _ink, fontSize: 14)),
        ),
      ],
    );
  }
}

class _ReportTile extends StatelessWidget {
  const _ReportTile({
    required this.color,
    required this.area,
    required this.subtitle,
    required this.status,
    this.onTap,
  });

  final Color color;
  final String area;
  final String subtitle;
  final String status;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFDDE3DA)),
      ),
      child: ListTile(
        onTap: onTap,
        leading: Icon(Icons.location_on_outlined, color: color, size: 28),
        title: Text(
          area,
          style: const TextStyle(fontWeight: FontWeight.w800, color: _ink),
        ),
        subtitle: Text(subtitle, style: const TextStyle(color: _muted)),
        trailing: Text(
          status,
          style: TextStyle(
            color: color,
            fontWeight: FontWeight.w700,
            fontSize: 11,
          ),
        ),
      ),
    );
  }
}
