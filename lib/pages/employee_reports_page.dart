// lib/pages/employee_reports_page.dart
import 'package:flutter/material.dart';
import 'package:testflut1/pages/assignment_report_page.dart';
import 'package:testflut1/pages/attendance_recap_report_page.dart';
import 'package:testflut1/pages/productivity_report_page.dart';

class EmployeeReportsPage extends StatelessWidget {
  const EmployeeReportsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Laporan Kepegawaian'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          _buildReportCard(
            context,
            title: 'Laporan Rekap Kehadiran',
            subtitle: 'Rekapitulasi kehadiran seluruh pegawai dalam periode.',
            icon: Icons.co_present_outlined,
            onTap: () {
              Navigator.push(context, MaterialPageRoute(builder: (context) => const AttendanceRecapReportPage()));
            },
          ),
          _buildReportCard(
            context,
            title: 'Laporan Produktivitas',
            subtitle: 'Jumlah tugas selesai dan total jam kerja per pegawai.',
            icon: Icons.trending_up_outlined,
            onTap: () {
              Navigator.push(context, MaterialPageRoute(builder: (context) => const ProductivityReportPage()));
            },
          ),
          _buildReportCard(
            context,
            title: 'Laporan Penugasan',
            subtitle: 'Analisis distribusi dan beban kerja tugas.',
            icon: Icons.assignment_ind_outlined,
            onTap: () {
              Navigator.push(context, MaterialPageRoute(builder: (context) => const AssignmentReportPage()));
            },
          ),
        ],
      ),
    );
  }

  Widget _buildReportCard(BuildContext context, {
    required String title,
    required String subtitle,
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return Card(
      elevation: 3,
      child: ListTile(
        leading: Icon(icon, size: 40, color: Theme.of(context).primaryColor),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text(subtitle),
        trailing: const Icon(Icons.arrow_forward_ios),
        onTap: onTap,
      ),
    );
  }
}