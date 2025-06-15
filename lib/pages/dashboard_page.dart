// lib/pages/dashboard_page.dart (FIXED SCHEDULE COLUMN NAME)
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:intl/intl.dart';

import '../widgets/app_drawer.dart';
import 'user_management_page.dart';
import 'workshop_page.dart';
import 'damage_reports_page.dart';
import 'warehouse_page.dart';
import 'schedule_page.dart';

// Data model for dashboard summary
class DashboardSummary {
  final int adminCount;
  final int operatorCount;
  final int warehouseCount;
  final int totalMachines;
  final int pendingReportsCount;
  final int lowStockItemsCount;

  DashboardSummary({
    this.adminCount = 0,
    this.operatorCount = 0,
    this.warehouseCount = 0,
    this.totalMachines = 0,
    this.pendingReportsCount = 0,
    this.lowStockItemsCount = 0,
  });

  int get totalUsers => adminCount + operatorCount + warehouseCount;
}

class DashboardPage extends StatefulWidget {
  const DashboardPage({super.key});

  static const String routeName = '/'; // Standard for home page

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  late Future<Map<String, dynamic>> _dashboardDataFuture;
  final _supabase = Supabase.instance.client;

  @override
  void initState() {
    super.initState();
    _dashboardDataFuture = _fetchDashboardData();
  }

  Future<Map<String, dynamic>> _fetchDashboardData() async {
    try {
      // Get today's date for filtering schedules
      final today = DateFormat('yyyy-MM-dd').format(DateTime.now());

      // ==[PERBAIKAN DIMULAI DI SINI]===
      // Changed column name from 'date' to 'schedule_date'
      final futures = <Future<dynamic>>[
        _supabase.from('profiles').select('role'),
        _supabase.from('machines').select('id'),
        _supabase.from('damage_reports').select('id, created_at, description, status, machines(machine_name)').eq('status', 'Pending').order('created_at', ascending: false).limit(5),
        _supabase.rpc('get_spareparts_summary'),
        _supabase.from('schedules').select('*, machines(machine_name)').gte('schedule_date', today).order('schedule_date', ascending: true).limit(5),
      ];
      // ===[PERBAIKAN SELESAI DI SINI]===

      // Run all queries in parallel
      final results = await Future.wait(futures);

      // Process profiles data
      final profiles = results[0] as List;
      final adminCount = profiles.where((p) => p['role'] == 'Admin').length;
      final operatorCount = profiles.where((p) => p['role'] == 'Operator').length;
      final warehouseCount = profiles.where((p) => p['role'] == 'Warehouse Staff').length;

      // Process machines data
      final machines = results[1] as List;
      final totalMachines = machines.length;

      // Process damage reports data
      final pendingReports = results[2] as List;
      final pendingReportsCount = pendingReports.length;

      // Process spareparts data
      final spareparts = results[3] as List;
      final lowStockItemsCount = spareparts.where((s) => (s['total_stock'] ?? 0) <= (s['minimum_stock_level'] ?? 0)).length;

      // Process schedules data
      final schedules = results[4] as List;

      return {
        'summary': DashboardSummary(
          adminCount: adminCount,
          operatorCount: operatorCount,
          warehouseCount: warehouseCount,
          totalMachines: totalMachines,
          pendingReportsCount: pendingReportsCount,
          lowStockItemsCount: lowStockItemsCount,
        ),
        'reports': pendingReports,
        'schedules': schedules, // Add schedules to the result map
      };
    } catch (e) {
      debugPrint('Error fetching dashboard data: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to load dashboard data: $e'), backgroundColor: Colors.red),
        );
      }
      rethrow;
    }
  }


  void _refreshData() {
    setState(() {
      _dashboardDataFuture = _fetchDashboardData();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Dashboard'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _refreshData,
            tooltip: 'Refresh Data',
          ),
        ],
      ),
      drawer: const AppDrawer(),
      body: FutureBuilder<Map<String, dynamic>>(
        future: _dashboardDataFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text('Error loading data: ${snapshot.error}'),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: _refreshData,
                    child: const Text('Try Again'),
                  ),
                ],
              ),
            );
          }
          if (!snapshot.hasData || snapshot.data == null) {
            return const Center(child: Text('No data available.'));
          }

          final summary = snapshot.data!['summary'] as DashboardSummary;
          final reports = snapshot.data!['reports'] as List;
          final schedules = snapshot.data!['schedules'] as List; // Get schedules

          // Use LayoutBuilder for responsive UI
          return LayoutBuilder(
            builder: (context, constraints) {
              if (constraints.maxWidth > 800) {
                return _buildWideLayout(context, summary, reports, schedules);
              } else {
                return _buildNarrowLayout(context, summary, reports, schedules);
              }
            },
          );
        },
      ),
    );
  }

  // Layout for wide screens (tablets/desktops)
  Widget _buildWideLayout(BuildContext context, DashboardSummary summary, List reports, List schedules) {
    return RefreshIndicator(
      onRefresh: () async => _refreshData(),
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            // Summary Cards
            GridView.count(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisCount: 4,
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
              childAspectRatio: 2.0, // Adjust aspect ratio for wide layout
              children: [
                _buildDashboardCard(context: context, count: summary.totalUsers, name: 'Users', icon: Icons.people, color: Colors.orange, routeName: UserManagementPage.routeName),
                _buildDashboardCard(context: context, count: summary.totalMachines, name: 'Machines', icon: Icons.precision_manufacturing_outlined, color: Colors.cyan, routeName: WorkshopPage.routeName),
                _buildDashboardCard(context: context, count: summary.pendingReportsCount, name: 'Pending Reports', icon: Icons.warning_amber_rounded, color: Colors.red, routeName: DamageReportsPage.routeName),
                _buildDashboardCard(context: context, count: summary.lowStockItemsCount, name: 'Low Stock', icon: Icons.inventory_2_outlined, color: Colors.amber, routeName: WarehousePage.routeName),
              ],
            ),
            const SizedBox(height: 24.0),
            // Data Tables
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Upcoming Schedules', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                        const SizedBox(height: 8.0),
                        _buildSchedulesTable(schedules),
                      ],
                    )
                ),
                const SizedBox(width: 24),
                Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Recent Pending Damage Reports', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                        const SizedBox(height: 8.0),
                        _buildReportsTable(reports),
                      ],
                    )
                )
              ],
            )
          ],
        ),
      ),
    );
  }

  // Layout for narrow screens (phones)
  Widget _buildNarrowLayout(BuildContext context, DashboardSummary summary, List reports, List schedules) {
    return RefreshIndicator(
      onRefresh: () async => _refreshData(),
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            // Summary Cards
            GridView.count(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisCount: 2,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              childAspectRatio: 1.5,
              children: [
                _buildDashboardCard(context: context, count: summary.totalUsers, name: 'Users', icon: Icons.people, color: Colors.orange, routeName: UserManagementPage.routeName),
                _buildDashboardCard(context: context, count: summary.totalMachines, name: 'Machines', icon: Icons.precision_manufacturing_outlined, color: Colors.cyan, routeName: WorkshopPage.routeName),
                _buildDashboardCard(context: context, count: summary.pendingReportsCount, name: 'Pending Reports', icon: Icons.warning_amber_rounded, color: Colors.red, routeName: DamageReportsPage.routeName),
                _buildDashboardCard(context: context, count: summary.lowStockItemsCount, name: 'Low Stock', icon: Icons.inventory_2_outlined, color: Colors.amber, routeName: WarehousePage.routeName),
              ],
            ),
            const SizedBox(height: 24.0),
            // Upcoming Schedules
            const Text('Upcoming Schedules', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8.0),
            _buildSchedulesList(schedules),
            const SizedBox(height: 24.0),
            // Recent Reports
            const Text('Recent Pending Damage Reports', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8.0),
            _buildReportsList(reports),
          ],
        ),
      ),
    );
  }

  // Reusable interactive dashboard card
  Widget _buildDashboardCard({
    required BuildContext context,
    required int count,
    required String name,
    required IconData icon,
    required Color color,
    required String routeName,
  }) {
    return Card(
      elevation: 3.0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.0)),
      child: InkWell(
        onTap: () {
          final userArgs = ModalRoute.of(context)?.settings.arguments;
          Navigator.pushNamed(context, routeName, arguments: userArgs);
        },
        borderRadius: BorderRadius.circular(10.0),
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Flexible(
                    child: Text(
                      name,
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: color),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  Icon(icon, size: 28.0, color: color.withAlpha(180)),
                ],
              ),
              Text(
                count.toString(),
                style: const TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Data table for wide screens
  Widget _buildReportsTable(List reports) {
    if (reports.isEmpty) {
      return const Center(child: Padding(padding: EdgeInsets.symmetric(vertical: 20.0), child: Text("No pending reports found.")));
    }
    return SizedBox(
      width: double.infinity,
      child: DataTable(
        columnSpacing: 16.0,
        headingRowColor: WidgetStateColor.resolveWith((states) => Colors.blueGrey.shade100),
        border: TableBorder.all(color: Colors.grey.shade400, width: 1, borderRadius: BorderRadius.circular(8.0)),
        columns: const <DataColumn>[
          DataColumn(label: Text('Date', style: TextStyle(fontWeight: FontWeight.bold))),
          DataColumn(label: Text('Machine', style: TextStyle(fontWeight: FontWeight.bold))),
          DataColumn(label: Text('Description', style: TextStyle(fontWeight: FontWeight.bold))),
        ],
        rows: reports.map((item) {
          final machineName = (item['machines'] as Map?)?['machine_name'] ?? 'N/A';
          final date = item['created_at'] != null ? DateFormat('dd MMM, HH:mm', 'id_ID').format(DateTime.parse(item['created_at'])) : 'N/A';
          return DataRow(
            cells: <DataCell>[
              DataCell(Text(date)),
              DataCell(Text(machineName)),
              DataCell(Text(item['description'] ?? 'No description')),
            ],
          );
        }).toList(),
      ),
    );
  }

  // List of cards for narrow screens
  Widget _buildReportsList(List reports) {
    if (reports.isEmpty) {
      return const Center(child: Padding(padding: EdgeInsets.symmetric(vertical: 20.0), child: Text("No pending reports found.")));
    }
    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: reports.length,
      itemBuilder: (context, index) {
        final item = reports[index];
        final machineName = (item['machines'] as Map?)?['machine_name'] ?? 'N/A';
        final date = item['created_at'] != null ? DateFormat('dd MMM, HH:mm', 'id_ID').format(DateTime.parse(item['created_at'])) : 'N/A';
        return Card(
          margin: const EdgeInsets.only(bottom: 8.0),
          child: ListTile(
            title: Text(machineName, style: const TextStyle(fontWeight: FontWeight.bold)),
            subtitle: Text(item['description'] ?? 'No description', maxLines: 2, overflow: TextOverflow.ellipsis),
            trailing: Text(date, style: const TextStyle(fontSize: 12, color: Colors.grey)),
          ),
        );
      },
    );
  }

  // Data table for wide screens - FOR SCHEDULES
  Widget _buildSchedulesTable(List schedules) {
    if (schedules.isEmpty) {
      return const Center(child: Padding(padding: EdgeInsets.symmetric(vertical: 20.0), child: Text("No upcoming schedules.")));
    }
    return SizedBox(
      width: double.infinity,
      child: DataTable(
        columnSpacing: 16.0,
        headingRowColor: WidgetStateColor.resolveWith((states) => Colors.green.shade100),
        border: TableBorder.all(color: Colors.grey.shade400, width: 1, borderRadius: BorderRadius.circular(8.0)),
        columns: const <DataColumn>[
          DataColumn(label: Text('Date', style: TextStyle(fontWeight: FontWeight.bold))),
          DataColumn(label: Text('Machine', style: TextStyle(fontWeight: FontWeight.bold))),
          DataColumn(label: Text('Activity', style: TextStyle(fontWeight: FontWeight.bold))),
        ],
        rows: schedules.map((item) {
          final machineName = (item['machines'] as Map?)?['machine_name'] ?? 'N/A';
          // ==[PERBAIKAN DIMULAI DI SINI]===
          final date = item['schedule_date'] != null ? DateFormat('EEE, dd MMM yyyy', 'id_ID').format(DateTime.parse(item['schedule_date'])) : 'N/A';
          // ===[PERBAIKAN SELESAI DI SINI]===
          return DataRow(
            cells: <DataCell>[
              DataCell(Text(date)),
              DataCell(Text(machineName)),
              DataCell(Text(item['task_description'] ?? 'No description')),
            ],
          );
        }).toList(),
      ),
    );
  }

  // List of cards for narrow screens - FOR SCHEDULES
  Widget _buildSchedulesList(List schedules) {
    if (schedules.isEmpty) {
      return const Center(child: Padding(padding: EdgeInsets.symmetric(vertical: 20.0), child: Text("No upcoming schedules.")));
    }
    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: schedules.length,
      itemBuilder: (context, index) {
        final item = schedules[index];
        final machineName = (item['machines'] as Map?)?['machine_name'] ?? 'N/A';
        // ==[PERBAIKAN DIMULAI DI SINI]===
        final date = item['schedule_date'] != null ? DateFormat('EEE, dd MMM', 'id_ID').format(DateTime.parse(item['schedule_date'])) : 'N/A';
        // ===[PERBAIKAN SELESAI DI SINI]===
        return Card(
          margin: const EdgeInsets.only(bottom: 8.0),
          child: ListTile(
            leading: CircleAvatar(
              backgroundColor: Colors.green.shade100,
              child: const Icon(Icons.calendar_today, color: Colors.green),
            ),
            title: Text('$machineName - $date', style: const TextStyle(fontWeight: FontWeight.bold)),
            subtitle: Text(item['task_description'] ?? 'No description', maxLines: 2, overflow: TextOverflow.ellipsis),
          ),
        );
      },
    );
  }
}