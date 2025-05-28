import 'package:flutter/material.dart';
import '../widgets/app_drawer.dart'; // Import the AppDrawer

class SparepartsPage extends StatelessWidget {
  const SparepartsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Spareparts'),
      ),
      drawer: const AppDrawer(), // Add the AppDrawer
      body: const Center(
        child: Text(
          'Spareparts Page Content',
          style: TextStyle(fontSize: 20),
        ),
      ),
    );
  }
}