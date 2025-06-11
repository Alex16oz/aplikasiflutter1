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
      // Use LayoutBuilder to make the UI responsive.
      body: LayoutBuilder(
        builder: (context, constraints) {
          // We set a breakpoint. If the screen is wider than 600px, we use a wide layout.
          // Otherwise, we use a layout optimized for narrow screens.
          if (constraints.maxWidth > 600) {
            return _buildWideLayout(context); // Layout for tablets/desktops
          } else {
            return _buildNarrowLayout(context); // Layout for phones
          }
        },
      ),
    );
  }

  // --- WIDGET FOR WIDE SCREENS (TABLETS/DESKTOPS) ---
  Widget _buildWideLayout(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          // The summary cards are in a Row, which works well on wide screens.
          Row(
            children: <Widget>[
              Expanded(
                child: _buildDashboardCard(
                  context: context,
                  count: 10,
                  name: 'Users',
                  icon: Icons.people,
                  color: Colors.orange,
                ),
              ),
              const SizedBox(width: 16.0),
              Expanded(
                child: _buildDashboardCard(
                  context: context,
                  count: 5,
                  name: 'Schedule',
                  icon: Icons.schedule,
                  color: Colors.blue,
                ),
              ),
              const SizedBox(width: 16.0),
              Expanded(
                child: _buildDashboardCard(
                  context: context,
                  count: 25,
                  name: 'Spareparts',
                  icon: Icons.build,
                  color: Colors.green,
                ),
              ),
            ],
          ),
          const SizedBox(height: 24.0),
          const Text(
            'Maintenance Schedule',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8.0),
          // DataTable is suitable for wide screens.
          SizedBox(
            width: double.infinity,
            child: DataTable(
              columnSpacing: 16.0,
              headingRowColor: WidgetStateColor.resolveWith((states) => Colors.blueGrey.shade100),
              border: TableBorder.all(
                color: Colors.grey.shade400,
                width: 1,
                borderRadius: BorderRadius.circular(8.0),
              ),
              columns: const <DataColumn>[
                DataColumn(label: Text('Date', style: TextStyle(fontWeight: FontWeight.bold))),
                DataColumn(label: Text('Operator', style: TextStyle(fontWeight: FontWeight.bold))),
                DataColumn(label: Text('Machine', style: TextStyle(fontWeight: FontWeight.bold))),
                DataColumn(label: Text('Oil', style: TextStyle(fontWeight: FontWeight.bold))),
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
        ],
      ),
    );
  }

  // --- WIDGET FOR NARROW SCREENS (PHONES) ---
  Widget _buildNarrowLayout(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(12.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          // On narrow screens, we use a Wrap widget for the cards.
          // This allows them to flow and arrange themselves vertically.
          Wrap(
            spacing: 12.0, // Horizontal space between cards
            runSpacing: 12.0, // Vertical space between card rows
            children: <Widget>[
              _buildDashboardCard(
                context: context,
                count: 10,
                name: 'Users',
                icon: Icons.people,
                color: Colors.orange,
              ),
              _buildDashboardCard(
                context: context,
                count: 5,
                name: 'Schedule',
                icon: Icons.schedule,
                color: Colors.blue,
              ),
              _buildDashboardCard(
                context: context,
                count: 25,
                name: 'Spareparts',
                icon: Icons.build,
                color: Colors.green,
              ),
            ],
          ),
          const SizedBox(height: 24.0),
          const Text(
            'Maintenance Schedule',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8.0),
          // DataTable is bad for small screens, so we use a ListView of Cards instead.
          ListView.builder(
            shrinkWrap: true, // Important to allow the ListView inside a Column
            physics: const NeverScrollableScrollPhysics(), // The parent is already scrollable
            itemCount: _maintenanceData.length,
            itemBuilder: (context, index) {
              final item = _maintenanceData[index];
              return Card(
                margin: const EdgeInsets.only(bottom: 8.0),
                child: ListTile(
                  title: Text(item['machine']!, style: const TextStyle(fontWeight: FontWeight.bold)),
                  subtitle: Text('Operator: ${item['operator']}\nOil: ${item['oil']}'),
                  trailing: Text(item['date']!),
                  isThreeLine: true,
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  // Helper widget to build a dashboard card. This is reusable for both layouts.
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
        height: 100, // Fixed height for consistency
        // Using a Flexible child inside a Wrap requires it to be wrapped in a specific way.
        // For simplicity, we can give it a specific width when in narrow mode
        // by calculating based on screen width minus padding.
        width: MediaQuery.of(context).size.width < 600
            ? (MediaQuery.of(context).size.width / 2) - 18 // Roughly half screen width
            : null, // No fixed width on wide screens (it will be handled by Expanded)
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
