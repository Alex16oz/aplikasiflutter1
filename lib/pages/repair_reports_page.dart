import 'package:flutter/material.dart';
import '../widgets/app_drawer.dart'; // Import the AppDrawer

class RepairReportsPage extends StatelessWidget {
  const RepairReportsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Repair Reports'),
      ),
      drawer: const AppDrawer(), // Add the AppDrawer
      body: const Center(
        child: Text(
          'Repair Reports Page Content',
          style: TextStyle(fontSize: 20),
        ),
      ),
    );
  }
}