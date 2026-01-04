

import 'package:flutter/material.dart';
import '../models/task.dart';

// this is the data we send while dragging.
// we need the task id + which day it came from.
class DragTaskData {
  final String taskId;
  final String fromDateIso;

  const DragTaskData({
    required this.taskId,
    required this.fromDateIso,
  });
}

class TaskCard extends StatelessWidget {
  final Task task;

  // called when checkbox changes
  final void Function(bool value) onToggle;

  // called when user deletes
  final VoidCallback onDelete;

  const TaskCard({
    super.key,
    required this.task,
    required this.onToggle,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    //  nice ui 
    final cardUi = Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFE9DED3)),
        boxShadow: const [
          BoxShadow(
            blurRadius: 10,
            offset: Offset(0, 6),
            color: Color(0x11000000),
          ),
        ],
      ),
      child: Row(
        children: [
          // drag handle (ONLY this is draggable)
        
          _DragHandle(
            data: DragTaskData(taskId: task.id, fromDateIso: task.dateIso),
            previewChild: _buildDragPreview(),
          ),

          const SizedBox(width: 8),

          // checkbox (normal click works)
          Checkbox(
            value: task.isDone,
            onChanged: (v) => onToggle(v ?? false),
            activeColor: const Color(0xFFB08968),
          ),

          const SizedBox(width: 6),

          // title text
          Expanded(
            child: Text(
              task.title,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: const Color(0xFF2C211A),
                decoration: task.isDone ? TextDecoration.lineThrough : null,
              ),
            ),
          ),

          // delete button
          IconButton(
            tooltip: 'Delete',
            onPressed: onDelete,
            icon: const Icon(Icons.close, size: 18),
          ),
        ],
      ),
    );

    return cardUi;
  }

  // a small preview box that follows your mouse while dragging.
  Widget _buildDragPreview() {
    return Material(
      color: Colors.transparent,
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 280),
        child: Opacity(
          opacity: 0.9,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: const Color(0xFFE9DED3)),
              boxShadow: const [
                BoxShadow(
                  blurRadius: 10,
                  offset: Offset(0, 6),
                  color: Color(0x11000000),
                ),
              ],
            ),
            child: Text(
              task.title,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: Color(0xFF2C211A),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// a  widget that is draggable.
class _DragHandle extends StatelessWidget {
  final DragTaskData data;
  final Widget previewChild;

  const _DragHandle({
    required this.data,
    required this.previewChild,
  });

  @override
  Widget build(BuildContext context) {
    return Draggable<DragTaskData>(
      data: data,

      // where the dragged preview should anchor under the mouse
      dragAnchorStrategy: pointerDragAnchorStrategy,

      // the preview shown while dragging
      feedback: previewChild,

      // while dragging, keep the handle visible but faded
      childWhenDragging: Opacity(
        opacity: 0.35,
        child: _handleUi(),
      ),

      child: _handleUi(),
    );
  }

  Widget _handleUi() {
    return Container(
      padding: const EdgeInsets.all(6),
      decoration: BoxDecoration(
        color: const Color(0xFFF2E9DF),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: const Color(0xFFE2D6C9)),
      ),
      child: const Icon(
        Icons.drag_indicator,
        size: 18,
        color: Color(0xFF7A5A44),
      ),
    );
  }
}
//