// this file holds the data model for a task
// we keep it separate so the ui files stay cleaner

class Task {
  // a unique id so we can safely find/update a task
  final String id;

  // the text the user typed
  final String title;

  // whether the task is ticked off
  final bool isDone;

  // which day bucket the task belongs to (0=today, 1=tomorrow, 2=day after)
  final int dayIndex;

  const Task({
    required this.id,
    required this.title,
    required this.isDone,
    required this.dayIndex,
  });

  // creates a new task with a few fields changed (immutable style)
  Task copyWith({
    String? id,
    String? title,
    bool? isDone,
    int? dayIndex,
  }) {
    return Task(
      id: id ?? this.id,
      title: title ?? this.title,
      isDone: isDone ?? this.isDone,
      dayIndex: dayIndex ?? this.dayIndex,
    );
  }

  // converts task -> map so we can json encode it for shared_preferences
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'isDone': isDone,
      'dayIndex': dayIndex,
    };
  }

  // converts map -> task when we load from shared_preferences
  factory Task.fromMap(Map<String, dynamic> map) {
    return Task(
      id: map['id'] as String,
      title: map['title'] as String,
      isDone: map['isDone'] as bool,
      dayIndex: map['dayIndex'] as int,
    );
  }
}
