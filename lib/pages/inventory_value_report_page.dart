// lib/pages/inventory_value_report_page.dart
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class InventoryValueReportPage extends StatefulWidget {
  const InventoryValueReportPage({super.key});

  @override
  State<InventoryValueReportPage> createState() => _InventoryValueReportPageState();
}

class _InventoryValueReportPageState extends State<InventoryValueReportPage> {
  late Future<List<Map<String, dynamic>>> _reportFuture;
  final _supabase = Supabase.instance.client;
  List<Map<String, dynamic>> _reportData = [];
  double _grandTotal = 0.0;

  @override
  void initState() {
    super.initState();
    _refreshReport();
  }

  void _refreshReport() {
    setState(() {
      _reportFuture = _fetchReport();
    });
  }

  Future<List<Map<String, dynamic>>> _fetchReport() async {
    try {
      final data = await _supabase.rpc('get_inventory_value_report');
      final reportList = List<Map<String, dynamic>>.from(data);

      double total = 0;
      for (var item in reportList) {
        total += (item['total_value'] as num?)?.toDouble() ?? 0.0;
      }

      if (mounted) {
        setState(() {
          _reportData = reportList;
          _grandTotal = total;
        });
      }
      return reportList;
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Gagal memuat laporan: $e'), backgroundColor: Colors.red));
      }
      return [];
    }
  }

  String _formatCurrency(dynamic value) {
    final number = (value as num?)?.toDouble() ?? 0.0;
    return NumberFormat.currency(locale: 'id_ID', symbol: 'Rp ', decimalDigits: 0).format(number);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Laporan Nilai Inventaris'),
        actions: [IconButton(onPressed: _refreshReport, icon: const Icon(Icons.refresh))],
      ),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: _reportFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }
          if (_reportData.isEmpty) {
            return const Center(child: Text('Tidak ada data untuk ditampilkan.'));
          }

          return SingleChildScrollView(
            scrollDirection: Axis.vertical,
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Card(
                    color: Theme.of(context).primaryColor,
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text('Total Nilai Gudang', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black)),
                          Text(_formatCurrency(_grandTotal), style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black)),
                        ],
                      ),
                    ),
                  ),
                ),
                // --- PERUBAHAN UTAMA DIMULAI DI SINI ---
                SizedBox(
                  width: double.infinity,
                  child: DataTable(
                    columnSpacing: 20.0,
                    columns: const [
                      DataColumn(label: Text('Nama Sparepart', style: TextStyle(fontWeight: FontWeight.bold))),
                      DataColumn(label: Text('Perhitungan', style: TextStyle(fontWeight: FontWeight.bold))),
                      DataColumn(label: Text('Total Nilai', style: TextStyle(fontWeight: FontWeight.bold)), numeric: true),
                    ],
                    rows: _reportData.map((item) {
                      final stock = item['total_stock'] ?? 0;
                      final unitPrice = (item['latest_unit_price'] as num?)?.toDouble() ?? 0.0;

                      // Membuat string untuk kolom perhitungan
                      final calculationString = '$stock pcs × ${_formatCurrency(unitPrice)}';

                      return DataRow(cells: [
                        DataCell(Text(item['sparepart_name'] ?? 'N/A')),
                        DataCell(Text(calculationString)), // Sel baru dengan detail perhitungan
                        DataCell(Text(_formatCurrency(item['total_value']))), // Sel dengan hasil akhir
                      ]);
                    }).toList(),
                  ),
                ),
                // --- PERUBAHAN UTAMA SELESAI DI SINI ---
              ],
            ),
          );
        },
      ),
    );
  }
}