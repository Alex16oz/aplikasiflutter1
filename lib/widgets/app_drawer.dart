// lib/widgets/app_drawer.dart
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../pages/login_page.dart';
import '../pages/dashboard_page.dart';
import '../pages/user_profile_page.dart';
import '../pages/attendance_page.dart';
import '../pages/user_management_page.dart';
import '../pages/workshop_page.dart';
import '../pages/schedule_page.dart';
import '../pages/warehouse_page.dart';
import '../pages/reports_hub_page.dart';
import '../pages/settings_page.dart';
import '../pages/about_page.dart';
import '../pages/my_tasks_page.dart';
import '../pages/work_log_approval_page.dart';
import '../pages/maintenance_templates_page.dart';

class AppDrawer extends StatelessWidget {
  const AppDrawer({super.key});

  void _navigateToPage(BuildContext context, String routeName, {bool replace = false, Object? arguments}) {
    if (!context.mounted) return;

    // Tutup drawer jika terbuka
    if (Navigator.canPop(context)) {
      Navigator.pop(context);
    }

    final String? currentRouteName = ModalRoute.of(context)?.settings.name;

    // Hanya navigasi jika halaman tujuan berbeda dengan halaman saat ini
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

    final routeArgs = ModalRoute.of(context)?.settings.arguments;
    Map<String, dynamic>? user;

    if (routeArgs is Map) {
      user = Map<String, dynamic>.from(
          routeArgs.map((key, value) => MapEntry(key.toString(), value))
      );
    }

    final String username = user?['username'] ?? 'Tamu';
    final String email = user?['email'] ?? 'tamu@example.com';
    final String userRole = user?['role'] ?? '';

    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: <Widget>[
          UserAccountsDrawerHeader(
            accountName: Text(
              username,
              style: const TextStyle(color: Color(0xFFFFFFFF), fontWeight: FontWeight.bold),
            ),
            accountEmail: Text(
              email,
              style: const TextStyle(color: Color(0xB3FFFFFF)),
            ),
            currentAccountPicture: CircleAvatar(
              backgroundColor: const Color(0xFFFFFFFF),
              child: Icon(Icons.person, size: 50.0, color: Theme.of(context).primaryColor),
            ),
            decoration: BoxDecoration(color: Theme.of(context).primaryColor),
          ),
          ListTile(
            leading: const Icon(Icons.dashboard_outlined),
            title: const Text('Dasbor'),
            selected: currentRouteName == DashboardPage.routeName,
            onTap: () => _navigateToPage(context, DashboardPage.routeName, replace: true, arguments: user),
          ),

          if (userRole == 'Operator') ...[
            const _DrawerSectionHeader(title: 'PEKERJAAN'),
            ListTile(
              leading: const Icon(Icons.checklist_rtl),
              title: const Text('Tugas Saya'),
              selected: currentRouteName == MyTasksPage.routeName,
              onTap: () => _navigateToPage(context, MyTasksPage.routeName, replace: true, arguments: user),
            ),
          ],

          if (userRole == 'Admin') ...[
            const _DrawerSectionHeader(title: 'MANAJEMEN PEGAWAI'),
            ListTile(
              leading: const Icon(Icons.approval_outlined),
              title: const Text('Persetujuan Kerja'),
              selected: currentRouteName == WorkLogApprovalPage.routeName,
              onTap: () => _navigateToPage(context, WorkLogApprovalPage.routeName, replace: true, arguments: user),
            ),
          ],

          const _DrawerSectionHeader(title: 'PENGGUNA'),
          ListTile(
            leading: const Icon(Icons.person_outline),
            title: const Text('Profil Pengguna'),
            selected: currentRouteName == UserProfilePage.routeName,
            onTap: () => _navigateToPage(context, UserProfilePage.routeName, replace: true, arguments: user),
          ),

          // Tambahkan kondisi 'if' di sini untuk menyembunyikan Absensi dari Admin
          if (userRole != 'Admin') ...[
            ListTile(
              leading: const Icon(Icons.check_circle_outline),
              title: const Text('Absensi'),
              selected: currentRouteName == AttendancePage.routeName,
              onTap: () => _navigateToPage(context, AttendancePage.routeName, replace: true, arguments: user),
            ),
          ],

          if (userRole == 'Admin') ...[
            ListTile(
              leading: const Icon(Icons.manage_accounts_outlined),
              title: const Text('Manajemen Pengguna'),
              selected: currentRouteName == UserManagementPage.routeName,
              onTap: () => _navigateToPage(context, UserManagementPage.routeName, replace: true, arguments: user),
            ),
          ],

          const _DrawerSectionHeader(title: 'DATA'),
          ListTile(
            leading: const Icon(Icons.store_mall_directory_outlined),
            title: const Text('Workshop'),
            selected: currentRouteName == WorkshopPage.routeName,
            onTap: () => _navigateToPage(context, WorkshopPage.routeName, replace: true, arguments: user),
          ),
          ListTile(
            leading: const Icon(Icons.schedule_outlined),
            title: const Text('Jadwal'),
            selected: currentRouteName == SchedulePage.routeName,
            onTap: () => _navigateToPage(context, SchedulePage.routeName, replace: true, arguments: user),
          ),
          ListTile(
            leading: const Icon(Icons.inventory_2_outlined),
            title: const Text('Gudang'),
            selected: currentRouteName == WarehousePage.routeName,
            onTap: () => _navigateToPage(context, WarehousePage.routeName, replace: true, arguments: user),
          ),

          if (userRole == 'Admin') ...[
            const _DrawerSectionHeader(title: 'MANAJEMEN PERAWATAN'),
            ListTile(
              leading: const Icon(Icons.event_repeat_outlined),
              title: const Text('Jadwal Berkala'),
              selected: currentRouteName == MaintenanceTemplatesPage.routeName,
              onTap: () {
                _navigateToPage(context, MaintenanceTemplatesPage.routeName, replace: true, arguments: user);
              },
            ),
          ],

          const _DrawerSectionHeader(title: 'LAPORAN'),
          ListTile(
            leading: const Icon(Icons.assessment_outlined),
            title: const Text('Pusat Laporan'),
            selected: currentRouteName == ReportsHubPage.routeName,
            onTap: () => _navigateToPage(context, ReportsHubPage.routeName, replace: true, arguments: user),
          ),

          const _DrawerSectionHeader(title: 'SISTEM'),
          ListTile(
            leading: const Icon(Icons.settings_outlined),
            title: const Text('Pengaturan'),
            selected: currentRouteName == SettingsPage.routeName,
            onTap: () => _navigateToPage(context, SettingsPage.routeName, replace: true, arguments: user),
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.info_outline),
            title: const Text('Tentang Aplikasi'),
            selected: currentRouteName == AboutPage.routeName,
            onTap: () => _navigateToPage(context, AboutPage.routeName, replace: true, arguments: user),
          ),

          const Divider(),
          ListTile(
            leading: const Icon(Icons.logout),
            title: const Text('Keluar'),
            onTap: () async {
              await Supabase.instance.client.auth.signOut();
              if (context.mounted) {
                _navigateToPage(context, LoginPage.routeName, replace: true);
              }
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