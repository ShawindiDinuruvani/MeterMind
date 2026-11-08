import 'package:flutter/material.dart';
import '../../services/auth_service.dart';
import '../../shared/widgets/common_widgets.dart';

class HomePage extends StatelessWidget {
  final ValueChanged<int>? onNavigateToTab;

  const HomePage({super.key, this.onNavigateToTab});

  @override
  Widget build(BuildContext context) {
    final currentUser = AuthService.instance.currentUser;
    final name = (currentUser?.name.isNotEmpty == true)
        ? currentUser!.name.split(' ').first
        : 'Tharusha';
    final meterId = currentUser?.meterId?.isNotEmpty == true
        ? currentUser!.meterId!
        : 'MM-04218';
    final area = currentUser?.area?.isNotEmpty == true
        ? currentUser!.area!
        : 'Homagama';

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(19, 18, 19, 25),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 480),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: _buildContent(context, name, meterId, area),
        ),
      ),
    );
  }

  List<Widget> _buildContent(
    BuildContext context,
    String name,
    String meterId,
    String area,
  ) =>
      [
        header(
          'Good morning,\n$name.',
          'Meter $meterId \u00b7 $area',
          isCustomer: true,
        ),
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
          chart(
            [298, 320, 286, 339, 312],
            ['Jun', 'Jul', 'Aug', 'Sep', 'Oct'],
            glass: true,
          ),
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
          link('View estimate \u2192', 'bill', onTap: () {
            onNavigateToTab?.call(1);
          }),
          link('Explore prediction \u2192', 'prediction', onTap: () {
            onNavigateToTab?.call(1);
          }),
        ),
        card([
          row(
            heading('Nearby outage reports'),
            chip('Unverified', 'warn'),
          ),
          text('12 reports near $area. A potential hotspot needs review.'),
          link('View outage intelligence \u2192', 'outages', onTap: () {
            onNavigateToTab?.call(2);
          }),
        ], alert: true),
        grid(
          button(
            'My meter',
            to: 'meter',
            secondary: true,
            action: () {
              onNavigateToTab?.call(4);
            },
          ),
          button(
            'Usage insights',
            to: 'insights',
            secondary: true,
            action: () {
              onNavigateToTab?.call(1);
            },
          ),
        ),
        card([
          heading('A small change, a lighter bill.'),
          text(
              'Review your highest usage periods before choosing what to reduce.'),
          link('Your recommendations \u2192', 'recommendations', onTap: () {
            onNavigateToTab?.call(3);
          }),
        ]),
      ];
}
