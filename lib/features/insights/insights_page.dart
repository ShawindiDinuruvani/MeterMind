import 'package:flutter/material.dart';
import '../../shared/widgets/common_widgets.dart';

class InsightsPage extends StatefulWidget {
  const InsightsPage({super.key});

  @override
  State<InsightsPage> createState() => _InsightsPageState();
}

class _InsightsPageState extends State<InsightsPage> {
  String _period = 'Monthly';

  static const Map<String, List<int>> _periodValues = {
    'Daily': [7, 9, 12, 11, 8, 10, 9],
    'Weekly': [72, 84, 80, 76],
    'Monthly': [298, 320, 286, 339, 312],
  };

  static const Map<String, List<String>> _periodLabels = {
    'Daily': ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'],
    'Weekly': ['W1', 'W2', 'W3', 'W4'],
    'Monthly': ['Jun', 'Jul', 'Aug', 'Sep', 'Oct'],
  };

  static const Map<String, String> _periodAverage = {
    'Daily': '9.4 kWh',
    'Weekly': '78 kWh',
    'Monthly': '311 kWh',
  };

  @override
  Widget build(BuildContext context) => SingleChildScrollView(
    padding: const EdgeInsets.fromLTRB(19, 18, 19, 25),
    child: ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 480),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: _buildContent(),
      ),
    ),
  );

  List<Widget> _buildContent() {
    final vals = _periodValues[_period]!;
    final labs = _periodLabels[_period]!;
    return [
      header('Consumption insights.', 'Readings become a clearer picture.', isCustomer: true),
      tabs(['Daily', 'Weekly', 'Monthly'], _period, (v) => setState(() => _period = v)),
      card([
        row(heading('$_period usage'), text('kWh', sub: true)),
        chart(vals, labs),
        rule(),
        text(
          _period == 'Monthly'
              ? 'Measured monthly readings.'
              : 'Illustrative breakdown: manual monthly readings cannot measure ${_period.toLowerCase()} usage.',
          sub: true,
        ),
      ]),
      grid(
        mini('Average', _periodAverage[_period]!),
        mini('Change', '\u2193 8%', 'Latest measured month'),
      ),
      card([
        entry('Highest month', '339 kWh', 'September'),
        entry('Lowest month', '286 kWh', 'August'),
        link('Reading history \u2192', 'history', onTap: () {}),
      ]),
      button('Smart prediction', to: 'prediction', action: () {}),
      button('Unusual usage example', to: 'anomaly', secondary: true, action: () {}),
    ];
  }
}