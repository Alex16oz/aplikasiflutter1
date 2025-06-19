// lib/pages/repair_reports_page.dart

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class RepairReportsPage extends StatefulWidget {
  final int? scheduleId;

  const RepairReportsPage({super.key, this.scheduleId});
  static const String routeName = '/repair-reports';

  @override
  State<RepairReportsPage> createState() => _RepairReportsPageState();
}

class _RepairReportsPageState extends State<RepairReportsPage> {
  late Future<List<Map<String, dynamic>>> _reportsFuture;
  final _supabase = Supabase.instance.client;
  String? _currentUserRole;

  @override
  void initState() {
    super.initState();
    _refreshReports();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final args = ModalRoute.of(context)?.settings.arguments;
    if (args is Map) {
      final safeArgs = Map<String, dynamic>.from(
          args.map((key, value) => MapEntry(key.toString(), value))
      );
      _currentUserRole = safeArgs['role'];
    }
  }

  void _refreshReports() {
    setState(() {
      _reportsFuture = _fetchReports();
    });
  }

  // ===[ PERBAIKAN DIMULAI DI SINI ]===
  // 1. Tambahkan parameter machineId
  Future<void> _verifyReport(int reportId, int scheduleId, int machineId) async {
    try {
      // Step 1: Update status laporan perbaikan
      await _supabase.from('repair_reports').update({
        'status': 'Terverifikasi',
        'verified_by': _supabase.auth.currentUser!.id,
      }).eq('id', reportId);

      // Step 2: Update status jadwal
      await _supabase.from('schedules').update({
        'status': 'Terverifikasi'
      }).eq('id', scheduleId);

      // Step 3 (BARU): Update status mesin menjadi 'operasional'
      await _supabase.from('machines').update({
        'operational_status': 'operasional'
      }).eq('id', machineId);

      if(mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text('Laporan berhasil diverifikasi & status mesin diperbarui!'),
          backgroundColor: Colors.green,
        ));
        _refreshReports();
      }

    } catch(e) {
      if(mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('Gagal verifikasi laporan: $e'),
          backgroundColor: Colors.red,
        ));
      }
    }
  }

  Future<List<Map<String, dynamic>>> _fetchReports() async {
    try {
      // 2. Pastikan machine_id diambil dari tabel schedules
      var query = _supabase.from('repair_reports').select(
          '*, schedules!inner(id, machine_id, machines(machine_name)), completed_by:profiles!repair_reports_completed_by_fkey(username)');

      if (widget.scheduleId != null) {
        query = query.eq('schedule_id', widget.scheduleId!);
      }

      final response = await query.order('created_at', ascending: false);
      return List<Map<String, dynamic>>.from(response);

    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('Gagal memuat laporan: $e'),
          backgroundColor: Colors.red,
        ));
      }
      return [];
    }
  }
  // ===[ PERBAIKAN SELESAI DI SINI ]===


  @override
  Widget build(BuildContext context) {
    final bool isAdmin = _currentUserRole == 'Admin';
    return Scaffold(
      appBar: AppBar(
        title: const Text('Laporan Perbaikan'),
        actions: [
          IconButton(onPressed: _refreshReports, icon: const Icon(Icons.refresh))
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
            return const Center(child: Text('Tidak ada laporan perbaikan yang ditemukan.'));
          }

          final reports = snapshot.data!;
          return ListView.builder(
            padding: const EdgeInsets.all(8),
            itemCount: reports.length,
            itemBuilder: (context, index) {
              final report = reports[index];
              final schedule = report['schedules'];
              final machine = schedule?['machines'];
              final operator = report['completed_by'];
              final photos = List<String>.from(report['photo_urls'] ?? []);
              final status = report['status'];

              // 3. Ambil machine_id dari data schedule
              final machineId = schedule?['machine_id'];

              return Card(
                elevation: 3,
                margin: const EdgeInsets.symmetric(vertical: 8),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Mesin: ${machine?['machine_name'] ?? 'N/A'}',
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                      const Divider(),
                      Text('Operator: ${operator?['username'] ?? 'N/A'}'),
                      Text('Tanggal Selesai: ${DateFormat('dd MMM yy, HH:mm').format(DateTime.parse(report['created_at']))}'),
                      const SizedBox(height: 8),
                      Text('Catatan: ${report['completion_notes'] ?? '-'}'),
                      if (photos.isNotEmpty) ...[
                        const SizedBox(height: 12),
                        const Text('Dokumentasi Foto:', style: TextStyle(fontWeight: FontWeight.bold)),
                        const SizedBox(height: 8),
                        SizedBox(
                          height: 100,
                          child: ListView.builder(
                            scrollDirection: Axis.horizontal,
                            itemCount: photos.length,
                            itemBuilder: (ctx, i) => Padding(
                              padding: const EdgeInsets.only(right: 8.0),
                              child: Image.network(photos[i], fit: BoxFit.cover, width: 100, errorBuilder: (c, e, s) => const Icon(Icons.error)),
                            ),
                          ),
                        ),
                      ],
                      const SizedBox(height: 16),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Chip(label: Text(status)),
                          if(isAdmin && status == 'Menunggu Verifikasi')
                            ElevatedButton.icon(
                              // 4. Kirim machineId saat memanggil fungsi verify
                              onPressed: () {
                                if (machineId != null) {
                                  _verifyReport(report['id'], schedule['id'], machineId);
                                } else {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(content: Text('Error: Machine ID tidak ditemukan.'), backgroundColor: Colors.red)
                                  );
                                }
                              },
                              icon: const Icon(Icons.check_circle_outline),
                              label: const Text('Verifikasi'),
                              style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
                            )
                        ],
                      )
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}