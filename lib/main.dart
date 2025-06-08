// lib/main.dart
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

// Import all page files for route definitions
import 'pages/login_page.dart'; // <-- IMPORT NEW LOGIN PAGE
import 'pages/dashboard_page.dart';
import 'pages/user_profile_page.dart';
import 'pages/attendance_page.dart';
import 'pages/user_management_page.dart';
import 'pages/warehouse_page.dart';
import 'pages/schedule_page.dart';
import 'pages/spareparts_page.dart';
import 'pages/repair_reports_page.dart';
import 'pages/damage_reports_page.dart';
import 'pages/attendance_reports_page.dart';
import 'pages/settings_page.dart';
import 'pages/about_page.dart';



Future<void> main() async {
  await Supabase.initialize(
    url: 'https://sgnavqdkkglhesglhrdi.supabase.co',
    anonKey: 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InNnbmF2cWRra2dsaGVzZ2xocmRpIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NDg0ODcyMzEsImV4cCI6MjA2NDA2MzIzMX0.nRQXlWwf-9CRjQVsff45aShM1_-WAqY1DZ0ND8r_i04',
  );
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter App Demo',
      theme: ThemeData(
        primaryColor: const Color(0xFF1EF1C9), // Your theme color
        appBarTheme: const AppBarTheme( // Consistent AppBar styling
          backgroundColor: Color(0xFF1EF1C9),
          foregroundColor: Colors.black, // Color for title text and icons in AppBar
          elevation: 8.0,
          centerTitle: true,
          titleTextStyle: TextStyle(
            color: Colors.black, // Explicitly set title text color
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        // If you want to use Material 3 features and theming:
        // colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF1EF1C9)),
        // useMaterial3: true,
      ),
      // Define the initial route
      initialRoute: LoginPage.routeName, // <-- SET LOGIN PAGE AS INITIAL
      // Define all named routes
      routes: {
        LoginPage.routeName: (context) => const LoginPage(), // <-- ADD LOGIN ROUTE
        DashboardPage.routeName: (context) => const DashboardPage(),
        UserProfilePage.routeName: (context) => const UserProfilePage(),
        AttendancePage.routeName: (context) => const AttendancePage(),
        UserManagementPage.routeName: (context) => const UserManagementPage(),
        WarehousePage.routeName: (context) => const WarehousePage(),
        SchedulePage.routeName: (context) => const SchedulePage(),
        SparepartsPage.routeName: (context) => const SparepartsPage(),
        RepairReportsPage.routeName: (context) => const RepairReportsPage(),
        DamageReportsPage.routeName: (context) => const DamageReportsPage(),
        AttendanceReportsPage.routeName: (context) => const AttendanceReportsPage(),
        SettingsPage.routeName: (context) => const SettingsPage(),
        AboutPage.routeName: (context) => const AboutPage(),
      },
      debugShowCheckedModeBanner: false, // Optional: removes the debug banner
    );
  }
}