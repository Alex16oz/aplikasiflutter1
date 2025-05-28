import 'package:flutter/material.dart';

class SparepartsPage extends StatelessWidget {
  const SparepartsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Spareparts'),
        backgroundColor: const Color(0xFF1EF1C9), // Consistent AppBar color
      ),
      body: const Center(
        child: Text('This is the Spareparts Page.'),
      ),
    );
  }
}