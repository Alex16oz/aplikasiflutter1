// lib/pages/stock_transaction_report_page.dart
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class StockTransactionReportPage extends StatefulWidget {
  const StockTransactionReportPage({super.key});

  @override
  State<StockTransactionReportPage> createState() => _StockTransactionReportPageState();
}

class _StockTransactionReportPageState extends State<StockTransactionReportPage> {
  final _supabase = Supabase.instance.client;
  List<Map<String, dynamic>> _reportData = [];
  bool _isLoading = false;
  DateTime _startDate = DateTime.now().subtract(const Duration(days: 30));
  DateTime _endDate = DateTime.now();

  @override
  void initState() {
    super.initState();
    _fetchReport();
  }

  Future<void> _selectDateRange(BuildContext context) async {
    final newDateRange = await showDateRangePicker(
      context: context,
      initialDateRange: DateTimeRange(start: _startDate, end: _endDate),
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
    );

    if (newDateRange != null) {
      setState(() {
        _startDate = newDateRange.start;
        _endDate = newDateRange.end;
      });
      _fetchReport();
    }
  }

  Future<void> _fetchReport() async {
    if (_isLoading) return;
    setState(() => _isLoading = true);
    try {
      final data = await _supabase.rpc('get_stock_transaction_report', params: {
        'start_date': DateFormat('yyyy-MM-dd').format(_startDate),
        'end_date': DateFormat('yyyy-MM-dd').format(_endDate),
      });
      if (mounted) {
        setState(() {
          _reportData = List<Map<String, dynamic>>.from(data);
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('Gagal memuat laporan: $e'),
          backgroundColor: Colors.red,
        ));
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Laporan Barang Masuk/Keluar'),
      ),
      body: Column(
        children: [
          _buildFilterBar(),
          if (_isLoading)
            const Expanded(child: Center(child: CircularProgressIndicator()))
          else if (_reportData.isEmpty)
            const Expanded(child: Center(child: Text('Tidak ada transaksi pada periode ini.')))
          else
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.all(8),
                itemCount: _reportData.length,
                itemBuilder: (context, index) {
                  final tx = _reportData[index];
                  return _buildTransactionTile(tx);
                },
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildFilterBar() {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Expanded(
            child: TextButton.icon(
              icon: const Icon(Icons.calendar_today),
              label: Text('${DateFormat('dd MMM yy', 'id_ID').format(_startDate)} - ${DateFormat('dd MMM yy', 'id_ID').format(_endDate)}'),
              onPressed: () => _selectDateRange(context),
            ),
          ),
          IconButton(onPressed: _fetchReport, icon: const Icon(Icons.refresh))
        ],
      ),
    );
  }

  Widget _buildTransactionTile(Map<String, dynamic> tx) {
    final type = tx['transaction_type'] as String;
    IconData icon;
    Color color;
    String title;

    switch (type) {
      case 'IN':
        icon = Icons.arrow_downward;
        color = Colors.green;
        title = 'Masuk dari ${tx['supplier'] ?? 'N/A'}';
        break;
      case 'OUT':
        icon = Icons.arrow_upward;
        color = Colors.red;
        title = 'Keluar untuk ${tx['supplier'] ?? 'N/A'}';
        break;
      case 'RECOUNT':
      default:
        icon = Icons.inventory_2_outlined;
        color = Colors.blue;
        title = 'Hitung Ulang Stok';
        break;
    }

    return Card(
      child: ListTile(
        leading: Icon(icon, color: color),
        title: Text(tx['sparepart_name'] ?? 'N/A', style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title),
            Text('Oleh: ${tx['username'] ?? 'Sistem'} pada ${DateFormat('dd MMM yy, HH:mm', 'id_ID').format(DateTime.parse(tx['transaction_date']))}'),
          ],
        ),
        trailing: Text(
          '${type == 'OUT' ? '-' : (type == 'IN' ? '+' : '')}${tx['quantity']}',
          style: TextStyle(color: color, fontWeight: FontWeight.bold, fontSize: 16),
        ),
      ),
    );
  }
}