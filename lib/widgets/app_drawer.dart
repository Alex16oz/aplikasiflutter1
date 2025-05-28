// lib/widgets/app_drawer.dart
import 'package:flutter/material.dart';

// Import all your page files
import '../pages/dashboard_page.dart';
import '../pages/user_profile_page.dart';
import '../pages/attendance_page.dart';
import '../pages/warehouse_page.dart';
import '../pages/schedule_page.dart';
import '../pages/spareparts_page.dart';
import '../pages/repair_reports_page.dart';
import '../pages/damage_reports_page.dart';
import '../pages/attendance_reports_page.dart';
import '../pages/settings_page.dart';
import '../pages/about_page.dart';

class AppDrawer extends StatelessWidget {
  const AppDrawer({super.key});

  // Helper method to navigate
  void _navigateToPage(BuildContext context, Widget page) {
    Navigator.pop(context); // Close the drawer

    // Check if the current route is the same as the page we want to navigate to
    // This prevents pushing the same page multiple times onto the stack
    // Note: This is a simple check. For more complex scenarios, you might need a more robust solution.
    if (ModalRoute.of(context)?.settings.name != page.toStringShort()) {
      Navigator.pushReplacement( // Use pushReplacement to avoid building up the stack
        context,
        MaterialPageRoute(
          builder: (context) => page,
          settings: RouteSettings(name: page.toStringShort()), // Set route name for checking
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    // Determine the current route to highlight the active item
    final String? currentRouteName = ModalRoute.of(context)?.settings.name;

    return Drawer(
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
                color: Color(0xB3FFFFFF), // White with 70% opacity
              ),
            ),
            currentAccountPicture: CircleAvatar(
              backgroundColor: const Color(0xFFFFFFFF), // White background
              child: Icon(
                Icons.person,
                size: 50.0,
                color: const Color(0xFF1976D2), // Medium blue icon
              ),
            ),
            decoration: BoxDecoration(
              color: const Color(0xFF1976D2), // Medium blue header background
            ),
          ),
          ListTile(
            leading: const Icon(Icons.dashboard),
            title: const Text('Dashboard'),
            selected: currentRouteName == const DashboardPage().toStringShort(),
            onTap: () {
              _navigateToPage(context, const DashboardPage());
            },
          ),
          // Separator for User
          const _DrawerSectionHeader(title: 'USER'),
          ListTile(
            leading: const Icon(Icons.person_outline),
            title: const Text('User Profile'),
            selected: currentRouteName == const UserProfilePage().toStringShort(),
            onTap: () {
              _navigateToPage(context, const UserProfilePage());
            },
          ),
          ListTile(
            leading: const Icon(Icons.check_circle_outline),
            title: const Text('Attendance'),
            selected: currentRouteName == const AttendancePage().toStringShort(),
            onTap: () {
              _navigateToPage(context, const AttendancePage());
            },
          ),
          // Separator for Data
          const _DrawerSectionHeader(title: 'DATA'),
          ListTile(
            leading: const Icon(Icons.store_mall_directory),
            title: const Text('Warehouse'),
            selected: currentRouteName == const WarehousePage().toStringShort(),
            onTap: () {
              _navigateToPage(context, const WarehousePage());
            },
          ),
          ListTile(
            leading: const Icon(Icons.schedule),
            title: const Text('Schedule'),
            selected: currentRouteName == const SchedulePage().toStringShort(),
            onTap: () {
              _navigateToPage(context, const SchedulePage());
            },
          ),
          ListTile(
            leading: const Icon(Icons.build_circle_outlined),
            title: const Text('Spareparts'),
            selected: currentRouteName == const SparepartsPage().toStringShort(),
            onTap: () {
              _navigateToPage(context, const SparepartsPage());
            },
          ),
          // Separator for Reports
          const _DrawerSectionHeader(title: 'REPORTS'),
          ListTile(
            leading: const Icon(Icons.receipt_long),
            title: const Text('Repair Reports'),
            selected: currentRouteName == const RepairReportsPage().toStringShort(),
            onTap: () {
              _navigateToPage(context, const RepairReportsPage());
            },
          ),
          ListTile(
            leading: const Icon(Icons.warning_amber_outlined),
            title: const Text('Damage Reports'),
            selected: currentRouteName == const DamageReportsPage().toStringShort(),
            onTap: () {
              _navigateToPage(context, const DamageReportsPage());
            },
          ),
          ListTile(
            leading: const Icon(Icons.event_note_outlined),
            title: const Text('Attendance Reports'),
            selected: currentRouteName == const AttendanceReportsPage().toStringShort(),
            onTap: () {
              _navigateToPage(context, const AttendanceReportsPage());
            },
          ),
          // Separator for System
          const _DrawerSectionHeader(title: 'SYSTEM'),
          ListTile(
            leading: const Icon(Icons.settings),
            title: const Text('Settings'),
            selected: currentRouteName == const SettingsPage().toStringShort(),
            onTap: () {
              _navigateToPage(context, const SettingsPage());
            },
          ),
          const Divider(), // Visual separator before About
          ListTile(
            leading: const Icon(Icons.info_outline),
            title: const Text('About'),
            selected: currentRouteName == const AboutPage().toStringShort(),
            onTap: () {
              _navigateToPage(context, const AboutPage());
            },
          ),
        ],
      ),
    );
  }
}

// Helper widget for section headers in the drawer
class _DrawerSectionHeader extends StatelessWidget {
  final String title;
  const _DrawerSectionHeader({required this.title});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 16.0, top: 16.0, bottom: 8.0),
      child: Text(
        title,
        style: TextStyle(
          fontSize: 12.0,
          fontWeight: FontWeight.bold,
          color: Colors.grey.shade600, // A bit darker grey
        ),
      ),
    );
  }
}
