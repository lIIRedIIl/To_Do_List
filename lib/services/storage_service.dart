
// saves and loads tasks using shared_preferences.

import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/task.dart';

class StorageService {
  static const String _key = 'tasks_v1';

  // loads all tasks from local storage
  Future<List<Task>> loadTasks() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_key);

    if (raw == null || raw.trim().isEmpty) return [];

    final decoded = jsonDecode(raw) as List;
    return decoded
        .cast<Map<String, dynamic>>()
        .map((m) => Task.fromMap(m))
        .toList();
  }

  // save all tasks to local storage
  Future<void> saveTasks(List<Task> tasks) async {
    final prefs = await SharedPreferences.getInstance();
    final encoded = jsonEncode(tasks.map((t) => t.toMap()).toList());
    await prefs.setString(_key, encoded);
  }
}
