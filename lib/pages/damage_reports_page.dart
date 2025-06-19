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
  String? _currentUserRole;

  @override
  void initState() {
    super.initState();
    _reportsFuture = _fetchReports();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final args = ModalRoute.of(context)?.settings.arguments;
    if (args is Map) {
      final safeArgs = Map<String, dynamic>.from(
          args.map((key, value) => MapEntry(key.toString(), value))
      );
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
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Gagal memuat laporan: $e")));
      }
      return [];
    }
  }

  // --- [PEMBARUAN FINAL LOGIKA PENGHAPUSAN] ---
  Future<void> _deleteReport(int reportId) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Konfirmasi Hapus'),
        content: const Text('Apakah Anda yakin ingin menghapus laporan ini beserta semua jadwal yang terkait dengannya? Aksi ini tidak dapat dibatalkan.'),
        actions: [
          TextButton(onPressed: () => Navigator.of(context).pop(false), child: const Text('Batal')),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Hapus Permanen'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      try {
        // Memanggil fungsi RPC di Supabase untuk menangani penghapusan secara transaksional
        await _supabase.rpc('delete_damage_report_and_schedule', params: {
          'report_id_to_delete': reportId
        });

        if(mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Laporan dan jadwal terkait berhasil dihapus.'), backgroundColor: Colors.green)
          );
          _refreshReports(); // Refresh daftar laporan setelah hapus
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Gagal menghapus: $e. Pastikan fungsi RPC "delete_damage_report_and_schedule" sudah dibuat di Supabase.'), backgroundColor: Colors.red, duration: const Duration(seconds: 5),)
          );
        }
      }
    }
  }
  // --- [AKHIR PEMBARUAN] ---


  String _formatDate(String dateString) {
    try {
      return DateFormat('dd MMM yy, HH:mm', 'id_ID').format(DateTime.parse(dateString));
    } catch(e) {
      return 'Tanggal Tidak Valid';
    }
  }

  @override
  Widget build(BuildContext context) {
    final bool isAdmin = _currentUserRole == 'Admin';

    return Scaffold(
      appBar: AppBar(
        title: const Text('Laporan Kerusakan'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _refreshReports,
            tooltip: 'Segarkan',
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
            return Center(child: Text('Gagal memuat: ${snapshot.error}'));
          }
          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('Tidak ada laporan kerusakan yang tertunda.'));
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
                        Text('Mesin: ${machine?['machine_name'] ?? 'N/A'}', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                        const Divider(),
                        Text('Deskripsi: ${report['description']}'),
                        const SizedBox(height: 8),
                        Text('Dilaporkan oleh: ${profile?['username'] ?? 'N/A'} pada ${_formatDate(report['created_at'])}', style: TextStyle(fontSize: 12, color: Colors.grey.shade600)),
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
                                          'role': _currentUserRole,
                                        }
                                    );
                                    if (result == true && mounted) {
                                      _refreshReports();
                                    }
                                  },
                                  icon: const Icon(Icons.calendar_today, size: 16),
                                  label: const Text('Jadwalkan'),
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