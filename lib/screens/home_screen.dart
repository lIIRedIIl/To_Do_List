import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/task.dart';
import '../widgets/empty_state.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  // in-memory list of tasks
  final List<Task> _tasks = [];

  // key used in shared preferences
  static const String _storageKey = 'tasks';

  @override
  void initState() {
    super.initState();
    _loadTasks();
  }

  // load tasks when the app starts
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

  // save tasks any time we change them
  Future<void> _saveTasks() async {
    final prefs = await SharedPreferences.getInstance();
    final encoded = jsonEncode(_tasks.map((t) => t.toMap()).toList());
    await prefs.setString(_storageKey, encoded);
  }

  // toggle done/undone when checkbox changes
  void _toggleTask(int index, bool? value) {
    setState(() {
      _tasks[index].isDone = value ?? false;
    });
    _saveTasks();
  }

  // remove a task (used by long press)
  void _removeTask(int index) {
    setState(() {
      _tasks.removeAt(index);
    });
    _saveTasks();
  }

  // show dialog to add a task
  Future<void> _showAddTaskDialog() async {
    final controller = TextEditingController();

    final String? result = await showDialog<String>(
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
            onSubmitted: (_) {
              Navigator.of(context).pop(controller.text);
            },
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

    setState(() {
      _tasks.add(Task(title: text));
    });

    _saveTasks();
  }

  @override
  Widget build(BuildContext context) {
    final hasTasks = _tasks.isNotEmpty;

    return Scaffold(
      appBar: AppBar(
        title: const Text('to do list'),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddTaskDialog,
        child: const Icon(Icons.add),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'today',
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 12),

            // empty message vs list
            if (!hasTasks)
              const EmptyState()
            else
              Expanded(
                child: ListView.builder(
                  itemCount: _tasks.length,
                  itemBuilder: (context, index) {
                    final task = _tasks[index];

                    // long press needs a wrapper to work
                    return InkWell(
                      onLongPress: () => _removeTask(index),
                      child: CheckboxListTile(
                        value: task.isDone,
                        title: Text(task.title),
                        onChanged: (value) => _toggleTask(index, value),
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
}
