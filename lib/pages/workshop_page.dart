// lib/pages/workshop_page.dart
import 'package:flutter/material.dart';
import '../widgets/app_drawer.dart'; // Import the AppDrawer

class WorkshopPage extends StatelessWidget {
  const WorkshopPage({super.key});

  static const String routeName = '/workshop';

  // Sample data for the machines table
  // Updated schema with new columns
  final List<Map<String, String>> _machineData = const [
    {
      'serial_number': 'SN-A123',
      'machine_name': 'Excavator Alpha',
      'model_number': 'CAT-320D',
      'manufacturer': 'Caterpillar',
      'category': 'Heavy Equipment',
      'location': 'Site A',
      'purchase_date': '2022-01-15',
      'last_maintenance_date': '2025-05-20',
      'operational_status': 'Operasional'
    },
    {
      'serial_number': 'SN-B456',
      'machine_name': 'Loader Bravo',
      'model_number': 'KOM-WA380',
      'manufacturer': 'Komatsu',
      'category': 'Heavy Equipment',
      'location': 'Site B',
      'purchase_date': '2021-11-20',
      'last_maintenance_date': '2025-04-10',
      'operational_status': 'Operasional'
    },
    {
      'serial_number': 'SN-C789',
      'machine_name': 'Dump Truck Charlie',
      'model_number': 'VOL-A40G',
      'manufacturer': 'Volvo',
      'category': 'Transport',
      'location': 'Site A',
      'purchase_date': '2023-02-10',
      'last_maintenance_date': '2025-03-15',
      'operational_status': 'Dalam Perawatan'
    },
    {
      'serial_number': 'SN-D101',
      'machine_name': 'Grader Delta',
      'model_number': 'JD-672G',
      'manufacturer': 'John Deere',
      'category': 'Heavy Equipment',
      'location': 'Workshop',
      'purchase_date': '2020-07-30',
      'last_maintenance_date': '2024-12-01',
      'operational_status': 'Rusak'
    },
    {
      'serial_number': 'SN-E112',
      'machine_name': 'Generator Echo',
      'model_number': 'CUM-C300D5',
      'manufacturer': 'Cummins',
      'category': 'Power Supply',
      'location': 'Site C',
      'purchase_date': '2023-08-01',
      'last_maintenance_date': '2025-06-01',
      'operational_status': 'perlu perawatan'
    },
  ];

  // Helper to determine color based on operational status
  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'operasional':
        return Colors.green.shade400;
      case 'dalam perawatan':
        return Colors.blue.shade400;
      case 'perlu perawatan':
        return Colors.orange.shade400;
      case 'rusak':
        return Colors.red.shade400;

      default:
        return Colors.grey.shade400;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Workshop'),
        actions: <Widget>[
          IconButton(
            icon: const Icon(Icons.add_box_outlined),
            tooltip: 'Add Machine',
            onPressed: () {
              // TODO: Implement add machine functionality
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Add Machine button pressed')),
              );
            },
          ),
        ],
      ),
      drawer: const AppDrawer(),
      body: SingleChildScrollView(
        scrollDirection: Axis.vertical,
        child: SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              const Text(
                'Machine List',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8.0),
              DataTable(
                columnSpacing: 12.0,
                horizontalMargin: 8.0,
                headingRowColor: WidgetStateColor.resolveWith((states) => Colors.blueGrey.shade100),
                border: TableBorder.all(
                    color: Colors.grey.shade400,
                    width: 1,
                    borderRadius: BorderRadius.circular(8.0)
                ),
                columns: const <DataColumn>[
                  DataColumn(label: Text('Serial Number', style: TextStyle(fontWeight: FontWeight.bold))),
                  DataColumn(label: Text('Machine Name', style: TextStyle(fontWeight: FontWeight.bold))),
                  DataColumn(label: Text('Model Number', style: TextStyle(fontWeight: FontWeight.bold))),
                  DataColumn(label: Text('Manufacturer', style: TextStyle(fontWeight: FontWeight.bold))),
                  DataColumn(label: Text('Purchase Date', style: TextStyle(fontWeight: FontWeight.bold))),
                  DataColumn(label: Text('Last Maintenance', style: TextStyle(fontWeight: FontWeight.bold))),
                  DataColumn(label: Text('Status', style: TextStyle(fontWeight: FontWeight.bold))),
                  DataColumn(label: Text('Action', style: TextStyle(fontWeight: FontWeight.bold))),
                ],
                rows: _machineData.map((item) {
                  return DataRow(
                    cells: <DataCell>[
                      DataCell(Text(item['serial_number']!)),
                      DataCell(Text(item['machine_name']!)),
                      DataCell(Text(item['model_number']!)),
                      DataCell(Text(item['manufacturer']!)),
                      DataCell(Text(item['purchase_date']!)),
                      DataCell(Text(item['last_maintenance_date']!)),
                      DataCell(
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: _getStatusColor(item['operational_status']!),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            item['operational_status']!,
                            style: const TextStyle(color: Colors.white, fontSize: 12),
                          ),
                        ),
                      ),
                      DataCell(
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              IconButton(
                                icon: Icon(Icons.edit, size: 20, color: Colors.blue.shade700),
                                tooltip: 'Edit',
                                onPressed: () {
                                  // TODO: Implement edit action
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(content: Text('Edit action for SN: ${item['serial_number']}')),
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
                                  // TODO: Implement delete action
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(content: Text('Delete action for SN: ${item['serial_number']}')),
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
            ],
          ),
        ),
      ),
    );
  }
}