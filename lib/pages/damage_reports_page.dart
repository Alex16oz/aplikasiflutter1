// lib/pages/damage_reports_page.dart
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:testflut1/pages/schedule_page.dart';
import '../widgets/app_drawer.dart';

class DamageReportsPage extends StatefulWidget {
  const DamageReportsPage({super.key});
  static const String routeName = '/damage-reports';

  @override
  State<DamageReportsPage> createState() => _DamageReportsPageState();
}

class _DamageReportsPageState extends State<DamageReportsPage> {
  late Future<List<Map<String, dynamic>>> _reportsFuture;
  final _supabase = Supabase.instance.client;

  @override
  void initState() {
    super.initState();
    _reportsFuture = _fetchReports();
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

  String _formatDate(String dateString) {
    try {
      return DateFormat('dd MMM yyyy, HH:mm').format(DateTime.parse(dateString));
    } catch(e) {
      return 'Invalid Date';
    }
  }

  @override
  Widget build(BuildContext context) {
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
      drawer: const AppDrawer(),
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
                            ElevatedButton.icon(
                              onPressed: isScheduled
                                  ? null // Tombol dinonaktifkan jika status bukan 'Pending'
                                  : () async {
                                // Navigasi ke halaman Schedule dan kirim data laporan
                                final result = await Navigator.pushNamed(
                                    context,
                                    SchedulePage.routeName,
                                    arguments: {
                                      'damage_report': report,
                                      // passing user data is important for role checks
                                      ...(ModalRoute.of(context)?.settings.arguments as Map? ?? {})
                                    }
                                );

                                // Refresh halaman ini setelah kembali dari halaman schedule
                                if (result == true && mounted) {
                                  _refreshReports();
                                }
                              },
                              icon: const Icon(Icons.calendar_today, size: 16),
                              label: const Text('Create Schedule'),
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