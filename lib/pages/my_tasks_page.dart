// lib/pages/my_tasks_page.dart (KODE LENGKAP FINAL)

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
  Stream<List<Map<String, dynamic>>>? _tasksStream;
  final Map<int, Timer> _timers = {};
  final Map<int, int> _elapsedSeconds = {};

  @override
  void initState() {
    super.initState();
    _refreshTasks();
  }

  void _refreshTasks() {
    final userId = _supabase.auth.currentUser?.id;
    if (userId != null) {
      setState(() {
        _tasksStream = _supabase
            .rpc('get_schedules_for_user', params: {'p_user_id': userId})
            .asStream()
            .map((response) => List<Map<String, dynamic>>.from(response));
      });
    }
  }

  @override
  void dispose() {
    for (var timer in _timers.values) {
      timer.cancel();
    }
    super.dispose();
  }

  Future<void> _showCreateReportDialog(int scheduleId) async {
    await showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext dialogContext) {
        return _CreateReportDialog(
          scheduleId: scheduleId,
          onReportSubmitted: () {
            _refreshTasks();
          },
        );
      },
    );
  }

  Future<void> _startWork(int scheduleId) async {
    try {
      final workLog = await _supabase.from('work_logs').insert({
        'schedule_id': scheduleId,
        'user_id': _supabase.auth.currentUser!.id,
        'start_time': DateTime.now().toUtc().toIso8601String(),
        'status': 'Berlangsung',
      }).select().single();

      final workLogId = workLog['id'] as int;
      _startTimer(workLogId);
      _refreshTasks();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('Gagal memulai tugas: $e'),
          backgroundColor: Colors.red,
        ));
      }
    }
  }

  Future<void> _stopWork(int workLogId) async {
    final notesController = TextEditingController();
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Selesaikan Tugas?'),
        content: TextField(
          controller: notesController,
          decoration: const InputDecoration(
            labelText: 'Catatan (opsional)',
            hintText: 'Masukkan catatan pekerjaan...',
          ),
          maxLines: 3,
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('Batal')),
          ElevatedButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: const Text('Selesaikan')),
        ],
      ),
    );

    if (confirmed == true) {
      try {
        final startTimeResponse = await _supabase
            .from('work_logs')
            .select('start_time')
            .eq('id', workLogId)
            .single();

        final startTimeString = startTimeResponse['start_time'] as String;
        final startTime = DateTime.parse(startTimeString).toUtc();
        final endTime = DateTime.now().toUtc();
        final duration = endTime.difference(startTime).inMinutes;

        await _supabase.from('work_logs').update({
          'end_time': endTime.toIso8601String(),
          'duration_minutes': duration < 0 ? 0 : duration,
          'status': 'Menunggu Persetujuan',
          'notes': notesController.text.trim(),
        }).eq('id', workLogId);

        _stopTimer(workLogId);
        _refreshTasks();
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text('Gagal menyelesaikan tugas: $e'),
            backgroundColor: Colors.red,
          ));
        }
      }
    }
  }

  void _startTimer(int workLogId) {
    _elapsedSeconds[workLogId] = 0;
    _timers[workLogId] = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (mounted) {
        setState(() {
          _elapsedSeconds[workLogId] = (_elapsedSeconds[workLogId] ?? 0) + 1;
        });
      }
    });
  }

  void _stopTimer(int workLogId) {
    _timers[workLogId]?.cancel();
    _timers.remove(workLogId);
    _elapsedSeconds.remove(workLogId);
  }

  String _formatDuration(int totalSeconds) {
    final duration = Duration(seconds: totalSeconds);
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    final hours = twoDigits(duration.inHours);
    final minutes = twoDigits(duration.inMinutes.remainder(60));
    final seconds = twoDigits(duration.inSeconds.remainder(60));
    return "$hours:$minutes:$seconds";
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Tugas Saya'),
        actions: [
          IconButton(onPressed: _refreshTasks, icon: const Icon(Icons.refresh))
        ],
      ),
      drawer: const AppDrawer(),
      body: StreamBuilder<List<Map<String, dynamic>>>(
        stream: _tasksStream,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting &&
              _tasksStream == null) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Error memuat tugas: ${snapshot.error}'));
          }
          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text('Tidak ada tugas yang dialokasikan untuk Anda.'),
                  const SizedBox(height: 8),
                  ElevatedButton(
                      onPressed: _refreshTasks, child: const Text('Refresh'))
                ],
              ),
            );
          }

          final tasks = snapshot.data!;
          return RefreshIndicator(
            onRefresh: () async => _refreshTasks(),
            child: ListView.builder(
              padding: const EdgeInsets.all(8),
              itemCount: tasks.length,
              itemBuilder: (context, index) {
                final task = tasks[index];
                final scheduleId = task['schedule_id'];
                final workLogsData = task['work_logs'];
                Map<String, dynamic>? workLog;

                if (workLogsData != null &&
                    workLogsData is List &&
                    workLogsData.isNotEmpty) {
                  final firstLog = workLogsData[0];
                  if (firstLog is Map<String, dynamic>) {
                    workLog = firstLog;
                  }
                }

                final status = workLog?['status'] ?? 'Belum Dikerjakan';

                return Card(
                  elevation: 3,
                  margin: const EdgeInsets.symmetric(vertical: 6),
                  child: Padding(
                    padding: const EdgeInsets.all(12.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          task['machine_name'] ?? 'Nama Mesin tidak ada',
                          style: const TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 16),
                        ),
                        const Divider(),
                        Text('Tugas: ${task['task_description']}'),
                        Text(
                            'Jadwal: ${DateFormat('dd MMM yy').format(DateTime.parse(task['schedule_date']))}'),
                        const SizedBox(height: 12),
                        _buildTaskActions(status, scheduleId, workLog),
                      ],
                    ),
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }

  Widget _buildTaskActions(
      String status, int scheduleId, Map<String, dynamic>? workLog) {
    switch (status) {
      case 'Berlangsung':
        final workLogId = workLog!['id'];
        return Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Waktu Berjalan: ${_formatDuration(_elapsedSeconds[workLogId] ?? 0)}',
              style: TextStyle(
                  color: Colors.red.shade700, fontWeight: FontWeight.bold),
            ),
            ElevatedButton.icon(
              onPressed: () => _stopWork(workLogId),
              icon: const Icon(Icons.stop_circle_outlined),
              label: const Text('Selesaikan'),
              style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            ),
          ],
        );
      case 'Menunggu Persetujuan':
        return const Chip(
            label: Text('Menunggu Persetujuan'),
            backgroundColor: Colors.orangeAccent);
      case 'Disetujui':
        return Align(
          alignment: Alignment.centerRight,
          child: ElevatedButton.icon(
            onPressed: () => _showCreateReportDialog(scheduleId),
            icon: const Icon(Icons.assignment_turned_in_outlined),
            label: const Text('Buat Laporan Perbaikan'),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.blue),
          ),
        );
      case 'Laporan Dibuat':
        return const Chip(
            label: Text('Laporan Telah Dibuat'),
            backgroundColor: Colors.tealAccent);
      case 'Ditolak':
        return const Chip(
            label: Text('Pekerjaan Ditolak'),
            backgroundColor: Colors.redAccent);
      default: // 'Belum Dikerjakan'
        return Align(
          alignment: Alignment.centerRight,
          child: ElevatedButton.icon(
            onPressed: () => _startWork(scheduleId),
            icon: const Icon(Icons.play_circle_outline),
            label: const Text('Mulai Tugas'),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
          ),
        );
    }
  }
}

// Dialog untuk membuat laporan
class _CreateReportDialog extends StatefulWidget {
  final int scheduleId;
  final VoidCallback onReportSubmitted;

  const _CreateReportDialog({required this.scheduleId, required this.onReportSubmitted});

  @override
  State<_CreateReportDialog> createState() => _CreateReportDialogState();
}

class _CreateReportDialogState extends State<_CreateReportDialog> {
  final _notesController = TextEditingController();
  final List<XFile> _images = [];
  final ImagePicker _picker = ImagePicker();
  bool _isLoading = false;

  Future<void> _pickImage() async {
    final XFile? image = await _picker.pickImage(source: ImageSource.gallery, imageQuality: 60);
    if (image != null) {
      setState(() {
        _images.add(image);
      });
    }
  }

  Future<void> _submitReport() async {
    if (_isLoading) return;
    setState(() {
      _isLoading = true;
    });

    try {
      final userId = Supabase.instance.client.auth.currentUser!.id;
      final List<String> photoUrls = [];

      for (final image in _images) {
        final imageExtension = image.path.split('.').last.toLowerCase();
        final imageBytes = await image.readAsBytes();
        final imagePath =
            '/${userId}/${DateTime.now().millisecondsSinceEpoch}.$imageExtension';

        await Supabase.instance.client.storage
            .from('repair_photos')
            .uploadBinary(
          imagePath,
          imageBytes,
          fileOptions: FileOptions(contentType: 'image/$imageExtension'),
        );

        final url = Supabase.instance.client.storage
            .from('repair_photos')
            .getPublicUrl(imagePath);
        photoUrls.add(url);
      }

      await Supabase.instance.client.from('repair_reports').insert({
        'schedule_id': widget.scheduleId,
        'completed_by': userId,
        'completion_notes': _notesController.text,
        'photo_urls': photoUrls,
      });

      await Supabase.instance.client
          .from('schedules')
          .update({'status': 'Selesai'})
          .eq('id', widget.scheduleId);

      await Supabase.instance.client
          .from('work_logs')
          .update({'status': 'Laporan Dibuat'})
          .eq('schedule_id', widget.scheduleId)
          .eq('user_id', userId);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text('Laporan berhasil dikirim!'),
          backgroundColor: Colors.green,
        ));
        Navigator.of(context).pop();
        widget.onReportSubmitted();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('Gagal mengirim laporan: $e'),
          backgroundColor: Colors.red,
        ));
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Buat Laporan Perbaikan'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextField(
              controller: _notesController,
              decoration:
              const InputDecoration(labelText: 'Catatan Penyelesaian'),
              maxLines: 3,
            ),
            const SizedBox(height: 16),
            const Text('Dokumentasi Foto:'),
            OutlinedButton.icon(
              onPressed: _pickImage,
              icon: const Icon(Icons.add_a_photo),
              label: const Text('Tambah Foto'),
            ),
            if (_images.isNotEmpty)
              SizedBox(
                height: 100,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: _images.length,
                  itemBuilder: (ctx, i) => Padding(
                    padding: const EdgeInsets.all(4.0),
                    child: Image.file(File(_images[i].path),
                        width: 100, fit: BoxFit.cover),
                  ),
                ),
              ),
            // TODO: Tambahkan fungsionalitas pemilihan sparepart di sini
          ],
        ),
      ),
      actions: [
        TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Batal')),
        ElevatedButton(
          onPressed: _submitReport,
          child: _isLoading
              ? const SizedBox(
              height: 20,
              width: 20,
              child: CircularProgressIndicator(color: Colors.white))
              : const Text('Kirim Laporan'),
        )
      ],
    );
  }
}