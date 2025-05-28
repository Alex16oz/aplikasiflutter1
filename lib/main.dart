import 'package:flutter/material.dart';

// Import your new page files
import 'pages/dashboard_page.dart';
import 'pages/user_profile_page.dart';
import 'pages/attendance_page.dart';
import 'pages/warehouse_page.dart';
import 'pages/schedule_page.dart';
import 'pages/spareparts_page.dart';
import 'pages/repair_reports_page.dart';
import 'pages/damage_reports_page.dart';
import 'pages/attendance_reports_page.dart';
import 'pages/settings_page.dart';
import 'pages/about_page.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter AppBar Demo',
      theme: ThemeData(
        primaryColor: const Color(0xFF1EF1C9),
      ),
      home: const SimplePageWithAppBar(),
      // You can also define routes here for more complex navigation
      // routes: {
      //   '/dashboard': (context) => const DashboardPage(),
      //   '/userProfile': (context) => const UserProfilePage(),
      //   // ... other routes
      // },
    );
  }
}

class SimplePageWithAppBar extends StatelessWidget {
  const SimplePageWithAppBar({super.key});

  // Helper method to navigate
  void _navigateToPage(BuildContext context, Widget page) {
    Navigator.pop(context); // Close the drawer
    Navigator.push(context, MaterialPageRoute(builder: (context) => page));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Simple Page'),
        backgroundColor: const Color(0xFF1EF1C9),
        elevation: 8.0,
        centerTitle: true,
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: <Widget>[
            UserAccountsDrawerHeader(
              accountName: const Text(
                'John Doe',
                style: TextStyle(
                  color: Color(0xFFFFFFFF),
                  fontWeight: FontWeight.bold,
                ),
              ),
              accountEmail: const Text(
                'john.doe@example.com',
                style: TextStyle(
                  color: Color(0xB3FFFFFF),
                ),
              ),
              currentAccountPicture: CircleAvatar(
                backgroundColor: const Color(0xFFFFFFFF),
                child: Icon(
                  Icons.person,
                  size: 50.0,
                  color: const Color(0xFF1976D2),
                ),
              ),
              decoration: BoxDecoration(
                color: const Color(0xFF1976D2),
              ),
            ),
            ListTile(
              leading: const Icon(Icons.dashboard),
              title: const Text('Dashboard'),
              onTap: () {
                _navigateToPage(context, const DashboardPage());
              },
            ),
            // Separator for User
            const Padding(
              padding: EdgeInsets.only(left: 16.0, top: 10.0, bottom: 5.0),
              child: Text(
                'USER',
                style: TextStyle(
                  fontSize: 12.0,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey,
                ),
              ),
            ),
            ListTile(
              leading: const Icon(Icons.person_outline),
              title: const Text('User Profile'),
              onTap: () {
                _navigateToPage(context, const UserProfilePage());
              },
            ),
            ListTile(
              leading: const Icon(Icons.check_circle_outline),
              title: const Text('Attendance'),
              onTap: () {
                _navigateToPage(context, const AttendancePage());
              },
            ),
            // Separator for Data
            const Padding(
              padding: EdgeInsets.only(left: 16.0, top: 10.0, bottom: 5.0),
              child: Text(
                'DATA',
                style: TextStyle(
                  fontSize: 12.0,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey,
                ),
              ),
            ),
            ListTile(
              leading: const Icon(Icons.store_mall_directory),
              title: const Text('Warehouse'),
              onTap: () {
                _navigateToPage(context, const WarehousePage());
              },
            ),
            ListTile(
              leading: const Icon(Icons.schedule),
              title: const Text('Schedule'),
              onTap: () {
                _navigateToPage(context, const SchedulePage());
              },
            ),
            ListTile(
              leading: const Icon(Icons.build_circle_outlined),
              title: const Text('Spareparts'),
              onTap: () {
                _navigateToPage(context, const SparepartsPage());
              },
            ),
            // Separator for Reports
            const Padding(
              padding: EdgeInsets.only(left: 16.0, top: 10.0, bottom: 5.0),
              child: Text(
                'REPORTS',
                style: TextStyle(
                  fontSize: 12.0,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey,
                ),
              ),
            ),
            ListTile(
              leading: const Icon(Icons.receipt_long),
              title: const Text('Repair Reports'),
              onTap: () {
                _navigateToPage(context, const RepairReportsPage());
              },
            ),
            ListTile(
              leading: const Icon(Icons.warning_amber_outlined),
              title: const Text('Damage Reports'),
              onTap: () {
                _navigateToPage(context, const DamageReportsPage());
              },
            ),
            ListTile(
              leading: const Icon(Icons.event_note_outlined),
              title: const Text('Attendance Reports'),
              onTap: () {
                _navigateToPage(context, const AttendanceReportsPage());
              },
            ),
            // Separator for System
            const Padding(
              padding: EdgeInsets.only(left: 16.0, top: 10.0, bottom: 5.0),
              child: Text(
                'SYSTEM',
                style: TextStyle(
                  fontSize: 12.0,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey,
                ),
              ),
            ),
            ListTile(
              leading: const Icon(Icons.settings),
              title: const Text('Settings'),
              onTap: () {
                _navigateToPage(context, const SettingsPage());
              },
            ),
            ListTile(
              leading: const Icon(Icons.info_outline),
              title: const Text('About'),
              onTap: () {
                _navigateToPage(context, const AboutPage());
              },
            ),
          ],
        ),
      ),
      body: const Center(
        child: Text(
          'Swipe right or tap the icon to open the drawer!',
          style: TextStyle(fontSize: 18.0),
        ),
      ),
    );
  }
}