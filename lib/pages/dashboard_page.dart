// lib/pages/dashboard_page.dart
import 'package:flutter/material.dart';
import '../widgets/app_drawer.dart'; // Import the AppDrawer

class DashboardPage extends StatelessWidget {
  const DashboardPage({super.key});

  static const String routeName = '/'; // Standard for home page

  // Sample data for the table
  final List<Map<String, String>> _maintenanceData = const [
    {'date': '2025-05-29', 'operator': 'John Doe', 'machine': 'Excavator A', 'oil': 'Engine Oil X'},
    {'date': '2025-06-05', 'operator': 'Jane Smith', 'machine': 'Loader B', 'oil': 'Hydraulic Oil Y'},
    {'date': '2025-06-12', 'operator': 'Mike Lee', 'machine': 'Dump Truck C', 'oil': 'Gear Oil Z'},
    {'date': '2025-06-19', 'operator': 'Alice Brown', 'machine': 'Grader D', 'oil': 'Transmission Oil'},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Dashboard'),
      ),
      drawer: const AppDrawer(),
      body: SingleChildScrollView( // Added SingleChildScrollView to prevent overflow
        padding: const EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            // Row for the three cards
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                Expanded(
                  child: _buildDashboardCard(
                    context: context,
                    count: 10, // Replace with actual data
                    name: 'Users',
                    icon: Icons.people,
                    color: Colors.orange,
                  ),
                ),
                const SizedBox(width: 12.0),
                Expanded(
                  child: _buildDashboardCard(
                    context: context,
                    count: 5, // Replace with actual data
                    name: 'Schedule',
                    icon: Icons.schedule,
                    color: Colors.blue,
                  ),
                ),
                const SizedBox(width: 12.0),
                Expanded(
                  child: _buildDashboardCard(
                    context: context,
                    count: 25, // Replace with actual data
                    name: 'Spareparts',
                    icon: Icons.build,
                    color: Colors.green,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24.0), // Increased spacing for title
            const Text(
              'Maintenance Schedule',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8.0),
            // Maintenance Schedule Table
            SizedBox(
              width: double.infinity, // Makes the DataTable take full width
              child: DataTable(
                columnSpacing: 16.0, // Adjust spacing between columns
                headingRowColor: WidgetStateColor.resolveWith((states) => Colors.blueGrey.shade100),
                border: TableBorder.all(
                    color: Colors.grey.shade400,
                    width: 1,
                    borderRadius: BorderRadius.circular(8.0)
                ),
                columns: const <DataColumn>[
                  DataColumn(
                    label: Text('Date', style: TextStyle(fontWeight: FontWeight.bold)),
                  ),
                  DataColumn(
                    label: Text('Operator', style: TextStyle(fontWeight: FontWeight.bold)),
                  ),
                  DataColumn(
                    label: Text('Machine', style: TextStyle(fontWeight: FontWeight.bold)),
                  ),
                  DataColumn(
                    label: Text('Oil', style: TextStyle(fontWeight: FontWeight.bold)),
                  ),
                ],
                rows: _maintenanceData.map((item) {
                  return DataRow(
                    cells: <DataCell>[
                      DataCell(Text(item['date']!)),
                      DataCell(Text(item['operator']!)),
                      DataCell(Text(item['machine']!)),
                      DataCell(Text(item['oil']!)),
                    ],
                  );
                }).toList(),
              ),
            ),
            const SizedBox(height: 20.0),
            // Original "Welcome" text, you can keep or remove this
            // const Center(
            //   child: Text(
            //     'Welcome to the Dashboard!',
            //     style: TextStyle(fontSize: 20),
            //   ),
            // ),
          ],
        ),
      ),
    );
  }

  // Helper widget to build a dashboard card
  Widget _buildDashboardCard({
    required BuildContext context,
    required int count,
    required String name,
    required IconData icon,
    required Color color,
  }) {
    return Card(
      elevation: 3.0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10.0),
      ),
      child: Container(
        padding: const EdgeInsets.all(12.0),
        height: 100,
        child: Stack(
          children: <Widget>[
            Positioned(
              top: 0,
              left: 0,
              child: Text(
                name,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
              ),
            ),
            Positioned(
              top: 4,
              right: 0,
              child: Icon(
                icon,
                size: 32.0,
                color: color.withAlpha((255 * 0.6).round()),
              ),
            ),
            Positioned(
              bottom: 0,
              left: 0,
              child: Text(
                count.toString(),
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}