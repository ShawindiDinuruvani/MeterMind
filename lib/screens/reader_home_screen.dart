import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/reader_model.dart';
import '../models/assignment_model.dart';
import '../services/firebase_service.dart';
import '../theme/app_theme.dart';
import '../widgets/glass_card.dart';
import '../widgets/status_chip.dart';
import '../widgets/common_widgets.dart';
import '../widgets/ai_assistant_sheet.dart';
import 'reading_entry_screen.dart';
import 'daily_progress_screen.dart';
import 'readings_history_screen.dart';

class ReaderHomeScreen extends StatelessWidget {
  final VoidCallback onNavigateToAssignments;

  const ReaderHomeScreen({
    super.key,
    required this.onNavigateToAssignments,
  });

  @override
  Widget build(BuildContext context) {
    final firebaseService = FirebaseService();
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return StreamBuilder<ReaderModel>(
      stream: firebaseService.streamReaderProfile(),
      builder: (context, readerSnapshot) {
        final reader = readerSnapshot.data ??
            ReaderModel(
              id: 'MR001',
              name: 'Nimal Perera',
              employeeCode: 'MR001',
              area: 'Homagama',
              email: 'nimal.perera@metermind.lk',
              assignedCount: 40,
              completedCount: 28,
              pendingCount: 12,
            );

        return StreamBuilder<List<AssignmentModel>>(
          stream: firebaseService.streamAssignments(),
          builder: (context, assignSnapshot) {
            final assignments = assignSnapshot.data ?? [];
            final nextAssignment = assignments.isNotEmpty
                ? assignments.firstWhere(
                    (a) => a.status == 'Pending',
                    orElse: () => assignments.first,
                  )
                : AssignmentModel(
                    id: 'MM-04218',
                    meterId: 'MM-04218',
                    customerName: 'Tharusha Wakwella',
                    address: '24 Temple Road, Homagama',
                    area: 'Homagama',
                    previousReading: 15700,
                    previousReadingDate: '01 Oct 2026',
                    dueDate: '04 Oct 2026',
                    status: 'Pending',
                    latitude: 6.8404,
                    longitude: 80.0034,
                  );

            final percent = reader.assignedCount > 0
                ? (reader.completedCount / reader.assignedCount).clamp(0.0, 1.0)
                : 0.7;

            return Scaffold(
              body: RefreshIndicator(
                color: AppColors.yellow,
                onRefresh: () async {
                  await Future.delayed(const Duration(milliseconds: 600));
                },
                child: SingleChildScrollView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  padding: const EdgeInsets.fromLTRB(18, 12, 18, 30),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Header
                      EyebrowHeader(
                        eyebrow: 'FIELD WORKSPACE',
                        title: 'Ready for your\nnext reading?',
                        subtitle: '${reader.name} · ${reader.employeeCode} · ${reader.area}',
                      ),

                      // Glass Hero Card
                      GlassCard(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Today’s route',
                              style: GoogleFonts.inter(
                                fontSize: 13,
                                color: AppColors.glassSub,
                              ),
                            ),
                            const SizedBox(height: 6),
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.baseline,
                              textBaseline: TextBaseline.alphabetic,
                              children: [
                                Text(
                                  '${reader.completedCount}',
                                  style: GoogleFonts.inter(
                                    fontSize: 48,
                                    fontWeight: FontWeight.w800,
                                    color: Colors.white,
                                    letterSpacing: -2,
                                  ),
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  ' / ${reader.assignedCount} meters',
                                  style: GoogleFonts.inter(
                                    fontSize: 16,
                                    color: AppColors.glassSub,
                                  ),
                                ),
                                const Spacer(),
                                StatusChip(
                                  label: '${(percent * 100).round()}% complete',
                                  type: ChipType.normal,
                                ),
                              ],
                            ),
                            const SizedBox(height: 12),
                            // Progress bar
                            Container(
                              height: 8,
                              decoration: BoxDecoration(
                                color: Colors.white.withValues(alpha: 0.15),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              clipBehavior: Clip.antiAlias,
                              child: FractionallySizedBox(
                                widthFactor: percent,
                                alignment: Alignment.centerLeft,
                                child: Container(
                                  decoration: BoxDecoration(
                                    color: AppColors.yellow,
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(height: 14),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  '${reader.pendingCount} readings remaining',
                                  style: GoogleFonts.inter(
                                    fontSize: 12,
                                    color: AppColors.glassSub,
                                  ),
                                ),
                                Text(
                                  reader.area,
                                  style: GoogleFonts.inter(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w700,
                                    color: Colors.white,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),

                      // Grid2 Mini Cards
                      Row(
                        children: [
                          MiniCard(
                            label: 'Assigned',
                            value: '${reader.assignedCount}',
                            sub: 'Today’s target',
                          ),
                          const SizedBox(width: 12),
                          MiniCard(
                            label: 'Pending',
                            value: '${reader.pendingCount}',
                            sub: 'In ${reader.area}',
                          ),
                        ],
                      ),

                      // Next on Route Card
                      Container(
                        margin: const EdgeInsets.only(top: 14),
                        padding: const EdgeInsets.all(18),
                        decoration: BoxDecoration(
                          color: isDark ? AppColors.darkCard : Colors.white,
                          borderRadius: BorderRadius.circular(21),
                          border: Border.all(
                            color: isDark ? AppColors.darkLine : AppColors.line,
                          ),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  'Next on your route',
                                  style: GoogleFonts.inter(
                                    fontSize: 15,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                                StatusChip.fromStatus(nextAssignment.status),
                              ],
                            ),
                            const SizedBox(height: 10),
                            Text(
                              nextAssignment.customerName,
                              style: GoogleFonts.inter(
                                fontSize: 16,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              '${nextAssignment.meterId} · ${nextAssignment.address}',
                              style: GoogleFonts.inter(
                                fontSize: 12.5,
                                color: isDark ? AppColors.darkMuted : AppColors.muted,
                              ),
                            ),
                            const SizedBox(height: 16),
                            ElevatedButton(
                              onPressed: () {
                                if (nextAssignment.status == 'Completed') {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => ReadingsHistoryScreen(
                                        meterId: nextAssignment.meterId,
                                      ),
                                    ),
                                  );
                                } else {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => ReadingEntryScreen(
                                        assignment: nextAssignment,
                                      ),
                                    ),
                                  );
                                }
                              },
                              child: Text(
                                nextAssignment.status == 'Completed'
                                    ? 'View submitted reading'
                                    : 'Enter meter reading',
                              ),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 12),
                      OutlinedButton(
                        onPressed: onNavigateToAssignments,
                        child: const Text('All assignments'),
                      ),

                      const HelpBox(
                        text: 'Manual entry or AI OCR scan. Look at the physical meter or tap camera icon to autofill digits.',
                      ),

                      const SizedBox(height: 12),
                      OutlinedButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const DailyProgressScreen(),
                            ),
                          );
                        },
                        child: const Text('Daily progress'),
                      ),

                      // AI Copilot Quick Assist Banner
                      Container(
                        margin: const EdgeInsets.only(top: 14),
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: isDark ? const Color(0xFF2E3831) : const Color(0xFFFAF7EE),
                          borderRadius: BorderRadius.circular(21),
                          border: Border.all(color: AppColors.yellow.withValues(alpha: 0.5)),
                        ),
                        child: Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                color: AppColors.yellow,
                                borderRadius: BorderRadius.circular(14),
                              ),
                              child: const Text('ϟ', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                            ),
                            const SizedBox(width: 14),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'MeterMind AI Field Copilot',
                                    style: GoogleFonts.inter(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    'Need error code or tariff assistance?',
                                    style: GoogleFonts.inter(
                                      fontSize: 12,
                                      color: isDark ? AppColors.darkMuted : AppColors.muted,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            IconButton.filledTonal(
                              style: IconButton.styleFrom(
                                backgroundColor: AppColors.yellowLight,
                                foregroundColor: AppColors.ink,
                              ),
                              icon: const Icon(Icons.chat_bubble_outline_rounded, size: 18),
                              onPressed: () => AiAssistantSheet.show(context),
                            ),
                          ],
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
    );
  }
}
