// lib/pages/damage_reports_page.dart
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:testflut1/pages/schedule_page.dart';

class DamageReportsPage extends StatefulWidget {
  const DamageReportsPage({super.key});
  static const String routeName = '/damage-reports';

  @override
  State<DamageReportsPage> createState() => _DamageReportsPageState();
}

class _DamageReportsPageState extends State<DamageReportsPage> {
  late Future<List<Map<String, dynamic>>> _reportsFuture;
  final _supabase = Supabase.instance.client;
  String? _currentUserRole; // Untuk menyimpan role pengguna

  @override
  void initState() {
    super.initState();
    _reportsFuture = _fetchReports();
  }

  // --- PENAMBAHAN: Mengambil role dari argumen navigasi ---
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final args = ModalRoute.of(context)?.settings.arguments;
    if (args is Map) {
      // Konversi argumen dengan aman
      final safeArgs = Map<String, dynamic>.from(
          args.map((key, value) => MapEntry(key.toString(), value))
      );
      // Set _currentUserRole dari argumen
      setState(() {
        _currentUserRole = safeArgs['role'];
      });
    }
  }

  Future<void> _refreshReports() async {
    setState(() {
      _reportsFuture = _fetchReports();
    });
  }

  Future<List<Map<String, dynamic>>> _fetchReports() async {
    try {
      final response = await _supabase
          .from('damage_reports')
          .select('*, machines(machine_name), profiles(username)')
          .order('created_at', ascending: false);
      return List<Map<String, dynamic>>.from(response);
    } catch(e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Error fetching reports: $e")));
      }
      return [];
    }
  }

  // --- FUNGSI BARU: Untuk menghapus laporan ---
  Future<void> _deleteReport(int reportId) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Konfirmasi Hapus'),
        content: const Text('Apakah Anda yakin ingin menghapus laporan kerusakan ini?'),
        actions: [
          TextButton(onPressed: () => Navigator.of(context).pop(false), child: const Text('Batal')),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Hapus'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      try {
        await _supabase.from('damage_reports').delete().eq('id', reportId);
        if(mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Laporan berhasil dihapus'), backgroundColor: Colors.green)
          );
          _refreshReports(); // Refresh daftar laporan setelah hapus
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Gagal menghapus laporan: $e'), backgroundColor: Colors.red)
          );
        }
      }
    }
  }

  String _formatDate(String dateString) {
    try {
      return DateFormat('dd MMM yy, HH:mm').format(DateTime.parse(dateString));
    } catch(e) {
      return 'Invalid Date';
    }
  }

  @override
  Widget build(BuildContext context) {
    // Tentukan apakah pengguna adalah admin
    final bool isAdmin = _currentUserRole == 'Admin';

    return Scaffold(
      appBar: AppBar(
        title: const Text('Damage Reports'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _refreshReports,
            tooltip: 'Refresh',
          )
        ],
      ),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: _reportsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }
          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('No pending damage reports.'));
          }

          final reports = snapshot.data!;
          return RefreshIndicator(
            onRefresh: _refreshReports,
            child: ListView.builder(
              padding: const EdgeInsets.all(8.0),
              itemCount: reports.length,
              itemBuilder: (context, index) {
                final report = reports[index];
                final machine = report['machines'];
                final profile = report['profiles'];
                final bool isScheduled = report['status'] != 'Pending';

                return Card(
                  elevation: 3,
                  margin: const EdgeInsets.symmetric(vertical: 6),
                  child: Padding(
                    padding: const EdgeInsets.all(12.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Machine: ${machine?['machine_name'] ?? 'N/A'}', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                        const Divider(),
                        Text('Description: ${report['description']}'),
                        const SizedBox(height: 8),
                        Text('Reported by: ${profile?['username'] ?? 'N/A'} on ${_formatDate(report['created_at'])}', style: TextStyle(fontSize: 12, color: Colors.grey.shade600)),
                        const SizedBox(height: 12),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Chip(
                              label: Text(report['status']),
                              backgroundColor: isScheduled ? Colors.green.shade100 : Colors.orange.shade100,
                            ),
                            Row(
                              children: [
                                // --- PENAMBAHAN: Tombol Hapus hanya untuk Admin ---
                                if(isAdmin)
                                  IconButton(
                                    icon: const Icon(Icons.delete_outline, color: Colors.red),
                                    tooltip: 'Hapus Laporan',
                                    onPressed: () => _deleteReport(report['id']),
                                  ),
                                ElevatedButton.icon(
                                  onPressed: isScheduled
                                      ? null
                                      : () async {
                                    final result = await Navigator.pushNamed(
                                        context,
                                        SchedulePage.routeName,
                                        arguments: {
                                          'damage_report': report,
                                          'role': _currentUserRole, // Kirim role ke halaman selanjutnya
                                        }
                                    );
                                    if (result == true && mounted) {
                                      _refreshReports();
                                    }
                                  },
                                  icon: const Icon(Icons.calendar_today, size: 16),
                                  label: const Text('Schedule'),
                                  style: ElevatedButton.styleFrom(
                                    foregroundColor: Colors.white,
                                    backgroundColor: isScheduled ? Colors.grey : Theme.of(context).primaryColor,
                                  ).copyWith(
                                      textStyle: WidgetStateProperty.all(const TextStyle(color: Colors.white))
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }
}