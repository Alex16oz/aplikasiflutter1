// lib/pages/dashboard_page.dart
import 'package:flutter/material.dart';
import '../widgets/app_drawer.dart'; // Import the AppDrawer

class DashboardPage extends StatelessWidget {
  const DashboardPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Dashboard'),
        // backgroundColor is handled by ThemeData.appBarTheme in main.dart
      ),
      drawer: const AppDrawer(), // Add the AppDrawer
      body: const Center(
        child: Text(
          'Welcome to the Dashboard!',
          style: TextStyle(fontSize: 20),
        ),
      ),
    );
  }
}