/// task model used across the app
class Task {
  /// unique id so we can update/delete the right task
  final String id;

  /// what the user typed
  final String title;

  /// ticked or not
  final bool isDone;

  /// due date stored as an iso date string: yyyy-mm-dd
  /// (we store iso for reliability, but display dd/mm/yyyy)
  final String dateIso;

  const Task({
    required this.id,
    required this.title,
    required this.isDone,
    required this.dateIso,
  });

  /// create a copy with some fields changed (immutable style)
  Task copyWith({
    String? id,
    String? title,
    bool? isDone,
    String? dateIso,
  }) {
    return Task(
      id: id ?? this.id,
      title: title ?? this.title,
      isDone: isDone ?? this.isDone,
      dateIso: dateIso ?? this.dateIso,
    );
  }

  /// convert task -> map so we can json encode it
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'isDone': isDone,
      'dateIso': dateIso,
    };
  }

  /// convert map -> task when we load from storage
  factory Task.fromMap(Map<String, dynamic> map) {
    return Task(
      id: map['id'] as String,
      title: map['title'] as String,
      isDone: map['isDone'] as bool,
      dateIso: map['dateIso'] as String,
    );
  }
}
//