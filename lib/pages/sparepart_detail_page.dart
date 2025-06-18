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
  StockTransaction? _lastTransaction; // Variabel untuk menyimpan transaksi terakhir

  @override
  void initState() {
    super.initState();
    _transactionsFuture = _fetchTransactions();
  }

  // Fungsi untuk memuat ulang data transaksi
  Future<void> _refreshTransactions() async {
    setState(() {
      _transactionsFuture = _fetchTransactions();
    });
  }

  // Fungsi untuk mengambil data transaksi dari database
  Future<List<StockTransaction>> _fetchTransactions() async {
    try {
      final response = await _supabase
          .from('stock_transactions')
          .select()
          .eq('sparepart_id', widget.sparepartSummary.id)
          .order('transaction_date', ascending: false);

      final transactions = (response as List)
          .map((item) => StockTransaction.fromJson(item))
          .toList();

      // Simpan transaksi pertama (yang terbaru) ke dalam state
      if (mounted) {
        setState(() {
          _lastTransaction = transactions.isNotEmpty ? transactions.first : null;
        });
      }
      return transactions;
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text('Error: $e')));
      }
      return [];
    }
  }

  // Fungsi untuk membatalkan (menghapus) transaksi terakhir
  Future<void> _undoLastTransaction(StockTransaction tx) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Undo Transaksi?'),
        content: const Text('Anda yakin ingin menghapus transaksi terakhir? Aksi ini akan mengembalikan nilai stok dan tidak dapat dibatalkan.'),
        actions: [
          TextButton(onPressed: () => Navigator.of(context).pop(false), child: const Text('Batal')),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Ya, Batalkan'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      try {
        await _supabase.from('stock_transactions').delete().eq('id', tx.id);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
            content: Text('Transaksi terakhir berhasil dibatalkan.'),
            backgroundColor: Colors.green,
          ));
          _refreshTransactions(); // Muat ulang data setelah berhasil
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text('Gagal membatalkan transaksi: $e'),
            backgroundColor: Colors.red,
          ));
        }
      }
    }
  }

  // Fungsi untuk menampilkan dialog edit transaksi
  Future<void> _showEditTransactionDialog(StockTransaction tx) async {
    final formKey = GlobalKey<FormState>();
    final qtyController = TextEditingController(text: tx.quantity.toString());
    final priceController = TextEditingController(text: tx.unitPrice?.toStringAsFixed(0) ?? '');
    final purposeOrSupplierController = TextEditingController(text: tx.supplier ?? '');

    final isStockIn = tx.transactionType == 'IN';
    final isStockOut = tx.transactionType == 'OUT';
    final isRecount = tx.transactionType == 'RECOUNT';

    await showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: Text('Edit Transaksi (${tx.transactionType})'),
          content: Form(
            key: formKey,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextFormField(
                    controller: qtyController,
                    decoration: InputDecoration(labelText: isRecount ? 'Jumlah Stok Baru' : 'Jumlah'),
                    keyboardType: TextInputType.number,
                    validator: (v) => v == null || v.isEmpty || int.tryParse(v) == null ? 'Angka tidak valid' : null,
                  ),
                  if (isStockIn || isStockOut)
                    TextFormField(
                      controller: purposeOrSupplierController,
                      decoration: InputDecoration(labelText: isStockIn ? 'Supplier' : 'Tujuan'),
                      validator: (v) => v == null || v.isEmpty ? 'Wajib diisi' : null,
                    ),
                  if (isStockIn)
                    TextFormField(
                      controller: priceController,
                      decoration: const InputDecoration(labelText: 'Harga per Unit'),
                      keyboardType: TextInputType.number,
                    ),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.of(context).pop(), child: const Text('Batal')),
            ElevatedButton(
              onPressed: () async {
                if (formKey.currentState!.validate()) {
                  try {
                    final updateData = {
                      'quantity': int.parse(qtyController.text),
                      'supplier': (isStockIn || isStockOut) ? purposeOrSupplierController.text.trim() : null,
                      'unit_price': isStockIn ? double.tryParse(priceController.text.trim()) : null,
                    };
                    updateData.removeWhere((key, value) => value == null && key != 'unit_price');

                    await _supabase.from('stock_transactions').update(updateData).eq('id', tx.id);

                    if (mounted) {
                      Navigator.of(context).pop();
                      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                        content: Text('Transaksi berhasil diperbarui!'),
                        backgroundColor: Colors.green,
                      ));
                      _refreshTransactions(); // Muat ulang data setelah berhasil
                    }
                  } catch (e) {
                    if (mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                        content: Text('Gagal memperbarui: $e'),
                        backgroundColor: Colors.red,
                      ));
                    }
                  }
                }
              },
              child: const Text('Simpan Perubahan'),
            ),
          ],
        ));
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.sparepartSummary.sparepartName),
        // Menambahkan tombol aksi di AppBar
        actions: [
          if (_lastTransaction != null)
            IconButton(
              icon: const Icon(Icons.edit_note),
              tooltip: 'Edit Transaksi Terakhir',
              onPressed: () => _showEditTransactionDialog(_lastTransaction!),
            ),
          if (_lastTransaction != null)
            IconButton(
              icon: const Icon(Icons.undo),
              tooltip: 'Undo Transaksi Terakhir',
              onPressed: () => _undoLastTransaction(_lastTransaction!),
            ),
        ],
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
                    // Cek apakah ini transaksi terakhir untuk diberi highlight
                    final isLastTx = tx.id == _lastTransaction?.id;

                    if (tx.transactionType == 'RECOUNT') {
                      return Card(
                        color: isLastTx ? Colors.yellow.shade100 : Colors.blue.shade50,
                        margin: const EdgeInsets.symmetric(vertical: 4),
                        child: ListTile(
                          leading: Icon(Icons.inventory_2_outlined, color: Colors.blue.shade800),
                          title: const Text('Hitung Ulang Stok (Recount)'),
                          subtitle: Text(DateFormat('dd MMM kk, HH:mm').format(tx.transactionDate.toLocal())),
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
                      final isStockIn = tx.transactionType == 'IN';
                      final purposeOrSupplier = tx.supplier;

                      return Card(
                        color: isLastTx ? Colors.yellow.shade100 : null,
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
                          subtitle: Text(DateFormat('dd MMM kk, HH:mm').format(tx.transactionDate.toLocal())),
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