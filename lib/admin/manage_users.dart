import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../services/admin_backend_service.dart';
import '../services/auth_service.dart';

class ManageUsersPage extends StatefulWidget {
  const ManageUsersPage({super.key});

  @override
  State<ManageUsersPage> createState() => _ManageUsersPageState();
}

class _ManageUsersPageState extends State<ManageUsersPage> {
  static const Color yellow = Color(0xFFF5C542);
  static const Color ink = Color(0xFF202523);
  static const Color soft = Color(0xFFF4F5F0);
  static const Color muted = Color(0xFF626B66);
  static const Color line = Color(0xFFDEE3DB);
  static const Color green = Color(0xFF237548);
  static const Color red = Color(0xFFB94338);

  final AdminBackendService _backendService = AdminBackendService();

  String searchText = '';
  String selectedRole = 'All';

  void _showAddMeterReaderDialog() {
    final formKey = GlobalKey<FormState>();
    final nameCtrl = TextEditingController();
    final emailCtrl = TextEditingController();
    final codeCtrl = TextEditingController(text: 'MR-${DateTime.now().millisecondsSinceEpoch.toString().substring(8)}');
    final areaCtrl = TextEditingController(text: 'Homagama');
    final phoneCtrl = TextEditingController();
    final passwordCtrl = TextEditingController();
    bool sendEmailSetup = true;
    bool isSaving = false;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (dialogCtx) => StatefulBuilder(
        builder: (ctx, setDialogState) => AlertDialog(
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(22)),
          title: const Row(
            children: [
              Icon(Icons.badge_rounded, color: ink),
              SizedBox(width: 8),
              Text(
                'Add Meter Reader',
                style: TextStyle(color: ink, fontWeight: FontWeight.w800),
              ),
            ],
          ),
          content: Form(
            key: formKey,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text(
                    'Create an authorized Meter Reader staff account. You will remain signed in as Admin.',
                    style: TextStyle(fontSize: 12, color: muted),
                  ),
                  const SizedBox(height: 14),
                  TextFormField(
                    controller: nameCtrl,
                    decoration: const InputDecoration(labelText: 'Full Name *', border: OutlineInputBorder()),
                    validator: (v) => v == null || v.trim().isEmpty ? 'Required' : null,
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: emailCtrl,
                    keyboardType: TextInputType.emailAddress,
                    decoration: const InputDecoration(labelText: 'Email Address *', border: OutlineInputBorder()),
                    validator: (v) => v == null || !v.contains('@') ? 'Valid email required' : null,
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: TextFormField(
                          controller: codeCtrl,
                          decoration: const InputDecoration(labelText: 'Employee Code *', border: OutlineInputBorder()),
                          validator: (v) => v == null || v.trim().isEmpty ? 'Required' : null,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: TextFormField(
                          controller: areaCtrl,
                          decoration: const InputDecoration(labelText: 'Assigned Depot / Area *', border: OutlineInputBorder()),
                          validator: (v) => v == null || v.trim().isEmpty ? 'Required' : null,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: phoneCtrl,
                    keyboardType: TextInputType.phone,
                    decoration: const InputDecoration(labelText: 'Phone (optional)', border: OutlineInputBorder()),
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: passwordCtrl,
                    obscureText: true,
                    decoration: const InputDecoration(
                      labelText: 'Initial Password (Optional)',
                      hintText: 'Leave empty to auto-send setup link',
                      border: OutlineInputBorder(),
                    ),
                    validator: (v) {
                      if (v != null && v.isNotEmpty && v.length < 6) {
                        return 'Must be at least 6 characters if set';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 10),
                  CheckboxListTile(
                    contentPadding: EdgeInsets.zero,
                    dense: true,
                    title: const Text(
                      'Send private password setup email to reader',
                      style: TextStyle(fontSize: 12.5, fontWeight: FontWeight.w600, color: ink),
                    ),
                    subtitle: const Text(
                      'The reader receives a secure link to set their own password and sign in on the shared Sign In screen.',
                      style: TextStyle(fontSize: 11, color: muted),
                    ),
                    value: sendEmailSetup,
                    onChanged: (val) {
                      setDialogState(() => sendEmailSetup = val ?? true);
                    },
                    controlAffinity: ListTileControlAffinity.leading,
                  ),
                ],
              ),
            ),
          ),
          actions: [
            if (!isSaving)
              TextButton(
                onPressed: () => Navigator.pop(dialogCtx),
                child: const Text('Cancel', style: TextStyle(color: muted)),
              ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: yellow, foregroundColor: ink),
              onPressed: isSaving
                  ? null
                  : () async {
                      if (!formKey.currentState!.validate()) return;
                      setDialogState(() => isSaving = true);

                      try {
                        final readerEmail = emailCtrl.text.trim();
                        final readerName = nameCtrl.text.trim();

                        await AuthService.instance.createMeterReaderAsAdmin(
                          name: readerName,
                          email: readerEmail,
                          password: passwordCtrl.text.trim().isNotEmpty ? passwordCtrl.text.trim() : null,
                          employeeCode: codeCtrl.text.trim(),
                          area: areaCtrl.text.trim(),
                          phone: phoneCtrl.text.trim(),
                          sendPasswordSetupEmail: sendEmailSetup,
                        );

                        if (dialogCtx.mounted) {
                          Navigator.pop(dialogCtx);
                        }

                        if (mounted) {
                          final msg = sendEmailSetup
                              ? 'Meter Reader $readerName created. A private password setup link was emailed to $readerEmail.'
                              : 'Meter Reader $readerName created successfully.';
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text(msg)),
                          );
                        }
                      } catch (e) {
                        setDialogState(() => isSaving = false);
                        if (mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('Failed to create Meter Reader: ${e.toString().replaceAll('Exception: ', '')}'),
                            ),
                          );
                        }
                      }
                    },
              child: isSaving
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2, color: ink),
                    )
                  : const Text('Create Account'),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
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
        actions: [
          IconButton(
            tooltip: 'Add Meter Reader',
            icon: const Icon(Icons.person_add_alt_1_rounded, color: ink),
            onPressed: _showAddMeterReaderDialog,
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: _backendService.getUsers(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(color: yellow),
            );
          }

          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          final rawDocs = snapshot.data?.docs ?? [];

          final List<Map<String, dynamic>> users = rawDocs.map((doc) {
            final data = doc.data() as Map<String, dynamic>;

            return <String, dynamic>{
              'id': doc.id,
              'name': (data['name'] ?? 'Unknown').toString(),
              'email': (data['email'] ?? '').toString(),
              'role': (data['role'] ?? 'Customer').toString(),
              'status': (data['status'] ?? 'Active').toString(),
            };
          }).toList();

          final query = searchText.toLowerCase();

          final filteredUsers = users.where((user) {
            final matchesSearch =
                user['name'].toString().toLowerCase().contains(query) ||
                user['email'].toString().toLowerCase().contains(query);

            final matchesRole =
                selectedRole == 'All' || user['role'].toString().toLowerCase() == selectedRole.toLowerCase();

            return matchesSearch && matchesRole;
          }).toList();

          final activeCount =
              users.where((user) => user['status'] == 'Active').length;

          return ListView(
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
                ),
              ),
              const SizedBox(height: 6),
              const Text(
                'View accounts, manage access and register meter readers.',
                style: TextStyle(
                  color: muted,
                  fontSize: 13,
                ),
              ),
              const SizedBox(height: 18),

              // Action Banner for Adding Meter Reader
              InkWell(
                onTap: _showAddMeterReaderDialog,
                borderRadius: BorderRadius.circular(18),
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: yellow,
                    borderRadius: BorderRadius.circular(18),
                  ),
                  child: const Row(
                    children: [
                      Icon(Icons.person_add_rounded, color: ink, size: 24),
                      SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Add Meter Reader',
                              style: TextStyle(color: ink, fontSize: 15, fontWeight: FontWeight.w800),
                            ),
                            SizedBox(height: 2),
                            Text(
                              'Register authorized field officer credentials',
                              style: TextStyle(color: ink, fontSize: 12),
                            ),
                          ],
                        ),
                      ),
                      Icon(Icons.arrow_forward_ios_rounded, color: ink, size: 16),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 16),

              // Summary Card
              Container(
                padding: const EdgeInsets.all(22),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [
                      Color(0xFF353E36),
                      Color(0xFF1C2421),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(21),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Total Registered Accounts',
                      style: TextStyle(
                        color: Color(0xFFC5D0C3),
                      ),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      '${users.length}',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 43,
                        fontWeight: FontWeight.w800,
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
                  hintText: 'Search users by name or email...',
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
                initialValue: selectedRole,
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
                items: ['All', 'customer', 'reader', 'admin']
                    .map(
                      (role) => DropdownMenuItem<String>(
                        value: role == 'All' ? 'All' : role,
                        child: Text(role == 'All' ? 'All Roles' : (role == 'reader' ? 'Meter Reader' : role.toUpperCase())),
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
                      fontSize: 13,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 12),

              // Users List
              if (filteredUsers.isEmpty)
                Container(
                  padding: const EdgeInsets.all(28),
                  alignment: Alignment.center,
                  child: const Text('No users found.', style: TextStyle(color: muted)),
                )
              else
                ...filteredUsers.map((user) {
                  final isActive = user['status'] == 'Active';

                  return Container(
                    margin: const EdgeInsets.only(bottom: 12),
                    padding: const EdgeInsets.all(17),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: line),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            CircleAvatar(
                              radius: 20,
                              backgroundColor: const Color(0xFFF0F3EC),
                              child: Text(
                                user['name'].toString().isNotEmpty
                                    ? user['name'].toString()[0].toUpperCase()
                                    : 'U',
                                style: const TextStyle(
                                  color: ink,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    user['name'].toString(),
                                    style: const TextStyle(
                                      color: ink,
                                      fontWeight: FontWeight.w800,
                                      fontSize: 15,
                                    ),
                                  ),
                                  const SizedBox(height: 3),
                                  Text(
                                    user['email'].toString(),
                                    style: const TextStyle(
                                      color: muted,
                                      fontSize: 12,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            PopupMenuButton<String>(
                              icon: const Icon(Icons.more_vert),
                              onSelected: (value) async {
                                if (value == 'status') {
                                  final newStatus =
                                      isActive ? 'Inactive' : 'Active';
                                  await _backendService.updateUserStatus(
                                    user['id'].toString(),
                                    newStatus,
                                  );
                                } else if (value == 'delete') {
                                  await _backendService.deleteUser(
                                    user['id'].toString(),
                                  );
                                }
                              },
                              itemBuilder: (context) => [
                                PopupMenuItem<String>(
                                  enabled: false,
                                  child: Text('Status: ${user['status']}'),
                                ),
                                PopupMenuItem<String>(
                                  value: 'status',
                                  child: Text(
                                    isActive
                                        ? 'Deactivate User'
                                        : 'Activate User',
                                  ),
                                ),
                                const PopupMenuItem<String>(
                                  value: 'delete',
                                  child: Text(
                                    'Delete User',
                                    style: TextStyle(color: red),
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
                                user['role'].toString().toUpperCase(),
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
                                user['status'].toString(),
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
            ],
          );
        },
      ),
    );
  }
}
