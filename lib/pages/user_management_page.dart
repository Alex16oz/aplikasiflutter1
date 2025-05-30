// lib/pages/user_management_page.dart
import 'package:flutter/material.dart';
import '../widgets/app_drawer.dart'; // Import the AppDrawer

class UserManagementPage extends StatelessWidget {
  const UserManagementPage({super.key});

  static const String routeName = '/user-management';

  // Sample data for user counts (replace with actual data logic)
  final int _adminCount = 2;
  final int _operatorCount = 5;
  final int _warehouseCount = 3;

  // Sample data for the user management table
  final List<Map<String, String>> _userData = const [
    {'id': '1', 'username': 'admin_user', 'email': 'admin@example.com', 'password': '••••••••', 'role': 'Admin'},
    {'id': '2', 'username': 'john_operator', 'email': 'john.op@example.com', 'password': '••••••••', 'role': 'Operator'},
    {'id': '3', 'username': 'jane_warehouse', 'email': 'jane.wh@example.com', 'password': '••••••••', 'role': 'Warehouse'},
    {'id': '4', 'username': 'mike_op', 'email': 'mike.operator@example.com', 'password': '••••••••', 'role': 'Operator'},
    {'id': '5', 'username': 'sara_admin', 'email': 'sara.admin@example.com', 'password': '••••••••', 'role': 'Admin'},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('User Management'),
        actions: <Widget>[
          IconButton(
            icon: const Icon(Icons.person_add),
            tooltip: 'Add User',
            onPressed: () {
              // TODO: Implement add user functionality
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Add User button pressed')),
              );
            },
          ),
        ],
      ),
      drawer: const AppDrawer(),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            // Row for the three user cards
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
            const SizedBox(height: 24.0), // Spacing before table
            const Text(
              'User Management Table',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8.0),
            SizedBox(
              width: double.infinity,
              child: DataTable(
                columnSpacing: 10.0, // Adjusted for more columns
                headingRowColor: WidgetStateColor.resolveWith((states) => Colors.blueGrey.shade100),
                border: TableBorder.all(
                    color: Colors.grey.shade400,
                    width: 1,
                    borderRadius: BorderRadius.circular(8.0)
                ),
                columns: const <DataColumn>[
                  DataColumn(label: Text('ID', style: TextStyle(fontWeight: FontWeight.bold))),
                  DataColumn(label: Text('Username', style: TextStyle(fontWeight: FontWeight.bold))),
                  DataColumn(label: Text('Email', style: TextStyle(fontWeight: FontWeight.bold))),
                  DataColumn(label: Text('Password', style: TextStyle(fontWeight: FontWeight.bold))),
                  DataColumn(label: Text('Role', style: TextStyle(fontWeight: FontWeight.bold))),
                  DataColumn(label: Text('Action', style: TextStyle(fontWeight: FontWeight.bold))),
                ],
                rows: _userData.map((user) {
                  return DataRow(
                    cells: <DataCell>[
                      DataCell(Text(user['id']!)),
                      DataCell(Text(user['username']!)),
                      DataCell(Text(user['email']!)),
                      DataCell(Text(user['password']!)), // Displaying masked password
                      DataCell(Text(user['role']!)),
                      DataCell(
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              icon: Icon(Icons.edit, size: 20, color: Colors.blue.shade700),
                              tooltip: 'Edit',
                              onPressed: () {
                                // TODO: Implement edit action for this user
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(content: Text('Edit action for ID: ${user['id']}')),
                                );
                              },
                              padding: EdgeInsets.zero,
                              constraints: const BoxConstraints(),
                            ),
                            const SizedBox(width: 4),
                            IconButton(
                              icon: Icon(Icons.delete, size: 20, color: Colors.red.shade700),
                              tooltip: 'Delete',
                              onPressed: () {
                                // TODO: Implement delete action for this user
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(content: Text('Delete action for ID: ${user['id']}')),
                                );
                              },
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