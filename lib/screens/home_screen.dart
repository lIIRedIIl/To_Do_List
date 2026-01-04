import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/task.dart';
import '../widgets/day_column.dart';

// this is the main page that holds the three day columns
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  // all tasks live here in memory
  final List<Task> _tasks = [];

  // key for shared_preferences storage
  static const String _storageKey = 'tasks_v1';

  // used for undo delete
  Task? _lastDeletedTask;

  @override
  void initState() {
    super.initState();
    // load saved tasks as soon as the screen starts
    _loadTasks();
  }

  // reads tasks from shared_preferences
  Future<void> _loadTasks() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_storageKey);

    if (raw == null) return;

    final decoded = jsonDecode(raw) as List;

    setState(() {
      _tasks
        ..clear()
        ..addAll(
          decoded.map((e) => Task.fromMap(Map<String, dynamic>.from(e))),
        );
    });
  }

  // saves tasks to shared_preferences whenever we change anything
  Future<void> _saveTasks() async {
    final prefs = await SharedPreferences.getInstance();

    final encoded = jsonEncode(
      _tasks.map((t) => t.toMap()).toList(),
    );

    await prefs.setString(_storageKey, encoded);
  }

  // opens a dialog so the user can add a task
  Future<void> _showAddTaskDialog() async {
    final controller = TextEditingController();

    final result = await showDialog<String>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('add task'),
          content: TextField(
            controller: controller,
            autofocus: true,
            decoration: const InputDecoration(
              hintText: 'e.g. buy milk',
            ),
            // pressing enter submits
            onSubmitted: (_) => Navigator.of(context).pop(controller.text),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(null),
              child: const Text('cancel'),
            ),
            FilledButton(
              onPressed: () => Navigator.of(context).pop(controller.text),
              child: const Text('add'),
            ),
          ],
        );
      },
    );

    controller.dispose();

    final text = (result ?? '').trim();
    if (text.isEmpty) return;

    // create a new task (default into today: dayIndex 0)
    final newTask = Task(
      id: DateTime.now().microsecondsSinceEpoch.toString(),
      title: text,
      isDone: false,
      dayIndex: 0,
    );

    setState(() {
      _tasks.add(newTask);
    });

    await _saveTasks();
  }

  // toggles a task tick
  Future<void> _toggleTask(String taskId) async {
    final index = _tasks.indexWhere((t) => t.id == taskId);
    if (index == -1) return;

    setState(() {
      final t = _tasks[index];
      _tasks[index] = t.copyWith(isDone: !t.isDone);
    });

    await _saveTasks();
  }

  // deletes a task (long press)
  Future<void> _deleteTask(String taskId) async {
    final index = _tasks.indexWhere((t) => t.id == taskId);
    if (index == -1) return;

    setState(() {
      _lastDeletedTask = _tasks.removeAt(index);
    });

    await _saveTasks();

    // show undo snackbar
    if (!mounted) return;

    ScaffoldMessenger.of(context).clearSnackBars();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('task deleted'),
        action: SnackBarAction(
          label: 'undo',
          onPressed: () async {
            final task = _lastDeletedTask;
            if (task == null) return;

            setState(() {
              _tasks.add(task);
              _lastDeletedTask = null;
            });

            await _saveTasks();
          },
        ),
      ),
    );
  }

  // moves a task to another day when dropped
  Future<void> _moveTaskToDay(Task task, int newDayIndex) async {
    final index = _tasks.indexWhere((t) => t.id == task.id);
    if (index == -1) return;

    setState(() {
      _tasks[index] = _tasks[index].copyWith(dayIndex: newDayIndex);
    });

    await _saveTasks();
  }

  // helper: get tasks for a day bucket
  List<Task> _tasksForDay(int dayIndex) {
    final list = _tasks.where((t) => t.dayIndex == dayIndex).toList();

    // simple sort: undone first, then done
    list.sort((a, b) {
      if (a.isDone == b.isDone) return 0;
      return a.isDone ? 1 : -1;
    });

    return list;
  }

  @override
  Widget build(BuildContext context) {
    // layout note:
    // - wide screens show 3 columns side-by-side
    // - narrow screens stack them vertically (still works)
    return Scaffold(
      appBar: AppBar(
        title: const Text('to do list'),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddTaskDialog,
        child: const Icon(Icons.add),
      ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          final isWide = constraints.maxWidth >= 900;

          final content = [
            DayColumn(
              title: 'today',
              dayIndex: 0,
              tasks: _tasksForDay(0),
              onDropTask: (task) => _moveTaskToDay(task, 0),
              onToggleTask: _toggleTask,
              onDeleteTask: _deleteTask,
            ),
            DayColumn(
              title: 'tomorrow',
              dayIndex: 1,
              tasks: _tasksForDay(1),
              onDropTask: (task) => _moveTaskToDay(task, 1),
              onToggleTask: _toggleTask,
              onDeleteTask: _deleteTask,
            ),
            DayColumn(
              title: 'day after',
              dayIndex: 2,
              tasks: _tasksForDay(2),
              onDropTask: (task) => _moveTaskToDay(task, 2),
              onToggleTask: _toggleTask,
              onDeleteTask: _deleteTask,
            ),
          ];

          if (isWide) {
            // side-by-side layout
            return Padding(
              padding: const EdgeInsets.all(12),
              child: Row(
                children: [
                  Expanded(child: content[0]),
                  const SizedBox(width: 12),
                  Expanded(child: content[1]),
                  const SizedBox(width: 12),
                  Expanded(child: content[2]),
                ],
              ),
            );
          }

          // stacked layout for smaller widths
          return Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              children: [
                Expanded(child: content[0]),
                const SizedBox(height: 12),
                Expanded(child: content[1]),
                const SizedBox(height: 12),
                Expanded(child: content[2]),
              ],
            ),
          );
        },
      ),
    );
  }
}
