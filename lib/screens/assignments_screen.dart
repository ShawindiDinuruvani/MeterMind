import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/assignment_model.dart';
import '../services/firebase_service.dart';
import '../theme/app_theme.dart';
import '../widgets/status_chip.dart';
import '../widgets/common_widgets.dart';
import 'reading_entry_screen.dart';
import 'readings_history_screen.dart';

class AssignmentsScreen extends StatefulWidget {
  const AssignmentsScreen({super.key});

  @override
  State<AssignmentsScreen> createState() => _AssignmentsScreenState();
}

class _AssignmentsScreenState extends State<AssignmentsScreen> {
  String _activeFilter = 'All'; // 'All', 'Pending', 'Completed'
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final firebaseService = FirebaseService();
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return StreamBuilder<List<AssignmentModel>>(
      stream: firebaseService.streamAssignments(),
      builder: (context, snapshot) {
        final allAssignments = snapshot.data ?? [];

        final filtered = allAssignments.where((a) {
          if (_activeFilter == 'Pending' && a.status != 'Pending') return false;
          if (_activeFilter == 'Completed' && a.status != 'Completed') return false;
          if (_searchQuery.isNotEmpty) {
            final q = _searchQuery.toLowerCase();
            final matchesName = a.customerName.toLowerCase().contains(q);
            final matchesMeter = a.meterId.toLowerCase().contains(q);
            final matchesAddress = a.address.toLowerCase().contains(q);
            return matchesName || matchesMeter || matchesAddress;
          }
          return true;
        }).toList();

        return Scaffold(
          body: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(18, 12, 18, 30),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const EyebrowHeader(
                  eyebrow: 'FIELD WORKSPACE',
                  title: 'Your assignments.',
                  subtitle: 'Homagama · due today',
                ),

                // Search Bar
                Container(
                  margin: const EdgeInsets.only(top: 14),
                  decoration: BoxDecoration(
                    color: isDark ? AppColors.darkCard : Colors.white,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: isDark ? AppColors.darkLine : AppColors.line),
                  ),
                  child: TextField(
                    controller: _searchController,
                    onChanged: (val) => setState(() => _searchQuery = val.trim()),
                    decoration: InputDecoration(
                      hintText: 'Search by meter ID, customer, address...',
                      prefixIcon: const Icon(Icons.search_rounded, size: 20),
                      border: InputBorder.none,
                      enabledBorder: InputBorder.none,
                      focusedBorder: InputBorder.none,
                      suffixIcon: _searchQuery.isNotEmpty
                          ? IconButton(
                              icon: const Icon(Icons.clear_rounded, size: 18),
                              onPressed: () {
                                _searchController.clear();
                                setState(() => _searchQuery = '');
                              },
                            )
                          : null,
                    ),
                  ),
                ),

                // Filter Tabs (All / Pending / Completed)
                Container(
                  margin: const EdgeInsets.only(top: 14),
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: isDark ? const Color(0xFF354138) : const Color(0xFFE7EAE2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: ['All', 'Pending', 'Completed'].map((tab) {
                      final isActive = _activeFilter == tab;
                      final count = allAssignments.where((a) {
                        if (tab == 'Pending') return a.status == 'Pending';
                        if (tab == 'Completed') return a.status == 'Completed';
                        return true;
                      }).length;

                      return Expanded(
                        child: GestureDetector(
                          onTap: () => setState(() => _activeFilter = tab),
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 180),
                            padding: const EdgeInsets.symmetric(vertical: 10),
                            decoration: BoxDecoration(
                              color: isActive
                                  ? (isDark ? const Color(0xFF4A5749) : Colors.white)
                                  : Colors.transparent,
                              borderRadius: BorderRadius.circular(9),
                              boxShadow: isActive
                                  ? [
                                      BoxShadow(
                                        color: Colors.black.withValues(alpha: 0.05),
                                        blurRadius: 4,
                                        offset: const Offset(0, 2),
                                      ),
                                    ]
                                  : [],
                            ),
                            child: Center(
                              child: Text(
                                '$tab ($count)',
                                style: GoogleFonts.inter(
                                  fontSize: 12.5,
                                  fontWeight: isActive ? FontWeight.w700 : FontWeight.w500,
                                  color: isActive
                                      ? (isDark ? AppColors.darkText : AppColors.ink)
                                      : (isDark ? AppColors.darkMuted : AppColors.muted),
                                ),
                              ),
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ),

                const SizedBox(height: 10),

                // Assignment List Cards
                if (filtered.isEmpty)
                  Container(
                    margin: const EdgeInsets.only(top: 24),
                    padding: const EdgeInsets.all(28),
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: isDark ? AppColors.darkCard : Colors.white,
                      borderRadius: BorderRadius.circular(21),
                      border: Border.all(color: isDark ? AppColors.darkLine : AppColors.line),
                    ),
                    child: Column(
                      children: [
                        const Icon(Icons.inbox_outlined, size: 40, color: AppColors.muted),
                        const SizedBox(height: 12),
                        Text(
                          'No assignments here',
                          style: GoogleFonts.inter(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Try another status filter or clear search.',
                          style: GoogleFonts.inter(fontSize: 13, color: AppColors.muted),
                        ),
                      ],
                    ),
                  )
                else
                  ...filtered.map((item) {
                    final isDone = item.status == 'Completed';

                    return Container(
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
                              Expanded(
                                child: Text(
                                  item.customerName,
                                  style: GoogleFonts.inter(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ),
                              StatusChip.fromStatus(item.status),
                            ],
                          ),
                          const SizedBox(height: 4),
                          Text(
                            '${item.meterId} · ${item.area}',
                            style: GoogleFonts.inter(
                              fontSize: 12.5,
                              color: isDark ? AppColors.darkMuted : AppColors.muted,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            item.address,
                            style: GoogleFonts.inter(
                              fontSize: 13.5,
                              color: isDark ? AppColors.darkText : AppColors.ink,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'Due ${item.dueDate}',
                                style: GoogleFonts.inter(
                                  fontSize: 11.5,
                                  color: AppColors.muted,
                                ),
                              ),
                              Text(
                                'Prev: ${item.previousReading.toString().replaceAllMapped(RegExp(r"(\d{1,3})(?=(\d{3})+(?!\d))"), (match) => "${match[1]},")} kWh',
                                style: GoogleFonts.inter(
                                  fontSize: 11.5,
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.muted,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 14),
                          if (isDone)
                            OutlinedButton(
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => ReadingsHistoryScreen(
                                      meterId: item.meterId,
                                    ),
                                  ),
                                );
                              },
                              child: const Text('View reading'),
                            )
                          else
                            ElevatedButton(
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => ReadingEntryScreen(
                                      assignment: item,
                                    ),
                                  ),
                                );
                              },
                              child: const Text('Enter reading'),
                            ),
                        ],
                      ),
                    );
                  }),
              ],
            ),
          ),
        );
      },
    );
  }
}
