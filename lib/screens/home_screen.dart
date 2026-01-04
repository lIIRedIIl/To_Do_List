
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
  //  show one week at a time.
  static const int daysToShow = 7;

  // storage helper (SharedPreferences wrapper).
  final StorageService _storage = StorageService();

  // all tasks for all days live here.
  final List<Task> _tasks = [];

  // start date for the week (we normalise to remove time).
  late DateTime _startDate;

  @override
  void initState() {
    super.initState();

    // today with time removed.
    final now = DateTime.now();
    _startDate = DateTime(now.year, now.month, now.day);

    // Load saved tasks when the screen opens.
    _loadTasks();
  }

  // ----------------------------
  // DATE HELPERS
  // ----------------------------

  // two digit helper: 4 -> "04"
  String _two(int n) => n.toString().padLeft(2, '0');

  String _iso(DateTime d) => '${d.year}-${_two(d.month)}-${_two(d.day)}';

  // ----------------------------
  // LOAD / SAVE
  // ----------------------------

  Future<void> _loadTasks() async {
    final loaded = await _storage.loadTasks();
    if (!mounted) return;

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
  // TASK 
  // ----------------------------

  // tasks for one day 
  List<Task> _tasksForIso(String iso) {
    return _tasks.where((t) => t.dateIso == iso).toList();
  }

  // count of done tasks for one day.
  int _doneCountForIso(String iso) {
    return _tasks.where((t) => t.dateIso == iso && t.isDone).length;
  }

  // ----------------------------
  // TASK ACTIONS
  // ----------------------------

  // toggle a task done/undone.
  Future<void> _toggleTask(String taskId, bool value) async {
    final i = _tasks.indexWhere((t) => t.id == taskId);
    if (i == -1) return;

    setState(() {
      _tasks[i] = _tasks[i].copyWith(isDone: value);
    });

    await _saveTasks();
  }

  // delete a task.
  Future<void> _deleteTask(String taskId) async {
    setState(() {
      _tasks.removeWhere((t) => t.id == taskId);
    });

    await _saveTasks();
  }

  // nove a task to a different day (used by the drag + drop).
  Future<void> _moveTaskToDateIso(String taskId, String fromIso, String toIso) async {
    // if task drops back onto the same column, do nothing.
    if (fromIso == toIso) return;

    final i = _tasks.indexWhere((t) => t.id == taskId);
    if (i == -1) return;

    setState(() {
      _tasks[i] = _tasks[i].copyWith(dateIso: toIso);
    });

    await _saveTasks();
  }

  // add a new task to a specific day iso.
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
  // ADD TASK DIALOG (used by + button)
  // ----------------------------

  // opens a box and adds the task to "today".
  Future<void> _showAddTaskDialog() async {
    final controller = TextEditingController();

    // today by default (the first column).
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

            onSubmitted: (value) {
              WidgetsBinding.instance.addPostFrameCallback((_) {
                if (Navigator.of(dialogContext).canPop()) {
                  Navigator.of(dialogContext).pop(value);
                }
              });
            },
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
  // UI  :)
  // ----------------------------

  @override
  Widget build(BuildContext context) {
    // header stats for today.
    final todayIso = _iso(_startDate);
    final todayTasks = _tasksForIso(todayIso);
    final todayDone = _doneCountForIso(todayIso);

    return Scaffold(
      backgroundColor: const Color(0xFFF6F1EA), // cozy background
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(
              todayTotal: todayTasks.length,
              todayDone: todayDone,
            ),

            // 7-day scrollable week
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
                        dayIso: dayIso,
                        tasks: dayTasks,
                        onToggle: _toggleTask,
                        onDelete: _deleteTask,
                        onMove: _moveTaskToDateIso,
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

  // banner with a  + button.
  Widget _buildHeader({
    required int todayTotal,
    required int todayDone,
  }) {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 24),
      margin: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFB08968), // coffee brown ☕
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
          // title 
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

          // + button 
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
//