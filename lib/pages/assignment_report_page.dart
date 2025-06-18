// lib/pages/assignment_report_page.dart
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class AssignmentReportPage extends StatefulWidget {
  const AssignmentReportPage({super.key});

  @override
  State<AssignmentReportPage> createState() => _AssignmentReportPageState();
}

class _AssignmentReportPageState extends State<AssignmentReportPage> {
  final _supabase = Supabase.instance.client;
  List<Map<String, dynamic>> _reportData = [];
  bool _isLoading = true;
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
      lastDate: DateTime.now().add(const Duration(days: 365)),
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
      final data = await _supabase.rpc('get_assignment_report', params: {
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
        title: const Text('Laporan Penugasan Tugas'),
      ),
      body: Column(
        children: [
          _buildFilterBar(),
          if (_isLoading)
            const Expanded(child: Center(child: CircularProgressIndicator()))
          else if (_reportData.isEmpty)
            const Expanded(child: Center(child: Text('Tidak ada data penugasan pada periode ini.')))
          else
            Expanded(
              child: DataTable(
                columns: const [
                  DataColumn(label: Text('Operator')),
                  DataColumn(label: Text('Jumlah Tugas'), numeric: true),
                ],
                rows: _reportData.map((row) {
                  return DataRow(cells: [
                    DataCell(Text(row['username'] ?? 'N/A')),
                    DataCell(Text(row['assigned_tasks_count'].toString())),
                  ]);
                }).toList(),
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
}