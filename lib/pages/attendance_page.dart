// lib/pages/attendance_page.dart
import 'package:flutter/material.dart';
import '../widgets/app_drawer.dart'; // Import the AppDrawer

class AttendancePage extends StatelessWidget {
  const AttendancePage({super.key});

  static const String routeName = '/attendance';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Attendance'),
      ),
      drawer: const AppDrawer(),
      body: const Center(
        child: Text(
          'Attendance Page Content',
          style: TextStyle(fontSize: 20),
        ),
      ),
    );
  }
}