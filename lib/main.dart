// lib/main.dart
import 'package:flutter/material.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
// Import semua halaman yang dibutuhkan
import 'pages/login_page.dart';
import 'pages/dashboard_page.dart';
import 'pages/user_profile_page.dart';
import 'pages/attendance_page.dart';
import 'pages/user_management_page.dart';
import 'pages/workshop_page.dart';
import 'pages/schedule_page.dart';
import 'pages/warehouse_page.dart';
import 'pages/repair_reports_page.dart';
import 'pages/damage_reports_page.dart';
import 'pages/attendance_reports_page.dart';
import 'pages/settings_page.dart';
import 'pages/about_page.dart';
import 'pages/user_attendance_history_page.dart';
import 'pages/my_tasks_page.dart';
import 'pages/work_log_approval_page.dart';
import 'pages/reports_hub_page.dart'; // Impor baru

// Fungsi utama yang dijalankan pertama kali
Future<void> main() async {
  // Memastikan semua komponen Flutter siap sebelum aplikasi berjalan
  WidgetsFlutterBinding.ensureInitialized();

  // Menginisialisasi data format tanggal untuk Bahasa Indonesia ('id_ID')
  await initializeDateFormatting('id_ID', null);

  // Menginisialisasi koneksi ke Supabase
  await Supabase.initialize(
    url: 'https://sgnavqdkkglhesglhrdi.supabase.co',
    anonKey: 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InNnbmF2cWRra2dsaGVzZ2xocmRpIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NDg0ODcyMzEsImV4cCI6MjA2NDA2MzIzMX0.nRQXlWwf-9CRjQVsff45aShM1_-WAqY1DZ0ND8r_i04',
  );

  // Menjalankan aplikasi
  runApp(const MyApp());
}

// Widget utama aplikasi
class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Aplikasi Manajemen Workshop',
      theme: ThemeData(
        primaryColor: const Color(0xFF1EF1C9),
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFF1EF1C9),
          foregroundColor: Colors.black,
          elevation: 8.0,
          centerTitle: true,
          titleTextStyle: TextStyle(
            color: Colors.black,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      // Halaman pertama yang dibuka saat aplikasi dijalankan
      initialRoute: LoginPage.routeName,
      // Daftar semua halaman yang bisa diakses melalui navigasi nama
      routes: {
        LoginPage.routeName: (context) => const LoginPage(),
        DashboardPage.routeName: (context) => const DashboardPage(),
        UserProfilePage.routeName: (context) => const UserProfilePage(),
        AttendancePage.routeName: (context) => const AttendancePage(),
        UserManagementPage.routeName: (context) => const UserManagementPage(),
        WorkshopPage.routeName: (context) => const WorkshopPage(),
        SchedulePage.routeName: (context) => const SchedulePage(),
        WarehousePage.routeName: (context) => const WarehousePage(),
        RepairReportsPage.routeName: (context) => const RepairReportsPage(),
        DamageReportsPage.routeName: (context) => const DamageReportsPage(),
        AttendanceReportsPage.routeName: (context) => const AttendanceReportsPage(),
        SettingsPage.routeName: (context) => const SettingsPage(),
        AboutPage.routeName: (context) => const AboutPage(),
        UserAttendanceHistoryPage.routeName: (context) => const UserAttendanceHistoryPage(),
        MyTasksPage.routeName: (context) => const MyTasksPage(),
        WorkLogApprovalPage.routeName: (context) => const WorkLogApprovalPage(),
        ReportsHubPage.routeName: (context) => const ReportsHubPage(),
      },
      // Menghilangkan banner debug di pojok kanan atas
      debugShowCheckedModeBanner: false,
    );
  }
}