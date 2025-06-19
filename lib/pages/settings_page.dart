// lib/pages/settings_page.dart
import 'package:flutter/material.dart';
import '../widgets/app_drawer.dart'; // Import AppDrawer

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  static const String routeName = '/settings';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Pengaturan'),
      ),
      drawer: const AppDrawer(),
      body: ListView(
        children: [
          ListTile(
            leading: const Icon(Icons.language),
            title: const Text('Bahasa'),
            subtitle: const Text('Indonesia'),
            trailing: const Icon(Icons.keyboard_arrow_down),
            onTap: () {
              // Menampilkan dialog atau pesan saat item diklik
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Saat ini hanya Bahasa Indonesia yang tersedia.'),
                  duration: Duration(seconds: 2),
                ),
              );
            },
          ),
          const Divider(),
          // Semua item pengaturan lainnya telah dihapus
        ],
      ),
    );
  }
}