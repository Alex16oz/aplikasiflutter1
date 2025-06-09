// lib/pages/user_management_page.dart
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../widgets/app_drawer.dart';

class UserManagementPage extends StatefulWidget {
  const UserManagementPage({super.key});

  static const String routeName = '/user-management';

  @override
  State<UserManagementPage> createState() => _UserManagementPageState();
}

class _UserManagementPageState extends State<UserManagementPage> {
  bool _isLoading = true;
  List<Map<String, dynamic>> _profiles = [];
  int _adminCount = 0;
  int _operatorCount = 0;
  int _warehouseCount = 0;
  String? _currentUserRole;

  final _supabase = Supabase.instance.client;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final args = ModalRoute.of(context)?.settings.arguments;
    if (args is Map<String, dynamic>) {
      _currentUserRole = args['role'];
    }
    _fetchData();
  }

  String _formatLastLogin(String? dateString) {
    if (dateString == null) {
      return 'Never';
    }
    try {
      final lastLogin = DateTime.parse(dateString);
      final now = DateTime.now();

      // Normalisasi ke tengah malam untuk membandingkan hari dengan mudah
      final lastLoginDate = DateTime(lastLogin.year, lastLogin.month, lastLogin.day);
      final nowDate = DateTime(now.year, now.month, now.day);

      final differenceInDays = nowDate.difference(lastLoginDate).inDays;

      if (differenceInDays == 0) {
        return 'Today';
      } else if (differenceInDays == 1) {
        return 'Yesterday';
      } else {
        return '$differenceInDays days ago';
      }
    } catch (e) {
      return 'N/A';
    }
  }

  Future<void> _fetchData() async {
    if (!mounted) return;
    setState(() {
      _isLoading = true;
    });

    try {
      // Panggil edge function untuk mendapatkan data pengguna secara aman
      final response = await _supabase.functions.invoke('get-all-users');

      if (response.status != 200) {
        final errorMessage = response.data is Map ? response.data['error'] : 'Unknown error';
        throw 'Failed to fetch users: $errorMessage';
      }

      final List<dynamic> data = response.data;
      if (!mounted) return;

      _profiles = data.map((item) => item as Map<String, dynamic>).toList();

      // Urutkan data berdasarkan nama pengguna secara alfabetis
      _profiles.sort((a, b) => (a['username'] as String).compareTo(b['username'] as String));

      // Hitung ulang jumlah peran
      _adminCount = _profiles.where((p) => p['role'] == 'Admin').length;
      _operatorCount = _profiles.where((p) => p['role'] == 'Operator').length;
      _warehouseCount =
          _profiles.where((p) => p['role'] == 'Warehouse').length;

    } catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('$error'),
            backgroundColor: Theme.of(context).colorScheme.error,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _showUserDialog({Map<String, dynamic>? profile}) async {
    if (_currentUserRole != 'Admin') {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('You do not have permission to perform this action.')),
      );
      return;
    }

    final formKey = GlobalKey<FormState>();
    final usernameController =
    TextEditingController(text: profile?['username']);
    final emailController = TextEditingController();
    final passwordController = TextEditingController();
    String selectedRole = profile?['role'] ?? 'Operator';
    final bool isEditing = profile != null;

    await showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(isEditing ? 'Edit User Profile' : 'Add New User'),
          content: Form(
            key: formKey,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextFormField(
                    controller: usernameController,
                    decoration: const InputDecoration(labelText: 'Username'),
                    validator: (v) =>
                    v!.isEmpty ? 'Username cannot be empty' : null,
                  ),
                  if (!isEditing) ...[
                    TextFormField(
                      controller: emailController,
                      decoration: const InputDecoration(labelText: 'Email'),
                      validator: (v) =>
                      v == null || !v.contains('@') ? 'Enter a valid email' : null,
                    ),
                    TextFormField(
                      controller: passwordController,
                      decoration: const InputDecoration(labelText: 'Password'),
                      obscureText: true,
                      validator: (v) =>
                      v == null || v.length < 6 ? 'Min 6 characters' : null,
                    ),
                  ],
                  DropdownButtonFormField<String>(
                    value: selectedRole,
                    decoration: const InputDecoration(labelText: 'Role'),
                    items: ['Admin', 'Operator', 'Warehouse']
                        .map((role) =>
                        DropdownMenuItem(value: role, child: Text(role)))
                        .toList(),
                    onChanged: (value) => selectedRole = value!,
                  ),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () async {
                if (formKey.currentState!.validate()) {
                  try {
                    if (isEditing) {
                      // --- LOGIKA EDIT ---
                      await _supabase.from('profiles').update({
                        'username': usernameController.text.trim(),
                        'role': selectedRole,
                      }).eq('id', profile['id']);
                    } else {
                      // --- LOGIKA TAMBAH PENGGUNA (MEMANGGIL EDGE FUNCTION) ---
                      await _supabase.functions.invoke('create-user',
                          body: {
                            'email': emailController.text.trim(),
                            'password': passwordController.text.trim(),
                            'username': usernameController.text.trim(),
                            'role': selectedRole,
                          });
                    }

                    if (mounted) {
                      Navigator.of(context).pop();
                      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                        content: Text(isEditing
                            ? 'User updated successfully!'
                            : 'User created successfully!'),
                        backgroundColor: Colors.green,
                      ));
                      _fetchData();
                    }
                  } catch (error) {
                    if (mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                        content: Text('Failed to save profile: $error'),
                        backgroundColor: Colors.red,
                      ));
                    }
                  }
                }
              },
              child: const Text('Save'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _deleteProfile(String id) async {
    final currentUser = _supabase.auth.currentUser;
    // Mencegah admin menghapus akunnya sendiri dari daftar
    if (currentUser != null && currentUser.id == id) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('You cannot delete your own account.'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    if (_currentUserRole != 'Admin') {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('You do not have permission to delete users.')),
      );
      return;
    }

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirm Deletion'),
        // Teks konfirmasi diubah untuk mencerminkan penghapusan permanen
        content: const Text('Are you sure you want to permanently delete this user? This action cannot be undone.'),
        actions: [
          TextButton(onPressed: () => Navigator.of(context).pop(false), child: const Text('Cancel')),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      try {
        // Panggil edge function 'delete-user'
        final response = await _supabase.functions.invoke(
          'delete-user',
          body: {'user_id': id},
        );

        if (response.status != 200) {
          final errorMessage = response.data is Map ? response.data['error'] : 'Failed to delete user.';
          throw Exception(errorMessage);
        }

        // Muat ulang daftar pengguna setelah berhasil dihapus
        _fetchData();

        if(mounted) {
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
            content: Text('User deleted successfully.'),
            backgroundColor: Colors.green,
          ));
        }
      } catch (error) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text('Failed to delete user: $error'),
            backgroundColor: Theme.of(context).colorScheme.error,
          ));
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final bool isAdmin = _currentUserRole == 'Admin';

    return Scaffold(
      appBar: AppBar(
        title: const Text('User Management'),
        actions: <Widget>[
          if (isAdmin)
            IconButton(
              icon: const Icon(Icons.person_add),
              tooltip: 'Add User',
              onPressed: () => _showUserDialog(),
            ),
        ],
      ),
      drawer: const AppDrawer(),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
        onRefresh: _fetchData,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(12.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Row(
                children: <Widget>[
                  Expanded(child: _buildUserCard(count: _adminCount, name: 'Admin', icon: Icons.admin_panel_settings, color: Colors.red.shade400)),
                  const SizedBox(width: 12.0),
                  Expanded(child: _buildUserCard(count: _operatorCount, name: 'Operator', icon: Icons.engineering, color: Colors.blue.shade400)),
                  const SizedBox(width: 12.0),
                  Expanded(child: _buildUserCard(count: _warehouseCount, name: 'Warehouse', icon: Icons.store, color: Colors.green.shade400)),
                ],
              ),
              const SizedBox(height: 24.0),
              const Text('User Profiles', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 8.0),
              SizedBox(
                width: double.infinity,
                child: DataTable(
                  columnSpacing: 16.0,
                  headingRowColor: WidgetStateColor.resolveWith((s) => Colors.blueGrey.shade100),
                  border: TableBorder.all(color: Colors.grey.shade400, width: 1, borderRadius: BorderRadius.circular(8.0)),
                  columns: <DataColumn>[
                    const DataColumn(label: Text('Username', style: TextStyle(fontWeight: FontWeight.bold))),
                    const DataColumn(label: Text('Email', style: TextStyle(fontWeight: FontWeight.bold))),
                    const DataColumn(label: Text('Role', style: TextStyle(fontWeight: FontWeight.bold))),
                    const DataColumn(label: Text('Last Login', style: TextStyle(fontWeight: FontWeight.bold))), // KOLOM BARU
                    if(isAdmin)
                      const DataColumn(label: Text('Action', style: TextStyle(fontWeight: FontWeight.bold))),
                  ],
                  rows: _profiles.map((profile) {
                    return DataRow(
                      cells: <DataCell>[
                        DataCell(Text(profile['username'] ?? 'N/A')),
                        DataCell(Text(profile['email'] ?? 'N/A')),
                        DataCell(Text(profile['role'] ?? 'N/A')),
                        DataCell(Text(_formatLastLogin(profile['last_sign_in_at']))), // CELL BARU
                        if(isAdmin)
                          DataCell(
                            Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                IconButton(
                                  icon: Icon(Icons.edit, size: 20, color: Colors.blue.shade700),
                                  tooltip: 'Edit',
                                  onPressed: () => _showUserDialog(profile: profile),
                                  padding: EdgeInsets.zero,
                                  constraints: const BoxConstraints(),
                                ),
                                const SizedBox(width: 4),
                                IconButton(
                                  icon: Icon(Icons.delete, size: 20, color: Colors.red.shade700),
                                  tooltip: 'Delete',
                                  onPressed: () => _deleteProfile(profile['id']),
                                  padding: EdgeInsets.zero,
                                  constraints: const BoxConstraints(),
                                ),
                              ],
                            ),
                          ),
                      ],
                    );
                  }).toList(),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildUserCard({required int count, required String name, required IconData icon, required Color color}) {
    return Card(
      elevation: 3.0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.0)),
      child: Container(
        padding: const EdgeInsets.all(12.0),
        height: 100,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(name, style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: color)),
                Icon(icon, size: 28.0, color: color.withAlpha(150)),
              ],
            ),
            Text(count.toString(), style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold)),
          ],
        ),
      ),
    );
  }
}