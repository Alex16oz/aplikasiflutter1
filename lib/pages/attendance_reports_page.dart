import 'package:flutter/material.dart';

class AttendanceReportsPage extends StatelessWidget {
  const AttendanceReportsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Attendance Reports'),
        backgroundColor: const Color(0xFF1EF1C9), // Consistent AppBar color
      ),
      body: const Center(
        child: Text('This is the Attendance Reports Page.'),
      ),
    );
  }
}
