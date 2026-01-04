import 'package:flutter/material.dart';
import '../models/task.dart';

// this is the little boxed task "card"
class TaskCard extends StatelessWidget {
  final Task task;
  final VoidCallback onToggle;
  final VoidCallback onDelete;

  const TaskCard({
    super.key,
    required this.task,
    required this.onToggle,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    // we use material so the card looks consistent and can have ink effects later
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(14),
      elevation: 1,
      child: InkWell(
        // long press deletes the task
        onLongPress: onDelete,
        borderRadius: BorderRadius.circular(14),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          child: Row(
            children: [
              // checkbox tick
              Checkbox(
                value: task.isDone,
                onChanged: (_) => onToggle(),
              ),

              const SizedBox(width: 8),

              // task title
              Expanded(
                child: Text(
                  task.title,
                  style: TextStyle(
                    fontSize: 15,
                    // strike-through if done
                    decoration:
                        task.isDone ? TextDecoration.lineThrough : null,
                    color: task.isDone
                        ? Colors.black.withOpacity(0.45)
                        : Colors.black.withOpacity(0.9),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
