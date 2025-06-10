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
            padding: const EdgeInsets.all(16.0),
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
          const Divider(height: 1),
          const Padding(
            padding: EdgeInsets.all(16.0),
            child: Text("Riwayat Transaksi",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          ),
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
                  itemCount: transactions.length,
                  itemBuilder: (context, index) {
                    final tx = transactions[index];
                    final isStockIn = tx.transactionType == 'IN';
                    return ListTile(
                      leading: Icon(
                        isStockIn ? Icons.arrow_downward : Icons.arrow_upward,
                        color: isStockIn ? Colors.green : Colors.red,
                      ),
                      title: Text(isStockIn
                          ? 'Stok Masuk dari ${tx.supplier ?? "N/A"}'
                          : 'Stok Keluar'),
                      subtitle: Text(
                          DateFormat('dd MMM yyyy, HH:mm').format(tx.transactionDate.toLocal())),
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
                    );
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