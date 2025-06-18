// lib/pages/warehouse_reports_page.dart
import 'package:flutter/material.dart';
import 'package:testflut1/pages/inventory_value_report_page.dart';
import 'package:testflut1/pages/moving_items_report_page.dart';
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
          ReportListItem(
            title: 'Laporan Nilai Inventaris',
            subtitle: 'Kalkulasi total nilai stok berdasarkan harga beli terakhir.',
            onTap: () {
              Navigator.push(context, MaterialPageRoute(builder: (context) => const InventoryValueReportPage()));
            },
          ),
          ReportListItem(
            title: 'Laporan Barang Masuk & Keluar',
            subtitle: 'Rincian semua transaksi stok dalam periode waktu.',
            onTap: () {
              Navigator.push(context, MaterialPageRoute(builder: (context) => const StockTransactionReportPage()));
            },
          ),
          ReportListItem(
            title: 'Laporan Fast/Slow Moving',
            subtitle: 'Analisis pergerakan sparepart yang paling sering dan jarang digunakan.',
            onTap: () {
              Navigator.push(context, MaterialPageRoute(builder: (context) => const MovingItemsReportPage()));
            },
          ),
        ],
      ),
    );
  }
}

class ReportListItem extends StatelessWidget {
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  const ReportListItem({
    super.key,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        title: Text(title),
        subtitle: Text(subtitle),
        trailing: const Icon(Icons.arrow_forward_ios),
        onTap: onTap,
      ),
    );
  }
}