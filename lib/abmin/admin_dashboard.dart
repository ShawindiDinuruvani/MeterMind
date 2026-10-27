import 'package:flutter/material.dart';

class AdminDashboard extends StatelessWidget {
  const AdminDashboard({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FB),
      appBar: AppBar(
        title: const Text('MeterMind Admin'),
        backgroundColor: const Color(0xFF2563EB),
        foregroundColor: Colors.white,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const Text(
            'Welcome back, Admin!',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          const Text('Electricity Management Overview'),
          const SizedBox(height: 24),

          GridView.count(
            crossAxisCount: 2,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
            childAspectRatio: 1.2,
            children: [
              _statCard('Customers', '1,248', Icons.people, Colors.blue),
              _statCard('Meters', '1,536', Icons.electric_meter, Colors.teal),
              _statCard('Readers', '32', Icons.badge, Colors.purple),
              _statCard('Active Outages', '8', Icons.warning, Colors.orange),
            ],
          ),

          const SizedBox(height: 24),
          const Text(
            'Recent Activities',
            style: TextStyle(
              fontSize: 19,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),

          const Card(
            child: Column(
              children: [
                ListTile(
                  leading: Icon(Icons.check_circle, color: Colors.green),
                  title: Text('Meter Reading Completed'),
                  subtitle: Text('Meter MTR-1001'),
                ),
                Divider(height: 1),
                ListTile(
                  leading: Icon(Icons.warning, color: Colors.orange),
                  title: Text('Power Outage Reported'),
                  subtitle: Text('Colombo'),
                ),
                Divider(height: 1),
                ListTile(
                  leading: Icon(Icons.person_add, color: Colors.blue),
                  title: Text('New Customer Registered'),
                  subtitle: Text('Customer CUS-1024'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _statCard(
    String title,
    String value,
    IconData icon,
    Color color,
  ) {
    return Card(
      color: Colors.white,
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Icon(icon, color: color, size: 30),
            Text(
              value,
              style: const TextStyle(
                fontSize: 25,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              title,
              style: const TextStyle(color: Colors.grey),
            ),
          ],
        ),
      ),
    );
  }
}