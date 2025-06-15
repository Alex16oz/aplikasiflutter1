// lib/pages/user_attendance_history_page.dart

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class UserAttendanceHistoryPage extends StatefulWidget {
  const UserAttendanceHistoryPage({super.key});

  static const String routeName = '/user-attendance-history';

  @override
  State<UserAttendanceHistoryPage> createState() => _UserAttendanceHistoryPageState();
}

class _UserAttendanceHistoryPageState extends State<UserAttendanceHistoryPage> {
  final _supabase = Supabase.instance.client;
  late Future<List<Map<String, dynamic>>> _attendanceFuture;

  @override
  void initState() {
    super.initState();
    _attendanceFuture = _fetchAttendanceHistory();
  }

  Future<List<Map<String, dynamic>>> _fetchAttendanceHistory() async {
    try {
      final userId = _supabase.auth.currentUser!.id;
      final response = await _supabase
          .from('attendances')
          .select()
          .eq('user_id', userId)
          .order('check_in_time', ascending: false);

      return List<Map<String, dynamic>>.from(response);

    } catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Gagal memuat riwayat: $error'), backgroundColor: Colors.red),
        );
      }
      return [];
    }
  }

  String _calculateDuration(DateTime? checkIn, DateTime? checkOut) {
    if (checkIn == null || checkOut == null) {
      return '-';
    }
    final duration = checkOut.difference(checkIn);
    final hours = duration.inHours;
    final minutes = duration.inMinutes.remainder(60);
    return '${hours}j ${minutes}m';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Riwayat Absensi Saya'),
      ),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: _attendanceFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }
          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('Tidak ada riwayat absensi.'));
          }

          final records = snapshot.data!;

          return ListView.builder(
            padding: const EdgeInsets.all(8.0),
            itemCount: records.length,
            itemBuilder: (context, index) {
              final record = records[index];
              final checkInTime = record['check_in_time'] != null ? DateTime.parse(record['check_in_time']) : null;
              final checkOutTime = record['check_out_time'] != null ? DateTime.parse(record['check_out_time']) : null;

              final formattedDate = checkInTime != null ? DateFormat('EEEE, dd MMMM yyyy', 'id_ID').format(checkInTime) : 'Tanggal tidak valid';

              return Card(
                margin: const EdgeInsets.symmetric(vertical: 6.0, horizontal: 8.0),
                elevation: 3,
                child: ListTile(
                  contentPadding: const EdgeInsets.symmetric(vertical: 10.0, horizontal: 16.0),
                  leading: CircleAvatar(
                    backgroundColor: Theme.of(context).primaryColor,
                    foregroundColor: Colors.white,
                    child: Text(
                      checkInTime != null ? DateFormat('dd').format(checkInTime) : '!',
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                  title: Text(
                    formattedDate,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  subtitle: Padding(
                    padding: const EdgeInsets.only(top: 8.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        _buildTimeColumn('Check-in', checkInTime != null ? DateFormat('HH:mm').format(checkInTime) : '-'),
                        _buildTimeColumn('Check-out', checkOutTime != null ? DateFormat('HH:mm').format(checkOutTime) : '-'),
                        _buildTimeColumn('Durasi', _calculateDuration(checkInTime, checkOutTime), isDuration: true),
                      ],
                    ),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }

  Widget _buildTimeColumn(String label, String value, {bool isDuration = false}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(color: Colors.grey.shade600, fontSize: 12),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 14,
            color: isDuration ? Colors.purple : Colors.black87,
          ),
        ),
      ],
    );
  }
}