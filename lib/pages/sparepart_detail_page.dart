// lib/pages/sparepart_detail_page.dart
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/sparepart_models.dart';

class SparepartDetailPage extends StatefulWidget {
  final SparepartSummary sparepartSummary;

  const SparepartDetailPage({super.key, required this.sparepartSummary});

  @override
  State<SparepartDetailPage> createState() => _SparepartDetailPageState();
}

class _SparepartDetailPageState extends State<SparepartDetailPage> {
  late Future<List<StockTransaction>> _transactionsFuture;
  final _supabase = Supabase.instance.client;

  @override
  void initState() {
    super.initState();
    _transactionsFuture = _fetchTransactions();
  }

  Future<List<StockTransaction>> _fetchTransactions() async {
    try {
      final response = await _supabase
          .from('stock_transactions')
          .select()
          .eq('sparepart_id', widget.sparepartSummary.id)
          .order('transaction_date', ascending: false);

      return (response as List)
          .map((item) => StockTransaction.fromJson(item))
          .toList();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text('Error: $e')));
      }
      return [];
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.sparepartSummary.sparepartName),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
            child: Card(
              child: ListTile(
                title: Text("Total Stok Saat Ini",
                    style: Theme.of(context).textTheme.titleMedium),
                trailing: Text(
                  widget.sparepartSummary.totalStock.toString(),
                  style: Theme.of(context)
                      .textTheme
                      .headlineMedium
                      ?.copyWith(fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ),
          if (widget.sparepartSummary.description != null &&
              widget.sparepartSummary.description!.isNotEmpty)
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
              child: Card(
                child: ListTile(
                  leading: const Icon(Icons.description_outlined),
                  title: const Text("Deskripsi"),
                  subtitle: Text(
                    widget.sparepartSummary.description!,
                  ),
                ),
              ),
            ),
          const Divider(height: 24),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.0),
            child: Text("Riwayat Transaksi",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          ),
          const SizedBox(height: 8),

          // LIST UNTUK RIWAYAT TRANSAKSI
          Expanded(
            child: FutureBuilder<List<StockTransaction>>(
              future: _transactionsFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return const Center(
                      child: Text('Belum ada riwayat transaksi.'));
                }
                final transactions = snapshot.data!;
                return ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  itemCount: transactions.length,
                  itemBuilder: (context, index) {
                    final tx = transactions[index];

                    // ==========================================================
                    // ==== AWAL DARI BLOK LOGIKA YANG DIPERBARUI ====
                    // ==========================================================
                    if (tx.transactionType == 'RECOUNT') {
                      // Tampilan khusus untuk transaksi RECOUNT
                      return Card(
                        color: Colors.blue.shade50,
                        margin: const EdgeInsets.symmetric(vertical: 4),
                        child: ListTile(
                          leading: Icon(Icons.inventory_2_outlined, color: Colors.blue.shade800),
                          title: const Text('Hitung Ulang Stok (Recount)'),
                          subtitle: Text(DateFormat('dd MMM yyyy, HH:mm').format(tx.transactionDate.toLocal())),
                          trailing: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              const Text('Jumlah Baru', style: TextStyle(fontSize: 12)),
                              Text(
                                tx.quantity.toString(),
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                  color: Colors.blue.shade800,
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    } else {
                      // Tampilan untuk transaksi IN dan OUT (logika yang sudah ada)
                      final isStockIn = tx.transactionType == 'IN';
                      final purposeOrSupplier = tx.supplier;

                      return Card(
                        margin: const EdgeInsets.symmetric(vertical: 4),
                        child: ListTile(
                          leading: Icon(
                            isStockIn ? Icons.arrow_downward : Icons.arrow_upward,
                            color: isStockIn ? Colors.green : Colors.red,
                          ),
                          title: Text(isStockIn
                              ? 'Stok Masuk dari ${purposeOrSupplier ?? "N/A"}'
                              : 'Stok Keluar untuk ${purposeOrSupplier ?? "N/A"}'
                          ),
                          subtitle: Text(DateFormat('dd MMM yyyy, HH:mm').format(tx.transactionDate.toLocal())),
                          trailing: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Text(
                                '${isStockIn ? "+" : "-"} ${tx.quantity}',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: isStockIn ? Colors.green : Colors.red,
                                ),
                              ),
                              if (isStockIn && tx.unitPrice != null)
                                Text(NumberFormat.currency(
                                    locale: 'id_ID', symbol: 'Rp ')
                                    .format(tx.unitPrice)),
                            ],
                          ),
                        ),
                      );
                    }
                    // ==========================================================
                    // ==== AKHIR DARI BLOK LOGIKA YANG DIPERBARUI ====
                    // ==========================================================
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}