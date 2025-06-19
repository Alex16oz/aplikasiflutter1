// lib/pages/reports_hub_page.dart
import 'package:flutter/material.dart';
import 'package:testflut1/pages/damage_reports_page.dart';
import 'package:testflut1/pages/employee_reports_page.dart';
import 'package:testflut1/pages/repair_reports_page.dart';
import 'package:testflut1/pages/warehouse_reports_page.dart';
import '../widgets/app_drawer.dart';

class ReportsHubPage extends StatelessWidget {
  const ReportsHubPage({super.key});
  static const String routeName = '/reports-hub';

  @override
  Widget build(BuildContext context) {
    final userArgs = ModalRoute.of(context)?.settings.arguments;

    // Tambahkan baris ini untuk mendapatkan role pengguna
    String userRole = '';
    if (userArgs is Map<String, dynamic>) {
      userRole = userArgs['role'] ?? '';
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Pusat Laporan'),
      ),
      drawer: const AppDrawer(),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          _buildReportCard(
            context,
            title: 'Laporan Kerusakan',
            subtitle: 'Lihat semua laporan kerusakan yang masuk dari operator.',
            icon: Icons.warning_amber_rounded,
            onTap: () {
              Navigator.pushNamed(context, DamageReportsPage.routeName, arguments: userArgs);
            },
          ),
          _buildReportCard(
            context,
            title: 'Laporan Perbaikan',
            subtitle: 'Tinjau semua laporan perbaikan yang telah diselesaikan.',
            icon: Icons.build_circle_outlined,
            onTap: () {
              Navigator.pushNamed(context, RepairReportsPage.routeName, arguments: userArgs);
            },
          ),
          _buildReportCard(
            context,
            title: 'Laporan Gudang',
            subtitle: 'Analisis stok, nilai inventaris, dan pergerakan barang.',
            icon: Icons.inventory_2_outlined,
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const WarehouseReportsPage(),
                  settings: RouteSettings(arguments: userArgs),
                ),
              );
            },
          ),
          // Tambahkan kondisi 'if' di sini untuk menampilkan kartu hanya untuk Admin
          if (userRole == 'Admin')
            _buildReportCard(
              context,
              title: 'Laporan Kepegawaian',
              subtitle: 'Analisis kehadiran, produktivitas, dan penugasan.',
              icon: Icons.people_alt_outlined,
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const EmployeeReportsPage(),
                    settings: RouteSettings(arguments: userArgs),
                  ),
                );
              },
            ),
        ],
      ),
    );
  }

  Widget _buildReportCard(BuildContext context, {
    required String title,
    required String subtitle,
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return Card(
      elevation: 3,
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        leading: Icon(icon, size: 40, color: Theme.of(context).primaryColor),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text(subtitle),
        trailing: const Icon(Icons.arrow_forward_ios),
        onTap: onTap,
      ),
    );
  }
}