// lib/pages/warehouse_page.dart
import 'package:flutter/material.dart';
import '../widgets/app_drawer.dart'; // Import the AppDrawer

class WarehousePage extends StatelessWidget {
  const WarehousePage({super.key});

  static const String routeName = '/warehouse';

  // Sample data for the spareparts table
  // Based on `spareparts` table schema: id_sparepart, sparepart_name, quantity, category_machine
  final List<Map<String, dynamic>> _sparepartsData = const [
    {'id_sparepart': 'SP001', 'sparepart_name': 'Oil Filter', 'quantity': 10, 'category_machine': 'Excavator'},
    {'id_sparepart': 'SP002', 'sparepart_name': 'Air Filter', 'quantity': 3, 'category_machine': 'Loader'},
    {'id_sparepart': 'SP003', 'sparepart_name': 'Hydraulic Hose', 'quantity': 0, 'category_machine': 'Excavator'},
    {'id_sparepart': 'SP004', 'sparepart_name': 'Spark Plug', 'quantity': 25, 'category_machine': 'Dump Truck'},
    {'id_sparepart': 'SP005', 'sparepart_name': 'Brake Pad', 'quantity': 5, 'category_machine': 'Grader'},
    {'id_sparepart': 'SP006', 'sparepart_name': 'Engine Gasket', 'quantity': 1, 'category_machine': 'Generator'},
  ];

  // Helper to determine status based on quantity
  Map<String, dynamic> _getSparepartStatus(int quantity) {
    if (quantity == 0) {
      return {'text': 'Kosong', 'color': Colors.red.shade400};
    } else if (quantity <= 5) {
      return {'text': 'Hampir Habis', 'color': Colors.orange.shade400};
    } else {
      return {'text': 'Aman', 'color': Colors.green.shade400};
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Warehouse'),
        actions: <Widget>[
          IconButton(
            icon: const Icon(Icons.add_circle_outline),
            tooltip: 'Add Sparepart',
            onPressed: () {
              // TODO: Implement add sparepart functionality
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Add Sparepart button pressed')),
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
              'Spareparts List',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8.0),
            SizedBox(
              width: double.infinity,
              child: DataTable(
                columnSpacing: 10.0,
                horizontalMargin: 8.0,
                headingRowColor: WidgetStateColor.resolveWith((states) => Colors.blueGrey.shade100),
                border: TableBorder.all(
                    color: Colors.grey.shade400,
                    width: 1,
                    borderRadius: BorderRadius.circular(8.0)
                ),
                columns: const <DataColumn>[
                  DataColumn(label: Text('ID', style: TextStyle(fontWeight: FontWeight.bold))),
                  DataColumn(label: Text('Name', style: TextStyle(fontWeight: FontWeight.bold))),
                  DataColumn(label: Text('Qty', style: TextStyle(fontWeight: FontWeight.bold))),
                  DataColumn(label: Text('Category Machine', style: TextStyle(fontWeight: FontWeight.bold))),
                  DataColumn(label: Text('Status', style: TextStyle(fontWeight: FontWeight.bold))),
                  DataColumn(label: Text('Action', style: TextStyle(fontWeight: FontWeight.bold))),
                ],
                rows: _sparepartsData.map((item) {
                  final statusInfo = _getSparepartStatus(item['quantity'] as int);
                  return DataRow(
                    cells: <DataCell>[
                      DataCell(Text(item['id_sparepart']! as String)),
                      DataCell(Text(item['sparepart_name']! as String)),
                      DataCell(Text((item['quantity'] as int).toString())),
                      DataCell(Text(item['category_machine']! as String)),
                      DataCell(
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: statusInfo['color'] as Color,
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            statusInfo['text'] as String,
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
                                    SnackBar(content: Text('Edit action for ID: ${item['id_sparepart']}')),
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
                                    SnackBar(content: Text('Delete action for ID: ${item['id_sparepart']}')),
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