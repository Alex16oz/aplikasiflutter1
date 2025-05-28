import 'package:flutter/material.dart';
import '../widgets/app_drawer.dart'; // Import the AppDrawer

class SchedulePage extends StatelessWidget {
  const SchedulePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Schedule'),
      ),
      drawer: const AppDrawer(), // Add the AppDrawer
      body: const Center(
        child: Text(
          'Schedule Page Content',
          style: TextStyle(fontSize: 20),
        ),
      ),
    );
  }
}