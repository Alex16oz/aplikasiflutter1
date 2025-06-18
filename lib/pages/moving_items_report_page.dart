// lib/pages/moving_items_report_page.dart
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class MovingItemsReportPage extends StatefulWidget {
  const MovingItemsReportPage({super.key});

  @override
  State<MovingItemsReportPage> createState() => _MovingItemsReportPageState();
}

class _MovingItemsReportPageState extends State<MovingItemsReportPage> with SingleTickerProviderStateMixin {
  final _supabase = Supabase.instance.client;
  List<Map<String, dynamic>> _reportData = [];
  bool _isLoading = false;
  DateTime _startDate = DateTime.now().subtract(const Duration(days: 90));
  DateTime _endDate = DateTime.now();
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _fetchReport();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
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
      final data = await _supabase.rpc('get_moving_items_report', params: {
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
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    // Ambil data setelah fetch selesai
    final fastMoving = _reportData.take(10).toList();
    // PERBAIKAN: Konversi dari Iterable<dynamic> ke List<Map<String, dynamic>>
    final slowMoving = List<Map<String, dynamic>>.from(_reportData.reversed.take(10));

    return Scaffold(
      appBar: AppBar(
        title: const Text('Laporan Fast/Slow Moving'),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(icon: Icon(Icons.trending_up), text: 'Fast Moving'),
            Tab(icon: Icon(Icons.trending_down), text: 'Slow Moving'),
          ],
        ),
      ),
      body: Column(
        children: [
          _buildFilterBar(),
          if (_isLoading)
            const Expanded(child: Center(child: CircularProgressIndicator()))
          else if (_reportData.isEmpty)
            const Expanded(child: Center(child: Text('Tidak ada data pergerakan barang pada periode ini.')))
          else
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: [
                  _buildDataTable(fastMoving, 'Top 10 Fast Moving Items'),
                  _buildDataTable(slowMoving, 'Top 10 Slow Moving Items'),
                ],
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

  Widget _buildDataTable(List<Map<String, dynamic>> data, String title) {
    // PERBAIKAN: Tambahkan kurung kurawal pada 'if'
    if (data.isEmpty) {
      return Center(child: Text('Tidak ada data untuk "$title"'));
    }

    return SingleChildScrollView(
      scrollDirection: Axis.vertical,
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: DataTable(
            columns: const [
              DataColumn(label: Text('Sparepart')),
              DataColumn(label: Text('Jml. Transaksi'), numeric: true),
              DataColumn(label: Text('Total Kuantitas'), numeric: true),
            ],
            rows: data.map((item) => DataRow(
                cells: [
                  DataCell(SizedBox(width: 200, child: Text(item['sparepart_name'] ?? 'N/A', overflow: TextOverflow.ellipsis,))),
                  DataCell(Text(item['transaction_count'].toString())),
                  DataCell(Text(item['total_quantity_out'].toString())),
                ]
            )).toList(),
          ),
        ),
      ),
    );
  }
}