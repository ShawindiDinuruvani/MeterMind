import 'package:flutter/material.dart';
import '../services/admin_backend_service.dart';

class OutageMapPage extends StatefulWidget {
  const OutageMapPage({super.key});

  @override
  State<OutageMapPage> createState() => _OutageMapPageState();
}

class _OutageMapPageState extends State<OutageMapPage> {
  static const Color yellow = Color(0xFFF5C542);
  static const Color ink = Color(0xFF202523);
  static const Color soft = Color(0xFFF4F5F0);
  static const Color muted = Color(0xFF626B66);
  static const Color line = Color(0xFFDEE3DB);
  static const Color green = Color(0xFF237548);
  static const Color red = Color(0xFFB94338);
  static const Color amber = Color(0xFF936715);

  final AdminBackendService _backendService = AdminBackendService();

  String selectedFilter = 'All';

  Color riskColor(String risk) {
    switch (risk) {
      case 'High':
        return red;
      case 'Medium':
        return amber;
      default:
        return green;
    }
  }

  Color riskBackground(String risk) {
    switch (risk) {
      case 'High':
        return const Color(0xFFFBECE8);
      case 'Medium':
        return const Color(0xFFFFF5D9);
      default:
        return const Color(0xFFE7F2E9);
    }
  }

  void showHotspotDetails(Map<String, dynamic> hotspot) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(24),
        ),
      ),
      builder: (context) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(23),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'HOTSPOT DETAILS',
                  style: TextStyle(
                    color: muted,
                    fontSize: 11,
                    letterSpacing: 2,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  (hotspot['location'] ?? 'Unknown').toString(),
                  style: const TextStyle(
                    color: ink,
                    fontSize: 24,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 18),
                _detailRow(
                  'Nearby reports',
                  '${hotspot['reports'] ?? 0}',
                ),
                _detailRow(
                  'Risk level',
                  (hotspot['risk'] ?? 'Low').toString(),
                ),
                _detailRow(
                  'Status',
                  (hotspot['status'] ?? 'Unverified').toString(),
                ),
                const SizedBox(height: 14),
                const Text(
                  'Live hotspot data from Firestore. '
                  'Reports do not confirm a power outage.',
                  style: TextStyle(
                    color: muted,
                    fontSize: 12,
                  ),
                ),
                const SizedBox(height: 18),
                SizedBox(
                  width: double.infinity,
                  child: FilledButton(
                    style: FilledButton.styleFrom(
                      backgroundColor: yellow,
                      foregroundColor: ink,
                      padding: const EdgeInsets.all(15),
                    ),
                    onPressed: () => Navigator.pop(context),
                    child: const Text('Close'),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _detailRow(String title, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Expanded(
            child: Text(
              title,
              style: const TextStyle(
                color: muted,
                fontSize: 13,
              ),
            ),
          ),
          Text(
            value,
            style: const TextStyle(
              color: ink,
              fontSize: 13,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List>(
      stream: _backendService.getOutageHotspots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Scaffold(
            backgroundColor: soft,
            appBar: AppBar(
              backgroundColor: soft,
              foregroundColor: ink,
              title: const Text(
                'Outage Map & Hotspots',
                style: TextStyle(
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
            body: const Center(
              child: CircularProgressIndicator(
                color: yellow,
              ),
            ),
          );
        }

        if (snapshot.hasError) {
          return Scaffold(
            backgroundColor: soft,
            appBar: AppBar(
              backgroundColor: soft,
              foregroundColor: ink,
              title: const Text('Outage Map & Hotspots'),
            ),
            body: Center(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Text(
                  'Unable to load outage data: ${snapshot.error}',
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: red),
                ),
              ),
            ),
          );
        }

        final hotspots = (snapshot.data ?? [])
            .map(
              (item) => Map<String, dynamic>.from(item as Map),
            )
            .toList();

        final filteredHotspots = hotspots.where((hotspot) {
          return selectedFilter == 'All' ||
              hotspot['risk'] == selectedFilter;
        }).toList();

        final totalReports = hotspots.fold<int>(
          0,
          (sum, hotspot) =>
              sum + ((hotspot['reports'] as num?)?.toInt() ?? 0),
        );

        return Scaffold(
          backgroundColor: soft,
          appBar: AppBar(
            backgroundColor: soft,
            foregroundColor: ink,
            elevation: 0,
            title: const Text(
              'Outage Map & Hotspots',
              style: TextStyle(
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
          body: ListView(
            padding: const EdgeInsets.fromLTRB(19, 15, 19, 30),
            children: [
              const Text(
                'OUTAGE INTELLIGENCE',
                style: TextStyle(
                  color: muted,
                  fontSize: 11,
                  letterSpacing: 2,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Spot the hotspots.',
                style: TextStyle(
                  color: ink,
                  fontSize: 28,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 6),
              const Text(
                'Explore reported power interruption clusters.',
                style: TextStyle(
                  color: muted,
                  fontSize: 13,
                ),
              ),
              const SizedBox(height: 18),

              // Summary Card
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
                      'Nearby outage reports',
                      style: TextStyle(
                        color: Color(0xFFC5D0C3),
                      ),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      '$totalReports',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 43,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '${hotspots.length} potential hotspots · Live Firestore Data',
                      style: const TextStyle(
                        color: Color(0xFFC5D0C3),
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              // Illustrative Map
              Container(
                height: 270,
                clipBehavior: Clip.antiAlias,
                decoration: BoxDecoration(
                  color: const Color(0xFFE8EDE4),
                  borderRadius: BorderRadius.circular(21),
                  border: Border.all(color: line),
                ),
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    return Stack(
                      children: [
                        Positioned.fill(
                          child: CustomPaint(
                            painter: _DemoMapPainter(),
                          ),
                        ),
                        for (int i = 0;
                            i < filteredHotspots.length;
                            i++)
                          Positioned(
                            left: (constraints.maxWidth - 44) *
                                _getCoordinate(
                                  filteredHotspots[i],
                                  'x',
                                  i,
                                ),
                            top: (constraints.maxHeight - 44) *
                                _getCoordinate(
                                  filteredHotspots[i],
                                  'y',
                                  i,
                                ),
                            child: GestureDetector(
                              onTap: () => showHotspotDetails(
                                filteredHotspots[i],
                              ),
                              child: Container(
                                width: 44,
                                height: 44,
                                alignment: Alignment.center,
                                decoration: BoxDecoration(
                                  color: riskColor(
                                    (filteredHotspots[i]['risk'] ??
                                            'Low')
                                        .toString(),
                                  ),
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                    color: Colors.white,
                                    width: 3,
                                  ),
                                  boxShadow: const [
                                    BoxShadow(
                                      color: Color(0x33000000),
                                      blurRadius: 8,
                                    ),
                                  ],
                                ),
                                child: Text(
                                  '${filteredHotspots[i]['reports'] ?? 0}',
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 13,
                                    fontWeight: FontWeight.w800,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        const Positioned(
                          left: 12,
                          bottom: 12,
                          child: Text(
                            'Illustrative map · Not GPS-based',
                            style: TextStyle(
                              color: muted,
                              fontSize: 10,
                            ),
                          ),
                        ),
                      ],
                    );
                  },
                ),
              ),

              const SizedBox(height: 12),

              const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _LegendDot(color: red, label: 'High'),
                  SizedBox(width: 15),
                  _LegendDot(color: amber, label: 'Medium'),
                  SizedBox(width: 15),
                  _LegendDot(color: green, label: 'Low'),
                ],
              ),

              const SizedBox(height: 23),

              const Text(
                'Filter by Risk',
                style: TextStyle(
                  color: ink,
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                ),
              ),

              const SizedBox(height: 12),

              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: ['All', 'High', 'Medium', 'Low'].map((risk) {
                  final selected = selectedFilter == risk;

                  return ChoiceChip(
                    label: Text(risk),
                    selected: selected,
                    selectedColor: yellow,
                    backgroundColor: Colors.white,
                    side: const BorderSide(color: line),
                    labelStyle: const TextStyle(
                      color: ink,
                      fontWeight: FontWeight.w600,
                    ),
                    onSelected: (_) {
                      setState(() {
                        selectedFilter = risk;
                      });
                    },
                  );
                }).toList(),
              ),

              const SizedBox(height: 23),

              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Hotspot Locations',
                    style: TextStyle(
                      color: ink,
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  Text(
                    '${filteredHotspots.length} areas',
                    style: const TextStyle(
                      color: muted,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 12),

              if (filteredHotspots.isEmpty)
                const Center(
                  child: Padding(
                    padding: EdgeInsets.all(20),
                    child: Text('No hotspots found'),
                  ),
                )
              else
                ...filteredHotspots.map((hotspot) {
                  final risk =
                      (hotspot['risk'] ?? 'Low').toString();

                  return Container(
                    margin: const EdgeInsets.only(bottom: 12),
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(21),
                      border: Border.all(color: line),
                    ),
                    child: InkWell(
                      onTap: () => showHotspotDetails(hotspot),
                      child: Row(
                        children: [
                          Container(
                            width: 44,
                            height: 44,
                            decoration: BoxDecoration(
                              color: riskBackground(risk),
                              borderRadius: BorderRadius.circular(13),
                            ),
                            child: Icon(
                              Icons.location_on_outlined,
                              color: riskColor(risk),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment:
                                  CrossAxisAlignment.start,
                              children: [
                                Text(
                                  (hotspot['location'] ?? 'Unknown')
                                      .toString(),
                                  style: const TextStyle(
                                    color: ink,
                                    fontSize: 15,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                                const SizedBox(height: 5),
                                Text(
                                  '${hotspot['reports'] ?? 0} nearby reports',
                                  style: const TextStyle(
                                    color: muted,
                                    fontSize: 12,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 6,
                            ),
                            decoration: BoxDecoration(
                              color: riskBackground(risk),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Text(
                              risk,
                              style: TextStyle(
                                color: riskColor(risk),
                                fontSize: 11,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                }),

              const SizedBox(height: 15),

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

  double _getCoordinate(
    Map<String, dynamic> hotspot,
    String key,
    int index,
  ) {
    final value = hotspot[key];

    if (value is num) {
      return value.toDouble().clamp(0.0, 1.0);
    }

    const defaultX = [0.45, 0.30, 0.65, 0.72];
    const defaultY = [0.55, 0.35, 0.38, 0.72];

    if (key == 'x') {
      return defaultX[index % defaultX.length];
    }

    return defaultY[index % defaultY.length];
  }
}

// Decorative illustration only, not a geographic map.
class _DemoMapPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final roadPaint = Paint()
      ..color = Colors.white
      ..strokeWidth = 13
      ..style = PaintingStyle.stroke;

    final secondaryRoadPaint = Paint()
      ..color = const Color(0xFFD2DCD0)
      ..strokeWidth = 5
      ..style = PaintingStyle.stroke;

    final road1 = Path()
      ..moveTo(0, size.height * 0.25)
      ..quadraticBezierTo(
        size.width * 0.5,
        size.height * 0.55,
        size.width,
        size.height * 0.2,
      );

    final road2 = Path()
      ..moveTo(size.width * 0.2, 0)
      ..quadraticBezierTo(
        size.width * 0.4,
        size.height * 0.5,
        size.width * 0.75,
        size.height,
      );

    final road3 = Path()
      ..moveTo(0, size.height * 0.8)
      ..lineTo(size.width, size.height * 0.65);

    canvas.drawPath(road1, roadPaint);
    canvas.drawPath(road2, roadPaint);
    canvas.drawPath(road3, secondaryRoadPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return false;
  }
}

class _LegendDot extends StatelessWidget {
  final Color color;
  final String label;

  const _LegendDot({
    required this.color,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 10,
          height: 10,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: 5),
        Text(
          label,
          style: const TextStyle(
            color: Color(0xFF626B66),
            fontSize: 11,
          ),
        ),
      ],
    );
  }
}