import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class UserAttendanceHistoryPage extends StatelessWidget {
  const UserAttendanceHistoryPage({super.key});

  static const String routeName = '/user-attendance-history';

  // Contoh data rekap absensi.
  // Dalam aplikasi nyata, data ini akan diambil dari database.
  final List<Map<String, dynamic>> _attendanceData = const [
    {'date': '2025-06-01', 'check_in': '08:05', 'check_out': '17:03', 'duration': '8j 58m'},
    {'date': '2025-06-02', 'check_in': '07:58', 'check_out': '17:01', 'duration': '9j 3m'},
    {'date': '2025-06-03', 'check_in': '08:10', 'check_out': '17:05', 'duration': '8j 55m'},
    {'date': '2025-06-04', 'check_in': '08:00', 'check_out': '17:15', 'duration': '9j 15m'},
    {'date': '2025-06-05', 'check_in': '07:55', 'check_out': '16:50', 'duration': '8j 55m'},
  ];


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Riwayat Absensi Saya'),
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(8.0),
        itemCount: _attendanceData.length,
        itemBuilder: (context, index) {
          final record = _attendanceData[index];
          final date = DateTime.parse(record['date']);
          final formattedDate = DateFormat('EEEE, dd MMMM yyyy', 'id_ID').format(date);

          return Card(
            margin: const EdgeInsets.symmetric(vertical: 6.0, horizontal: 8.0),
            elevation: 3,
            child: ListTile(
              contentPadding: const EdgeInsets.symmetric(vertical: 10.0, horizontal: 16.0),
              leading: CircleAvatar(
                backgroundColor: Theme.of(context).primaryColor,
                foregroundColor: Colors.white,
                child: Text(
                  DateFormat('dd').format(date),
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
                    _buildTimeColumn('Check-in', record['check_in']),
                    _buildTimeColumn('Check-out', record['check_out']),
                    _buildTimeColumn('Durasi', record['duration'], isDuration: true),
                  ],
                ),
              ),
            ),
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