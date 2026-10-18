import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../services/firebase_service.dart';
import '../theme/app_theme.dart';
import '../widgets/common_widgets.dart';
import '../widgets/status_chip.dart';
import '../widgets/route_map_view.dart';
import 'reading_entry_screen.dart';
import 'readings_history_screen.dart';

class RouteMapScreen extends StatefulWidget {
  const RouteMapScreen({super.key});

  @override
  State<RouteMapScreen> createState() => _RouteMapScreenState();
}

class _RouteMapScreenState extends State<RouteMapScreen> {
  String _selectedArea = 'Homagama';
  String _selectedMeterId = 'MM-04218';

  void _onSelectStop(String area, String meterId) {
    setState(() {
      _selectedArea = area;
      _selectedMeterId = meterId;
    });
  }

  @override
  Widget build(BuildContext context) {
    final firebaseService = FirebaseService();
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cardBg = isDark ? AppColors.darkCard : Colors.white;
    final borderColor = isDark ? AppColors.darkLine : AppColors.line;
    final textColor = isDark ? AppColors.darkText : AppColors.ink;
    final mutedColor = isDark ? AppColors.darkMuted : AppColors.muted;

    final assignment = firebaseService.getAssignment(_selectedMeterId);
    final customerName = assignment?.customerName ??
        (_selectedArea == 'Homagama'
            ? 'Tharusha Wakwella'
            : _selectedArea == 'Pitipana'
                ? 'S. Fernando'
                : 'D. Jayasinghe');
    final isCompleted = assignment?.status == 'Completed' || _selectedArea == 'Makumbura';

    return Scaffold(
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(18, 12, 18, 30),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const EyebrowHeader(
              eyebrow: 'FIELD WORKSPACE',
              title: 'Your route, at a glance.',
              subtitle: 'Homagama · assigned meter locations',
            ),

            // Interactive vector map
            RouteMapView(
              selectedArea: _selectedArea,
              onSelectStop: _onSelectStop,
            ),

            // AI Route Optimization recommendation card
            Container(
              margin: const EdgeInsets.only(top: 14),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF2E3831) : const Color(0xFFFAF7EE),
                borderRadius: BorderRadius.circular(21),
                border: Border.all(color: AppColors.yellow.withValues(alpha: 0.6)),
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: AppColors.yellow,
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: const Icon(Icons.route_rounded, color: AppColors.ink, size: 22),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'AI Route Optimization',
                          style: GoogleFonts.inter(
                            fontSize: 14,
                            fontWeight: FontWeight.w800,
                            color: textColor,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          'Optimal order: Makumbura → Homagama → Pitipana. Saves 18 mins & 1.4 km.',
                          style: GoogleFonts.inter(
                            fontSize: 12,
                            color: mutedColor,
                            height: 1.35,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            // Selected Stop Card
            Container(
              margin: const EdgeInsets.only(top: 14),
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: cardBg,
                borderRadius: BorderRadius.circular(21),
                border: Border.all(color: borderColor),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        customerName,
                        style: GoogleFonts.inter(
                          fontSize: 17,
                          fontWeight: FontWeight.w800,
                          color: textColor,
                        ),
                      ),
                      StatusChip(
                        label: isCompleted ? 'Completed' : 'Pending',
                        type: isCompleted ? ChipType.normal : ChipType.warn,
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '$_selectedArea · $_selectedMeterId',
                    style: GoogleFonts.inter(
                      fontSize: 13,
                      color: mutedColor,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    assignment?.address ?? 'Homagama Central Route',
                    style: GoogleFonts.inter(
                      fontSize: 13,
                      color: textColor,
                    ),
                  ),
                  const SizedBox(height: 16),
                  if (isCompleted)
                    OutlinedButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => ReadingsHistoryScreen(
                              meterId: _selectedMeterId,
                            ),
                          ),
                        );
                      },
                      child: const Text('View submitted reading'),
                    )
                  else
                    ElevatedButton(
                      onPressed: () {
                        if (assignment != null) {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => ReadingEntryScreen(
                                assignment: assignment,
                              ),
                            ),
                          );
                        }
                      },
                      child: const Text('Enter reading'),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
