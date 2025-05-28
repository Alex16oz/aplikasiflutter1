// lib/pages/attendance_reports_page.dart
import 'package:flutter/material.dart';
import '../widgets/app_drawer.dart'; // Import the AppDrawer

class AttendanceReportsPage extends StatelessWidget {
  const AttendanceReportsPage({super.key});

  static const String routeName = '/attendance-reports';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Attendance Reports'),
      ),
      drawer: const AppDrawer(),
      body: const Center(
        child: Text(
          'Attendance Reports Page Content',
          style: TextStyle(fontSize: 20),
        ),
      ),
    );
  }
}