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
            onTap: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Pengaturan bahasa lain belum tersedia.')),
              );
            },
          ),
          SwitchListTile(
            title: const Text('Notifikasi Push'),
            subtitle: const Text('Terima pembaruan penting'),
            value: true, // Nilai statis sebagai contoh
            onChanged: (bool value) {
              // Logika untuk mengubah status notifikasi
            },
            secondary: const Icon(Icons.notifications_active),
          ),
          const Divider(),
          ListTile(
            title: const Text('Bantuan & Dukungan'),
            leading: const Icon(Icons.help_outline),
            onTap: () {},
          ),
          ListTile(
            title: const Text('Kebijakan Privasi'),
            leading: const Icon(Icons.privacy_tip_outlined),
            onTap: () {},
          ),
        ],
      ),
    );
  }
}