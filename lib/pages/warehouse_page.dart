// lib/pages/warehouse_page.dart
import 'package:flutter/material.dart';
import 'package:intl/intl.dart'; // Pastikan 'intl' sudah ditambahkan di pubspec.yaml
import 'package:supabase_flutter/supabase_flutter.dart';
import '../widgets/app_drawer.dart'; // Import the AppDrawer

class WarehousePage extends StatefulWidget {
  const WarehousePage({super.key});

  static const String routeName = '/warehouse';

  @override
  State<WarehousePage> createState() => _WarehousePageState();
}

class _WarehousePageState extends State<WarehousePage> {
  late Future<List<Map<String, dynamic>>> _sparepartsFuture;
  final _supabase = Supabase.instance.client;
  String? _currentUserRole;

  @override
  void initState() {
    super.initState();
    _sparepartsFuture = _fetchSpareparts();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Get user role from arguments passed during navigation
    final args = ModalRoute.of(context)?.settings.arguments;
    if (args is Map<String, dynamic>) {
      _currentUserRole = args['role'];
    }
  }

  Future<List<Map<String, dynamic>>> _fetchSpareparts() async {
    try {
      final response = await _supabase
          .from('spareparts')
          .select()
          .order('sparepart_name', ascending: true);
      return List<Map<String, dynamic>>.from(response);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error fetching data: $e'),
            backgroundColor: Theme.of(context).colorScheme.error,
          ),
        );
      }
      return [];
    }
  }

  void _refreshData() {
    setState(() {
      _sparepartsFuture = _fetchSpareparts();
    });
  }

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

  String _formatCurrency(dynamic price) {
    if (price == null || price is! num) {
      return 'N/A';
    }
    final format = NumberFormat.currency(locale: 'id_ID', symbol: 'Rp', decimalDigits: 0);
    return format.format(price);
  }

  String _formatTimestamp(String? dateString) {
    if (dateString == null) return 'N/A';
    try {
      final dateTime = DateTime.parse(dateString);
      return DateFormat('dd MMM yyyy, HH:mm').format(dateTime);
    } catch (e) {
      return 'Invalid Date';
    }
  }

  // --- Dialog for Add/Edit Sparepart ---
  Future<void> _showSparepartDialog({Map<String, dynamic>? sparepart}) async {
    final formKey = GlobalKey<FormState>();
    final isEditing = sparepart != null;

    final partNumberController = TextEditingController(text: sparepart?['part_number']);
    final nameController = TextEditingController(text: sparepart?['sparepart_name']);
    final qtyController = TextEditingController(text: sparepart?['quantity']?.toString());
    final machineController = TextEditingController(text: sparepart?['compatible_machine']);
    final supplierController = TextEditingController(text: sparepart?['supplier']);
    final priceController = TextEditingController(text: sparepart?['unit_price']?.toString());
    final locationController = TextEditingController(text: sparepart?['location']);

    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(isEditing ? 'Edit Sparepart' : 'Add New Sparepart'),
        content: Form(
          key: formKey,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(controller: partNumberController, decoration: const InputDecoration(labelText: 'Part Number'), validator: (v) => v!.isEmpty ? 'Required' : null),
                TextFormField(controller: nameController, decoration: const InputDecoration(labelText: 'Sparepart Name'), validator: (v) => v!.isEmpty ? 'Required' : null),
                TextFormField(controller: qtyController, decoration: const InputDecoration(labelText: 'Quantity'), keyboardType: TextInputType.number, validator: (v) => v!.isEmpty ? 'Required' : null),
                TextFormField(controller: machineController, decoration: const InputDecoration(labelText: 'Compatible Machine')),
                TextFormField(controller: supplierController, decoration: const InputDecoration(labelText: 'Supplier')),
                TextFormField(controller: priceController, decoration: const InputDecoration(labelText: 'Unit Price'), keyboardType: TextInputType.number),
                TextFormField(controller: locationController, decoration: const InputDecoration(labelText: 'Location')),
              ],
            ),
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.of(context).pop(), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () async {
              if (formKey.currentState!.validate()) {
                final data = {
                  'part_number': partNumberController.text.trim(),
                  'sparepart_name': nameController.text.trim(),
                  'quantity': int.tryParse(qtyController.text.trim()) ?? 0,
                  'compatible_machine': machineController.text.trim(),
                  'supplier': supplierController.text.trim(),
                  'unit_price': double.tryParse(priceController.text.trim()),
                  'location': locationController.text.trim(),
                  'last_updated': DateTime.now().toIso8601String(),
                };

                try {
                  if (isEditing) {
                    await _supabase.from('spareparts').update(data).eq('id', sparepart['id']);
                  } else {
                    await _supabase.from('spareparts').insert(data);
                  }
                  if (mounted) {
                    Navigator.of(context).pop();
                    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Sparepart saved successfully!'), backgroundColor: Colors.green));
                    _refreshData();
                  }
                } on PostgrestException catch (e) {
                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Failed to save: ${e.message}'), backgroundColor: Colors.red));
                  }
                } catch (e) {
                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('An unexpected error occurred: $e'), backgroundColor: Colors.red));
                  }
                }
              }
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  // --- Delete Sparepart ---
  Future<void> _deleteSparepart(int id) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirm Deletion'),
        content: const Text('Are you sure you want to delete this sparepart?'),
        actions: [
          TextButton(onPressed: () => Navigator.of(context).pop(false), child: const Text('Cancel')),
          TextButton(onPressed: () => Navigator.of(context).pop(true), style: TextButton.styleFrom(foregroundColor: Colors.red), child: const Text('Delete')),
        ],
      ),
    );

    if (confirmed == true) {
      try {
        await _supabase.from('spareparts').delete().eq('id', id);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Sparepart deleted successfully.'), backgroundColor: Colors.green));
          _refreshData();
        }
      } on PostgrestException catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Failed to delete: ${e.message}'), backgroundColor: Theme.of(context).colorScheme.error));
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('An unexpected error occurred: $e'), backgroundColor: Theme.of(context).colorScheme.error));
        }
      }
    }
  }


  @override
  Widget build(BuildContext context) {
    // Check if the current user is a warehouse staff to show/hide action buttons
    final isWarehouseStaff = _currentUserRole == 'Warehouse Staff';

    return Scaffold(
      appBar: AppBar(
        title: const Text('Warehouse'),
        actions: <Widget>[
          IconButton(
            icon: const Icon(Icons.refresh),
            tooltip: 'Refresh Data',
            onPressed: _refreshData,
          ),
          if (isWarehouseStaff) // Only show add button to warehouse staff
            IconButton(
              icon: const Icon(Icons.add_circle_outline),
              tooltip: 'Add Sparepart',
              onPressed: () => _showSparepartDialog(),
            ),
        ],
      ),
      drawer: const AppDrawer(),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: _sparepartsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }
          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text('No spareparts found.'),
                  const SizedBox(height: 10),
                  ElevatedButton(
                    onPressed: _refreshData,
                    child: const Text('Try Again'),
                  )
                ],
              ),
            );
          }

          final spareparts = snapshot.data!;

          return SingleChildScrollView(
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
                    headingRowColor: WidgetStateColor.resolveWith((states) => Colors.blueGrey.shade100), // <-- PERBAIKAN DI SINI
                    border: TableBorder.all(
                        color: Colors.grey.shade400,
                        width: 1,
                        borderRadius: BorderRadius.circular(8.0)
                    ),
                    columns: <DataColumn>[
                      const DataColumn(label: Text('Part Number', style: TextStyle(fontWeight: FontWeight.bold))),
                      const DataColumn(label: Text('Name', style: TextStyle(fontWeight: FontWeight.bold))),
                      const DataColumn(label: Text('Qty', style: TextStyle(fontWeight: FontWeight.bold))),
                      const DataColumn(label: Text('Unit Price', style: TextStyle(fontWeight: FontWeight.bold))),
                      const DataColumn(label: Text('Location', style: TextStyle(fontWeight: FontWeight.bold))),
                      const DataColumn(label: Text('Last Updated', style: TextStyle(fontWeight: FontWeight.bold))),
                      const DataColumn(label: Text('Status', style: TextStyle(fontWeight: FontWeight.bold))),
                      if (isWarehouseStaff) // Only show action column to warehouse staff
                        const DataColumn(label: Text('Action', style: TextStyle(fontWeight: FontWeight.bold))),
                    ],
                    rows: spareparts.map((item) {
                      final statusInfo = _getSparepartStatus(item['quantity'] as int);
                      return DataRow(
                        cells: <DataCell>[
                          DataCell(Text(item['part_number']?.toString() ?? '')),
                          DataCell(Text(item['sparepart_name']?.toString() ?? '')),
                          DataCell(Text((item['quantity'] as int).toString())),
                          DataCell(Text(_formatCurrency(item['unit_price']))),
                          DataCell(Text(item['location']?.toString() ?? 'N/A')),
                          DataCell(Text(_formatTimestamp(item['last_updated']))),
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
                          if (isWarehouseStaff) // Only show action cells to warehouse staff
                            DataCell(
                                Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    IconButton(
                                      icon: Icon(Icons.edit, size: 20, color: Colors.blue.shade700),
                                      tooltip: 'Edit',
                                      onPressed: () => _showSparepartDialog(sparepart: item),
                                      padding: EdgeInsets.zero,
                                      constraints: const BoxConstraints(),
                                    ),
                                    const SizedBox(width: 4),
                                    IconButton(
                                      icon: Icon(Icons.delete, size: 20, color: Colors.red.shade700),
                                      tooltip: 'Delete',
                                      onPressed: () => _deleteSparepart(item['id']),
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
          );
        },
      ),
    );
  }
}