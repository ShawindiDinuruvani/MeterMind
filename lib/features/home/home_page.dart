import 'package:flutter/material.dart';
import '../../shared/widgets/common_widgets.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

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

  List<Widget> _buildContent() => [
    header('Good morning,\nTharusha.', 'Meter MM-04218 \u00b7 Homagama', isCustomer: true),
    card([
      row(
        text('Your usage this month', size: 12, light: true),
        chip('Meter active', '', true),
      ),
      bigNumber('312', 'kWh'),
      Align(
        alignment: Alignment.centerLeft,
        child: chip('\u2193 8% vs last month', '', true),
      ),
      chart([298, 320, 286, 339, 312], ['Jun', 'Jul', 'Aug', 'Sep', 'Oct'], glass: true),
      rule(light: true),
      row(
        text('Latest reading \u00b7 01 Oct', size: 12, light: true),
        text('15,700 kWh', light: true, bold: true),
      ),
    ], glass: true, padding: 23),
    grid(
      mini('Estimated bill', 'Rs. 8,100', 'Illustrative tariff'),
      mini('Next month', '328\u2013345', 'kWh \u00b7 forecast range'),
    ),
    grid(
      link('View estimate \u2192', 'bill', onTap: () {}),
      link('Explore prediction \u2192', 'prediction', onTap: () {}),
    ),
    card([
      row(
        heading('Nearby outage reports'),
        chip('Unverified', 'warn'),
      ),
      text('12 reports near Homagama. A potential hotspot needs review.'),
      link('View outage intelligence \u2192', 'outages', onTap: () {}),
    ], alert: true),
    grid(
      button('My meter', to: 'meter', secondary: true, action: () {}),
      button('Usage insights', to: 'insights', secondary: true, action: () {}),
    ),
    card([
      heading('A small change, a lighter bill.'),
      text('Review your highest usage periods before choosing what to reduce.'),
      link('Your recommendations \u2192', 'recommendations', onTap: () {}),
    ]),
  ];
}