// lib/pages/damage_reports_page.dart
import 'package:flutter/material.dart';
import '../widgets/app_drawer.dart'; // Import the AppDrawer

class DamageReportsPage extends StatelessWidget {
  const DamageReportsPage({super.key});

  static const String routeName = '/damage-reports';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Damage Reports'),
      ),
      drawer: const AppDrawer(),
      body: const Center(
        child: Text(
          'Damage Reports Page Content',
          style: TextStyle(fontSize: 20),
        ),
      ),
    );
  }
}