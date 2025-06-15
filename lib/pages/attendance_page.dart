// lib/pages/attendance_page.dart

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../widgets/app_drawer.dart';
import './user_attendance_history_page.dart';

class AttendancePage extends StatefulWidget {
  const AttendancePage({super.key});

  static const String routeName = '/attendance';

  @override
  State<AttendancePage> createState() => _AttendancePageState();
}

class _AttendancePageState extends State<AttendancePage> {
  final _supabase = Supabase.instance.client;
  bool _isLoading = true;
  String? _attendanceStatus; // 'in', 'out', atau null jika loading
  DateTime? _checkInTime;
  DateTime? _checkOutTime;
  int? _currentAttendanceId;

  @override
  void initState() {
    super.initState();
    _fetchLatestAttendance();
  }

  Future<void> _fetchLatestAttendance() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final userId = _supabase.auth.currentUser!.id;
      final response = await _supabase
          .from('attendances')
          .select()
          .eq('user_id', userId)
          .order('check_in_time', ascending: false)
          .limit(1)
          .single();

      if (mounted && response != null) {
        final checkIn = response['check_in_time'] != null
            ? DateTime.parse(response['check_in_time'])
            : null;
        final checkOut = response['check_out_time'] != null
            ? DateTime.parse(response['check_out_time'])
            : null;

        setState(() {
          _checkInTime = checkIn;
          _checkOutTime = checkOut;
          _currentAttendanceId = response['id'];
          // Jika sudah check-in tapi belum check-out
          if (checkIn != null && checkOut == null) {
            _attendanceStatus = 'in';
          } else {
            _attendanceStatus = 'out';
          }
        });
      } else {
        setState(() {
          _attendanceStatus = 'out'; // Default jika tidak ada data
        });
      }
    } catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Gagal memuat status absensi: $error'), backgroundColor: Colors.red),
        );
        setState(() {
          _attendanceStatus = 'out'; // Fallback jika terjadi error
        });
      }
    } finally {
      if(mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _toggleAttendance() async {
    setState(() { _isLoading = true; });

    try {
      final userId = _supabase.auth.currentUser!.id;
      final now = DateTime.now();

      if (_attendanceStatus == 'out') {
        // --- PROSES CHECK-IN ---
        final response = await _supabase.from('attendances').insert({
          'user_id': userId,
          'check_in_time': now.toIso8601String(),
        }).select().single();

        setState(() {
          _attendanceStatus = 'in';
          _checkInTime = now;
          _checkOutTime = null;
          _currentAttendanceId = response['id'];
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Anda berhasil check-in pada pukul ${DateFormat('HH:mm:ss').format(now)}'),
              backgroundColor: Colors.green,
            ),
          );
        });

      } else {
        // --- PROSES CHECK-OUT ---
        await _supabase.from('attendances').update({
          'check_out_time': now.toIso8601String(),
        }).eq('id', _currentAttendanceId!);

        setState(() {
          _attendanceStatus = 'out';
          _checkOutTime = now;
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Anda berhasil check-out pada pukul ${DateFormat('HH:mm:ss').format(now)}'),
              backgroundColor: Colors.orange,
            ),
          );
        });
      }
    } catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Terjadi kesalahan: $error'), backgroundColor: Colors.red),
        );
      }
    } finally {
      if(mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Absensi Kehadiran'),
      ),
      drawer: const AppDrawer(),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _buildAttendanceActionCard(),
            const SizedBox(height: 24),
            const Text(
              'Aktivitas Hari Ini',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const Divider(height: 16),
            _buildTimeInfoCard(
              title: 'Waktu Check-in',
              time: _checkInTime,
              icon: Icons.login,
              color: Colors.blue.shade700,
            ),
            const SizedBox(height: 12),
            _buildTimeInfoCard(
              title: 'Waktu Check-out',
              time: _checkOutTime,
              icon: Icons.logout,
              color: Colors.red.shade700,
            ),
            const SizedBox(height: 12),
            _buildDurationCard(),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: () {
                Navigator.of(context).pushNamed(UserAttendanceHistoryPage.routeName);
              },
              icon: const Icon(Icons.history),
              label: const Text('Lihat Riwayat Absensi Saya'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
                foregroundColor: Theme.of(context).primaryColor,
                side: BorderSide(color: Theme.of(context).primaryColor),
                padding: const EdgeInsets.symmetric(vertical: 12),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAttendanceActionCard() {
    return Card(
      elevation: 5,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            Text(
              'Status Saat Ini',
              style: TextStyle(fontSize: 16, color: Colors.grey.shade600),
            ),
            const SizedBox(height: 8),
            Text(
              _attendanceStatus == 'in' ? 'ANDA SUDAH MASUK' : 'ANDA DI LUAR',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: _attendanceStatus == 'in' ? Colors.green : Colors.orange,
              ),
            ),
            const SizedBox(height: 20),
            StreamBuilder(
              stream: Stream.periodic(const Duration(seconds: 1)),
              builder: (context, snapshot) {
                return Text(
                  DateFormat('EEEE, dd MMMM yyyy | HH:mm:ss', 'id_ID').format(DateTime.now()),
                  style: const TextStyle(fontSize: 16),
                );
              },
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: _isLoading ? null : _toggleAttendance,
              icon: Icon(_attendanceStatus == 'out' ? Icons.login : Icons.logout),
              label: Text(
                _attendanceStatus == 'out' ? 'Check-in Sekarang' : 'Check-out Sekarang',
                style: const TextStyle(fontSize: 18),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: _attendanceStatus == 'out' ? Theme.of(context).primaryColor : Colors.red,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 15),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTimeInfoCard({ required String title, required DateTime? time, required IconData icon, required Color color }) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      child: ListTile(
        leading: Icon(icon, color: color, size: 30),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.w600)),
        subtitle: Text(
          time != null ? DateFormat('HH:mm:ss').format(time) : 'Belum tercatat',
          style: const TextStyle(fontSize: 16),
        ),
      ),
    );
  }

  Widget _buildDurationCard() {
    String durationText = '00:00:00';
    if (_checkInTime != null) {
      DateTime endTime = _checkOutTime ?? DateTime.now();
      Duration duration = endTime.difference(_checkInTime!);

      if (duration.isNegative) {
        duration = Duration.zero;
      }

      String twoDigits(int n) => n.toString().padLeft(2, '0');
      String twoDigitMinutes = twoDigits(duration.inMinutes.remainder(60));
      String twoDigitSeconds = twoDigits(duration.inSeconds.remainder(60));
      durationText = "${twoDigits(duration.inHours)}:$twoDigitMinutes:$twoDigitSeconds";
    }

    return Card(
      elevation: 2,
      child: ListTile(
        leading: Icon(Icons.timer_outlined, color: Colors.purple.shade700, size: 30),
        title: const Text('Total Durasi Kerja', style: TextStyle(fontWeight: FontWeight.w600)),
        subtitle: Text(
          durationText,
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }
}