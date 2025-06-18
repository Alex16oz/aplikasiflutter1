// lib/pages/my_tasks_page.dart

import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../widgets/app_drawer.dart';

class MyTasksPage extends StatefulWidget {
  const MyTasksPage({super.key});
  static const String routeName = '/my-tasks';

  @override
  State<MyTasksPage> createState() => _MyTasksPageState();
}

class _MyTasksPageState extends State<MyTasksPage> {
  final _supabase = Supabase.instance.client;
  late Future<List<Map<String, dynamic>>> _allTasksFuture;

  final Map<int, Timer> _timers = {};
  final Map<int, int> _elapsedSeconds = {};

  @override
  void initState() {
    super.initState();
    _allTasksFuture = _fetchAllTasks();
  }

  Future<List<Map<String, dynamic>>> _fetchAllTasks() async {
    final userId = _supabase.auth.currentUser?.id;
    if (userId == null) return [];

    try {
      final responses = await Future.wait([
        _supabase.rpc('get_schedules_for_user', params: {'p_user_id': userId}),
        _supabase.rpc('get_templates_for_user', params: {'p_user_id': userId}),
      ]);

      final activeTasks = List<Map<String, dynamic>>.from(responses[0]);
      final futureTasks = List<Map<String, dynamic>>.from(responses[1]);

      final combinedList = [
        ...activeTasks.map((task) => {...task, 'is_template': false}),
        ...futureTasks.map((template) => {...template, 'is_template': true}),
      ];

      return combinedList;

    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Gagal memuat semua tugas: $e')));
      }
      return [];
    }
  }

  void _refreshAllTasks() {
    setState(() {
      _allTasksFuture = _fetchAllTasks();
    });
  }

  @override
  void dispose() {
    for (var timer in _timers.values) {
      timer.cancel();
    }
    super.dispose();
  }

  DateTime _calculateNextDueDate(String type, String valueStr) {
    final now = DateTime.now();
    var today = DateTime(now.year, now.month, now.day);

    if (type == 'weekly') {
      final targetWeekday = int.parse(valueStr); // 1 for Monday, 7 for Sunday
      var nextDate = today;
      // Loop untuk menemukan hari yang tepat di minggu ini atau minggu depan
      while (nextDate.weekday != targetWeekday) {
        nextDate = nextDate.add(const Duration(days: 1));
      }
      // Jika tanggal yang ditemukan adalah hari ini tapi jam sudah lewat, atau di masa lalu, tambahkan 7 hari
      if (nextDate.isBefore(today)) {
        nextDate = nextDate.add(const Duration(days: 7));
      }
      return nextDate;
    } else if (type == 'monthly') {
      final targetDay = int.parse(valueStr);
      var nextDate = DateTime(today.year, today.month, targetDay);
      // Jika tanggalnya bulan ini sudah lewat, cari bulan depan
      if (nextDate.isBefore(today)) {
        nextDate = DateTime(today.year, today.month + 1, targetDay);
      }
      return nextDate;
    }
    return now; // Fallback
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Tugas Saya'),
        actions: [
          IconButton(onPressed: _refreshAllTasks, icon: const Icon(Icons.refresh))
        ],
      ),
      drawer: const AppDrawer(),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: _allTasksFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }
          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('Tidak ada tugas yang dialokasikan.'));
          }

          final tasks = snapshot.data!;
          final activeTasks = tasks.where((t) => t['is_template'] == false).toList();
          final futureTemplates = tasks.where((t) => t['is_template'] == true).toList();

          return RefreshIndicator(
            onRefresh: () async => _refreshAllTasks(),
            child: ListView(
              padding: const EdgeInsets.all(8),
              children: [
                if (activeTasks.isNotEmpty) ...[
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 8.0, horizontal: 8.0),
                    child: Text('TUGAS HARI INI & AKTIF', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.blueGrey)),
                  ),
                  // --- PERBAIKAN WARNING: Menghapus .toList() ---
                  ...activeTasks.map((task) => _buildActiveTaskCard(task)),
                ],
                if (futureTemplates.isNotEmpty) ...[
                  const Padding(
                    padding: EdgeInsets.only(top: 24.0, bottom: 8.0, left: 8.0, right: 8.0),
                    child: Text('RENCANA TUGAS AKAN DATANG', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.blueGrey)),
                  ),
                  // --- PERBAIKAN WARNING: Menghapus .toList() ---
                  ...futureTemplates.map((template) => _buildFutureTaskCard(template)),
                ]
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildFutureTaskCard(Map<String, dynamic> template) {
    final nextDueDate = _calculateNextDueDate(template['recurrence_type'], template['recurrence_value']);
    return Card(
      elevation: 2,
      color: Colors.grey.shade100,
      margin: const EdgeInsets.symmetric(vertical: 6),
      child: ListTile(
        // --- PERBAIKAN ERROR: Mengganti ikon yang tidak valid ---
        leading: const Icon(Icons.event_note, color: Colors.purple),
        title: Text(template['task_description'], style: const TextStyle(fontWeight: FontWeight.w600)),
        subtitle: Text(template['machine_name'] ?? 'N/A'),
        trailing: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            const Text('Akan Datang', style: TextStyle(color: Colors.purple)),
            Text(DateFormat('EEE, dd MMM', 'id_ID').format(nextDueDate), style: const TextStyle(fontWeight: FontWeight.bold)),
          ],
        ),
      ),
    );
  }

  Widget _buildActiveTaskCard(Map<String, dynamic> task) {
    final scheduleId = task['schedule_id'];
    final workLogsData = task['work_logs'];
    Map<String, dynamic>? workLog;

    if (workLogsData != null && workLogsData is List && workLogsData.isNotEmpty) {
      workLog = Map<String, dynamic>.from(workLogsData[0]);
    }

    final status = workLog?['status'] ?? 'Belum Dikerjakan';

    return Card(
      elevation: 3,
      margin: const EdgeInsets.symmetric(vertical: 6),
      color: status == 'Ditolak' ? Colors.red.shade50 : null,
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              task['machine_name'] ?? 'Nama Mesin tidak ada',
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            const Divider(),
            Text('Tugas: ${task['task_description']}'),
            Text('Jadwal: ${DateFormat('dd MMM yy').format(DateTime.parse(task['schedule_date']))}'),
            if (status == 'Ditolak' && workLog?['rejection_reason'] != null)
              Padding(
                padding: const EdgeInsets.only(top: 8.0),
                child: Text(
                  'Alasan Penolakan: ${workLog!['rejection_reason']}',
                  style: TextStyle(color: Colors.red.shade800, fontStyle: FontStyle.italic),
                ),
              ),
            const SizedBox(height: 12),
            _buildTaskActions(status, scheduleId, workLog),
          ],
        ),
      ),
    );
  }

  Widget _buildTaskActions(String status, int scheduleId, Map<String, dynamic>? workLog) {
    final workLogId = workLog?['id'];
    switch (status) {
      case 'Berlangsung':
        return Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
          Text('Waktu Berjalan: ${_formatDuration(_elapsedSeconds[workLogId] ?? 0)}', style: TextStyle(color: Colors.red.shade700, fontWeight: FontWeight.bold)),
          ElevatedButton.icon(onPressed: () => _stopWork(workLogId), icon: const Icon(Icons.stop_circle_outlined), label: const Text('Selesaikan'), style: ElevatedButton.styleFrom(backgroundColor: Colors.red)),
        ]);
      case 'Menunggu Persetujuan': return const Chip(label: Text('Menunggu Persetujuan'), backgroundColor: Colors.orangeAccent);
      case 'Disetujui': return Align(alignment: Alignment.centerRight, child: ElevatedButton.icon(onPressed: () => _showCreateReportDialog(scheduleId), icon: const Icon(Icons.assignment_turned_in_outlined), label: const Text('Buat Laporan Perbaikan'), style: ElevatedButton.styleFrom(backgroundColor: Colors.blue)));
      case 'Laporan Dibuat': return const Chip(label: Text('Laporan Telah Dibuat'), backgroundColor: Colors.tealAccent);
      case 'Ditolak': return Align(alignment: Alignment.centerRight, child: ElevatedButton.icon(onPressed: () => _showEditReportDialog(scheduleId, workLog!), icon: const Icon(Icons.edit_note), label: const Text('Edit & Kirim Ulang'), style: ElevatedButton.styleFrom(backgroundColor: Colors.orange)));
      default: return Align(alignment: Alignment.centerRight, child: ElevatedButton.icon(onPressed: () => _startWork(scheduleId), icon: const Icon(Icons.play_circle_outline), label: const Text('Mulai Tugas'), style: ElevatedButton.styleFrom(backgroundColor: Colors.green)));
    }
  }
  Future<void> _startWork(int scheduleId) async {
    try {
      final workLog = await _supabase.from('work_logs').insert({'schedule_id': scheduleId,'user_id': _supabase.auth.currentUser!.id,'start_time': DateTime.now().toUtc().toIso8601String(),'status': 'Berlangsung',}).select().single();
      final workLogId = workLog['id'] as int; _startTimer(workLogId); _refreshAllTasks();
    } catch (e) {
      if (mounted) { ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Gagal memulai tugas: $e'), backgroundColor: Colors.red)); }
    }
  }
  Future<void> _stopWork(int workLogId) async {
    final notesController = TextEditingController();
    final confirmed = await showDialog<bool>(context: context, builder: (context) => AlertDialog(title: const Text('Selesaikan Tugas?'), content: TextField(controller: notesController, decoration: const InputDecoration(labelText: 'Catatan (opsional)', hintText: 'Masukkan catatan pekerjaan...'), maxLines: 3), actions: [TextButton(onPressed: () => Navigator.of(context).pop(false), child: const Text('Batal')), ElevatedButton(onPressed: () => Navigator.of(context).pop(true), child: const Text('Selesaikan'))]));
    if (confirmed == true) {
      try {
        final startTimeResponse = await _supabase.from('work_logs').select('start_time').eq('id', workLogId).single();
        final startTimeString = startTimeResponse['start_time'] as String;
        final startTime = DateTime.parse(startTimeString);
        final endTime = DateTime.now();
        final totalDurationInMinutes = endTime.difference(startTime).inMinutes;
        const int standardWorkMinutes = 480; int overtimeMinutes = 0;
        if (totalDurationInMinutes > standardWorkMinutes) { overtimeMinutes = totalDurationInMinutes - standardWorkMinutes; }
        await _supabase.from('work_logs').update({'end_time': endTime.toUtc().toIso8601String(), 'duration_minutes': totalDurationInMinutes < 0 ? 0 : totalDurationInMinutes, 'overtime_minutes': overtimeMinutes, 'status': 'Menunggu Persetujuan', 'notes': notesController.text.trim(),}).eq('id', workLogId);
        _stopTimer(workLogId); _refreshAllTasks();
      } catch (e) { if (mounted) { ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Gagal menyelesaikan tugas: $e'), backgroundColor: Colors.red,));}}
    }
  }
  void _startTimer(int workLogId) {
    _elapsedSeconds[workLogId] = 0; _timers[workLogId] = Timer.periodic(const Duration(seconds: 1), (timer) { if (mounted) { setState(() { _elapsedSeconds[workLogId] = (_elapsedSeconds[workLogId] ?? 0) + 1; }); } else { timer.cancel(); } });
  }
  void _stopTimer(int workLogId) {
    _timers[workLogId]?.cancel(); _timers.remove(workLogId); _elapsedSeconds.remove(workLogId);
  }
  String _formatDuration(int totalSeconds) {
    final duration = Duration(seconds: totalSeconds); String twoDigits(int n) => n.toString().padLeft(2, '0'); final hours = twoDigits(duration.inHours); final minutes = twoDigits(duration.inMinutes.remainder(60)); final seconds = twoDigits(duration.inSeconds.remainder(60)); return "$hours:$minutes:$seconds";
  }
  Future<void> _showCreateReportDialog(int scheduleId) async {
    await showDialog(context: context, barrierDismissible: false, builder: (BuildContext dialogContext) { return _CreateOrEditReportDialog(scheduleId: scheduleId, onReportSubmitted: _refreshAllTasks); });
  }
  Future<void> _showEditReportDialog(int scheduleId, Map<String, dynamic> workLog) async {
    await showDialog(context: context, barrierDismissible: false, builder: (BuildContext dialogContext) { return _CreateOrEditReportDialog(scheduleId: scheduleId, existingWorkLog: workLog, onReportSubmitted: _refreshAllTasks); });
  }
}

class _CreateOrEditReportDialog extends StatefulWidget {
  final int scheduleId; final Map<String, dynamic>? existingWorkLog; final VoidCallback onReportSubmitted;
  const _CreateOrEditReportDialog({required this.scheduleId, this.existingWorkLog, required this.onReportSubmitted});
  @override
  State<_CreateOrEditReportDialog> createState() => _CreateOrEditReportDialogState();
}
class _CreateOrEditReportDialogState extends State<_CreateOrEditReportDialog> {
  final _notesController = TextEditingController(); final List<XFile> _images = []; final ImagePicker _picker = ImagePicker(); bool _isLoading = false;
  bool get _isEditing => widget.existingWorkLog != null;
  @override
  void initState() { super.initState(); if (_isEditing) { _notesController.text = widget.existingWorkLog?['notes'] ?? ''; } }
  Future<void> _pickImage() async { final XFile? image = await _picker.pickImage(source: ImageSource.gallery, imageQuality: 60); if (image != null) { setState(() { _images.add(image); }); } }
  Future<void> _submitReport() async {
    setState(() {_isLoading = true;});
    try {
      final userId = Supabase.instance.client.auth.currentUser!.id; final List<String> photoUrls = [];
      for (final image in _images) {
        final imageExtension = image.path.split('.').last.toLowerCase(); final imageBytes = await image.readAsBytes();
        final imagePath = '/$userId/${DateTime.now().millisecondsSinceEpoch}.$imageExtension';
        await Supabase.instance.client.storage.from('repair_photos').uploadBinary(imagePath, imageBytes, fileOptions: FileOptions(contentType: 'image/$imageExtension'));
        final url = Supabase.instance.client.storage.from('repair_photos').getPublicUrl(imagePath); photoUrls.add(url);
      }
      if (_isEditing) {
        await Supabase.instance.client.from('work_logs').update({'status': 'Menunggu Persetujuan','notes': _notesController.text, 'rejection_reason': null,}).eq('id', widget.existingWorkLog!['id']);
      } else {
        await Supabase.instance.client.from('repair_reports').insert({'schedule_id': widget.scheduleId,'completed_by': userId,'completion_notes': _notesController.text,'photo_urls': photoUrls,});
        await Supabase.instance.client.from('schedules').update({'status': 'Selesai'}).eq('id', widget.scheduleId);
        await Supabase.instance.client.from('work_logs').update({'status': 'Laporan Dibuat'}).eq('schedule_id', widget.scheduleId).eq('user_id', userId);
      }
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Laporan berhasil ${_isEditing ? 'dikirim ulang' : 'dikirim'}!'), backgroundColor: Colors.green,));
        Navigator.of(context).pop(); widget.onReportSubmitted();
      }
    } catch (e) { if (mounted) { ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Gagal mengirim laporan: $e'), backgroundColor: Colors.red,)); }
    } finally { if (mounted) { setState(() { _isLoading = false; }); } }
  }
  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(_isEditing ? 'Edit Laporan Kerja' : 'Buat Laporan Perbaikan'),
      content: SingleChildScrollView(child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [
        TextFormField(controller: _notesController, decoration: const InputDecoration(labelText: 'Catatan'), maxLines: 3), const SizedBox(height: 16),
        const Text('Dokumentasi Foto:'), OutlinedButton.icon(onPressed: _pickImage, icon: const Icon(Icons.add_a_photo), label: const Text('Tambah Foto')),
        if (_images.isNotEmpty) SizedBox(height: 100, child: ListView.builder(scrollDirection: Axis.horizontal, itemCount: _images.length, itemBuilder: (ctx, i) => Padding(padding: const EdgeInsets.all(4.0), child: Image.file(File(_images[i].path), width: 100, fit: BoxFit.cover)))),
      ],)),
      actions: [ TextButton(onPressed: () => Navigator.of(context).pop(), child: const Text('Batal')), ElevatedButton(onPressed: _submitReport, child: _isLoading ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(color: Colors.white)) : Text(_isEditing ? 'Kirim Ulang' : 'Kirim Laporan'))],
    );
  }
}