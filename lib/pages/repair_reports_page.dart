import 'package:flutter/material.dart';

class RepairReportsPage extends StatelessWidget {
  const RepairReportsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Repair Reports'),
        backgroundColor: const Color(0xFF1EF1C9), // Consistent AppBar color
      ),
      body: const Center(
        child: Text('This is the Repair Reports Page.'),
      ),
    );
  }
}