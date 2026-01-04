
import 'package:flutter/material.dart';

import '../models/task.dart';
import '../services/storage_service.dart';
import '../widgets/day_column.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  // show 7 days.
  static const int daysToShow = 7;

  // handles saving/loading tasks.
  final StorageService _storage = StorageService();

  // all tasks for all days live here.
  final List<Task> _tasks = [];

  // week starts from today (date only, no time).
  late DateTime _startDate;

  @override
  void initState() {
    super.initState();

    // make "today" the day today
    final now = DateTime.now();
    _startDate = DateTime(now.year, now.month, now.day);

    // looad saved tasks.
    _loadTasks();
  }

  // ----------------------------
  // date helpers
  // ----------------------------

  String _two(int n) => n.toString().padLeft(2, '0');

  // Date storage key: yyyy-MM-dd (matches your Task.dateIso)
  String _iso(DateTime d) => '${d.year}-${_two(d.month)}-${_two(d.day)}';

  // ----------------------------
  // storage
  // ----------------------------

  Future<void> _loadTasks() async {
    final loaded = await _storage.loadTasks();
    setState(() {
      _tasks
        ..clear()
        ..addAll(loaded);
    });
  }

  Future<void> _saveTasks() async {
    await _storage.saveTasks(_tasks);
  }

  // ----------------------------
  // task helper
  // ----------------------------

  List<Task> _tasksForIso(String iso) =>
      _tasks.where((t) => t.dateIso == iso).toList();

  int _doneCountForIso(String iso) =>
      _tasks.where((t) => t.dateIso == iso && t.isDone).length;

  // ----------------------------
  // task action
  // ----------------------------

  Future<void> _toggleTask(String taskId, bool value) async {
    final i = _tasks.indexWhere((t) => t.id == taskId);
    if (i == -1) return;

    setState(() {
      _tasks[i] = _tasks[i].copyWith(isDone: value);
    });

    await _saveTasks();
  }

  Future<void> _deleteTask(String taskId) async {
    setState(() {
      _tasks.removeWhere((t) => t.id == taskId);
    });

    await _saveTasks();
  }

  
  
  void _moveTask(String taskId, String fromIso, String toIso) {
    // if dropped back into same day, do nothing.
    if (fromIso == toIso) return;

    final i = _tasks.indexWhere((t) => t.id == taskId);
    if (i == -1) return;

    setState(() {
      _tasks[i] = _tasks[i].copyWith(dateIso: toIso);
    });

    // save after movingg
    _saveTasks();
  }

  Future<void> _addTaskToIso(String iso, String title) async {
    final newTask = Task(
      id: DateTime.now().microsecondsSinceEpoch.toString(),
      title: title,
      isDone: false,
      dateIso: iso,
    );

    setState(() {
      _tasks.add(newTask);
    });

    await _saveTasks();
  }

  // ----------------------------
  // ading task dialog (+ button)
  // ----------------------------

  Future<void> _showAddTaskDialog() async {
    final controller = TextEditingController();
    final todayIso = _iso(_startDate);

    final String? result = await showDialog<String>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Add task'),
          content: TextField(
            controller: controller,
            autofocus: true,
            decoration: const InputDecoration(
              hintText: 'e.g. buy milk',
            ),
            onSubmitted: (_) =>
                Navigator.of(dialogContext).pop(controller.text),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(null),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () => Navigator.of(dialogContext).pop(controller.text),
              child: const Text('Add'),
            ),
          ],
        );
      },
    );

    controller.dispose();

    final text = (result ?? '').trim();
    if (text.isEmpty) return;

    await _addTaskToIso(todayIso, text);
  }

  // ----------------------------
  // UI
  // ----------------------------

  @override
  Widget build(BuildContext context) {
    final todayIso = _iso(_startDate);
    final todayTasks = _tasksForIso(todayIso);
    final todayDone = _doneCountForIso(todayIso);

    return Scaffold(
      backgroundColor: const Color(0xFFF6F1EA),
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(
              todayTotal: todayTasks.length,
              todayDone: todayDone,
            ),

            Expanded(
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.all(16),
                itemCount: daysToShow,
                itemBuilder: (context, index) {
                  final date = _startDate.add(Duration(days: index));
                  final dayIso = _iso(date);
                  final dayTasks = _tasksForIso(dayIso);

                  return Padding(
                    padding: const EdgeInsets.only(right: 12),
                    child: SizedBox(
                      width: 300,
                      child: DayColumn(
                        // DayColumn expects dayIso 
                        dayIso: dayIso,

                        // tasks for set day
                        tasks: dayTasks,

                        // callbacks
                        onToggle: _toggleTask,
                        onDelete: _deleteTask,
                        onMove: _moveTask,
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader({
    required int todayTotal,
    required int todayDone,
  }) {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 24),
      margin: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFB08968),
        borderRadius: BorderRadius.circular(20),
        boxShadow: const [
          BoxShadow(
            blurRadius: 18,
            offset: Offset(0, 10),
            color: Color(0x22000000),
          ),
        ],
      ),
      child: Row(
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'to do list',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w800,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'today: $todayTotal • done: $todayDone/$todayTotal',
                style: const TextStyle(
                  fontSize: 14,
                  color: Colors.white70,
                ),
              ),
            ],
          ),
          const Spacer(),
          Container(
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.25),
              shape: BoxShape.circle,
            ),
            child: IconButton(
              icon: const Icon(Icons.add, color: Colors.white),
              onPressed: _showAddTaskDialog,
            ),
          ),
        ],
      ),
    );
  }
}
