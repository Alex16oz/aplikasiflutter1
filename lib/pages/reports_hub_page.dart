// lib/pages/reports_hub_page.dart
import 'package:flutter/material.dart';
import 'package:testflut1/pages/warehouse_reports_page.dart';
import '../widgets/app_drawer.dart';

class ReportsHubPage extends StatelessWidget {
  const ReportsHubPage({super.key});
  static const String routeName = '/reports-hub';

  @override
  Widget build(BuildContext context) {
    final userArgs = ModalRoute.of(context)?.settings.arguments;

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
          // Tambahkan card untuk jenis laporan lain di sini (misal: Laporan Keuangan, dll)
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