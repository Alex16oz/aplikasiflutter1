// lib/pages/attendance_recap_report_page.dart
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class AttendanceRecapReportPage extends StatefulWidget {
  const AttendanceRecapReportPage({super.key});

  @override
  State<AttendanceRecapReportPage> createState() => _AttendanceRecapReportPageState();
}

class _AttendanceRecapReportPageState extends State<AttendanceRecapReportPage> {
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
      final data = await _supabase.rpc('get_attendance_recap', params: {
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
        title: const Text('Laporan Rekap Kehadiran'),
      ),
      body: Column(
        children: [
          _buildFilterBar(),
          if (_isLoading)
            const Expanded(child: Center(child: CircularProgressIndicator()))
          else if (_reportData.isEmpty)
            const Expanded(child: Center(child: Text('Tidak ada data kehadiran pada periode ini.')))
          else
            Expanded(
              child: SingleChildScrollView(
                scrollDirection: Axis.vertical,
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: DataTable(
                      columns: const [
                        DataColumn(label: Text('Pegawai')),
                        DataColumn(label: Text('Total Hadir'), numeric: true),
                        DataColumn(label: Text('Total Jam Kerja'), numeric: true),
                        DataColumn(label: Text('Rata-rata Masuk'), numeric: true),
                        DataColumn(label: Text('Rata-rata Pulang'), numeric: true),
                      ],
                      rows: _reportData.map((row) {
                        final totalHours = (row['total_work_hours'] as num?)?.toDouble() ?? 0.0;
                        return DataRow(cells: [
                          DataCell(Text(row['username'] ?? 'N/A')),
                          DataCell(Text(row['total_days_present'].toString())),
                          DataCell(Text('${totalHours.toStringAsFixed(1)} jam')),
                          DataCell(Text(row['avg_check_in']?.substring(0, 5) ?? '-')),
                          DataCell(Text(row['avg_check_out']?.substring(0, 5) ?? '-')),
                        ]);
                      }).toList(),
                    ),
                  ),
                ),
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