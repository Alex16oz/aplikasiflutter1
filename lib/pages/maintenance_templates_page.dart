// lib/pages/maintenance_templates_page.dart
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../widgets/app_drawer.dart';

class MaintenanceTemplatesPage extends StatefulWidget {
  const MaintenanceTemplatesPage({super.key});
  static const String routeName = '/maintenance-templates';

  @override
  State<MaintenanceTemplatesPage> createState() => _MaintenanceTemplatesPageState();
}

class _MaintenanceTemplatesPageState extends State<MaintenanceTemplatesPage> {
  final _supabase = Supabase.instance.client;
  late Future<List<Map<String, dynamic>>> _templatesFuture;

  @override
  void initState() {
    super.initState();
    _templatesFuture = _fetchTemplates();
  }

  Future<List<Map<String, dynamic>>> _fetchTemplates() async {
    final response = await _supabase.from('maintenance_templates').select(
        '*, machines(machine_name)'
    ).order('created_at', ascending: false);
    return List<Map<String, dynamic>>.from(response);
  }

  void _refreshTemplates() {
    setState(() {
      _templatesFuture = _fetchTemplates();
    });
  }

  Future<void> _deleteTemplate(int id) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Konfirmasi Hapus'),
        content: const Text('Anda yakin ingin menghapus template jadwal ini?'),
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
        await _supabase.from('maintenance_templates').delete().eq('id', id);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Template berhasil dihapus'), backgroundColor: Colors.green)
          );
        }
        _refreshTemplates();
      } catch (e) {
        if(mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Gagal menghapus: $e'), backgroundColor: Colors.red)
          );
        }
      }
    }
  }

  String _formatRecurrence(String type, String value) {
    if (type == 'weekly') {
      final days = ['Senin', 'Selasa', 'Rabu', 'Kamis', 'Jumat', 'Sabtu', 'Minggu'];
      try {
        return 'Setiap hari ${days[int.parse(value) - 1]}';
      } catch (e) {
        return 'Setiap Minggu';
      }
    } else if (type == 'monthly') {
      return 'Setiap tanggal $value';
    }
    return 'Tidak valid';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Jadwal Perawatan Berkala'),
        actions: [
          IconButton(onPressed: _refreshTemplates, icon: const Icon(Icons.refresh))
        ],
      ),
      drawer: const AppDrawer(),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: _templatesFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }
          final templates = snapshot.data ?? [];
          if (templates.isEmpty) {
            return const Center(child: Text('Belum ada jadwal perawatan berkala.'));
          }

          return ListView.builder(
            padding: const EdgeInsets.all(8),
            itemCount: templates.length,
            itemBuilder: (context, index) {
              final template = templates[index];
              final machine = template['machines'];
              return Card(
                child: ListTile(
                  title: Text(template['task_description']),
                  subtitle: Text(
                      '${machine?['machine_name'] ?? 'N/A'}\n${_formatRecurrence(template['recurrence_type'], template['recurrence_value'])}'
                  ),
                  isThreeLine: true,
                  trailing: IconButton(
                    icon: const Icon(Icons.delete_outline, color: Colors.red),
                    onPressed: () => _deleteTemplate(template['id']),
                  ),
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showTemplateDialog(),
        tooltip: 'Buat Jadwal Baru',
        // --- PERBAIKAN WARNING: Argumen 'child' dipindahkan ke akhir ---
        child: const Icon(Icons.add),
      ),
    );
  }

  Future<void> _showTemplateDialog() async {
    showDialog(context: context, barrierDismissible: false, builder: (_) => const Center(child: CircularProgressIndicator()));

    final responses = await Future.wait([
      _supabase.from('machines').select('id, machine_name').order('machine_name'),
      _supabase.from('profiles').select('id, username').eq('role', 'Operator').order('username')
    ]);

    if (!mounted) return;
    Navigator.of(context).pop();

    final machines = List<Map<String, dynamic>>.from(responses[0]);
    final operators = List<Map<String, dynamic>>.from(responses[1]);

    final formKey = GlobalKey<FormState>();
    int? selectedMachineId;
    final taskController = TextEditingController();
    String recurrenceType = 'weekly';
    String? recurrenceValue;
    final Set<String> selectedOperatorIds = {};

    await showDialog(
      context: context,
      builder: (_) {
        return StatefulBuilder(
          builder: (dialogContext, setDialogState) {
            return AlertDialog(
              title: const Text('Buat Template Jadwal Baru'),
              content: Form(
                  key: formKey,
                  child: SingleChildScrollView(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // --- PERBAIKAN ERROR TIPE DATA ---
                        DropdownButtonFormField<int>(
                          value: selectedMachineId,
                          hint: const Text('Pilih Mesin'),
                          items: machines.map((m) {
                            return DropdownMenuItem<int>(
                              value: m['id'] as int, // Eksplisit beritahu Dart bahwa ini int
                              child: Text(m['machine_name'] as String),
                            );
                          }).toList(),
                          onChanged: (val) => selectedMachineId = val,
                          validator: (v) => v == null ? 'Mesin wajib dipilih' : null,
                        ),
                        // ------------------------------------
                        TextFormField(
                          controller: taskController,
                          decoration: const InputDecoration(labelText: 'Deskripsi Tugas'),
                          validator: (v) => v == null || v.isEmpty ? 'Tugas wajib diisi' : null,
                        ),
                        DropdownButtonFormField<String>(
                          value: recurrenceType,
                          items: const [
                            DropdownMenuItem(value: 'weekly', child: Text('Mingguan')),
                            DropdownMenuItem(value: 'monthly', child: Text('Bulanan')),
                          ],
                          onChanged: (val) {
                            setDialogState(() {
                              recurrenceType = val!;
                              recurrenceValue = null;
                            });
                          },
                        ),
                        if (recurrenceType == 'weekly')
                          DropdownButtonFormField<String>(
                            value: recurrenceValue,
                            hint: const Text('Pilih Hari'),
                            items: const [
                              DropdownMenuItem(value: '1', child: Text('Senin')),
                              DropdownMenuItem(value: '2', child: Text('Selasa')),
                              DropdownMenuItem(value: '3', child: Text('Rabu')),
                              DropdownMenuItem(value: '4', child: Text('Kamis')),
                              DropdownMenuItem(value: '5', child: Text('Jumat')),
                              DropdownMenuItem(value: '6', child: Text('Sabtu')),
                              DropdownMenuItem(value: '7', child: Text('Minggu')),
                            ],
                            onChanged: (val) => recurrenceValue = val,
                            validator: (v) => v == null ? 'Hari wajib dipilih' : null,
                          ),
                        if (recurrenceType == 'monthly')
                          DropdownButtonFormField<String>(
                            value: recurrenceValue,
                            hint: const Text('Pilih Tanggal'),
                            items: List.generate(31, (i) => DropdownMenuItem(value: (i + 1).toString(), child: Text('${i+1}'))),
                            onChanged: (val) => recurrenceValue = val,
                            validator: (v) => v == null ? 'Tanggal wajib dipilih' : null,
                          ),
                        const SizedBox(height: 16),
                        const Text('Tugaskan ke Operator:'),
                        ...operators.map((op) {
                          return CheckboxListTile(
                            title: Text(op['username']),
                            value: selectedOperatorIds.contains(op['id']),
                            onChanged: (val) {
                              setDialogState(() {
                                if (val == true) {
                                  selectedOperatorIds.add(op['id']);
                                } else {
                                  selectedOperatorIds.remove(op['id']);
                                }
                              });
                            },
                          );
                        }).toList()
                      ],
                    ),
                  )
              ),
              actions: [
                TextButton(onPressed: () => Navigator.of(dialogContext).pop(), child: const Text('Batal')),
                ElevatedButton(
                  onPressed: () async {
                    if (formKey.currentState!.validate()) {
                      try {
                        await _supabase.from('maintenance_templates').insert({
                          'machine_id': selectedMachineId!,
                          'task_description': taskController.text,
                          'recurrence_type': recurrenceType,
                          'recurrence_value': recurrenceValue!,
                          'assigned_operator_ids': selectedOperatorIds.toList(),
                          'created_by': _supabase.auth.currentUser!.id,
                        });
                        if(mounted) {
                          Navigator.of(dialogContext).pop();
                          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Template berhasil dibuat!'), backgroundColor: Colors.green,));
                          _refreshTemplates();
                        }
                      } catch (e) {
                        if(mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Gagal: $e'), backgroundColor: Colors.red));
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
}