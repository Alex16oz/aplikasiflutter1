// lib/pages/schedule_page.dart
import 'package:flutter/material.dart';
import '../widgets/app_drawer.dart'; // Import the AppDrawer

class SchedulePage extends StatelessWidget {
  const SchedulePage({super.key});

  static const String routeName = '/schedule';

  // Sample data for the schedule table
  final List<Map<String, String>> _scheduleData = const [
    {'id_schedule': 'SCH001', 'operator_name': 'John Doe', 'machine_name': 'Excavator A', 'date': '2025-06-01', 'status': 'Scheduled', 'damage_type': 'Routine Check'},
    {'id_schedule': 'SCH002', 'operator_name': 'Jane Smith', 'machine_name': 'Loader B', 'date': '2025-06-03', 'status': 'Completed', 'damage_type': 'Oil Leak'},
    {'id_schedule': 'SCH003', 'operator_name': 'Mike Lee', 'machine_name': 'Dump Truck C', 'date': '2025-06-05', 'status': 'Pending', 'damage_type': 'Engine Overheat'},
    {'id_schedule': 'SCH004', 'operator_name': 'Alice Brown', 'machine_name': 'Grader D', 'date': '2025-06-07', 'status': 'Scheduled', 'damage_type': 'Filter Change'},
    {'id_schedule': 'SCH005', 'operator_name': 'Robert Davis', 'machine_name': 'Excavator A', 'date': '2025-06-10', 'status': 'Cancelled', 'damage_type': 'Hydraulic Issue'},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Schedule'),
        actions: <Widget>[
          IconButton(
            icon: const Icon(Icons.add_task),
            tooltip: 'Add Schedule',
            onPressed: () {
              // TODO: Implement add schedule functionality
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Add Schedule button pressed')),
              );
            },
          ),
        ],
      ),
      drawer: const AppDrawer(),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            const Text(
              'Schedule Table',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8.0),
            SizedBox(
              width: double.infinity, // Makes the DataTable take full width
              child: DataTable(
                columnSpacing: 10.0, // Adjust spacing between columns
                horizontalMargin: 8.0, // Reduce horizontal margin
                headingRowColor: WidgetStateColor.resolveWith((states) => Colors.blueGrey.shade100),
                border: TableBorder.all(
                    color: Colors.grey.shade400,
                    width: 1,
                    borderRadius: BorderRadius.circular(8.0)
                ),
                columns: const <DataColumn>[
                  DataColumn(label: Text('ID', style: TextStyle(fontWeight: FontWeight.bold))),
                  DataColumn(label: Text('Operator', style: TextStyle(fontWeight: FontWeight.bold))),
                  DataColumn(label: Text('Machine', style: TextStyle(fontWeight: FontWeight.bold))),
                  DataColumn(label: Text('Date', style: TextStyle(fontWeight: FontWeight.bold))),
                  DataColumn(label: Text('Status', style: TextStyle(fontWeight: FontWeight.bold))),
                  DataColumn(label: Text('Damage', style: TextStyle(fontWeight: FontWeight.bold))),
                  DataColumn(label: Text('Action', style: TextStyle(fontWeight: FontWeight.bold))),
                ],
                rows: _scheduleData.map((item) {
                  return DataRow(
                    cells: <DataCell>[
                      DataCell(Text(item['id_schedule']!)),
                      DataCell(Text(item['operator_name']!)),
                      DataCell(Text(item['machine_name']!)),
                      DataCell(Text(item['date']!)),
                      DataCell(
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: _getStatusColor(item['status']!),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(
                              item['status']!,
                              style: const TextStyle(color: Colors.white, fontSize: 12),
                            ),
                          )
                      ),
                      DataCell(Text(item['damage_type']!)),
                      DataCell(
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              IconButton(
                                icon: Icon(Icons.edit, size: 20, color: Colors.blue.shade700),
                                tooltip: 'Edit',
                                onPressed: () {
                                  // TODO: Implement edit action for this schedule
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(content: Text('Edit action for ID: ${item['id_schedule']}')),
                                  );
                                },
                                padding: EdgeInsets.zero,
                                constraints: const BoxConstraints(),
                              ),
                              const SizedBox(width: 4),
                              IconButton(
                                icon: Icon(Icons.delete, size: 20, color: Colors.red.shade700),
                                tooltip: 'Delete',
                                onPressed: () {
                                  // TODO: Implement delete action for this schedule
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(content: Text('Delete action for ID: ${item['id_schedule']}')),
                                  );
                                },
                                padding: EdgeInsets.zero,
                                constraints: const BoxConstraints(),
                              ),
                            ],
                          )
                      ),
                    ],
                  );
                }).toList(),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Helper to determine color based on status
  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'scheduled':
        return Colors.blue.shade400;
      case 'completed':
        return Colors.green.shade400;
      case 'pending':
        return Colors.orange.shade400;
      case 'cancelled':
        return Colors.red.shade400;
      default:
        return Colors.grey.shade400;
    }
  }
}