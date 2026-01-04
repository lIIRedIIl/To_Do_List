import 'package:flutter/material.dart';
import '../models/task.dart';
import 'empty_state.dart';
import 'task_card.dart';

// this widget shows one day bucket (today / tomorrow / day after)
// it is also a drag target so you can drop tasks into it
class DayColumn extends StatelessWidget {
  final String title;
  final int dayIndex;

  final List<Task> tasks;

  // called when a task is dropped into this column
  final void Function(Task task) onDropTask;

  // called when user ticks a task
  final void Function(String taskId) onToggleTask;

  // called when user long-press deletes
  final void Function(String taskId) onDeleteTask;

  const DayColumn({
    super.key,
    required this.title,
    required this.dayIndex,
    required this.tasks,
    required this.onDropTask,
    required this.onToggleTask,
    required this.onDeleteTask,
  });

  @override
  Widget build(BuildContext context) {
    // dragtarget receives a Task object from a draggable
    return DragTarget<Task>(
      onWillAccept: (task) {
        // allow dropping if the task exists and is from a different day
        if (task == null) return false;
        return task.dayIndex != dayIndex;
      },
      onAccept: (task) {
        // when dropped, tell the parent to move the task into this day
        onDropTask(task);
      },
      builder: (context, candidateData, rejectedData) {
        // if user is hovering a dragged task over this column,
        // we tint the background a bit
        final bool isHovering = candidateData.isNotEmpty;

        return Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: isHovering
                ? Colors.blue.withOpacity(0.06)
                : Colors.black.withOpacity(0.03),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: isHovering
                  ? Colors.blue.withOpacity(0.30)
                  : Colors.black.withOpacity(0.08),
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // day title
              Text(
                title,
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 10),

              // list of tasks (or empty state)
              Expanded(
                child: tasks.isEmpty
                    ? const EmptyState(message: 'no tasks yet')
                    : ListView.separated(
                        itemCount: tasks.length,
                        separatorBuilder: (_, __) => const SizedBox(height: 10),
                        itemBuilder: (context, index) {
                          final task = tasks[index];

                          // draggable wraps the task card so we can drag it between days
                          return Draggable<Task>(
                            data: task,

                            // the widget under your finger while dragging
                            feedback: ConstrainedBox(
                              constraints: const BoxConstraints(maxWidth: 320),
                              child: Opacity(
                                opacity: 0.95,
                                child: TaskCard(
                                  task: task,
                                  onToggle: () {},
                                  onDelete: () {},
                                ),
                              ),
                            ),

                            // what stays behind in the list while dragging
                            childWhenDragging: Opacity(
                              opacity: 0.35,
                              child: TaskCard(
                                task: task,
                                onToggle: () => onToggleTask(task.id),
                                onDelete: () => onDeleteTask(task.id),
                              ),
                            ),

                            child: TaskCard(
                              task: task,
                              onToggle: () => onToggleTask(task.id),
                              onDelete: () => onDeleteTask(task.id),
                            ),
                          );
                        },
                      ),
              ),
            ],
          ),
        );
      },
    );
  }
}
