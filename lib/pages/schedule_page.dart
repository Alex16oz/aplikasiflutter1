// lib/pages/schedule_page.dart
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../widgets/app_drawer.dart';

class SchedulePage extends StatefulWidget {
  const SchedulePage({super.key});
  static const String routeName = '/schedule';

  @override
  State<SchedulePage> createState() => _SchedulePageState();
}

class _SchedulePageState extends State<SchedulePage> {
  late Future<List<Map<String, dynamic>>> _schedulesFuture;
  final _supabase = Supabase.instance.client;
  String? _currentUserRole;
  Map<String, dynamic>? _initialDamageReport;

  @override
  void initState() {
    super.initState();
    _schedulesFuture = _fetchSchedules();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final args = ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
    _currentUserRole = args?['role'] ?? (args?['user']?['role']);
    _initialDamageReport = args?['damage_report'];

    if (_initialDamageReport != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          _showCreateScheduleDialog(damageReport: _initialDamageReport);
        }
      });
    }
  }

  Future<void> _refreshSchedules() async {
    setState(() {
      _schedulesFuture = _fetchSchedules();
    });
  }

  Future<List<Map<String, dynamic>>> _fetchSchedules() async {
    try {
      final response = await _supabase.rpc('get_schedules_with_details');
      return List<Map<String, dynamic>>.from(response);
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Error fetching schedules: $e"), backgroundColor: Colors.red));
      return [];
    }
  }

  Future<void> _showCreateScheduleDialog({Map<String, dynamic>? damageReport}) async {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(child: CircularProgressIndicator()),
    );

    try {
      final machines = await _supabase.from('machines').select('id, machine_name');
      final operators = await _supabase.from('profiles').select('id, username').eq('role', 'Operator');

      if(mounted) Navigator.of(context).pop();

      final formKey = GlobalKey<FormState>();
      int? selectedMachineId = damageReport?['machine_id'] as int?;
      final dateController = TextEditingController();
      final descriptionController = TextEditingController(text: damageReport?['description'] as String?);
      final Set<String> selectedOperatorIds = {};

      final result = await showDialog<bool>(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext dialogContext) {
          return StatefulBuilder(
            builder: (context, setDialogState) {
              return AlertDialog(
                title: const Text('Create New Schedule'),
                content: Form(
                  key: formKey,
                  child: SingleChildScrollView(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        DropdownButtonFormField<int>(
                          value: selectedMachineId,
                          hint: const Text('Select Machine'),
                          isExpanded: true,
                          items: (machines as List).map((m) {
                            return DropdownMenuItem<int>(
                              value: m['id'] as int,
                              child: Text(m['machine_name'] as String),
                            );
                          }).toList(),
                          onChanged: (value) => setDialogState(() => selectedMachineId = value),
                          validator: (v) => v == null ? 'Machine must be selected' : null,
                        ),
                        const SizedBox(height: 16),
                        TextFormField(
                          controller: dateController,
                          decoration: const InputDecoration(labelText: 'Schedule Date', suffixIcon: Icon(Icons.calendar_today)),
                          readOnly: true,
                          onTap: () async {
                            final picked = await showDatePicker(context: context, initialDate: DateTime.now(), firstDate: DateTime.now(), lastDate: DateTime(2100));
                            if (picked != null) dateController.text = DateFormat('yyyy-MM-dd').format(picked);
                          },
                          validator: (v) => v!.isEmpty ? 'Date is required' : null,
                        ),
                        const SizedBox(height: 16),
                        TextFormField(controller: descriptionController, decoration: const InputDecoration(labelText: 'Task Description'), validator: (v) => v!.isEmpty ? 'Description is required' : null),
                        const SizedBox(height: 24),
                        const Text('Assign Operators', style: TextStyle(fontWeight: FontWeight.bold)),
                        const Divider(),
                        Container(
                          height: 150,
                          width: double.maxFinite, // Ensure container takes full width of dialog
                          decoration: BoxDecoration(border: Border.all(color: Colors.grey)),
                          child: ListView.builder(
                            shrinkWrap: true,
                            itemCount: operators.length,
                            itemBuilder: (context, index) {
                              final op = operators[index];
                              final String operatorId = op['id'] as String;
                              final String operatorName = op['username'] as String;
                              final isSelected = selectedOperatorIds.contains(operatorId);

                              return CheckboxListTile(
                                title: Text(operatorName),
                                value: isSelected,
                                onChanged: (bool? value) {
                                  setDialogState(() {
                                    if (value == true) {
                                      selectedOperatorIds.add(operatorId);
                                    } else {
                                      selectedOperatorIds.remove(operatorId);
                                    }
                                  });
                                },
                              );
                            },
                          ),
                        ),
                        if(selectedOperatorIds.isEmpty)
                          Padding(
                            padding: const EdgeInsets.only(top: 8.0),
                            child: Text('Please select at least one operator', style: TextStyle(color: Theme.of(context).colorScheme.error, fontSize: 12)),
                          ),
                      ],
                    ),
                  ),
                ),
                actions: [
                  TextButton(onPressed: () => Navigator.of(dialogContext).pop(false), child: const Text('Cancel')),
                  ElevatedButton(
                    onPressed: () async {
                      if (formKey.currentState!.validate() && selectedOperatorIds.isNotEmpty) {
                        try {
                          final newSchedule = await _supabase.from('schedules').insert({
                            'machine_id': selectedMachineId!,
                            'schedule_date': dateController.text,
                            'task_description': descriptionController.text.trim(),
                            'created_by': _supabase.auth.currentUser!.id,
                            'damage_report_id': damageReport?['id'],
                            'status': 'Scheduled',
                          }).select().single();

                          final newScheduleId = newSchedule['id'];

                          final operatorRecords = selectedOperatorIds.map((opId) => {'schedule_id': newScheduleId, 'operator_id': opId}).toList();
                          await _supabase.from('schedule_operators').insert(operatorRecords);

                          if(damageReport != null) {
                            await _supabase.from('damage_reports').update({'status': 'Scheduled'}).eq('id', damageReport['id']);
                          }

                          if(mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Schedule created successfully!'), backgroundColor: Colors.green));
                            Navigator.of(dialogContext).pop(true);
                            _refreshSchedules();
                          }

                        } catch (e) {
                          if(mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Failed to create schedule: $e'), backgroundColor: Colors.red));
                          }
                        }
                      }
                    },
                    child: const Text('Save Schedule'),
                  ),
                ],
              );
            },
          );
        },
      );
      if (damageReport != null && mounted) {
        Navigator.of(context).pop(result);
      }
    } catch (e) {
      if (mounted) {
        Navigator.of(context).pop();
        ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text("Error preparing form: $e"), backgroundColor: Colors.red)
        );
      }
    }
  }


  @override
  Widget build(BuildContext context) {
    final bool isAdmin = _currentUserRole == 'Admin';

    return Scaffold(
      appBar: AppBar(
        title: const Text('Maintenance Schedule'),
        actions: <Widget>[
          IconButton(onPressed: _refreshSchedules, icon: const Icon(Icons.refresh), tooltip: 'Refresh'),
          if (isAdmin)
            IconButton(
              icon: const Icon(Icons.add_task),
              tooltip: 'Create New Schedule',
              onPressed: _showCreateScheduleDialog,
            ),
        ],
      ),
      drawer: const AppDrawer(),
      body: RefreshIndicator(
        onRefresh: _refreshSchedules,
        child: FutureBuilder<List<Map<String, dynamic>>>(
          future: _schedulesFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }

            // --- PERBAIKAN UTAMA DI SINI ---
            // Menggunakan pendekatan yang lebih sederhana untuk kondisi error dan data kosong
            if (snapshot.hasError) {
              return ListView(
                physics: const AlwaysScrollableScrollPhysics(),
                children: [
                  Container(
                    padding: const EdgeInsets.all(48.0),
                    alignment: Alignment.center,
                    child: Text('Error: ${snapshot.error}'),
                  )
                ],
              );
            }

            if (!snapshot.hasData || snapshot.data!.isEmpty) {
              return ListView(
                physics: const AlwaysScrollableScrollPhysics(),
                children: [
                  Container(
                    height: MediaQuery.of(context).size.height * 0.7,
                    child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Text('No schedules found.'),
                          const SizedBox(height: 16),
                          ElevatedButton(onPressed: _refreshSchedules, child: const Text('Refresh')),
                        ],
                      ),
                    ),
                  )
                ],
              );
            }
            // --- AKHIR PERBAIKAN ---

            final schedules = snapshot.data!;
            return SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.all(16.0),
                child: DataTable(
                  headingRowColor: WidgetStateColor.resolveWith((states) => Colors.blueGrey.shade100),
                  border: TableBorder.all(color: Colors.grey.shade400, width: 1, borderRadius: BorderRadius.circular(8.0)),
                  columns: const <DataColumn>[
                    DataColumn(label: Text('Date', style: TextStyle(fontWeight: FontWeight.bold))),
                    DataColumn(label: Text('Machine', style: TextStyle(fontWeight: FontWeight.bold))),
                    DataColumn(label: Text('Assigned Operators', style: TextStyle(fontWeight: FontWeight.bold))),
                    DataColumn(label: Text('Status', style: TextStyle(fontWeight: FontWeight.bold))),
                    DataColumn(label: Text('Action', style: TextStyle(fontWeight: FontWeight.bold))),
                  ],
                  rows: schedules.map((schedule) {
                    final operatorNames = List<String>.from(schedule['operator_names'] ?? []);
                    return DataRow(
                      cells: <DataCell>[
                        DataCell(Text(DateFormat('dd MMM yy').format(DateTime.parse(schedule['schedule_date'])))),
                        DataCell(Text(schedule['machine_name'] ?? 'N/A')),
                        DataCell(Text(operatorNames.isNotEmpty ? operatorNames.join(', ') : 'Not Assigned')),
                        DataCell(
                            Chip(label: Text(schedule['status'] ?? 'N/A'),
                              backgroundColor: (schedule['status'] == 'Completed') ? Colors.green.shade100 : Colors.blue.shade100,
                            )
                        ),
                        DataCell(Row(
                          children: [
                            if(isAdmin) ...[
                              IconButton(icon: Icon(Icons.edit, size: 20, color: Colors.blue.shade700), onPressed: () {}),
                              IconButton(icon: Icon(Icons.delete, size: 20, color: Colors.red.shade700), onPressed: () {}),
                            ]
                          ],
                        )),
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