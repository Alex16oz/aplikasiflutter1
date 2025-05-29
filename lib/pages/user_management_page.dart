// lib/pages/user_management_page.dart
import 'package:flutter/material.dart';
import '../widgets/app_drawer.dart'; // Import the AppDrawer

class UserManagementPage extends StatelessWidget {
  const UserManagementPage({super.key});

  static const String routeName = '/user-management';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('User Management'),
      ),
      drawer: const AppDrawer(),
      body: const Center(
        child: Text(
          'User Management Page Content',
          style: TextStyle(fontSize: 20),
        ),
      ),
    );
  }
}