// lib/pages/work_log_approval_page.dart

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../widgets/app_drawer.dart';

class WorkLogApprovalPage extends StatefulWidget {
  const WorkLogApprovalPage({super.key});
  static const String routeName = '/work-log-approval';

  @override
  State<WorkLogApprovalPage> createState() => _WorkLogApprovalPageState();
}

class _WorkLogApprovalPageState extends State<WorkLogApprovalPage> {
  final _supabase = Supabase.instance.client;
  late Future<List<Map<String, dynamic>>> _approvalFuture;

  @override
  void initState() {
    super.initState();
    _refreshApprovals();
  }

  void _refreshApprovals() {
    setState(() {
      _approvalFuture = _fetchApprovals();
    });
  }

  Future<List<Map<String, dynamic>>> _fetchApprovals() async {
    try {
      final response = await _supabase
          .from('work_logs')
          .select(
          '*, '
              'operator:profiles!work_logs_user_id_fkey(username), '
              'schedules(task_description, machines(machine_name))'
      )
          .eq('status', 'Menunggu Persetujuan')
          .order('created_at', ascending: true);
      return List<Map<String, dynamic>>.from(response);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('Gagal memuat data: $e'),
          backgroundColor: Colors.red,
        ));
      }
      return [];
    }
  }

  Future<void> _approveWorkLog(int workLogId) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Konfirmasi Persetujuan'),
        content: const Text('Anda yakin ingin menyetujui catatan kerja ini?'),
        actions: [
          TextButton(onPressed: () => Navigator.of(context).pop(false), child: const Text('Batal')),
          ElevatedButton(onPressed: () => Navigator.of(context).pop(true), child: const Text('Setujui')),
        ],
      ),
    ) ?? false;

    if (confirmed) {
      try {
        await _supabase.from('work_logs').update({
          'status': 'Disetujui',
          'approved_by': _supabase.auth.currentUser!.id,
        }).eq('id', workLogId);

        if(mounted) {
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
            content: Text('Catatan kerja berhasil disetujui.'),
            backgroundColor: Colors.green,
          ));
        }
        _refreshApprovals();

      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text('Gagal memperbarui status: $e'),
            backgroundColor: Colors.red,
          ));
        }
      }
    }
  }

  Future<void> _rejectWorkLog(int workLogId) async {
    final reasonController = TextEditingController();
    final formKey = GlobalKey<FormState>();

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Alasan Penolakan'),
        content: Form(
          key: formKey,
          child: TextFormField(
            controller: reasonController,
            decoration: const InputDecoration(
              labelText: 'Alasan Penolakan',
              hintText: 'Contoh: Foto tidak jelas, jam kerja tidak sesuai.',
            ),
            validator: (value) {
              if (value == null || value.trim().isEmpty) {
                return 'Alasan penolakan wajib diisi.';
              }
              return null;
            },
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.of(context).pop(false), child: const Text('Batal')),
          ElevatedButton(
            onPressed: () {
              if (formKey.currentState!.validate()) {
                Navigator.of(context).pop(true);
              }
            },
            child: const Text('Tolak Laporan'),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      try {
        await _supabase.from('work_logs').update({
          'status': 'Ditolak',
          'rejection_reason': reasonController.text.trim(), // Simpan alasan
          'approved_by': _supabase.auth.currentUser!.id,
        }).eq('id', workLogId);

        if(mounted) {
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
            content: Text('Laporan kerja berhasil ditolak.'),
            backgroundColor: Colors.orange,
          ));
        }
        _refreshApprovals();
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text('Gagal menolak laporan: $e'),
            backgroundColor: Colors.red,
          ));
        }
      }
    }
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Persetujuan Jam Kerja'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _refreshApprovals,
            tooltip: 'Refresh',
          )
        ],
      ),
      drawer: const AppDrawer(),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: _approvalFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }
          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('Tidak ada catatan kerja yang menunggu persetujuan.'));
          }

          final logs = snapshot.data!;
          return ListView.builder(
            padding: const EdgeInsets.all(8),
            itemCount: logs.length,
            itemBuilder: (context, index) {
              final log = logs[index];
              final operatorProfile = log['operator'];
              final schedule = log['schedules'];
              final machine = schedule?['machines'];
              final duration = log['duration_minutes'] ?? 0;
              final overtime = log['overtime_minutes'] ?? 0;

              return Card(
                elevation: 3,
                margin: const EdgeInsets.symmetric(vertical: 6),
                child: Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Operator: ${operatorProfile?['username'] ?? 'N/A'}',
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                      ),
                      const Divider(),
                      Text('Mesin: ${machine?['machine_name'] ?? 'N/A'}'),
                      Text('Tugas: ${schedule?['task_description'] ?? 'N/A'}'),
                      Text('Tanggal: ${DateFormat('dd MMM yyyy, HH:mm').format(DateTime.parse(log['end_time']))}'),
                      const SizedBox(height: 8),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          _buildInfoChip('Durasi', '$duration Menit', Colors.blue),
                          _buildInfoChip('Lembur', '$overtime Menit', Colors.purple),
                        ],
                      ),
                      const SizedBox(height: 12),
                      if (log['notes'] != null && log['notes'].isNotEmpty)
                        Text('Catatan: ${log['notes']}'),
                      const SizedBox(height: 12),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          OutlinedButton.icon(
                            onPressed: () => _rejectWorkLog(log['id']),
                            icon: const Icon(Icons.close),
                            label: const Text('Tolak'),
                            style: OutlinedButton.styleFrom(foregroundColor: Colors.red),
                          ),
                          const SizedBox(width: 8),
                          ElevatedButton.icon(
                            onPressed: () => _approveWorkLog(log['id']),
                            icon: const Icon(Icons.check),
                            label: const Text('Setujui'),
                            style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
                          ),
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

  Widget _buildInfoChip(String label, String value, Color color) {
    return Chip(
      avatar: CircleAvatar(
        backgroundColor: color.withOpacity(0.8),
        child: Text(label[0], style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
      ),
      label: Text('$label: $value'),
      backgroundColor: color.withOpacity(0.1),
    );
  }
}