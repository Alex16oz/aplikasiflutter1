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

  @override
  void initState() {
    super.initState();
    _sparepartsFuture = _fetchSparepartsSummary();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final args = ModalRoute.of(context)?.settings.arguments;
    if (args is Map<String, dynamic>) {
      _currentUserRole = args['role'];
    }
  }

  Future<List<SparepartSummary>> _fetchSparepartsSummary() async {
    try {
      final response = await _supabase.rpc('get_spareparts_summary');
      return (response as List)
          .map((item) => SparepartSummary.fromJson(item))
          .toList();
    } catch (e) {
      if (mounted) {
        _showErrorSnackBar('Error fetching data: $e');
      }
      return [];
    }
  }

  void _refreshData() {
    setState(() {
      _sparepartsFuture = _fetchSparepartsSummary();
    });
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Theme.of(context).colorScheme.error,
      ),
    );
  }

  Future<void> _showAddSparepartMasterDialog() async {
    final formKey = GlobalKey<FormState>();
    final partNumberController = TextEditingController();
    final nameController = TextEditingController();
    final descriptionController = TextEditingController();
    final locationController = TextEditingController();
    final minStockController = TextEditingController();

    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Daftarkan Jenis Sparepart Baru'),
        content: Form(
          key: formKey,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(controller: partNumberController, decoration: const InputDecoration(labelText: 'Nomor Part'), validator: (v) => v!.isEmpty ? 'Wajib diisi' : null),
                TextFormField(controller: nameController, decoration: const InputDecoration(labelText: 'Nama Sparepart'), validator: (v) => v!.isEmpty ? 'Wajib diisi' : null),
                TextFormField(controller: descriptionController, decoration: const InputDecoration(labelText: 'Deskripsi')),
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
                  await _supabase.from('spareparts').insert({
                    'part_number': partNumberController.text.trim(),
                    'sparepart_name': nameController.text.trim(),
                    'description': descriptionController.text.trim(),
                    'location': locationController.text.trim(),
                    'minimum_stock_level': int.tryParse(minStockController.text.trim()) ?? 0,
                  });
                  if (mounted) {
                    Navigator.of(context).pop();
                    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Jenis sparepart baru berhasil ditambahkan!'), backgroundColor: Colors.green));
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

  @override
  Widget build(BuildContext context) {
    final canManage = _currentUserRole == 'Admin' || _currentUserRole == 'Warehouse Staff';

    return Scaffold(
      appBar: AppBar(
        title: const Text('Gudang Sparepart'),
        actions: <Widget>[
          IconButton(
            icon: const Icon(Icons.refresh),
            tooltip: 'Refresh Data',
            onPressed: _refreshData,
          ),
          if (canManage)
            IconButton(
              icon: const Icon(Icons.add_box_outlined),
              tooltip: 'Tambah Jenis Sparepart Baru',
              onPressed: _showAddSparepartMasterDialog,
            ),
          if (canManage)
            IconButton(
              icon: const Icon(Icons.add_shopping_cart),
              tooltip: 'Catat Stok Masuk',
              onPressed: _showAddStockInDialog,
            ),
        ],
      ),
      drawer: const AppDrawer(),
      body: RefreshIndicator(
        onRefresh: _fetchSparepartsSummary,
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

            return ListView.builder(
              itemCount: spareparts.length,
              itemBuilder: (context, index) {
                final item = spareparts[index];
                return Card(
                  margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                  child: ListTile(
                    title: Text(item.sparepartName, style: const TextStyle(fontWeight: FontWeight.bold)),
                    subtitle: Text('Part No: ${item.partNumber ?? "N/A"} | Lokasi: ${item.location ?? "N/A"}'),
                    trailing: Text(
                      'Stok: ${item.totalStock}',
                      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => SparepartDetailPage(sparepartSummary: item),
                        ),
                      ).then((_) => _refreshData());
                    },
                  ),
                );
              },
            );
          },
        ),
      ),
    );
  }
}