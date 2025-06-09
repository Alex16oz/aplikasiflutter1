// lib/pages/warehouse_page.dart
import 'package:flutter/material.dart';
import '../widgets/app_drawer.dart'; // Import the AppDrawer

class WarehousePage extends StatelessWidget {
  const WarehousePage({super.key});

  static const String routeName = '/warehouse';

  // Sample data for the spareparts table
  // Updated with new columns: part_number, supplier, unit_price, location, last_updated, and compatible_machine
  final List<Map<String, dynamic>> _sparepartsData = const [
    {'part_number': 'PN-OF-001', 'sparepart_name': 'Oil Filter', 'quantity': 10, 'compatible_machine': 'Excavator', 'supplier': 'Supplier A', 'unit_price': 150000, 'location': 'Rack A1', 'last_updated': '2025-06-01'},
    {'part_number': 'PN-AF-002', 'sparepart_name': 'Air Filter', 'quantity': 3, 'compatible_machine': 'Loader', 'supplier': 'Supplier B', 'unit_price': 120000, 'location': 'Rack A2', 'last_updated': '2025-06-05'},
    {'part_number': 'PN-HH-003', 'sparepart_name': 'Hydraulic Hose', 'quantity': 0, 'compatible_machine': 'Excavator', 'supplier': 'Supplier C', 'unit_price': 550000, 'location': 'Rack B1', 'last_updated': '2025-05-20'},
    {'part_number': 'PN-SP-004', 'sparepart_name': 'Spark Plug', 'quantity': 25, 'compatible_machine': 'Dump Truck', 'supplier': 'Supplier A', 'unit_price': 50000, 'location': 'Shelf C3', 'last_updated': '2025-06-10'},
    {'part_number': 'PN-BP-005', 'sparepart_name': 'Brake Pad', 'quantity': 5, 'compatible_machine': 'Grader', 'supplier': 'Supplier D', 'unit_price': 350000, 'location': 'Rack B2', 'last_updated': '2025-05-15'},
    {'part_number': 'PN-EG-006', 'sparepart_name': 'Engine Gasket', 'quantity': 1, 'compatible_machine': 'Generator', 'supplier': 'Supplier B', 'unit_price': 250000, 'location': 'Shelf D1', 'last_updated': '2025-06-08'},
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
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: DataTable(
                columnSpacing: 12.0,
                horizontalMargin: 8.0,
                headingRowColor: WidgetStateColor.resolveWith((states) => Colors.blueGrey.shade100),
                border: TableBorder.all(
                    color: Colors.grey.shade400,
                    width: 1,
                    borderRadius: BorderRadius.circular(8.0)
                ),
                columns: const <DataColumn>[
                  DataColumn(label: Text('Part Number', style: TextStyle(fontWeight: FontWeight.bold))),
                  DataColumn(label: Text('Name', style: TextStyle(fontWeight: FontWeight.bold))),
                  DataColumn(label: Text('Qty', style: TextStyle(fontWeight: FontWeight.bold))),
                  DataColumn(label: Text('Compatible Machine', style: TextStyle(fontWeight: FontWeight.bold))),
                  DataColumn(label: Text('Supplier', style: TextStyle(fontWeight: FontWeight.bold))),
                  DataColumn(label: Text('Unit Price', style: TextStyle(fontWeight: FontWeight.bold))),
                  DataColumn(label: Text('Location', style: TextStyle(fontWeight: FontWeight.bold))),
                  DataColumn(label: Text('Last Updated', style: TextStyle(fontWeight: FontWeight.bold))),
                  DataColumn(label: Text('Status', style: TextStyle(fontWeight: FontWeight.bold))),
                  DataColumn(label: Text('Action', style: TextStyle(fontWeight: FontWeight.bold))),
                ],
                rows: _sparepartsData.map((item) {
                  final statusInfo = _getSparepartStatus(item['quantity'] as int);
                  return DataRow(
                    cells: <DataCell>[
                      DataCell(Text(item['part_number']! as String)),
                      DataCell(Text(item['sparepart_name']! as String)),
                      DataCell(Text((item['quantity'] as int).toString())),
                      DataCell(Text(item['compatible_machine']! as String)),
                      DataCell(Text(item['supplier']! as String)),
                      DataCell(Text("Rp${item['unit_price']}")),
                      DataCell(Text(item['location']! as String)),
                      DataCell(Text(item['last_updated']! as String)),
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
                                    SnackBar(content: Text('Edit action for Part Number: ${item['part_number']}')),
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
                                    SnackBar(content: Text('Delete action for Part Number: ${item['part_number']}')),
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