import 'package:flutter/material.dart';

class DamageReportsPage extends StatelessWidget {
  const DamageReportsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Damage Reports'),
        backgroundColor: const Color(0xFF1EF1C9), // Consistent AppBar color
      ),
      body: const Center(
        child: Text('This is the Damage Reports Page.'),
      ),
    );
  }
}
