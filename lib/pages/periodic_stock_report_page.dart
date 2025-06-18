// lib/pages/periodic_stock_report_page.dart
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class PeriodicStockReportPage extends StatefulWidget {
  const PeriodicStockReportPage({super.key});

  @override
  State<PeriodicStockReportPage> createState() => _PeriodicStockReportPageState();
}

class _PeriodicStockReportPageState extends State<PeriodicStockReportPage> {
  final _supabase = Supabase.instance.client;
  late Future<List<Map<String, dynamic>>> _stockReportFuture;

  @override
  void initState() {
    super.initState();
    _stockReportFuture = _fetchReport();
  }

  Future<List<Map<String, dynamic>>> _fetchReport() async {
    final data = await _supabase.rpc('get_periodic_stock_report');
    return List<Map<String, dynamic>>.from(data);
  }

  void _refreshReport() {
    setState(() {
      _stockReportFuture = _fetchReport();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Laporan Stok Periodik'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _refreshReport,
          ),
        ],
      ),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: _stockReportFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Terjadi kesalahan: ${snapshot.error}'));
          }
          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('Tidak ada data stok ditemukan.'));
          }

          final reportData = snapshot.data!;

          return SingleChildScrollView(
            scrollDirection: Axis.vertical,
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: DataTable(
                  columns: const [
                    DataColumn(label: Text('Nama Barang')),
                    DataColumn(label: Text('Part Number')),
                    DataColumn(label: Text('Stok Saat Ini'), numeric: true),
                    DataColumn(label: Text('Min. Stok'), numeric: true),
                  ],
                  rows: reportData.map((row) {
                    final currentStock = (row['stock_on_hand'] as int?) ?? 0;
                    final minStock = (row['minimum_stock_level'] as int?) ?? 0;
                    final isLowStock = currentStock <= minStock;

                    return DataRow(
                      cells: [
                        DataCell(
                            Row(
                              children: [
                                Text(row['part_name'] ?? 'N/A'),
                                if (isLowStock)
                                  const Padding(
                                    padding: EdgeInsets.only(left: 8.0),
                                    child: Icon(Icons.warning, color: Colors.orange, size: 16),
                                  )
                              ],
                            )
                        ),
                        DataCell(Text(row['part_number'] ?? '-')),
                        DataCell(
                          Text(
                            currentStock.toString(),
                            style: TextStyle(
                              color: isLowStock ? Colors.red : null,
                              fontWeight: isLowStock ? FontWeight.bold : FontWeight.normal,
                            ),
                          ),
                        ),
                        DataCell(Text(minStock.toString())),
                      ],
                    );
                  }).toList(),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}