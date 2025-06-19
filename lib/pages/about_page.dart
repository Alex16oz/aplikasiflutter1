// lib/pages/about_page.dart
import 'package:flutter/material.dart';
import '../widgets/app_drawer.dart'; // Import AppDrawer

class AboutPage extends StatelessWidget {
  const AboutPage({super.key});

  static const String routeName = '/about';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Tentang Aplikasi'),
      ),
      drawer: const AppDrawer(),
      body: const Center(
        child: Padding(
          padding: EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'Aplikasi Manajemen Workshop',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 8),
              Text(
                'Versi 1.0.0',
                style: TextStyle(fontSize: 16, color: Colors.grey),
              ),
              SizedBox(height: 24),
              Text(
                'Aplikasi ini dibuat untuk membantu mengelola operasional workshop secara efisien.',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 18),
              ),
            ],
          ),
        ),
      ),
    );
  }
}