// lib/pages/item_usage_report_page.dart
import 'package:flutter/material.dart';
// --- DUA IMPORT YANG DITAMBAHKAN UNTUK MEMPERBAIKI ERROR ---
import 'package:intl/intl.dart';
import 'package:intl/date_symbol_data_local.dart';
// ---------------------------------------------------------
import 'package:supabase_flutter/supabase_flutter.dart';

class ItemUsageReportPage extends StatefulWidget {
  const ItemUsageReportPage({super.key});

  @override
  State<ItemUsageReportPage> createState() => _ItemUsageReportPageState();
}

class _ItemUsageReportPageState extends State<ItemUsageReportPage> {
  final _supabase = Supabase.instance.client;
  List<Map<String, dynamic>> _reportData = [];
  bool _isLoading = true;
  DateTime _startDate = DateTime.now().subtract(const Duration(days: 30));
  DateTime _endDate = DateTime.now();

  @override
  void initState() {
    super.initState();
    // Inisialisasi locale untuk intl
    initializeDateFormatting('id_ID', null);
    _fetchReport();
  }

  Future<void> _selectDateRange(BuildContext context) async {
    final newDateRange = await showDateRangePicker(
      context: context,
      initialDateRange: DateTimeRange(start: _startDate, end: _endDate),
      firstDate: DateTime(2020),
      lastDate: DateTime.now().add(const Duration(days: 365)),
      locale: const Locale('id', 'ID'),
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
    if (!mounted) return;
    setState(() => _isLoading = true);
    try {
      final data = await _supabase.rpc('get_item_usage_report', params: {
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
          backgroundColor: Theme.of(context).colorScheme.error,
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
        title: const Text('Laporan Penggunaan Barang'),
      ),
      body: Column(
        children: [
          _buildFilterBar(),
          if (_isLoading)
            const Expanded(child: Center(child: CircularProgressIndicator()))
          else if (_reportData.isEmpty)
            const Expanded(child: Center(child: Text('Tidak ada data penggunaan barang pada periode ini.')))
          else
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.all(8),
                itemCount: _reportData.length,
                itemBuilder: (context, index) {
                  final row = _reportData[index];
                  final usageDate = row['usage_date'] != null
                      ? DateFormat('d MMMM yyyy', 'id_ID').format(DateTime.parse(row['usage_date']))
                      : 'N/A';
                  return Card(
                    child: ListTile(
                      title: Text('${row['sparepart_name']} (x${row['quantity_used']})'),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Mesin: ${row['machine_name']}'),
                          Text('Tugas: ${row['task_description']}'),
                        ],
                      ),
                      trailing: Text(usageDate, style: Theme.of(context).textTheme.bodySmall),
                    ),
                  );
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
              label: Text(
                '${DateFormat('dd MMM yy', 'id_ID').format(_startDate)} - ${DateFormat('dd MMM yy', 'id_ID').format(_endDate)}',
              ),
              onPressed: () => _selectDateRange(context),
            ),
          ),
          IconButton(onPressed: _fetchReport, icon: const Icon(Icons.refresh))
        ],
      ),
    );
  }
}