import 'package:flutter/material.dart';
import '../widgets/app_drawer.dart'; // Import the AppDrawer

class WarehousePage extends StatelessWidget {
  const WarehousePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Warehouse'),
      ),
      drawer: const AppDrawer(), // Add the AppDrawer
      body: const Center(
        child: Text(
          'Warehouse Page Content',
          style: TextStyle(fontSize: 20),
        ),
      ),
    );
  }
}