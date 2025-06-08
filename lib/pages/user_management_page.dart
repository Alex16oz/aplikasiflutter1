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
  // State variables for data and loading
  bool _isLoading = true;
  List<Map<String, dynamic>> _users = [];
  int _adminCount = 0;
  int _operatorCount = 0;
  int _warehouseCount = 0;

  // Supabase client instance
  final _supabase = Supabase.instance.client;

  @override
  void initState() {
    super.initState();
    _fetchData(); // Fetch data when the page loads
  }

  // Fetch all necessary data from Supabase
  Future<void> _fetchData() async {
    setState(() {
      _isLoading = true;
    });

    try {
      // Fetch user list
      final usersResponse = await _supabase
          .from('users')
          .select('id, username, email, role')
          .order('id', ascending: true);

      // Fetch role counts using the RPC function
      final countsResponse = await _supabase.rpc('get_user_role_counts');

      setState(() {
        _users = List<Map<String, dynamic>>.from(usersResponse);
        _adminCount = countsResponse['admin_count'] as int;
        _operatorCount = countsResponse['operator_count'] as int;
        _warehouseCount = countsResponse['warehouse_count'] as int;
        _isLoading = false;
      });
    } catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error fetching data: ${error.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
      setState(() {
        _isLoading = false;
      });
    }
  }

  // Show a dialog to add or edit a user
  Future<void> _showUserDialog({Map<String, dynamic>? user}) async {
    final formKey = GlobalKey<FormState>();
    final usernameController = TextEditingController(text: user?['username']);
    final emailController = TextEditingController(text: user?['email']);
    String selectedRole = user?['role'] ?? 'Operator';
    final bool isEditing = user != null;

    await showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(isEditing ? 'Edit User' : 'Add User'),
          content: Form(
            key: formKey,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextFormField(
                    controller: usernameController,
                    decoration: const InputDecoration(labelText: 'Username'),
                    validator: (value) =>
                    value!.isEmpty ? 'Username cannot be empty' : null,
                  ),
                  TextFormField(
                    controller: emailController,
                    decoration: const InputDecoration(labelText: 'Email'),
                    validator: (value) =>
                    !value!.contains('@') ? 'Enter a valid email' : null,
                  ),
                  // **CHANGE**: Password input is removed.
                  DropdownButtonFormField<String>(
                    value: selectedRole,
                    decoration: const InputDecoration(labelText: 'Role'),
                    items: ['Admin', 'Operator', 'Warehouse']
                        .map((role) => DropdownMenuItem(
                      value: role,
                      child: Text(role),
                    ))
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
                      // Update existing user
                      await _supabase.from('users').update({
                        'username': usernameController.text,
                        'email': emailController.text,
                        'role': selectedRole,
                      }).eq('id', user['id']);
                    } else {
                      // **CHANGE**: Add new user with a default password.
                      // IMPORTANT: In a real app, this should be a securely hashed password.
                      // Using a default plaintext password is a major security risk.
                      await _supabase.from('users').insert({
                        'username': usernameController.text,
                        'email': emailController.text,
                        'password_hash': 'password', // Default password
                        'role': selectedRole,
                      });
                    }
                    if (mounted) Navigator.of(context).pop();
                    _fetchData(); // Refresh data
                  } catch (error) {
                    if (mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                        content: Text('Failed to save user: ${error.toString()}'),
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

  // **NEW**: Reset a user's password to the default
  Future<void> _resetPassword(int id) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Confirm Password Reset'),
          content: const Text('Are you sure you want to reset this user\'s password to the default?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(true),
              style: TextButton.styleFrom(foregroundColor: Colors.orange),
              child: const Text('Reset'),
            ),
          ],
        );
      },
    );

    if (confirmed == true) {
      try {
        // IMPORTANT: Again, using a plaintext password is not secure.
        await _supabase.from('users').update({'password_hash': 'password'}).eq('id', id);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
            content: Text('Password has been reset successfully.'),
            backgroundColor: Colors.green,
          ));
        }
      } catch (error) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text('Failed to reset password: ${error.toString()}'),
            backgroundColor: Colors.red,
          ));
        }
      }
    }
  }

  // Delete a user after confirmation
  Future<void> _deleteUser(int id) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Confirm Deletion'),
          content: const Text('Are you sure you want to delete this user?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(true),
              style: TextButton.styleFrom(foregroundColor: Colors.red),
              child: const Text('Delete'),
            ),
          ],
        );
      },
    );

    if (confirmed == true) {
      try {
        await _supabase.from('users').delete().eq('id', id);
        _fetchData(); // Refresh data
      } catch (error) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text('Failed to delete user: ${error.toString()}'),
            backgroundColor: Colors.red,
          ));
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('User Management'),
        actions: <Widget>[
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
          padding: const EdgeInsets.all(12.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  Expanded(
                    child: _buildUserCard(
                      context: context,
                      count: _adminCount,
                      name: 'Admin',
                      icon: Icons.admin_panel_settings,
                      color: Colors.red.shade400,
                    ),
                  ),
                  const SizedBox(width: 12.0),
                  Expanded(
                    child: _buildUserCard(
                      context: context,
                      count: _operatorCount,
                      name: 'Operator',
                      icon: Icons.engineering,
                      color: Colors.blue.shade400,
                    ),
                  ),
                  const SizedBox(width: 12.0),
                  Expanded(
                    child: _buildUserCard(
                      context: context,
                      count: _warehouseCount,
                      name: 'Warehouse',
                      icon: Icons.store,
                      color: Colors.green.shade400,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24.0),
              const Text(
                'User Management Table',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8.0),
              SizedBox(
                width: double.infinity,
                child: DataTable(
                  columnSpacing: 10.0,
                  headingRowColor: WidgetStateColor.resolveWith(
                          (states) => Colors.blueGrey.shade100),
                  border: TableBorder.all(
                    color: Colors.grey.shade400,
                    width: 1,
                    borderRadius: BorderRadius.circular(8.0),
                  ),
                  columns: const <DataColumn>[
                    DataColumn(label: Text('ID', style: TextStyle(fontWeight: FontWeight.bold))),
                    DataColumn(label: Text('Username', style: TextStyle(fontWeight: FontWeight.bold))),
                    DataColumn(label: Text('Email', style: TextStyle(fontWeight: FontWeight.bold))),
                    DataColumn(label: Text('Role', style: TextStyle(fontWeight: FontWeight.bold))),
                    DataColumn(label: Text('Action', style: TextStyle(fontWeight: FontWeight.bold))),
                  ],
                  rows: _users.map((user) {
                    return DataRow(
                      cells: <DataCell>[
                        DataCell(Text(user['id'].toString())),
                        DataCell(Text(user['username'])),
                        DataCell(Text(user['email'])),
                        DataCell(Text(user['role'])),
                        DataCell(
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              IconButton(
                                icon: Icon(Icons.edit, size: 20, color: Colors.blue.shade700),
                                tooltip: 'Edit',
                                onPressed: () => _showUserDialog(user: user),
                                padding: EdgeInsets.zero,
                                constraints: const BoxConstraints(),
                              ),
                              const SizedBox(width: 4),
                              // **NEW**: Reset password button
                              IconButton(
                                icon: Icon(Icons.lock_reset, size: 20, color: Colors.orange.shade700),
                                tooltip: 'Reset Password',
                                onPressed: () => _resetPassword(user['id']),
                                padding: EdgeInsets.zero,
                                constraints: const BoxConstraints(),
                              ),
                              const SizedBox(width: 4),
                              IconButton(
                                icon: Icon(Icons.delete, size: 20, color: Colors.red.shade700),
                                tooltip: 'Delete',
                                onPressed: () => _deleteUser(user['id']),
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

  // Helper widget to build a user card
  Widget _buildUserCard({
    required BuildContext context,
    required int count,
    required String name,
    required IconData icon,
    required Color color,
  }) {
    return Card(
      elevation: 3.0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10.0),
      ),
      child: Container(
        padding: const EdgeInsets.all(12.0),
        height: 100,
        child: Stack(
          children: <Widget>[
            Positioned(
              top: 0,
              left: 0,
              child: Text(
                name,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
              ),
            ),
            Positioned(
              top: 4,
              right: 0,
              child: Icon(
                icon,
                size: 32.0,
                color: color.withAlpha((255 * 0.6).round()),
              ),
            ),
            Positioned(
              bottom: 0,
              left: 0,
              child: Text(
                count.toString(),
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}