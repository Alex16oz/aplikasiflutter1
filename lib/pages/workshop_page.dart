// lib/pages/workshop_page.dart
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../widgets/app_drawer.dart'; // Pastikan path ini benar

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

  Future<void> _showReportDamageDialog(int machineId, String machineName) async {
    final formKey = GlobalKey<FormState>();
    final descriptionController = TextEditingController();

    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Laporkan Kerusakan untuk $machineName'),
        content: Form(
          key: formKey,
          child: TextFormField(
            controller: descriptionController,
            decoration: const InputDecoration(
              labelText: 'Deskripsi Kerusakan',
              alignLabelWithHint: true,
              border: OutlineInputBorder(),
            ),
            maxLines: 4,
            validator: (v) => v!.isEmpty ? 'Deskripsi wajib diisi' : null,
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.of(context).pop(), child: const Text('Batal')),
          ElevatedButton(
            onPressed: () async {
              if (formKey.currentState!.validate()) {
                try {
                  // Menggunakan RPC untuk keamanan dan atomicity
                  await _supabase.rpc('report_machine_damage', params: {
                    'p_machine_id': machineId,
                    'report_description': descriptionController.text.trim(),
                  });

                  if (mounted) {
                    Navigator.of(context).pop();
                    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                      content: Text('Laporan kerusakan berhasil dikirim!'),
                      backgroundColor: Colors.green,
                    ));
                    _refreshData();
                  }
                } catch (e) {
                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                      content: Text('Gagal mengirim laporan: $e'),
                      backgroundColor: Colors.red,
                    ));
                  }
                }
              }
            },
            child: const Text('Kirim Laporan'),
          ),
        ],
      ),
    );
  }

  Future<void> _showManualStatusUpdateDialog(int machineId, String currentStatus) async {
    final List<String> manualStatuses = ['operasional', 'tidak aktif'];
    String? selectedStatus = manualStatuses.contains(currentStatus) ? currentStatus : null;
    final formKey = GlobalKey<FormState>();

    await showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              title: const Text('Ubah Status Manual'),
              content: Form(
                key: formKey,
                child: DropdownButtonFormField<String>(
                  value: selectedStatus,
                  hint: const Text("Pilih status"),
                  items: manualStatuses
                      .map((status) => DropdownMenuItem(value: status, child: Text(status.toUpperCase())))
                      .toList(),
                  onChanged: (value) {
                    setDialogState(() {
                      selectedStatus = value;
                    });
                  },
                  validator: (value) => value == null ? 'Pilih salah satu status' : null,
                ),
              ),
              actions: [
                TextButton(onPressed: () => Navigator.of(context).pop(), child: const Text('Batal')),
                ElevatedButton(
                  onPressed: () async {
                    if (formKey.currentState!.validate()) {
                      try {
                        await _supabase
                            .from('machines')
                            .update({'operational_status': selectedStatus!})
                            .eq('id', machineId);
                        if (mounted) {
                          Navigator.of(context).pop();
                          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                              content: Text('Status berhasil diperbarui!'),
                              backgroundColor: Colors.green));
                          _refreshData();
                        }
                      } catch (e) {
                        if (mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                              content: Text('Gagal memperbarui status: $e'),
                              backgroundColor: Colors.red));
                        }
                      }
                    }
                  },
                  child: const Text('Simpan'),
                )
              ],
            );
          },
        );
      },
    );
  }

  Color _getStatusColor(String? status) {
    switch (status?.toLowerCase()) {
      case 'operasional':
        return Colors.green.shade400;
      case 'dalam perbaikan':
      case 'dalam perawatan':
        return Colors.blue.shade400;
      case 'perlu perbaikan':
        return Colors.orange.shade400;
      case 'rusak':
        return Colors.red.shade400;
      case 'tidak aktif':
        return Colors.grey.shade600;
      default:
        return Colors.grey.shade400;
    }
  }

  String _formatDate(String? dateString) {
    if (dateString == null) return 'N/A';
    try {
      final dateTime = DateTime.parse(dateString);
      return DateFormat('dd MMM yyyy', 'id_ID').format(dateTime);
    } catch (e) {
      return 'Invalid Date';
    }
  }

  Future<void> _showMachineDialog({Map<String, dynamic>? machine}) async {
    final formKey = GlobalKey<FormState>();
    final isEditing = machine != null;
    final serialController = TextEditingController(text: machine?['serial_number']);
    final nameController = TextEditingController(text: machine?['machine_name']);
    final modelController = TextEditingController(text: machine?['model_number']);
    final manufacturerController = TextEditingController(text: machine?['manufacturer']);
    final categoryController = TextEditingController(text: machine?['category']);
    final locationController = TextEditingController(text: machine?['location']);
    final purchaseDateController = TextEditingController(text: machine?['purchase_date']);

    await showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: Text(isEditing ? 'Edit Info Mesin' : 'Tambah Mesin Baru'),
          content: Form(
            key: formKey,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextFormField(controller: serialController, decoration: const InputDecoration(labelText: 'Serial Number'), validator: (v) => v!.isEmpty ? 'Wajib diisi' : null),
                  TextFormField(controller: nameController, decoration: const InputDecoration(labelText: 'Nama Mesin'), validator: (v) => v!.isEmpty ? 'Wajib diisi' : null),
                  TextFormField(controller: modelController, decoration: const InputDecoration(labelText: 'Model Number')),
                  TextFormField(controller: manufacturerController, decoration: const InputDecoration(labelText: 'Pabrikan')),
                  TextFormField(controller: categoryController, decoration: const InputDecoration(labelText: 'Kategori')),
                  TextFormField(controller: locationController, decoration: const InputDecoration(labelText: 'Lokasi')),
                  TextFormField(
                    controller: purchaseDateController,
                    decoration: const InputDecoration(
                      labelText: 'Tanggal Pembelian',
                      hintText: 'Pilih tanggal',
                      suffixIcon: Icon(Icons.calendar_today),
                    ),
                    readOnly: true,
                    onTap: () async {
                      DateTime? pickedDate = await showDatePicker(
                          context: context,
                          initialDate: DateTime.now(),
                          firstDate: DateTime(2000),
                          lastDate: DateTime(2101));
                      if (pickedDate != null) {
                        String formattedDate = DateFormat('yyyy-MM-dd').format(pickedDate);
                        purchaseDateController.text = formattedDate;
                      }
                    },
                  ),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.of(context).pop(), child: const Text('Batal')),
            ElevatedButton(
              onPressed: () async {
                if (formKey.currentState!.validate()) {
                  final data = {
                    'serial_number': serialController.text.trim(),
                    'machine_name': nameController.text.trim(),
                    'model_number': modelController.text.trim(),
                    'manufacturer': manufacturerController.text.trim(),
                    'category': categoryController.text.trim(),
                    'location': locationController.text.trim(),
                    'purchase_date': purchaseDateController.text.trim().isEmpty ? null : purchaseDateController.text.trim(),
                    if (!isEditing) 'operational_status': 'operasional',
                  };
                  try {
                    if (isEditing) {
                      await _supabase.from('machines').update(data).eq('id', machine['id']);
                    } else {
                      await _supabase.from('machines').insert(data);
                    }
                    if (mounted) {
                      Navigator.of(context).pop();
                      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Data mesin berhasil disimpan!'), backgroundColor: Colors.green));
                      _refreshData();
                    }
                  } on PostgrestException catch (e) {
                    if (mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Gagal menyimpan: ${e.message}'), backgroundColor: Colors.red));
                    }
                  }
                }
              },
              child: const Text('Simpan'),
            ),
          ],
        ));
  }

  Future<void> _deleteMachine(int id) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Konfirmasi Hapus'),
        content: const Text('Anda yakin ingin menghapus data mesin ini?'),
        actions: [
          TextButton(onPressed: () => Navigator.of(context).pop(false), child: const Text('Batal')),
          TextButton(onPressed: () => Navigator.of(context).pop(true), style: TextButton.styleFrom(foregroundColor: Colors.red), child: const Text('Hapus')),
        ],
      ),
    );

    if (confirmed == true) {
      try {
        await _supabase.from('machines').delete().eq('id', id);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Mesin berhasil dihapus.'), backgroundColor: Colors.green,));
          _refreshData();
        }
      } on PostgrestException catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Gagal menghapus: ${e.message}'), backgroundColor: Theme.of(context).colorScheme.error,));
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final canManage = _currentUserRole == 'Admin' || _currentUserRole == 'Warehouse Staff';
    final isOperator = _currentUserRole == 'Operator';
    final isAdmin = _currentUserRole == 'Admin';

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
              tooltip: 'Tambah Mesin',
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
            return const Center(child: Text('Tidak ada mesin yang terdaftar.'));
          }

          final machines = snapshot.data!;

          return RefreshIndicator(
            onRefresh: _fetchMachines,
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              scrollDirection: Axis.vertical,
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.all(16.0),
                child: DataTable(
                  columnSpacing: 12.0,
                  horizontalMargin: 8.0,
                  headingRowColor: MaterialStateColor.resolveWith((states) => Colors.blueGrey.shade100),
                  border: TableBorder.all(color: Colors.grey.shade400, width: 1, borderRadius: BorderRadius.circular(8.0)),
                  columns: const <DataColumn>[
                    DataColumn(label: Text('Serial Number', style: TextStyle(fontWeight: FontWeight.bold))),
                    DataColumn(label: Text('Nama Mesin', style: TextStyle(fontWeight: FontWeight.bold))),
                    DataColumn(label: Text('Status', style: TextStyle(fontWeight: FontWeight.bold))),
                    DataColumn(label: Text('Tgl. Pembelian', style: TextStyle(fontWeight: FontWeight.bold))),
                    DataColumn(label: Text('Perawatan Terakhir', style: TextStyle(fontWeight: FontWeight.bold))),
                    DataColumn(label: Text('Aksi', style: TextStyle(fontWeight: FontWeight.bold))),
                  ],
                  rows: machines.map((item) {
                    return DataRow(
                      cells: <DataCell>[
                        DataCell(Text(item['serial_number'] ?? '')),
                        DataCell(Text(item['machine_name'] ?? '')),
                        DataCell(
                          Chip(
                            label: Text(
                              (item['operational_status'] ?? 'N/A').toUpperCase(),
                              style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold),
                            ),
                            backgroundColor: _getStatusColor(item['operational_status']),
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                          ),
                        ),
                        DataCell(Text(_formatDate(item['purchase_date']))),
                        DataCell(Text(_formatDate(item['last_maintenance_date']))),
                        DataCell(Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            if (canManage) ...[
                              IconButton(
                                icon: Icon(Icons.edit_note, size: 22, color: Colors.blue.shade700),
                                tooltip: 'Edit Info Mesin',
                                onPressed: () => _showMachineDialog(machine: item),
                              ),
                              IconButton(
                                icon: Icon(Icons.delete_forever, size: 22, color: Colors.red.shade700),
                                tooltip: 'Hapus Mesin',
                                onPressed: () => _deleteMachine(item['id']),
                              ),
                            ],
                            if (isOperator)
                              IconButton(
                                icon: Icon(Icons.warning_amber_rounded, size: 22, color: Colors.orange.shade800),
                                tooltip: 'Laporkan Kerusakan',
                                onPressed: () => _showReportDamageDialog(item['id'], item['machine_name']),
                              ),
                            if (isAdmin)
                              IconButton(
                                icon: Icon(Icons.settings_power, size: 22, color: Colors.purple.shade700),
                                tooltip: 'Ubah Status Manual',
                                onPressed: () => _showManualStatusUpdateDialog(item['id'], item['operational_status']),
                              )
                          ],
                        )),
                      ],
                    );
                  }).toList(),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}