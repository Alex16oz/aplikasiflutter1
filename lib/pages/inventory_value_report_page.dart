// lib/pages/inventory_value_report_page.dart

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:collection/collection.dart'; // Import package baru

// Model data untuk merepresentasikan setiap lapisan stok
class InventoryLayer {
  final String sparepartName;
  final int remainingQuantity;
  final double unitPrice;
  final double totalValue;
  final DateTime? purchaseDate;

  InventoryLayer({
    required this.sparepartName,
    required this.remainingQuantity,
    required this.unitPrice,
    required this.totalValue,
    this.purchaseDate,
  });

  factory InventoryLayer.fromJson(Map<String, dynamic> json) {
    return InventoryLayer(
      sparepartName: json['sparepart_name'] ?? 'N/A',
      remainingQuantity: (json['remaining_quantity'] as num?)?.toInt() ?? 0,
      unitPrice: (json['unit_price'] as num?)?.toDouble() ?? 0.0,
      totalValue: (json['total_value'] as num?)?.toDouble() ?? 0.0,
      purchaseDate: json['purchase_date'] != null
          ? DateTime.parse(json['purchase_date'])
          : null,
    );
  }
}

class InventoryValueReportPage extends StatefulWidget {
  const InventoryValueReportPage({super.key});

  @override
  State<InventoryValueReportPage> createState() =>
      _InventoryValueReportPageState();
}

class _InventoryValueReportPageState extends State<InventoryValueReportPage> {
  // Future sekarang akan berisi data yang sudah dikelompokkan
  late Future<Map<String, List<InventoryLayer>>> _reportFuture;
  final _supabase = Supabase.instance.client;
  double _grandTotal = 0.0;

  @override
  void initState() {
    super.initState();
    _refreshReport();
  }

  void _refreshReport() {
    setState(() {
      _reportFuture = _fetchAndGroupReport();
    });
  }

  // Fungsi baru untuk mengambil dan mengelompokkan data
  Future<Map<String, List<InventoryLayer>>> _fetchAndGroupReport() async {
    try {
      // PENTING: Panggil RPC baru yang sudah menerapkan logika FIFO di backend
      final data = await _supabase.rpc('get_fifo_inventory_report');

      final layers =
      (data as List).map((item) => InventoryLayer.fromJson(item)).toList();

      // Hitung grand total dari semua lapisan stok
      double total = 0;
      for (var layer in layers) {
        total += layer.totalValue;
      }

      if (mounted) {
        setState(() {
          _grandTotal = total;
        });
      }

      // Kelompokkan data berdasarkan nama sparepart
      final groupedData = groupBy(layers, (layer) => layer.sparepartName);
      return groupedData;
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text(
                'Gagal memuat laporan: $e. Pastikan RPC "get_fifo_inventory_report" ada di Supabase.'),
            backgroundColor: Colors.red));
      }
      return {};
    }
  }

  String _formatCurrency(dynamic value) {
    final number = (value as num?)?.toDouble() ?? 0.0;
    return NumberFormat.currency(
        locale: 'id_ID', symbol: 'Rp ', decimalDigits: 0)
        .format(number);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Nilai Inventaris (FIFO)'),
        actions: [
          IconButton(onPressed: _refreshReport, icon: const Icon(Icons.refresh))
        ],
      ),
      body: FutureBuilder<Map<String, List<InventoryLayer>>>(
        future: _reportFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }
          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(
                child: Text('Tidak ada data untuk ditampilkan.'));
          }

          final groupedReport = snapshot.data!;
          final sparepartNames = groupedReport.keys.toList();

          return Column(
            children: [
              // Kartu Grand Total
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Card(
                  color: Theme.of(context).primaryColor,
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('Total Nilai Gudang',
                            style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Colors.black)),
                        Text(_formatCurrency(_grandTotal),
                            style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Colors.black)),
                      ],
                    ),
                  ),
                ),
              ),
              // Teks penjelasan metode FIFO
              const Padding(
                padding:
                EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                child: Text(
                  'Laporan ini dihitung menggunakan metode FIFO (First-In, First-Out). Barang yang pertama masuk diasumsikan keluar lebih dulu.',
                  style: TextStyle(fontStyle: FontStyle.italic, color: Colors.grey),
                  textAlign: TextAlign.center,
                ),
              ),
              // Daftar sparepart yang bisa diperluas (ExpansionTile)
              Expanded(
                child: ListView.builder(
                  itemCount: sparepartNames.length,
                  itemBuilder: (context, index) {
                    final sparepartName = sparepartNames[index];
                    final layers = groupedReport[sparepartName]!;
                    final totalValuePerItem = layers.fold<double>(
                        0, (sum, item) => sum + item.totalValue);
                    final totalStockPerItem = layers.fold<int>(
                        0, (sum, item) => sum + item.remainingQuantity);

                    return Card(
                      margin: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 6),
                      child: ExpansionTile(
                        title: Text(sparepartName,
                            style:
                            const TextStyle(fontWeight: FontWeight.bold)),
                        subtitle: Text('Total Stok: $totalStockPerItem pcs'),
                        trailing: Text(
                          _formatCurrency(totalValuePerItem),
                          style: const TextStyle(
                              fontWeight: FontWeight.bold, color: Colors.blue),
                        ),
                        // Bagian ini menampilkan detail lapisan stok saat diperluas
                        children: [
                          DataTable(
                            columnSpacing: 10,
                            columns: const [
                              DataColumn(label: Text('Tgl. Beli')),
                              DataColumn(
                                  label: Text('Sisa Stok'), numeric: true),
                              DataColumn(
                                  label: Text('Harga Beli'), numeric: true),
                              DataColumn(label: Text('Nilai'), numeric: true),
                            ],
                            rows: layers.map((layer) {
                              return DataRow(cells: [
                                DataCell(Text(layer.purchaseDate != null
                                    ? DateFormat('dd MMM yy', 'id_ID')
                                    .format(layer.purchaseDate!)
                                    : 'N/A')),
                                DataCell(
                                    Text(layer.remainingQuantity.toString())),
                                DataCell(
                                    Text(_formatCurrency(layer.unitPrice))),
                                DataCell(
                                    Text(_formatCurrency(layer.totalValue))),
                              ]);
                            }).toList(),
                          )
                        ],
                      ),
                    );
                  },
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}