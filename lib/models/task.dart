class Task {
  final String title;
  bool isDone;

  Task({
    required this.title,
    this.isDone = false,
  });

  // turn a task into a map for json saving
  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'isDone': isDone,
    };
  }

  // build a task from saved json data
  factory Task.fromMap(Map<String, dynamic> map) {
    return Task(
      title: (map['title'] ?? '') as String,
      isDone: (map['isDone'] ?? false) as bool,
    );
  }
}
