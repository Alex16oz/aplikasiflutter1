import 'package:flutter/material.dart';
import '../widgets/app_drawer.dart'; // Import the AppDrawer
import 'package:intl/intl.dart';
import './user_attendance_history_page.dart'; // <-- IMPORT HALAMAN BARU

class AttendancePage extends StatefulWidget {
  const AttendancePage({super.key});

  static const String routeName = '/attendance';

  @override
  State<AttendancePage> createState() => _AttendancePageState();
}

class _AttendancePageState extends State<AttendancePage> {
  // Status absensi saat ini ('in' atau 'out')
  String _attendanceStatus = 'out'; // Default status
  DateTime? _checkInTime;
  DateTime? _checkOutTime;

  // Handler untuk tombol Check-in / Check-out
  void _toggleAttendance() {
    setState(() {
      if (_attendanceStatus == 'out') {
        _attendanceStatus = 'in';
        _checkInTime = DateTime.now();
        _checkOutTime = null; // Reset checkout time
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
                'Anda berhasil check-in pada pukul ${DateFormat('HH:mm:ss').format(_checkInTime!)}'),
            backgroundColor: Colors.green,
          ),
        );
      } else {
        _attendanceStatus = 'out';
        _checkOutTime = DateTime.now();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
                'Anda berhasil check-out pada pukul ${DateFormat('HH:mm:ss').format(_checkOutTime!)}'),
            backgroundColor: Colors.orange,
          ),
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Absensi Kehadiran'),
      ),
      drawer: const AppDrawer(),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // --- KARTU UTAMA UNTUK AKSI ABSENSI ---
            _buildAttendanceActionCard(),

            const SizedBox(height: 24),

            // --- JUDUL BAGIAN RIWAYAT ---
            const Text(
              'Aktivitas Hari Ini',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const Divider(height: 16),

            // --- KARTU INFORMASI CHECK-IN & CHECK-OUT ---
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

            // --- TOMBOL BARU UNTUK MELIHAT RIWAYAT ---
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
            // --- AKHIR TOMBOL BARU ---

            const SizedBox(height: 24),

            // --- JUDUL BAGIAN TUGAS ---
            const Text(
              'Alokasi Jam Kerja (Tugas)',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const Divider(height: 16),

            // --- DAFTAR TUGAS YANG DIALOKASIKAN ---
            _buildTaskCard(
                machineName: 'Excavator EX-01',
                taskDescription: 'Perawatan rutin bulanan: ganti oli dan filter',
                scheduleTime: '09:00 - 11:00',
                isCompleted: true
            ),
            _buildTaskCard(
                machineName: 'Dump Truck DT-05',
                taskDescription: 'Pemeriksaan sistem hidrolik',
                scheduleTime: '13:00 - 14:30',
                isCompleted: false
            ),
          ],
        ),
      ),
    );
  }

  // ... (Sisa widget lainnya tidak berubah) ...
  // Widget untuk kartu aksi utama (Tombol Check-in/out)
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
                color:
                _attendanceStatus == 'in' ? Colors.green : Colors.orange,
              ),
            ),
            const SizedBox(height: 20),
            StreamBuilder(
              stream: Stream.periodic(const Duration(seconds: 1)),
              builder: (context, snapshot) {
                return Text(
                  DateFormat('EEEE, dd MMMM yyyy | HH:mm:ss', 'id_ID')
                      .format(DateTime.now()),
                  style: const TextStyle(fontSize: 16),
                );
              },
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: _toggleAttendance,
              icon: Icon(
                  _attendanceStatus == 'out' ? Icons.login : Icons.logout),
              label: Text(
                _attendanceStatus == 'out' ? 'Check-in Sekarang' : 'Check-out Sekarang',
                style: const TextStyle(fontSize: 18),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: _attendanceStatus == 'out'
                    ? Theme.of(context).primaryColor
                    : Colors.red,
                foregroundColor: Colors.white,
                padding:
                const EdgeInsets.symmetric(horizontal: 40, vertical: 15),
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

  // Widget untuk kartu informasi waktu
  Widget _buildTimeInfoCard({
    required String title,
    required DateTime? time,
    required IconData icon,
    required Color color,
  }) {
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

  // Widget untuk menampilkan durasi kerja
  Widget _buildDurationCard() {
    String durationText = '00:00:00';
    if (_checkInTime != null) {
      DateTime endTime = _checkOutTime ?? DateTime.now();
      Duration duration = endTime.difference(_checkInTime!);

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

  // Widget untuk menampilkan kartu tugas
  Widget _buildTaskCard({
    required String machineName,
    required String taskDescription,
    required String scheduleTime,
    required bool isCompleted,
  }) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12.0),
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(machineName, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            const Divider(),
            Text(taskDescription),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Jadwal: $scheduleTime', style: TextStyle(color: Colors.grey.shade700)),
                Chip(
                  label: Text(isCompleted ? 'Selesai' : 'Berjalan'),
                  backgroundColor: isCompleted ? Colors.green.shade100 : Colors.blue.shade100,
                  avatar: isCompleted ? const Icon(Icons.check_circle, color: Colors.green) : const Icon(Icons.hourglass_top, color: Colors.blue),
                )
              ],
            )
          ],
        ),
      ),
    );
  }
}