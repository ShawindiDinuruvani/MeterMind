
import 'package:flutter/material.dart';

class ManageUsersPage extends StatefulWidget {
  const ManageUsersPage({super.key});

  @override
  State<ManageUsersPage> createState() => _ManageUsersPageState();
}

class _ManageUsersPageState extends State<ManageUsersPage> {
  static const yellow = Color(0xFFF5C542);
  static const ink = Color(0xFF202523);
  static const soft = Color(0xFFF4F5F0);
  static const muted = Color(0xFF626B66);
  static const line = Color(0xFFDEE3DB);
  static const green = Color(0xFF237548);
  static const red = Color(0xFFB94338);

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
      final query = searchText.toLowerCase();

      final matchesSearch =
          user['name']!.toLowerCase().contains(query) ||
          user['email']!.toLowerCase().contains(query);

      final matchesRole =
          selectedRole == 'All' || user['role'] == selectedRole;

      return matchesSearch && matchesRole;
    }).toList();

    final activeCount =
        users.where((user) => user['status'] == 'Active').length;

    return Scaffold(
      backgroundColor: soft,
      appBar: AppBar(
        backgroundColor: soft,
        foregroundColor: ink,
        elevation: 0,
        title: const Text(
          'Manage Users',
          style: TextStyle(
            fontWeight: FontWeight.w800,
            letterSpacing: -0.5,
          ),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(19, 15, 19, 30),
        children: [
          const Text(
            'SUPERVISOR WORKSPACE',
            style: TextStyle(
              color: muted,
              fontSize: 11,
              fontWeight: FontWeight.w700,
              letterSpacing: 2,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Your users.',
            style: TextStyle(
              color: ink,
              fontSize: 28,
              fontWeight: FontWeight.w800,
              letterSpacing: -1,
            ),
          ),
          const SizedBox(height: 5),
          const Text(
            'Manage customers and meter readers.',
            style: TextStyle(color: muted, fontSize: 13),
          ),
          const SizedBox(height: 18),

          // Summary Card
          Container(
            padding: const EdgeInsets.all(22),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [
                  Color(0xFF353E36),
                  Color(0xFF1C2421),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(21),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Total registered users',
                  style: TextStyle(
                    color: Color(0xFFC5D0C3),
                    fontSize: 13,
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  '${users.length}',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 43,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  '$activeCount active · '
                  '${users.length - activeCount} inactive',
                  style: const TextStyle(
                    color: Color(0xFFC5D0C3),
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 20),

          // Search Field
          TextField(
            style: const TextStyle(color: ink),
            decoration: InputDecoration(
              hintText: 'Search users...',
              hintStyle: const TextStyle(color: muted),
              prefixIcon: const Icon(Icons.search, color: muted),
              filled: true,
              fillColor: Colors.white,
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 15,
                vertical: 15,
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: const BorderSide(color: line),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: const BorderSide(
                  color: yellow,
                  width: 2,
                ),
              ),
            ),
            onChanged: (value) {
              setState(() {
                searchText = value;
              });
            },
          ),

          const SizedBox(height: 13),

          // Role Filter
          DropdownButtonFormField<String>(
            value: selectedRole,
            decoration: InputDecoration(
              labelText: 'Filter by Role',
              labelStyle: const TextStyle(color: muted),
              filled: true,
              fillColor: Colors.white,
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: const BorderSide(color: line),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: const BorderSide(
                  color: yellow,
                  width: 2,
                ),
              ),
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

          const SizedBox(height: 23),

          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'User Directory',
                style: TextStyle(
                  color: ink,
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                ),
              ),
              Text(
                '${filteredUsers.length} users',
                style: const TextStyle(
                  color: muted,
                  fontSize: 12,
                ),
              ),
            ],
          ),

          const SizedBox(height: 12),

          if (filteredUsers.isEmpty)
            Container(
              padding: const EdgeInsets.all(28),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(21),
                border: Border.all(color: line),
              ),
              child: const Center(
                child: Text(
                  'No users found',
                  style: TextStyle(color: muted),
                ),
              ),
            )
          else
            ...filteredUsers.map((user) {
              final isActive = user['status'] == 'Active';
              final isReader = user['role'] == 'Meter Reader';

              return Container(
                margin: const EdgeInsets.only(bottom: 12),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(21),
                  border: Border.all(color: line),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          width: 44,
                          height: 44,
                          decoration: BoxDecoration(
                            color: const Color(0xFFF0F1E9),
                            borderRadius: BorderRadius.circular(13),
                          ),
                          child: Icon(
                            isReader
                                ? Icons.badge_outlined
                                : Icons.person_outline,
                            color: ink,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment:
                                CrossAxisAlignment.start,
                            children: [
                              Text(
                                user['name']!,
                                style: const TextStyle(
                                  color: ink,
                                  fontSize: 15,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                user['email']!,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                  color: muted,
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                        ),
                        PopupMenuButton<String>(
                          tooltip: 'User actions',
                          icon: const Icon(
                            Icons.more_vert,
                            color: ink,
                          ),
                          onSelected: (action) {
                            if (action == 'status') {
                              setState(() {
                                user['status'] =
                                    isActive ? 'Inactive' : 'Active';
                              });

                              ScaffoldMessenger.of(context)
                                  .showSnackBar(
                                SnackBar(
                                  content: Text(
                                    '${user['name']} status updated '
                                    'in demo.',
                                  ),
                                ),
                              );
                            }
                          },
                          itemBuilder: (context) => [
                            PopupMenuItem<String>(
                              enabled: false,
                              child: Text(
                                'Status: ${user['status']}',
                              ),
                            ),
                            PopupMenuItem<String>(
                              value: 'status',
                              child: Text(
                                isActive
                                    ? 'Deactivate User'
                                    : 'Activate User',
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(height: 14),
                    const Divider(color: line, height: 1),
                    const SizedBox(height: 13),
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: const Color(0xFFFFF5D9),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            user['role']!,
                            style: const TextStyle(
                              color: ink,
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                        const Spacer(),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: isActive
                                ? const Color(0xFFE7F2E9)
                                : const Color(0xFFFBECE8),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            user['status']!,
                            style: TextStyle(
                              color: isActive ? green : red,
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              );
            }),

          const SizedBox(height: 12),
          const Center(
            child: Text(
              'Demo user data · Backend not connected',
              style: TextStyle(
                color: muted,
                fontSize: 11,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
