// lib/widgets/app_drawer.dart
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart'; // Import Supabase
import '../pages/login_page.dart';
// ... (import halaman lainnya)
import '../pages/dashboard_page.dart';
import '../pages/user_profile_page.dart';
import '../pages/attendance_page.dart';
import '../pages/user_management_page.dart';
import '../pages/workshop_page.dart';
import '../pages/schedule_page.dart';
import '../pages/warehouse_page.dart';
import '../pages/repair_reports_page.dart';
import '../pages/damage_reports_page.dart';
import '../pages/attendance_reports_page.dart';
import '../pages/settings_page.dart';
import '../pages/about_page.dart';


class AppDrawer extends StatelessWidget {
  const AppDrawer({super.key});

  void _navigateToPage(BuildContext context, String routeName, {bool replace = false, Object? arguments}) {
    if (Navigator.canPop(context)) {
      Navigator.pop(context);
    }

    final String? currentRouteName = ModalRoute.of(context)?.settings.name;

    if (currentRouteName != routeName) {
      if (replace) {
        Navigator.pushReplacementNamed(context, routeName, arguments: arguments);
      } else {
        Navigator.pushNamed(context, routeName, arguments: arguments);
      }
    }
  }


  @override
  Widget build(BuildContext context) {
    final String? currentRouteName = ModalRoute.of(context)?.settings.name;
    final user = ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;

    final String username = user?['username'] ?? 'Guest';
    final String email = user?['email'] ?? 'guest@example.com';

    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: <Widget>[
          UserAccountsDrawerHeader(
            accountName: Text(
              username,
              style: const TextStyle(
                color: Color(0xFFFFFFFF),
                fontWeight: FontWeight.bold,
              ),
            ),
            accountEmail: Text(
              email,
              style: const TextStyle(
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
            decoration: const BoxDecoration(
              color: Color(0xFF1976D2),
            ),
          ),
          // ... (semua ListTile lainnya tetap sama) ...
          ListTile(
            leading: const Icon(Icons.dashboard),
            title: const Text('Dashboard'),
            selected: currentRouteName == DashboardPage.routeName,
            onTap: () {
              _navigateToPage(context, DashboardPage.routeName, replace: true, arguments: user);
            },
          ),
          const _DrawerSectionHeader(title: 'USER'),
          ListTile(
            leading: const Icon(Icons.person_outline),
            title: const Text('User Profile'),
            selected: currentRouteName == UserProfilePage.routeName,
            onTap: () {
              _navigateToPage(context, UserProfilePage.routeName, replace: true, arguments: user);
            },
          ),
          ListTile(
            leading: const Icon(Icons.check_circle_outline),
            title: const Text('Attendance'),
            selected: currentRouteName == AttendancePage.routeName,
            onTap: () {
              _navigateToPage(context, AttendancePage.routeName, replace: true, arguments: user);
            },
          ),
          ListTile(
            leading: const Icon(Icons.manage_accounts_outlined),
            title: const Text('User Management'),
            selected: currentRouteName == UserManagementPage.routeName,
            onTap: () {
              _navigateToPage(context, UserManagementPage.routeName, replace: true, arguments: user);
            },
          ),
          const _DrawerSectionHeader(title: 'DATA'),
          ListTile(
            leading: const Icon(Icons.store_mall_directory),
            title: const Text('Workshop'),
            selected: currentRouteName == WorkshopPage.routeName,
            onTap: () {
              _navigateToPage(context, WorkshopPage.routeName, replace: true, arguments: user);
            },
          ),
          ListTile(
            leading: const Icon(Icons.schedule),
            title: const Text('Schedule'),
            selected: currentRouteName == SchedulePage.routeName,
            onTap: () {
              _navigateToPage(context, SchedulePage.routeName, replace: true, arguments: user);
            },
          ),
          ListTile(
            leading: const Icon(Icons.build_circle_outlined),
            title: const Text('Warehouse'),
            selected: currentRouteName == WarehousePage.routeName,
            onTap: () {
              _navigateToPage(context, WarehousePage.routeName, replace: true, arguments: user);
            },
          ),
          const _DrawerSectionHeader(title: 'REPORTS'),
          ListTile(
            leading: const Icon(Icons.receipt_long),
            title: const Text('Repair Reports'),
            selected: currentRouteName == RepairReportsPage.routeName,
            onTap: () {
              _navigateToPage(context, RepairReportsPage.routeName, replace: true, arguments: user);
            },
          ),
          ListTile(
            leading: const Icon(Icons.warning_amber_outlined),
            title: const Text('Damage Reports'),
            selected: currentRouteName == DamageReportsPage.routeName,
            onTap: () {
              _navigateToPage(context, DamageReportsPage.routeName, replace: true, arguments: user);
            },
          ),
          ListTile(
            leading: const Icon(Icons.event_note_outlined),
            title: const Text('Attendance Reports'),
            selected: currentRouteName == AttendanceReportsPage.routeName,
            onTap: () {
              _navigateToPage(context, AttendanceReportsPage.routeName, replace: true, arguments: user);
            },
          ),
          const _DrawerSectionHeader(title: 'SYSTEM'),
          ListTile(
            leading: const Icon(Icons.settings),
            title: const Text('Settings'),
            selected: currentRouteName == SettingsPage.routeName,
            onTap: () {
              _navigateToPage(context, SettingsPage.routeName, replace: true, arguments: user);
            },
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.info_outline),
            title: const Text('About'),
            selected: currentRouteName == AboutPage.routeName,
            onTap: () {
              _navigateToPage(context, AboutPage.routeName, replace: true, arguments: user);
            },
          ),

          const Divider(),
          ListTile(
            leading: const Icon(Icons.logout),
            title: const Text('Logout'),
            //===[PERUBAHAN: Menambahkan sign out dan mengubah onTap menjadi async]==
            onTap: () async {
              await Supabase.instance.client.auth.signOut();
              _navigateToPage(context, LoginPage.routeName, replace: true);
            },
          ),
        ],
      ),
    );
  }
}

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
          color: Colors.grey.shade600,
        ),
      ),
    );
  }
}