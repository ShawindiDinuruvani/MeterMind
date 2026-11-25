import 'package:flutter/material.dart';
import '../../models/customer_model.dart';
import '../../services/auth_service.dart';
import '../../services/customer_firebase_service.dart';
import '../../shared/widgets/common_widgets.dart';

class HomePage extends StatelessWidget {
  final ValueChanged<int>? onNavigateToTab;

  const HomePage({super.key, this.onNavigateToTab});

  @override
  Widget build(BuildContext context) {
    final currentUser = AuthService.instance.currentUser;
    final meterId = currentUser?.meterId?.isNotEmpty == true
        ? currentUser!.meterId!
        : 'MM-04218';

    final customerService = CustomerFirebaseService();

    return StreamBuilder<CustomerModel>(
      stream: customerService.streamCustomerProfile(meterId: meterId),
      builder: (context, snapshot) {
        final customer = snapshot.data ?? customerService.currentCustomer;
        final name = (currentUser?.name.isNotEmpty == true)
            ? currentUser!.name.split(' ').first
            : (customer.name.isNotEmpty ? customer.name.split(' ').first : 'Customer');
        final displayMeterId = (currentUser?.meterId?.isNotEmpty == true)
            ? currentUser!.meterId!
            : customer.meterId;
        final area = (currentUser?.area?.isNotEmpty == true)
            ? currentUser!.area!
            : customer.area;

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
                      name: name,
                      meterId: displayMeterId,
                      area: area,
                      customer: customer,
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
    required String name,
    required String meterId,
    required String area,
    required CustomerModel customer,
  }) {
    final usageThisMonth = customer.currentUsageKwh;
    final usageChangePercent = customer.usageChangePercent;
    final changeText = usageChangePercent <= 0
        ? '\u2193 ${usageChangePercent.abs().toStringAsFixed(0)}% vs last month'
        : '\u2191 ${usageChangePercent.toStringAsFixed(0)}% vs last month';
    final latestReading = customer.latestReadingKwh > 0
        ? '${customer.latestReadingKwh} kWh'
        : 'No readings yet';
    final readingDate = customer.latestReadingDate.isNotEmpty
        ? customer.latestReadingDate
        : 'Pending';
    final estimatedBill = customer.estimatedBillLkr > 0
        ? 'Rs. ${customer.estimatedBillLkr.toStringAsFixed(0)}'
        : 'Rs. 0';
    final forecastRange = '${customer.forecastMinKwh}\u2013${customer.forecastMaxKwh}';

    final headerWidget = header(
      'Good morning,\n$name.',
      'Meter $meterId \u00b7 $area',
      isCustomer: true,
    );

    final usageCard = card([
      row(
        text('Your usage this month', size: 12, light: true),
        chip(customer.meterStatus.isNotEmpty ? customer.meterStatus : 'Meter active', '', true),
      ),
      bigNumber('$usageThisMonth', 'kWh'),
      Align(
        alignment: Alignment.centerLeft,
        child: chip(changeText, '', true),
      ),
      chart(
        const [298, 320, 286, 339, 312],
        const ['Jun', 'Jul', 'Aug', 'Sep', 'Oct'],
        glass: true,
      ),
      rule(light: true),
      row(
        text('Latest reading \u00b7 $readingDate', size: 12, light: true),
        text(latestReading, light: true, bold: true),
      ),
    ], glass: true, padding: 23);

    final metricsGrid = grid(
      mini('Estimated bill', estimatedBill, 'Illustrative tariff'),
      mini('Next month', forecastRange, 'kWh \u00b7 forecast range'),
    );

    final linksGrid = grid(
      link('View estimate \u2192', 'bill', onTap: () {
        onNavigateToTab?.call(1);
      }),
      link('Explore prediction \u2192', 'prediction', onTap: () {
        onNavigateToTab?.call(1);
      }),
    );

    final outageCard = card([
      row(
        heading('Nearby outage reports'),
        chip('Unverified', 'warn'),
      ),
      text('Community reports near $area. Verify status before acting.'),
      link('View outage intelligence \u2192', 'outages', onTap: () {
        onNavigateToTab?.call(2);
      }),
    ], alert: true);

    final actionButtons = grid(
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
    );

    final tipsCard = card([
      heading('A small change, a lighter bill.'),
      text('Review your highest usage periods before choosing what to reduce.'),
      link('Your recommendations \u2192', 'recommendations', onTap: () {
        onNavigateToTab?.call(3);
      }),
    ]);

    if (!isWide) {
      return [
        headerWidget,
        usageCard,
        metricsGrid,
        linksGrid,
        outageCard,
        actionButtons,
        tipsCard,
      ];
    }

    // Wide screen 2-column balanced layout
    return [
      headerWidget,
      const SizedBox(height: 8),
      Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 6,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                usageCard,
                const SizedBox(height: 14),
                tipsCard,
              ],
            ),
          ),
          const SizedBox(width: 20),
          Expanded(
            flex: 5,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                metricsGrid,
                linksGrid,
                outageCard,
                actionButtons,
              ],
            ),
          ),
        ],
      ),
    ];
  }
}
