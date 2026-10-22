import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../widgets/app_header.dart';

const Color _background = Color(0xFFF4F5F0);
const Color _ink = Color(0xFF17201D);
const Color _muted = Color(0xFF65716A);
const Color _hotspot = Color(0xFFBE443B);
const Color _reported = Color(0xFFA86A19);
const Color _clear = Color(0xFF237548);
const Color _yellow = Color(0xFFF7C844);

class OutagePage extends StatelessWidget {
  const OutagePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _background,
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            return SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(20, 10, 20, 22),
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  minHeight: constraints.maxHeight - 32,
                ),
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
                      'Community reports · verify before acting',
                      style: TextStyle(fontSize: 14, color: _muted),
                    ),
                    const SizedBox(height: 20),
                    const _OutageMap(),
                    const SizedBox(height: 15),
                    const Wrap(
                      spacing: 13,
                      runSpacing: 9,
                      children: [
                        _LegendItem(
                          color: _hotspot,
                          label: 'Potential hotspot',
                        ),
                        _LegendItem(color: _reported, label: 'Reported issue'),
                        _LegendItem(color: _clear, label: 'No active reports'),
                      ],
                    ),
                    const SizedBox(height: 19),
                    _AreaCard(onTap: () => _showAreaDetails(context)),
                    const SizedBox(height: 16),
                    SizedBox(
                      width: double.infinity,
                      height: 58,
                      child: ElevatedButton(
                        onPressed: () => _showReportDialog(context),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: _yellow,
                          foregroundColor: _ink,
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(17),
                          ),
                        ),
                        child: const Text(
                          'Report an outage',
                          style: TextStyle(
                            fontSize: 17,
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
                      child: const Text(
                        'Grouped customer reports suggest an issue; they do not prove an outage or provide a restoration time.',
                        style: TextStyle(
                          fontSize: 13,
                          color: _muted,
                          height: 1.45,
                        ),
                      ),
                    ),
                    const SizedBox(height: 13),
                    SizedBox(
                      width: double.infinity,
                      height: 58,
                      child: OutlinedButton(
                        onPressed: () => _showReportList(context),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: _ink,
                          backgroundColor: Colors.white,
                          side: const BorderSide(color: Color(0xFFDDE3DA)),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(17),
                          ),
                        ),
                        child: const Text(
                          'Report list',
                          style: TextStyle(
                            fontSize: 17,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  void _showAreaDetails(BuildContext context) {
    showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      backgroundColor: _background,
      builder: (sheetContext) => const SafeArea(
        child: Padding(
          padding: EdgeInsets.fromLTRB(24, 8, 24, 30),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Homagama Area Details',
                style: TextStyle(
                  fontSize: 23,
                  fontWeight: FontWeight.w800,
                  color: _ink,
                ),
              ),
              SizedBox(height: 18),
              _DetailRow(
                icon: Icons.report_outlined,
                text: '12 nearby community reports',
              ),
              SizedBox(height: 12),
              _DetailRow(
                icon: Icons.radar,
                text: 'Potential hotspot · approx. 600 m radius',
              ),
              SizedBox(height: 12),
              _DetailRow(
                icon: Icons.verified_outlined,
                text: 'Status: Unverified',
              ),
              SizedBox(height: 16),
              Text(
                'These are illustrative reports. They do not confirm an actual electricity outage.',
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
    String selectedIssue = 'Power cut';

    showDialog<void>(
      context: context,
      builder: (dialogContext) => StatefulBuilder(
        builder: (dialogContext, setDialogState) => AlertDialog(
          backgroundColor: Colors.white,
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
                      'Share what you are experiencing in your area.',
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
                      DropdownMenuItem(
                        value: 'Power cut',
                        child: Text('Power cut'),
                      ),
                      DropdownMenuItem(
                        value: 'Low voltage',
                        child: Text('Low voltage'),
                      ),
                      DropdownMenuItem(
                        value: 'Power fluctuation',
                        child: Text('Power fluctuation'),
                      ),
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
                    validator: (value) => value == null || value.trim().isEmpty
                        ? 'Enter your area'
                        : null,
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: detailsController,
                    maxLines: 3,
                    decoration: const InputDecoration(
                      labelText: 'Additional details (optional)',
                      border: OutlineInputBorder(),
                    ),
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
              onPressed: () {
                if (!formKey.currentState!.validate()) return;
                final area = locationController.text.trim();
                Navigator.pop(dialogContext);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      '$selectedIssue report prepared for $area. Demo only—no data was sent.',
                    ),
                    duration: const Duration(seconds: 4),
                  ),
                );
              },
              child: const Text('Submit report'),
            ),
          ],
        ),
      ),
    ).whenComplete(() {
      locationController.dispose();
      detailsController.dispose();
    });
  }

  void _showReportList(BuildContext context) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      backgroundColor: _background,
      builder: (sheetContext) => const SafeArea(
        child: Padding(
          padding: EdgeInsets.fromLTRB(20, 8, 20, 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Report list',
                style: TextStyle(
                  fontSize: 23,
                  fontWeight: FontWeight.w800,
                  color: _ink,
                ),
              ),
              SizedBox(height: 7),
              Text(
                'Community-submitted sample reports',
                style: TextStyle(color: _muted),
              ),
              SizedBox(height: 15),
              _ReportTile(
                color: _hotspot,
                area: 'Homagama',
                subtitle: '12 nearby sample reports',
                status: 'Unverified',
              ),
              SizedBox(height: 8),
              _ReportTile(
                color: _reported,
                area: 'Pitipana',
                subtitle: '3 nearby sample reports',
                status: 'Pending',
              ),
              SizedBox(height: 12),
              Text(
                'Sample data for this UI prototype. Reports are not verified outage information.',
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
  const _AreaCard({required this.onTap});

  final VoidCallback onTap;

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
              const Expanded(
                child: Text(
                  'Homagama',
                  style: TextStyle(
                    fontWeight: FontWeight.w800,
                    fontSize: 17,
                    color: Colors.white,
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.10),
                  borderRadius: BorderRadius.circular(22),
                ),
                child: const Text(
                  'Unverified',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          const Text(
            '12 nearby reports',
            style: TextStyle(
              fontSize: 26,
              letterSpacing: -0.5,
              color: Colors.white,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Potential outage hotspot · approx. 600 m radius',
            style: TextStyle(color: Colors.white70, fontSize: 14, height: 1.45),
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
              'View area details →',
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.w800),
            ),
          ),
        ],
      ),
    );
  }
}

class _OutageMap extends StatelessWidget {
  const _OutageMap();

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final mapHeight = math.min(constraints.maxWidth * 0.72, 300.0);
        return Container(
          height: mapHeight,
          width: double.infinity,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(22),
            border: Border.all(color: const Color(0xFFDDE3D6)),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(22),
            child: Stack(
              children: [
                const Positioned.fill(
                  child: CustomPaint(painter: _MapRoadPainter()),
                ),
                const Positioned(
                  top: 15,
                  left: 16,
                  child: Text(
                    'Homagama',
                    style: TextStyle(fontSize: 13, color: _muted),
                  ),
                ),
                const Align(
                  alignment: Alignment(0.53, 0.58),
                  child: Text(
                    'Pitipana',
                    style: TextStyle(fontSize: 13, color: _muted),
                  ),
                ),
                const Align(
                  alignment: Alignment(0.05, -0.15),
                  child: _MapMarker(color: _hotspot, label: '12', radius: 25),
                ),
                const Align(
                  alignment: Alignment(0.53, 0.35),
                  child: _MapMarker(color: _reported, label: '3', radius: 24),
                ),
                const Align(
                  alignment: Alignment(-0.55, 0.55),
                  child: _MapMarker(color: _clear, label: '✓', radius: 24),
                ),
                Positioned(
                  left: 13,
                  right: 13,
                  bottom: 12,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 10,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.96),
                      borderRadius: BorderRadius.circular(13),
                    ),
                    child: const Text(
                      'Illustrative map · location services not connected',
                      style: TextStyle(fontSize: 11, color: _muted),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _MapMarker extends StatelessWidget {
  const _MapMarker({
    required this.color,
    required this.label,
    required this.radius,
  });

  final Color color;
  final String label;
  final double radius;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: radius * 2,
      height: radius * 2,
      decoration: BoxDecoration(
        color: color,
        shape: BoxShape.circle,
        border: Border.all(color: Colors.white, width: 4),
        boxShadow: const [
          BoxShadow(
            color: Color(0x26000000),
            blurRadius: 9,
            offset: Offset(0, 3),
          ),
        ],
      ),
      alignment: Alignment.center,
      child: Text(
        label,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 17,
          fontWeight: FontWeight.w800,
        ),
      ),
    );
  }
}

class _MapRoadPainter extends CustomPainter {
  const _MapRoadPainter();

  @override
  void paint(Canvas canvas, Size size) {
    canvas.drawColor(const Color(0xFFE6EADD), BlendMode.src);
    canvas.save();
    canvas.scale(size.width, size.height);

    final blockPaint = Paint()
      ..color = const Color(0xFFCCD9B9)
      ..style = PaintingStyle.fill;

    canvas.drawRRect(
      RRect.fromRectAndRadius(
        const Rect.fromLTWH(0.64, 0.07, 0.17, 0.18),
        const Radius.circular(0.035),
      ),
      blockPaint,
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        const Rect.fromLTWH(0.07, 0.59, 0.16, 0.13),
        const Radius.circular(0.03),
      ),
      blockPaint,
    );

    final roadBase = Paint()
      ..color = const Color(0xFFD1D7C9)
      ..strokeWidth = 0.026
      ..strokeCap = StrokeCap.square
      ..style = PaintingStyle.stroke;
    final roadCenter = Paint()
      ..color = Colors.white
      ..strokeWidth = 0.014
      ..strokeCap = StrokeCap.square
      ..style = PaintingStyle.stroke;

    const roads = [
      [Offset(-0.08, 0.36), Offset(1.08, 0.40)],
      [Offset(-0.08, 0.80), Offset(1.08, 0.20)],
      [Offset(0.17, -0.08), Offset(0.80, 1.08)],
      [Offset(-0.08, 0.10), Offset(0.77, 1.08)],
      [Offset(-0.08, 0.57), Offset(1.08, 0.57)],
      [Offset(0.14, -0.08), Offset(1.08, 0.82)],
    ];

    for (final road in roads) {
      final path = Path()
        ..moveTo(road[0].dx, road[0].dy)
        ..lineTo(road[1].dx, road[1].dy);
      canvas.drawPath(path, roadBase);
      canvas.drawPath(path, roadCenter);
    }
    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant _MapRoadPainter oldDelegate) => false;
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
  });

  final Color color;
  final String area;
  final String subtitle;
  final String status;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFDDE3DA)),
      ),
      child: ListTile(
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
