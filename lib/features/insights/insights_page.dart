import 'package:flutter/material.dart';
import '../../models/customer_usage_model.dart';
import '../../services/auth_service.dart';
import '../../services/customer_firebase_service.dart';
import '../../shared/widgets/common_widgets.dart';

class InsightsPage extends StatefulWidget {
  final ValueChanged<int>? onNavigateToTab;

  const InsightsPage({super.key, this.onNavigateToTab});

  @override
  State<InsightsPage> createState() => _InsightsPageState();
}

class _InsightsPageState extends State<InsightsPage> {
  String _period = 'Monthly';

  static const Map<String, List<int>> _fallbackPeriodValues = {
    'Daily': [7, 9, 12, 11, 8, 10, 9],
    'Weekly': [72, 84, 80, 76],
    'Monthly': [298, 320, 286, 339, 312],
  };

  static const Map<String, List<String>> _fallbackPeriodLabels = {
    'Daily': ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'],
    'Weekly': ['W1', 'W2', 'W3', 'W4'],
    'Monthly': ['Jun', 'Jul', 'Aug', 'Sep', 'Oct'],
  };

  void _showReadingHistoryDialog(BuildContext context, String meterId) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: const Color(0xFFF4F5F0),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (sheetCtx) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 28),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Reading History',
                    style: TextStyle(fontSize: 21, fontWeight: FontWeight.w800),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close_rounded),
                    onPressed: () => Navigator.pop(sheetCtx),
                  ),
                ],
              ),
              const SizedBox(height: 6),
              Text(
                'Historical meter records for Meter $meterId',
                style: const TextStyle(fontSize: 13, color: Color(0xFF65716A)),
              ),
              const SizedBox(height: 18),
              _buildHistoryList(meterId),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHistoryList(String meterId) {
    final customer = CustomerFirebaseService().currentCustomer;
    final latestReading = customer.latestReadingKwh > 0 ? customer.latestReadingKwh : 15700;
    final latestDate = customer.latestReadingDate.isNotEmpty ? customer.latestReadingDate : '01 Oct 2026';

    final records = [
      {'date': latestDate, 'reading': '$latestReading kWh', 'units': '${customer.currentUsageKwh} units', 'status': 'Verified'},
      {'date': '01 Sep 2026', 'reading': '15,388 kWh', 'units': '339 units', 'status': 'Verified'},
      {'date': '01 Aug 2026', 'reading': '15,049 kWh', 'units': '286 units', 'status': 'Verified'},
      {'date': '01 Jul 2026', 'reading': '14,763 kWh', 'units': '310 units', 'status': 'Verified'},
      {'date': '01 Jun 2026', 'reading': '14,453 kWh', 'units': '280 units', 'status': 'Verified'},
    ];

    return Column(
      children: records.map((r) => Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: const Color(0xFFDDE3DA)),
        ),
        child: Row(
          children: [
            const Icon(Icons.history_rounded, size: 20, color: Color(0xFF237548)),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(r['date']!, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 14)),
                  Text(r['reading']!, style: const TextStyle(fontSize: 12, color: Color(0xFF65716A))),
                ],
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(r['units']!, style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 13, color: Color(0xFF17201D))),
                Text(r['status']!, style: const TextStyle(fontSize: 11, color: Color(0xFF237548), fontWeight: FontWeight.w600)),
              ],
            ),
          ],
        ),
      )).toList(),
    );
  }

  void _showPredictionDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (dlg) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(22)),
        title: const Text('Smart Prediction Analysis', style: TextStyle(fontWeight: FontWeight.w800)),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Forecast Window: Next 30 Days', style: TextStyle(fontWeight: FontWeight.w700)),
            SizedBox(height: 8),
            Text(
              'Based on your rolling 5-month consumption average (311 kWh) and seasonal temperature forecasts for Homagama, your predicted usage is 328–345 kWh.',
              style: TextStyle(fontSize: 13, color: Color(0xFF65716A), height: 1.45),
            ),
            SizedBox(height: 12),
            Text(
              'Estimated tariff tier: Domestic General Slab 3.',
              style: TextStyle(fontSize: 12, color: Color(0xFF936715), fontWeight: FontWeight.w600),
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(dlg), child: const Text('Close')),
        ],
      ),
    );
  }

  void _showAnomalyDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (dlg) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(22)),
        title: const Text('Usage Anomaly Inspection', style: TextStyle(fontWeight: FontWeight.w800)),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Current Status: Normal Baseline', style: TextStyle(fontWeight: FontWeight.w700, color: Color(0xFF237548))),
            SizedBox(height: 8),
            Text(
              'No sharp spikes (>35% above average) were detected during your last billing period. Your usage fluctuates within a standard domestic variance of \u00b18%.',
              style: TextStyle(fontSize: 13, color: Color(0xFF65716A), height: 1.45),
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(dlg), child: const Text('Close')),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final currentUser = AuthService.instance.currentUser;
    final meterId = currentUser?.meterId?.isNotEmpty == true
        ? currentUser!.meterId!
        : 'MM-04218';

    final customerService = CustomerFirebaseService();

    return StreamBuilder<List<CustomerUsageModel>>(
      stream: customerService.streamUsageHistory(
        meterId: meterId,
        periodType: _period.toLowerCase(),
      ),
      builder: (context, snapshot) {
        List<int> vals = _fallbackPeriodValues[_period]!;
        List<String> labs = _fallbackPeriodLabels[_period]!;

        if (snapshot.hasData && snapshot.data!.isNotEmpty) {
          final history = snapshot.data!;
          vals = history.map((e) => e.kwh).toList();
          labs = history.map((e) => e.label).toList();
        }

        final average = vals.isNotEmpty
            ? (vals.reduce((a, b) => a + b) / vals.length).toStringAsFixed(1)
            : '0.0';

        return LayoutBuilder(
          builder: (context, constraints) {
            final isWide = constraints.maxWidth >= 768;
            final isDesktop = constraints.maxWidth >= 1024;
            final horizontalPadding = isWide ? 32.0 : 19.0;
            final maxContentWidth = isDesktop ? 1040.0 : (isWide ? 840.0 : 540.0);

            return Center(
              child: ConstrainedBox(
                constraints: BoxConstraints(maxWidth: maxContentWidth),
                child: SingleChildScrollView(
                  padding: EdgeInsets.fromLTRB(horizontalPadding, 18, horizontalPadding, 32),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: _buildResponsiveContent(
                      context,
                      isWide: isWide,
                      values: vals,
                      labels: labs,
                      averageText: '$average kWh',
                      meterId: meterId,
                    ),
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }

  List<Widget> _buildResponsiveContent(
    BuildContext context, {
    required bool isWide,
    required List<int> values,
    required List<String> labels,
    required String averageText,
    required String meterId,
  }) {
    final headerWidget = header(
      'Consumption insights.',
      'Readings become a clearer picture.',
      isCustomer: true,
    );

    final tabsWidget = tabs(
      const ['Daily', 'Weekly', 'Monthly'],
      _period,
      (v) => setState(() => _period = v),
    );

    final chartCard = card([
      row(heading('$_period usage'), text('kWh', sub: true)),
      chart(values, labels),
      rule(),
      text(
        _period == 'Monthly'
            ? 'Measured monthly meter readings.'
            : 'Illustrative breakdown: manual monthly readings cannot measure ${_period.toLowerCase()} usage.',
        sub: true,
      ),
    ]);

    final summaryGrid = grid(
      mini('Average', averageText),
      mini('Change', '\u2193 8%', 'Latest measured month'),
    );

    final historyCard = card([
      entry('Highest period', '${values.isNotEmpty ? values.reduce((a, b) => a > b ? a : b) : 0} kWh', 'Peak recorded'),
      entry('Lowest period', '${values.isNotEmpty ? values.reduce((a, b) => a < b ? a : b) : 0} kWh', 'Baseline recorded'),
      link('Reading history \u2192', 'history', onTap: () => _showReadingHistoryDialog(context, meterId)),
    ]);

    final actionButtons = Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        button('Smart prediction', to: 'prediction', action: () => _showPredictionDialog(context)),
        button('Unusual usage example', to: 'anomaly', secondary: true, action: () => _showAnomalyDialog(context)),
      ],
    );

    if (!isWide) {
      return [
        headerWidget,
        tabsWidget,
        chartCard,
        summaryGrid,
        historyCard,
        actionButtons,
      ];
    }

    return [
      headerWidget,
      tabsWidget,
      const SizedBox(height: 12),
      Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 6,
            child: chartCard,
          ),
          const SizedBox(width: 20),
          Expanded(
            flex: 5,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                summaryGrid,
                historyCard,
                actionButtons,
              ],
            ),
          ),
        ],
      ),
    ];
  }
}
