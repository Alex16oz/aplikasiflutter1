import 'package:flutter/material.dart';

class SchedulePage extends StatelessWidget {
  const SchedulePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Schedule'),
        backgroundColor: const Color(0xFF1EF1C9), // Consistent AppBar color
      ),
      body: const Center(
        child: Text('This is the Schedule Page.'),
      ),
    );
  }
}