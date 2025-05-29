// lib/pages/warehouse_page.dart
import 'package:flutter/material.dart';
import '../widgets/app_drawer.dart'; // Import the AppDrawer

class WarehousePage extends StatelessWidget {
  const WarehousePage({super.key});

  static const String routeName = '/warehouse';

  // Sample data for the spareparts table
  final List<Map<String, String>> _sparepartsData = const [
    {'id': '1', 'sparepart_name': 'Oil Filter', 'machinename': 'Excavator A', 'quantity': '10'},
    {'id': '2', 'sparepart_name': 'Air Filter', 'machinename': 'Loader B', 'quantity': '5'},
    {'id': '3', 'sparepart_name': 'Hydraulic Hose', 'machinename': 'Excavator A', 'quantity': '2'},
    {'id': '4', 'sparepart_name': 'Spark Plug', 'machinename': 'Dump Truck C', 'quantity': '20'},
    {'id': '5', 'sparepart_name': 'Brake Pad', 'machinename': 'Grader D', 'quantity': '8'},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Warehouse'),
        actions: <Widget>[
          IconButton(
            icon: const Icon(Icons.add),
            tooltip: 'Insert',
            onPressed: () {
              // TODO: Implement insert functionality
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Insert button pressed')),
              );
            },
          ),
        ],
      ),
      drawer: const AppDrawer(),
      body: SingleChildScrollView( // Added SingleChildScrollView to prevent overflow
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            const Text(
              'Spareparts',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8.0),
            SizedBox(
              width: double.infinity, // Makes the DataTable take full width
              child: DataTable(
                columnSpacing: 12.0, // Adjust spacing between columns
                headingRowColor: WidgetStateColor.resolveWith((states) => Colors.blueGrey.shade100),
                border: TableBorder.all(
                    color: Colors.grey.shade400,
                    width: 1,
                    borderRadius: BorderRadius.circular(8.0)
                ),
                columns: const <DataColumn>[
                  DataColumn(
                    label: Text('ID', style: TextStyle(fontWeight: FontWeight.bold)),
                  ),
                  DataColumn(
                    label: Text('Sparepart Name', style: TextStyle(fontWeight: FontWeight.bold)),
                  ),
                  DataColumn(
                    label: Text('Machine Name', style: TextStyle(fontWeight: FontWeight.bold)),
                  ),
                  DataColumn(
                    label: Text('Quantity', style: TextStyle(fontWeight: FontWeight.bold)),
                  ),
                  DataColumn(
                    label: Text('Action', style: TextStyle(fontWeight: FontWeight.bold)),
                  ),
                ],
                rows: _sparepartsData.map((item) {
                  return DataRow(
                    cells: <DataCell>[
                      DataCell(Text(item['id']!)),
                      DataCell(Text(item['sparepart_name']!)),
                      DataCell(Text(item['machinename']!)),
                      DataCell(Text(item['quantity']!)),
                      DataCell(
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              IconButton(
                                icon: Icon(Icons.edit, size: 20, color: Colors.blue.shade700),
                                tooltip: 'Edit',
                                onPressed: () {
                                  // TODO: Implement edit action for this item
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(content: Text('Edit action for ID: ${item['id']}')),
                                  );
                                },
                                padding: EdgeInsets.zero, // remove extra padding
                                constraints: const BoxConstraints(), // remove extra padding
                              ),
                              const SizedBox(width: 4), // Minimal spacing
                              IconButton(
                                icon: Icon(Icons.delete, size: 20, color: Colors.red.shade700),
                                tooltip: 'Delete',
                                onPressed: () {
                                  // TODO: Implement delete action for this item
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(content: Text('Delete action for ID: ${item['id']}')),
                                  );
                                },
                                padding: EdgeInsets.zero, // remove extra padding
                                constraints: const BoxConstraints(), // remove extra padding
                              ),
                            ],
                          )
                      ),
                    ],
                  );
                }).toList(),
              ),
            ),
            // Original "Warehouse Page Content" text, can be removed or kept
            // const SizedBox(height: 20.0),
            // const Center(
            //   child: Text(
            //     'Warehouse Page Content',
            //     style: TextStyle(fontSize: 20),
            //   ),
            // ),
          ],
        ),
      ),
    );
  }
}