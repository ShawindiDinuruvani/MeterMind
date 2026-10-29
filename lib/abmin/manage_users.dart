
import 'package:flutter/material.dart';

class ManageUsersPage extends StatefulWidget {
  const ManageUsersPage({super.key});

  @override
  State<ManageUsersPage> createState() => _ManageUsersPageState();
}

class _ManageUsersPageState extends State<ManageUsersPage> {
  String searchText = '';
  String selectedRole = 'All';

  final List<Map<String, String>> users = [
    {
      'name': 'Nimal Perera',
      'email': 'nimal@example.com',
      'role': 'Customer',
      'status': 'Active',
    },
    {
      'name': 'Kamal Silva',
      'email': 'kamal@example.com',
      'role': 'Meter Reader',
      'status': 'Active',
    },
    {
      'name': 'Amali Fernando',
      'email': 'amali@example.com',
      'role': 'Customer',
      'status': 'Inactive',
    },
    {
      'name': 'Saman Kumara',
      'email': 'saman@example.com',
      'role': 'Meter Reader',
      'status': 'Active',
    },
  ];

  @override
  Widget build(BuildContext context) {
    final filteredUsers = users.where((user) {
      final matchesSearch =
          user['name']!.toLowerCase().contains(searchText.toLowerCase()) ||
          user['email']!.toLowerCase().contains(searchText.toLowerCase());

      final matchesRole =
          selectedRole == 'All' || user['role'] == selectedRole;

      return matchesSearch && matchesRole;
    }).toList();

    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FB),
      appBar: AppBar(
        title: const Text('Manage Users'),
        backgroundColor: const Color(0xFF2563EB),
        foregroundColor: Colors.white,
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                TextField(
                  decoration: InputDecoration(
                    hintText: 'Search users...',
                    prefixIcon: const Icon(Icons.search),
                    filled: true,
                    fillColor: Colors.white,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  onChanged: (value) {
                    setState(() {
                      searchText = value;
                    });
                  },
                ),
                const SizedBox(height: 12),
                DropdownButtonFormField<String>(
                  initialValue: selectedRole,
                  decoration: const InputDecoration(
                    labelText: 'Filter by Role',
                    border: OutlineInputBorder(),
                  ),
                  items: ['All', 'Customer', 'Meter Reader']
                      .map(
                        (role) => DropdownMenuItem(
                          value: role,
                          child: Text(role),
                        ),
                      )
                      .toList(),
                  onChanged: (value) {
                    if (value != null) {
                      setState(() {
                        selectedRole = value;
                      });
                    }
                  },
                ),
              ],
            ),
          ),
          Expanded(
            child: filteredUsers.isEmpty
                ? const Center(child: Text('No users found'))
                : ListView.builder(
                    itemCount: filteredUsers.length,
                    itemBuilder: (context, index) {
                      final user = filteredUsers[index];

                      return Card(
                        margin: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 6,
                        ),
                        child: ListTile(
                          leading: const CircleAvatar(
                            backgroundColor: Color(0xFFDBEAFE),
                            child: Icon(Icons.person),
                          ),
                          title: Text(user['name']!),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(user['email']!),
                              Text('Role: ${user['role']}'),
                            ],
                          ),
                          trailing: PopupMenuButton<String>(
                            onSelected: (action) {
                              if (action == 'status') {
                                setState(() {
                                  user['status'] =
                                      user['status'] == 'Active'
                                          ? 'Inactive'
                                          : 'Active';
                                });
                              }
                            },
                            itemBuilder: (context) => [
                              PopupMenuItem(
                                enabled: false,
                                child: Text(user['status']!),
                              ),
                              const PopupMenuItem(
                                value: 'status',
                                child: Text('Change Status'),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}
