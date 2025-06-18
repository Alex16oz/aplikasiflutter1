// lib/pages/warehouse_reports_page.dart
import 'package:flutter/material.dart';
// Impor halaman-halaman baru
import 'package:testflut1/pages/inventory_value_report_page.dart';
import 'package:testflut1/pages/item_usage_report_page.dart';
import 'package:testflut1/pages/moving_items_report_page.dart';
import 'package:testflut1/pages/periodic_stock_report_page.dart';
import 'package:testflut1/pages/stock_transaction_report_page.dart';

class WarehouseReportsPage extends StatelessWidget {
  const WarehouseReportsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Laporan Gudang'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          // --- TAMBAHKAN CARD INI ---
          _buildReportCard(
            context,
            title: 'Laporan Stok Periodik',
            subtitle: 'Lihat kondisi stok semua barang saat ini.',
            icon: Icons.inventory,
            onTap: () {
              Navigator.push(context, MaterialPageRoute(builder: (context) => const PeriodicStockReportPage()));
            },
          ),
          // --- DAN INI ---
          _buildReportCard(
            context,
            title: 'Laporan Penggunaan Barang',
            subtitle: 'Riwayat penggunaan barang untuk perbaikan mesin.',
            icon: Icons.construction,
            onTap: () {
              Navigator.push(context, MaterialPageRoute(builder: (context) => const ItemUsageReportPage()));
            },
          ),
          // --- Kartu-kartu yang sudah ada sebelumnya ---
          const Divider(height: 24),
          _buildReportCard(
            context,
            title: 'Laporan Transaksi Barang',
            subtitle: 'Catatan semua barang masuk dan keluar.',
            icon: Icons.sync_alt,
            onTap: () {
              Navigator.push(context, MaterialPageRoute(builder: (context) => const StockTransactionReportPage()));
            },
          ),
          _buildReportCard(
            context,
            title: 'Laporan Nilai Inventaris',
            subtitle: 'Kalkulasi nilai total semua barang di gudang.',
            icon: Icons.attach_money,
            onTap: () {
              Navigator.push(context, MaterialPageRoute(builder: (context) => const InventoryValueReportPage()));
            },
          ),
          _buildReportCard(
            context,
            title: 'Laporan Fast & Slow Moving',
            subtitle: 'Identifikasi barang yang sering & jarang digunakan.',
            icon: Icons.trending_up,
            onTap: () {
              Navigator.push(context, MaterialPageRoute(builder: (context) => const MovingItemsReportPage()));
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