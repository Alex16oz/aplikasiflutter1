// lib/pages/warehouse_page.dart
import 'package:flutter/material.dart';
import '../widgets/app_drawer.dart'; // Import the AppDrawer

class WarehousePage extends StatelessWidget {
  const WarehousePage({super.key});

  static const String routeName = '/warehouse';

  // Sample data for the machines table
  // Based on the `machines` table schema: id_machine, machine_name, category, location
  final List<Map<String, String>> _machineData = const [
    {'id_machine': 'MCH001', 'machine_name': 'Excavator Alpha', 'category': 'Heavy Equipment', 'location': 'Site A'},
    {'id_machine': 'MCH002', 'machine_name': 'Loader Bravo', 'category': 'Heavy Equipment', 'location': 'Site B'},
    {'id_machine': 'MCH003', 'machine_name': 'Dump Truck Charlie', 'category': 'Transport', 'location': 'Site A'},
    {'id_machine': 'MCH004', 'machine_name': 'Grader Delta', 'category': 'Heavy Equipment', 'location': 'Workshop'},
    {'id_machine': 'MCH005', 'machine_name': 'Generator Echo', 'category': 'Power Supply', 'location': 'Site C'},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Warehouse'), // AppBar title remains 'Warehouse' as it's the page name
        actions: <Widget>[
          IconButton(
            icon: const Icon(Icons.add_box_outlined), // Changed icon to better represent adding a machine
            tooltip: 'Add Machine', // Updated tooltip
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
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            const Text(
              'Machine List', // Changed title from 'Spareparts' to 'Machine List'
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8.0),
            SizedBox(
              width: double.infinity,
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
                  DataColumn(
                    label: Text('ID Machine', style: TextStyle(fontWeight: FontWeight.bold)), // Changed from 'ID'
                  ),
                  DataColumn(
                    label: Text('Machine Name', style: TextStyle(fontWeight: FontWeight.bold)), // Changed from 'Sparepart Name'
                  ),
                  DataColumn(
                    label: Text('Category', style: TextStyle(fontWeight: FontWeight.bold)), // Added 'Category' column
                  ),
                  DataColumn(
                    label: Text('Location', style: TextStyle(fontWeight: FontWeight.bold)), // Added 'Location' column
                  ),
                  DataColumn(
                    label: Text('Action', style: TextStyle(fontWeight: FontWeight.bold)),
                  ),
                ],
                rows: _machineData.map((item) {
                  return DataRow(
                    cells: <DataCell>[
                      DataCell(Text(item['id_machine']!)),
                      DataCell(Text(item['machine_name']!)),
                      DataCell(Text(item['category']!)),
                      DataCell(Text(item['location']!)),
                      DataCell(
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              IconButton(
                                icon: Icon(Icons.edit, size: 20, color: Colors.blue.shade700),
                                tooltip: 'Edit',
                                onPressed: () {
                                  // TODO: Implement edit action for this machine
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(content: Text('Edit action for ID: ${item['id_machine']}')),
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
                                  // TODO: Implement delete action for this machine
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(content: Text('Delete action for ID: ${item['id_machine']}')),
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
}