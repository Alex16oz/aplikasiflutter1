// lib/pages/warehouse_page.dart
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../widgets/app_drawer.dart';
import '../models/sparepart_models.dart';
import 'sparepart_detail_page.dart';

class WarehousePage extends StatefulWidget {
  const WarehousePage({super.key});
  static const String routeName = '/warehouse';

  @override
  State<WarehousePage> createState() => _WarehousePageState();
}

class _WarehousePageState extends State<WarehousePage> {
  late Future<List<SparepartSummary>> _sparepartsFuture;
  final _supabase = Supabase.instance.client;
  String? _currentUserRole;
  List<SparepartSummary> _currentSummaries = []; // Cache the summary list

  @override
  void initState() {
    super.initState();
    _refreshData(); // Panggil refresh data saat inisialisasi
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final args = ModalRoute.of(context)?.settings.arguments;
    if (args is Map<String, dynamic>) {
      _currentUserRole = args['role'];
    }
  }

  Future<void> _fetchSparepartsSummary() async {
    try {
      final response = await _supabase.rpc('get_spareparts_summary');
      final data = (response as List)
          .map((item) => SparepartSummary.fromJson(item))
          .toList();
      if (mounted) {
        setState(() {
          _currentSummaries = data;
        });
      }
    } catch (e) {
      if (mounted) {
        _showErrorSnackBar('Error fetching data: $e');
      }
    }
  }

  void _refreshData() {
    setState(() {
      _sparepartsFuture = _fetchAndReturnSparepartsSummary();
    });
  }

  Future<List<SparepartSummary>> _fetchAndReturnSparepartsSummary() async {
    final response = await _supabase.rpc('get_spareparts_summary');
    final data = (response as List)
        .map((item) => SparepartSummary.fromJson(item))
        .toList();
    if (mounted) {
      setState(() {
        _currentSummaries = data;
      });
    }
    return data;
  }

  void _showErrorSnackBar(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Theme.of(context).colorScheme.error,
      ),
    );
  }

  Map<String, dynamic> _getSparepartStatus(int totalStock, int minLevel) {
    if (totalStock <= 0) {
      return {'text': 'Kosong', 'color': Colors.red.shade400};
    } else if (totalStock <= minLevel) {
      return {'text': 'Hampir Habis', 'color': Colors.orange.shade400};
    } else {
      return {'text': 'Aman', 'color': Colors.green.shade400};
    }
  }

  Future<void> _showSparepartMasterDialog({SparepartSummary? item}) async {
    final bool isEditing = item != null;
    final formKey = GlobalKey<FormState>();
    final partNumberController = TextEditingController(text: item?.partNumber);
    final nameController = TextEditingController(text: item?.sparepartName);
    final descriptionController = TextEditingController();
    final locationController = TextEditingController(text: item?.location);
    final minStockController = TextEditingController(text: item?.minimumStockLevel.toString());

    if (isEditing && item?.id != null) {
      final fullData = await _supabase.from('spareparts').select('description').eq('id', item!.id).single();
      descriptionController.text = fullData['description'] ?? '';
    }

    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(isEditing ? 'Edit Jenis Sparepart' : 'Daftarkan Jenis Sparepart Baru'),
        content: Form(
          key: formKey,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(controller: partNumberController, decoration: const InputDecoration(labelText: 'Nomor Part'), validator: (v) => v!.isEmpty ? 'Wajib diisi' : null),
                TextFormField(controller: nameController, decoration: const InputDecoration(labelText: 'Nama Sparepart'), validator: (v) => v!.isEmpty ? 'Wajib diisi' : null),
                TextFormField(controller: descriptionController, decoration: const InputDecoration(labelText: 'Deskripsi (Opsional)')),
                TextFormField(controller: locationController, decoration: const InputDecoration(labelText: 'Lokasi Penyimpanan')),
                TextFormField(controller: minStockController, decoration: const InputDecoration(labelText: 'Stok Minimum'), keyboardType: TextInputType.number),
              ],
            ),
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.of(context).pop(), child: const Text('Batal')),
          ElevatedButton(
            onPressed: () async {
              if (formKey.currentState!.validate()) {
                try {
                  final data = {
                    'part_number': partNumberController.text.trim(),
                    'sparepart_name': nameController.text.trim(),
                    'description': descriptionController.text.trim(),
                    'location': locationController.text.trim(),
                    'minimum_stock_level': int.tryParse(minStockController.text.trim()) ?? 0,
                  };

                  if (isEditing) {
                    await _supabase.from('spareparts').update(data).eq('id', item.id);
                  } else {
                    await _supabase.from('spareparts').insert(data);
                  }

                  if (mounted) {
                    Navigator.of(context).pop();
                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Data berhasil ${isEditing ? 'diperbarui' : 'disimpan'}!'), backgroundColor: Colors.green));
                    _refreshData();
                  }
                } catch(e) {
                  if (mounted) {
                    if (e is PostgrestException && e.code == '23505') {
                      _showErrorSnackBar('Gagal: Nomor Part sudah ada.');
                    } else {
                      _showErrorSnackBar('Gagal menyimpan: $e');
                    }
                  }
                }
              }
            },
            child: const Text('Simpan'),
          ),
        ],
      ),
    );
  }

  Future<void> _deleteSparepartMaster(int id, String name) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Konfirmasi Hapus'),
        content: Text('Apakah Anda yakin ingin menghapus "$name"?\n\nPERINGATAN: Semua riwayat transaksi untuk sparepart ini juga akan ikut terhapus secara permanen.'),
        actions: [
          TextButton(onPressed: () => Navigator.of(context).pop(false), child: const Text('Batal')),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Hapus'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      try {
        await _supabase.from('spareparts').delete().eq('id', id);
        if(mounted) {
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Data berhasil dihapus.'), backgroundColor: Colors.green));
          _refreshData();
        }
      } catch (e) {
        _showErrorSnackBar('Gagal menghapus data: $e');
      }
    }
  }


  Future<void> _showAddStockInDialog() async {
    final allSpareparts = await _supabase.from('spareparts').select('id, sparepart_name, part_number').order('sparepart_name');

    final formKey = GlobalKey<FormState>();
    int? selectedSparepartId;
    final qtyController = TextEditingController();
    final priceController = TextEditingController();
    final supplierController = TextEditingController();
    final purchaseDateController = TextEditingController();

    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Catat Stok Masuk'),
        content: Form(
          key: formKey,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                DropdownButtonFormField<int>(
                  hint: const Text('Pilih Sparepart'),
                  isExpanded: true,
                  items: (allSpareparts as List).map((sparepart) {
                    return DropdownMenuItem<int>(
                      value: sparepart['id'],
                      child: Text("${sparepart['sparepart_name']} (${sparepart['part_number']})"),
                    );
                  }).toList(),
                  onChanged: (value) => selectedSparepartId = value,
                  validator: (v) => v == null ? 'Sparepart harus dipilih' : null,
                ),
                TextFormField(controller: qtyController, decoration: const InputDecoration(labelText: 'Jumlah'), keyboardType: TextInputType.number, validator: (v) => v!.isEmpty ? 'Wajib diisi' : null),
                TextFormField(controller: priceController, decoration: const InputDecoration(labelText: 'Harga per Unit'), keyboardType: TextInputType.number),
                TextFormField(controller: supplierController, decoration: const InputDecoration(labelText: 'Supplier')),
                TextFormField(
                  controller: purchaseDateController,
                  decoration: const InputDecoration(labelText: 'Tanggal Beli', hintText: 'YYYY-MM-DD'),
                  readOnly: true,
                  onTap: () async {
                    DateTime? pickedDate = await showDatePicker(context: context, initialDate: DateTime.now(), firstDate: DateTime(2000), lastDate: DateTime(2101));
                    if(pickedDate != null) {
                      purchaseDateController.text = DateFormat('yyyy-MM-dd').format(pickedDate);
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
                try {
                  await _supabase.from('stock_transactions').insert({
                    'sparepart_id': selectedSparepartId!,
                    'transaction_type': 'IN',
                    'quantity': int.parse(qtyController.text),
                    'unit_price': double.tryParse(priceController.text.trim()),
                    'supplier': supplierController.text.trim(),
                    'purchase_date': purchaseDateController.text.isEmpty ? null : purchaseDateController.text,
                    'created_by': _supabase.auth.currentUser!.id,
                  });
                  if (mounted) {
                    Navigator.of(context).pop();
                    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Stok masuk berhasil dicatat!'), backgroundColor: Colors.green));
                    _refreshData();
                  }
                } catch(e) {
                  if (mounted) {
                    _showErrorSnackBar('Gagal menyimpan: $e');
                  }
                }
              }
            },
            child: const Text('Simpan'),
          ),
        ],
      ),
    );
  }

  // =================================================================
  // FUNGSI DIALOG BARU UNTUK CATAT STOK KELUAR
  // =================================================================
  Future<void> _showAddStockOutDialog() async {
    if (_currentSummaries.isEmpty) {
      _showErrorSnackBar("Data sparepart belum termuat. Silakan coba lagi.");
      return;
    }

    final formKey = GlobalKey<FormState>();
    SparepartSummary? selectedSparepart;
    final qtyController = TextEditingController();
    final purposeController = TextEditingController();
    final retrievalDateController = TextEditingController();

    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Catat Stok Keluar'),
        content: Form(
          key: formKey,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                DropdownButtonFormField<SparepartSummary>(
                  hint: const Text('Pilih Sparepart'),
                  isExpanded: true,
                  items: _currentSummaries.map((sparepart) {
                    return DropdownMenuItem<SparepartSummary>(
                      value: sparepart,
                      child: Text("${sparepart.sparepartName} (Stok: ${sparepart.totalStock})"),
                    );
                  }).toList(),
                  onChanged: (value) => selectedSparepart = value,
                  validator: (v) => v == null ? 'Sparepart harus dipilih' : null,
                ),
                TextFormField(
                  controller: qtyController,
                  decoration: const InputDecoration(labelText: 'Jumlah yang Diambil'),
                  keyboardType: TextInputType.number,
                  validator: (v) {
                    if (v == null || v.isEmpty) return 'Wajib diisi';
                    final qty = int.tryParse(v);
                    if (qty == null || qty <= 0) return 'Jumlah tidak valid';
                    if (selectedSparepart != null && qty > selectedSparepart!.totalStock) {
                      return 'Stok tidak mencukupi (sisa: ${selectedSparepart!.totalStock})';
                    }
                    return null;
                  },
                ),
                TextFormField(
                    controller: purposeController,
                    decoration: const InputDecoration(labelText: 'Tujuan Pengambilan'),
                    validator: (v) => v!.isEmpty ? 'Wajib diisi' : null
                ),
                TextFormField(
                  controller: retrievalDateController,
                  decoration: const InputDecoration(labelText: 'Tanggal Pengambilan', hintText: 'YYYY-MM-DD'),
                  readOnly: true,
                  onTap: () async {
                    DateTime? pickedDate = await showDatePicker(
                        context: context,
                        initialDate: DateTime.now(),
                        firstDate: DateTime(2000),
                        lastDate: DateTime(2101));
                    if (pickedDate != null) {
                      retrievalDateController.text = DateFormat('yyyy-MM-dd').format(pickedDate);
                    }
                  },
                  validator: (v) => v!.isEmpty ? 'Tanggal wajib diisi' : null,
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
                try {
                  await _supabase.from('stock_transactions').insert({
                    'sparepart_id': selectedSparepart!.id,
                    'transaction_type': 'OUT',
                    'quantity': int.parse(qtyController.text),
                    'supplier': purposeController.text.trim(),
                    'purchase_date': retrievalDateController.text,
                    'created_by': _supabase.auth.currentUser!.id,
                  });
                  if (mounted) {
                    Navigator.of(context).pop();
                    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                        content: Text('Stok keluar berhasil dicatat!'),
                        backgroundColor: Colors.green));
                    _refreshData();
                  }
                } catch (e) {
                  if (mounted) {
                    _showErrorSnackBar('Gagal menyimpan: $e');
                  }
                }
              }
            },
            child: const Text('Simpan'),
          ),
        ],
      ),
    );
  }

  // =================================================================
  // FUNGSI DIALOG BARU UNTUK PENGHITUNGAN ULANG STOK (RECOUNT)
  // =================================================================
  Future<void> _showStockRecountDialog() async {
    if (_currentSummaries.isEmpty) {
      _showErrorSnackBar("Data sparepart belum termuat. Silakan coba lagi.");
      return;
    }

    final formKey = GlobalKey<FormState>();
    int? selectedSparepartId;
    final newQtyController = TextEditingController();
    final recountDateController = TextEditingController();

    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Hitung Ulang Stok Manual'),
        content: Form(
          key: formKey,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                DropdownButtonFormField<int>(
                  hint: const Text('Pilih Sparepart'),
                  isExpanded: true,
                  items: _currentSummaries.map((sparepart) {
                    return DropdownMenuItem<int>(
                      value: sparepart.id,
                      child: Text(sparepart.sparepartName),
                    );
                  }).toList(),
                  onChanged: (value) => selectedSparepartId = value,
                  validator: (v) => v == null ? 'Sparepart harus dipilih' : null,
                ),
                TextFormField(
                  controller: newQtyController,
                  decoration: const InputDecoration(labelText: 'Jumlah Stok Baru (Fisik)'),
                  keyboardType: TextInputType.number,
                  validator: (v) {
                    if (v == null || v.isEmpty) return 'Wajib diisi';
                    if (int.tryParse(v) == null) return 'Jumlah tidak valid';
                    return null;
                  },
                ),
                TextFormField(
                  controller: recountDateController,
                  decoration: const InputDecoration(labelText: 'Tanggal Penghitungan', hintText: 'YYYY-MM-DD'),
                  readOnly: true,
                  onTap: () async {
                    DateTime? pickedDate = await showDatePicker(
                        context: context,
                        initialDate: DateTime.now(),
                        firstDate: DateTime(2000),
                        lastDate: DateTime(2101));
                    if (pickedDate != null) {
                      recountDateController.text = DateFormat('yyyy-MM-dd').format(pickedDate);
                    }
                  },
                  validator: (v) => v!.isEmpty ? 'Tanggal wajib diisi' : null,
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
                try {
                  await _supabase.from('stock_transactions').insert({
                    'sparepart_id': selectedSparepartId!,
                    'transaction_type': 'RECOUNT',
                    'quantity': int.parse(newQtyController.text),
                    'purchase_date': recountDateController.text,
                    'created_by': _supabase.auth.currentUser!.id,
                  });
                  if (mounted) {
                    Navigator.of(context).pop();
                    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                        content: Text('Penghitungan ulang stok berhasil dicatat!'),
                        backgroundColor: Colors.green));
                    _refreshData();
                  }
                } catch (e) {
                  if (mounted) {
                    _showErrorSnackBar('Gagal menyimpan: $e');
                  }
                }
              }
            },
            child: const Text('Simpan Hasil Hitung'),
          ),
        ],
      ),
    );
  }

  void _navigateToDetail(SparepartSummary item) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => SparepartDetailPage(sparepartSummary: item),
      ),
    ).then((_) => _refreshData());
  }

  @override
  Widget build(BuildContext context) {
    final canManage = _currentUserRole == 'Admin' || _currentUserRole == 'Warehouse Staff';

    return Scaffold(
      appBar: AppBar(
        title: const Text('Gudang Sparepart'),
        actions: <Widget>[
          IconButton(icon: const Icon(Icons.refresh), tooltip: 'Refresh Data', onPressed: _refreshData),
          if (canManage)
            PopupMenuButton<String>(
              onSelected: (value) {
                if (value == 'add_master') {
                  _showSparepartMasterDialog();
                } else if (value == 'stock_in') {
                  _showAddStockInDialog();
                } else if (value == 'stock_out') {
                  _showAddStockOutDialog();
                } else if (value == 'recount') {
                  _showStockRecountDialog();
                }
              },
              itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
                const PopupMenuItem<String>(
                  value: 'add_master',
                  child: ListTile(leading: Icon(Icons.add_box_outlined), title: Text('Tambah Jenis Sparepart')),
                ),
                const PopupMenuItem<String>(
                  value: 'stock_in',
                  child: ListTile(leading: Icon(Icons.add_shopping_cart), title: Text('Catat Stok Masuk')),
                ),
                const PopupMenuItem<String>(
                  value: 'stock_out',
                  child: ListTile(leading: Icon(Icons.remove_shopping_cart), title: Text('Catat Stok Keluar')),
                ),
                const PopupMenuItem<String>(
                  value: 'recount',
                  child: ListTile(leading: Icon(Icons.inventory_2_outlined), title: Text('Hitung Ulang Stok')),
                ),
              ],
            ),
        ],
      ),
      drawer: const AppDrawer(),
      body: RefreshIndicator(
        onRefresh: _fetchAndReturnSparepartsSummary,
        child: FutureBuilder<List<SparepartSummary>>(
          future: _sparepartsFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }
            if (snapshot.hasError) {
              return Center(child: Text('Error: ${snapshot.error}'));
            }
            if (!snapshot.hasData || snapshot.data!.isEmpty) {
              return const Center(child: Text('Tidak ada data sparepart.'));
            }

            final spareparts = snapshot.data!;

            return SingleChildScrollView(
              scrollDirection: Axis.vertical,
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.all(16.0),
                child: DataTable(
                  columnSpacing: 20.0,
                  headingRowColor: WidgetStateColor.resolveWith((states) => Colors.blueGrey.shade100),
                  border: TableBorder.all(color: Colors.grey.shade400, width: 1, borderRadius: BorderRadius.circular(8.0)),
                  columns: const <DataColumn>[
                    DataColumn(label: Text('Part Number', style: TextStyle(fontWeight: FontWeight.bold))),
                    DataColumn(label: Text('Nama Sparepart', style: TextStyle(fontWeight: FontWeight.bold))),
                    DataColumn(label: Text('Lokasi', style: TextStyle(fontWeight: FontWeight.bold))),
                    DataColumn(label: Text('Total Stok', style: TextStyle(fontWeight: FontWeight.bold))),
                    DataColumn(label: Text('Status', style: TextStyle(fontWeight: FontWeight.bold))),
                    DataColumn(label: Text('Aksi', style: TextStyle(fontWeight: FontWeight.bold))),
                  ],
                  rows: spareparts.map((item) {
                    final statusInfo = _getSparepartStatus(item.totalStock, item.minimumStockLevel);
                    return DataRow(
                      cells: <DataCell>[
                        DataCell(Text(item.partNumber ?? 'N/A')),
                        DataCell(Text(item.sparepartName)),
                        DataCell(Text(item.location ?? 'N/A')),
                        DataCell(Text(item.totalStock.toString())),
                        DataCell(
                          Chip(
                            label: Text(statusInfo['text'], style: const TextStyle(color: Colors.white, fontSize: 12)),
                            backgroundColor: statusInfo['color'],
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                          ),
                        ),
                        DataCell(
                            Row(
                              children: [
                                IconButton(
                                  icon: Icon(Icons.visibility, color: Colors.blue.shade700, size: 20),
                                  tooltip: 'Lihat Detail',
                                  onPressed: () => _navigateToDetail(item),
                                ),
                                if (canManage) ...[
                                  IconButton(
                                    icon: Icon(Icons.edit, color: Colors.orange.shade800, size: 20),
                                    tooltip: 'Edit Jenis Sparepart',
                                    onPressed: () => _showSparepartMasterDialog(item: item),
                                  ),
                                  IconButton(
                                    icon: Icon(Icons.delete, color: Colors.red.shade700, size: 20),
                                    tooltip: 'Hapus Jenis Sparepart',
                                    onPressed: () => _deleteSparepartMaster(item.id, item.sparepartName),
                                  ),
                                ],
                              ],
                            )
                        ),
                      ],
                    );
                  }).toList(),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}