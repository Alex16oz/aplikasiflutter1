// lib/pages/workshop_page.dart
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../widgets/app_drawer.dart'; // Import the AppDrawer

class WorkshopPage extends StatefulWidget {
  const WorkshopPage({super.key});

  static const String routeName = '/workshop';

  @override
  State<WorkshopPage> createState() => _WorkshopPageState();
}

class _WorkshopPageState extends State<WorkshopPage> {
  late Future<List<Map<String, dynamic>>> _machinesFuture;
  final _supabase = Supabase.instance.client;
  String? _currentUserRole;

  @override
  void initState() {
    super.initState();
    _machinesFuture = _fetchMachines();
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

  Future<List<Map<String, dynamic>>> _fetchMachines() async {
    try {
      final response = await _supabase
          .from('machines')
          .select()
          .order('machine_name', ascending: true);
      return List<Map<String, dynamic>>.from(response);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error fetching machines: $e'),
            backgroundColor: Theme.of(context).colorScheme.error,
          ),
        );
      }
      return [];
    }
  }

  void _refreshData() {
    setState(() {
      _machinesFuture = _fetchMachines();
    });
  }

  Color _getStatusColor(String? status) {
    switch (status?.toLowerCase()) {
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

  String _formatDate(String? dateString) {
    if (dateString == null) return 'N/A';
    try {
      final dateTime = DateTime.parse(dateString);
      return DateFormat('dd MMM yyyy').format(dateTime);
    } catch (e) {
      return 'Invalid Date';
    }
  }

  // --- DIALOG UNTUK TAMBAH/UBAH MESIN ---
  Future<void> _showMachineDialog({Map<String, dynamic>? machine}) async {
    final formKey = GlobalKey<FormState>();
    final isEditing = machine != null;

    // Controllers untuk setiap field
    final serialController = TextEditingController(text: machine?['serial_number']);
    final nameController = TextEditingController(text: machine?['machine_name']);
    final modelController = TextEditingController(text: machine?['model_number']);
    final manufacturerController = TextEditingController(text: machine?['manufacturer']);
    final categoryController = TextEditingController(text: machine?['category']);
    final locationController = TextEditingController(text: machine?['location']);
    final purchaseDateController = TextEditingController(text: machine?['purchase_date']);
    final statusController = TextEditingController(text: machine?['operational_status']);

    await showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: Text(isEditing ? 'Edit Machine' : 'Add New Machine'),
          content: Form(
            key: formKey,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextFormField(controller: serialController, decoration: const InputDecoration(labelText: 'Serial Number'), validator: (v) => v!.isEmpty ? 'Required' : null),
                  TextFormField(controller: nameController, decoration: const InputDecoration(labelText: 'Machine Name'), validator: (v) => v!.isEmpty ? 'Required' : null),
                  TextFormField(controller: modelController, decoration: const InputDecoration(labelText: 'Model Number')),
                  TextFormField(controller: manufacturerController, decoration: const InputDecoration(labelText: 'Manufacturer')),
                  TextFormField(controller: categoryController, decoration: const InputDecoration(labelText: 'Category')),
                  TextFormField(controller: locationController, decoration: const InputDecoration(labelText: 'Location')),
                  // --- PERUBAHAN: Input Tanggal dengan Date Picker ---
                  TextFormField(
                    controller: purchaseDateController,
                    decoration: const InputDecoration(
                      labelText: 'Purchase Date',
                      hintText: 'Select date',
                      suffixIcon: Icon(Icons.calendar_today),
                    ),
                    readOnly: true, // Membuat field tidak bisa diketik manual
                    onTap: () async {
                      // Tampilkan date picker saat field diklik
                      DateTime? pickedDate = await showDatePicker(
                          context: context,
                          initialDate: DateTime.now(),
                          firstDate: DateTime(2000),
                          lastDate: DateTime(2101));

                      if (pickedDate != null) {
                        // Format tanggal dan set ke controller
                        String formattedDate = DateFormat('yyyy-MM-dd').format(pickedDate);
                        purchaseDateController.text = formattedDate;
                      }
                    },
                  ),
                  TextFormField(controller: statusController, decoration: const InputDecoration(labelText: 'Operational Status')),
                  // --- PERUBAHAN: Input 'last_maintenance_date' dihilangkan ---
                ],
              ),
            ),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.of(context).pop(), child: const Text('Cancel')),
            ElevatedButton(
              onPressed: () async {
                if (formKey.currentState!.validate()) {
                  // Data yang akan dikirim ke Supabase
                  final data = {
                    'serial_number': serialController.text.trim(),
                    'machine_name': nameController.text.trim(),
                    'model_number': modelController.text.trim(),
                    'manufacturer': manufacturerController.text.trim(),
                    'category': categoryController.text.trim(),
                    'location': locationController.text.trim(),
                    'purchase_date': purchaseDateController.text.trim().isEmpty ? null : purchaseDateController.text.trim(),
                    'operational_status': statusController.text.trim(),
                    // 'last_maintenance_date' tidak lagi dimasukkan dari sini
                  };
                  try {
                    if (isEditing) {
                      await _supabase.from('machines').update(data).eq('id', machine['id']);
                    } else {
                      await _supabase.from('machines').insert(data);
                    }
                    if (mounted) {
                      Navigator.of(context).pop();
                      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Machine saved successfully!'), backgroundColor: Colors.green));
                      _refreshData();
                    }
                  } on PostgrestException catch (e) {
                    if (mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Failed to save: ${e.message}'), backgroundColor: Colors.red));
                    }
                  }
                }
              },
              child: const Text('Save'),
            ),
          ],
        ));
  }

  Future<void> _deleteMachine(int id) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirm Deletion'),
        content: const Text('Are you sure you want to delete this machine?'),
        actions: [
          TextButton(onPressed: () => Navigator.of(context).pop(false), child: const Text('Cancel')),
          TextButton(onPressed: () => Navigator.of(context).pop(true), style: TextButton.styleFrom(foregroundColor: Colors.red), child: const Text('Delete')),
        ],
      ),
    );

    if (confirmed == true) {
      try {
        await _supabase.from('machines').delete().eq('id', id);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Machine deleted successfully.'), backgroundColor: Colors.green,));
          _refreshData();
        }
      } on PostgrestException catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Failed to delete: ${e.message}'), backgroundColor: Theme.of(context).colorScheme.error,));
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final canManage = _currentUserRole == 'Admin' || _currentUserRole == 'Warehouse Staff';

    return Scaffold(
      appBar: AppBar(
        title: const Text('Workshop'),
        actions: <Widget>[
          IconButton(
            icon: const Icon(Icons.refresh),
            tooltip: 'Refresh Data',
            onPressed: _refreshData,
          ),
          if (canManage)
            IconButton(
              icon: const Icon(Icons.add_box_outlined),
              tooltip: 'Add Machine',
              onPressed: () => _showMachineDialog(),
            ),
        ],
      ),
      drawer: const AppDrawer(),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: _machinesFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }
          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('No machines found.'));
          }

          final machines = snapshot.data!;

          return SingleChildScrollView(
            scrollDirection: Axis.vertical,
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  const Text('Machine List', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8.0),
                  DataTable(
                    columnSpacing: 12.0,
                    horizontalMargin: 8.0,
                    headingRowColor: WidgetStateColor.resolveWith((states) => Colors.blueGrey.shade100),
                    border: TableBorder.all(color: Colors.grey.shade400, width: 1, borderRadius: BorderRadius.circular(8.0)),
                    columns: <DataColumn>[
                      const DataColumn(label: Text('Serial Number', style: TextStyle(fontWeight: FontWeight.bold))),
                      const DataColumn(label: Text('Machine Name', style: TextStyle(fontWeight: FontWeight.bold))),
                      const DataColumn(label: Text('Model', style: TextStyle(fontWeight: FontWeight.bold))),
                      const DataColumn(label: Text('Manufacturer', style: TextStyle(fontWeight: FontWeight.bold))),
                      const DataColumn(label: Text('Purchase Date', style: TextStyle(fontWeight: FontWeight.bold))),
                      const DataColumn(label: Text('Last Maintenance', style: TextStyle(fontWeight: FontWeight.bold))),
                      const DataColumn(label: Text('Status', style: TextStyle(fontWeight: FontWeight.bold))),
                      if (canManage) const DataColumn(label: Text('Action', style: TextStyle(fontWeight: FontWeight.bold))),
                    ],
                    rows: machines.map((item) {
                      return DataRow(
                        cells: <DataCell>[
                          DataCell(Text(item['serial_number'] ?? '')),
                          DataCell(Text(item['machine_name'] ?? '')),
                          DataCell(Text(item['model_number'] ?? 'N/A')),
                          DataCell(Text(item['manufacturer'] ?? 'N/A')),
                          DataCell(Text(_formatDate(item['purchase_date']))),
                          DataCell(Text(_formatDate(item['last_maintenance_date']))),
                          DataCell(
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                              decoration: BoxDecoration(color: _getStatusColor(item['operational_status']), borderRadius: BorderRadius.circular(4)),
                              child: Text(item['operational_status'] ?? 'N/A', style: const TextStyle(color: Colors.white, fontSize: 12)),
                            ),
                          ),
                          if (canManage)
                            DataCell(Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                IconButton(
                                  icon: Icon(Icons.edit, size: 20, color: Colors.blue.shade700),
                                  tooltip: 'Edit',
                                  onPressed: () => _showMachineDialog(machine: item),
                                  padding: EdgeInsets.zero,
                                  constraints: const BoxConstraints(),
                                ),
                                const SizedBox(width: 4),
                                IconButton(
                                  icon: Icon(Icons.delete, size: 20, color: Colors.red.shade700),
                                  tooltip: 'Delete',
                                  onPressed: () => _deleteMachine(item['id']),
                                  padding: EdgeInsets.zero,
                                  constraints: const BoxConstraints(),
                                ),
                              ],
                            )),
                        ],
                      );
                    }).toList(),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}