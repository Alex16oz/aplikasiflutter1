// lib/pages/schedule_page.dart (KODE LENGKAP FINAL)

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:testflut1/pages/repair_reports_page.dart';
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

  bool _isInitialDialogShown = false;

  @override
  void initState() {
    super.initState();
    _schedulesFuture = _fetchSchedules();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    if (!_isInitialDialogShown) {
      final routeArgs = ModalRoute.of(context)?.settings.arguments;
      Map<String, dynamic>? args;

      if (routeArgs is Map) {
        args = Map<String, dynamic>.from(routeArgs);
      }

      _currentUserRole = args?['role'] ?? (args?['user']?['role']);
      _initialDamageReport = args?['damage_report'];

      if (_initialDamageReport != null) {
        _isInitialDialogShown = true;
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (mounted) {
            _showScheduleDialog(damageReport: _initialDamageReport);
          }
        });
      }
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
      if (response is! List) {
        return [];
      }
      return List<Map<String, dynamic>>.from(response);
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Error fetching schedules: $e"), backgroundColor: Colors.red));
      return [];
    }
  }

  // ... (Fungsi _deleteSchedule dan _showScheduleDialog tetap sama seperti sebelumnya) ...
  Future<void> _deleteSchedule(int scheduleId) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirm Deletion'),
        content: const Text('Are you sure you want to delete this schedule?'),
        actions: [
          TextButton(onPressed: () => Navigator.of(context).pop(false), child: const Text('Cancel')),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      try {
        await _supabase.from('schedules').delete().eq('id', scheduleId);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Schedule deleted successfully!'), backgroundColor: Colors.green));
          _refreshSchedules();
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Failed to delete schedule: $e'), backgroundColor: Colors.red));
        }
      }
    }
  }

  Future<void> _showScheduleDialog({Map<String, dynamic>? schedule, Map<String, dynamic>? damageReport}) async {
    final isEditing = schedule != null;

    showDialog(context: context, barrierDismissible: false, builder: (context) => const Center(child: CircularProgressIndicator()));

    try {
      final machinesData = await _supabase.from('machines').select('id, machine_name');
      final operatorsData = await _supabase.from('profiles').select('id, username').eq('role', 'Operator');

      Set<String> selectedOperatorIds = {};
      int? machineIdForEditing;

      if (isEditing) {
        final assignedOperatorsData = await _supabase.from('schedule_operators').select('operator_id').eq('schedule_id', schedule['schedule_id']);
        selectedOperatorIds = (assignedOperatorsData as List).map((row) => row['operator_id']).whereType<String>().toSet();
        final machineName = schedule['machine_name'];
        final machineIterable = (machinesData as List).where((m) => m['machine_name'] == machineName);
        final machine = machineIterable.isNotEmpty ? machineIterable.first : null;
        machineIdForEditing = machine?['id'];
      }

      if (mounted) Navigator.of(context).pop();

      final formKey = GlobalKey<FormState>();
      final int? initialSelectedMachineId = isEditing ? machineIdForEditing : (damageReport?['machine_id'] as int?);
      final dateController = TextEditingController(text: isEditing ? (schedule['schedule_date'] ?? '') : '');
      final descriptionController = TextEditingController(text: isEditing ? (schedule['task_description'] ?? '') : (damageReport?['description'] ?? ''));

      await showDialog<bool>(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext dialogContext) {
          int? currentMachineId = initialSelectedMachineId;
          return StatefulBuilder(
            builder: (context, setDialogState) {
              return AlertDialog(
                title: Text(isEditing ? 'Edit Schedule' : 'Create New Schedule'),
                content: Form(
                  key: formKey,
                  child: SingleChildScrollView(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        DropdownButtonFormField<int>(
                          value: currentMachineId,
                          hint: const Text('Select Machine'),
                          isExpanded: true,
                          items: (machinesData as List).map((m) => DropdownMenuItem<int>(value: m['id'], child: Text(m['machine_name'] ?? 'Unknown Machine'))).toList(),
                          onChanged: (value) => setDialogState(() => currentMachineId = value),
                          validator: (v) => v == null ? 'Machine must be selected' : null,
                        ),
                        const SizedBox(height: 16),
                        TextFormField(
                          controller: dateController,
                          decoration: const InputDecoration(labelText: 'Schedule Date', suffixIcon: Icon(Icons.calendar_today)),
                          readOnly: true,
                          onTap: () async {
                            final picked = await showDatePicker(
                              context: context,
                              initialDate: dateController.text.isNotEmpty ? DateTime.parse(dateController.text) : DateTime.now(),
                              firstDate: DateTime(2020),
                              lastDate: DateTime(2100),
                            );
                            if (picked != null) dateController.text = DateFormat('yyyy-MM-dd').format(picked);
                          },
                          validator: (v) => v!.isEmpty ? 'Date is required' : null,
                        ),
                        const SizedBox(height: 16),
                        TextFormField(controller: descriptionController, decoration: const InputDecoration(labelText: 'Task Description'), validator: (v) => v!.isEmpty ? 'Description is required' : null),
                        const SizedBox(height: 24),
                        const Text('Assign Operators', style: TextStyle(fontWeight: FontWeight.bold)),
                        const Divider(),
                        SizedBox(
                          height: 150,
                          width: double.maxFinite,
                          child: ListView(
                            children: (operatorsData as List).map((op) {
                              final operatorId = op['id'] as String;
                              return CheckboxListTile(
                                title: Text(op['username'] ?? 'Unknown Operator'),
                                value: selectedOperatorIds.contains(operatorId),
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
                            }).toList(),
                          ),
                        ),
                        if (selectedOperatorIds.isEmpty)
                          Padding(
                            padding: const EdgeInsets.only(top: 8.0),
                            child: Text('Please select at least one operator', style: TextStyle(color: Theme.of(context).colorScheme.error, fontSize: 12)),
                          ),
                      ],
                    ),
                  ),
                ),
                actions: [
                  TextButton(onPressed: () => Navigator.of(context).pop(), child: const Text('Cancel')),
                  ElevatedButton(
                    onPressed: () async {
                      if (formKey.currentState!.validate() && selectedOperatorIds.isNotEmpty) {
                        try {
                          final scheduleData = {
                            'machine_id': currentMachineId!,
                            'schedule_date': dateController.text,
                            'task_description': descriptionController.text.trim(),
                          };

                          if (isEditing) {
                            await _supabase.from('schedules').update(scheduleData).eq('id', schedule['schedule_id']);
                            await _supabase.from('schedule_operators').delete().eq('schedule_id', schedule['schedule_id']);
                            final operatorRecords = selectedOperatorIds.map((opId) => {'schedule_id': schedule['schedule_id'], 'operator_id': opId}).toList();
                            await _supabase.from('schedule_operators').insert(operatorRecords);
                          } else {
                            final newSchedule = await _supabase.from('schedules').insert({
                              ...scheduleData,
                              'created_by': _supabase.auth.currentUser!.id,
                              'damage_report_id': damageReport?['id'],
                            }).select().single();
                            final newScheduleId = newSchedule['id'];
                            final operatorRecords = selectedOperatorIds.map((opId) => {'schedule_id': newScheduleId, 'operator_id': opId}).toList();
                            await _supabase.from('schedule_operators').insert(operatorRecords);
                            if (damageReport != null) {
                              await _supabase.from('damage_reports').update({'status': 'Scheduled'}).eq('id', damageReport['id']);
                            }
                          }

                          if (mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Schedule ${isEditing ? 'updated' : 'created'} successfully!'), backgroundColor: Colors.green));
                            Navigator.of(dialogContext).pop();
                            _refreshSchedules();
                          }
                        } catch (e) {
                          if (mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Failed to save schedule: $e'), backgroundColor: Colors.red));
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
    } catch (e) {
      if (mounted) {
        Navigator.of(context).pop();
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Error preparing form: $e"), backgroundColor: Colors.red));
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
              onPressed: () => _showScheduleDialog(),
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
            if (snapshot.hasError) {
              return Center(child: Text('Error: ${snapshot.error}'));
            }
            if (!snapshot.hasData || snapshot.data!.isEmpty) {
              return const Center(child: Text('No schedules found.'));
            }
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
                    final scheduleStatus = schedule['status'] ?? 'Dijadwalkan';

                    return DataRow(
                      cells: <DataCell>[
                        DataCell(Text((schedule['schedule_date'] != null) ? DateFormat('dd MMM yy').format(DateTime.parse(schedule['schedule_date'])) : 'N/A')),
                        DataCell(Text(schedule['machine_name'] ?? 'N/A')),
                        DataCell(Text(operatorNames.isNotEmpty ? operatorNames.join(', ') : 'Not Assigned')),
                        DataCell(
                          Chip(
                            label: Text(scheduleStatus),
                            backgroundColor: _getStatusColor(scheduleStatus),
                          ),
                        ),
                        DataCell(Row(
                          children: [
                            if (scheduleStatus == 'Selesai' || scheduleStatus == 'Terverifikasi')
                              IconButton(
                                icon: Icon(Icons.description_outlined, size: 20, color: Colors.teal.shade700),
                                tooltip: 'Lihat Laporan Perbaikan',
                                onPressed: () {
                                  Navigator.push(context, MaterialPageRoute(
                                    builder: (context) => RepairReportsPage(scheduleId: schedule['schedule_id']),
                                  )).then((_) => _refreshSchedules());
                                },
                              )
                            else if (isAdmin)
                              IconButton(
                                icon: Icon(Icons.edit, size: 20, color: Colors.blue.shade700),
                                tooltip: 'Edit Schedule',
                                onPressed: () => _showScheduleDialog(schedule: schedule),
                              ),

                            if (isAdmin && scheduleStatus == 'Dijadwalkan')
                              IconButton(
                                icon: Icon(Icons.delete, size: 20, color: Colors.red.shade700),
                                tooltip: 'Delete Schedule',
                                onPressed: () => _deleteSchedule(schedule['schedule_id']),
                              ),
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

  Color _getStatusColor(String status) {
    switch (status) {
      case 'Selesai':
        return Colors.lightBlue.shade100;
      case 'Terverifikasi':
        return Colors.green.shade100;
      default: // Dijadwalkan
        return Colors.orange.shade100;
    }
  }
}