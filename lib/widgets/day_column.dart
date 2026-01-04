
import 'package:flutter/material.dart';

import '../models/task.dart';
import 'task_card.dart';

class DayColumn extends StatelessWidget {
  final String dayIso;
  final List<Task> tasks;

  // (taskId, newValue)
  final void Function(String taskId, bool value) onToggle;

  // (taskId)
  final void Function(String taskId) onDelete;

  // (taskId, fromIso, toIso)
  final void Function(String taskId, String fromIso, String toIso) onMove;

  const DayColumn({
    super.key,
    required this.dayIso,
    required this.tasks,
    required this.onToggle,
    required this.onDelete,
    required this.onMove,
  });

  String _two(int n) => n.toString().padLeft(2, '0');

  // Convert yyyy-mm-dd into dd/mm/yyyy for the label
  String _prettyFromIso(String iso) {
    final parts = iso.split('-'); // [yyyy, mm, dd]
    if (parts.length != 3) return iso;
    final y = parts[0];
    final m = parts[1];
    final d = parts[2];
    return '$d/$m/$y';
  }

  String _weekdayFromIso(String iso) {
    final parts = iso.split('-');
    if (parts.length != 3) return '';
    final y = int.tryParse(parts[0]) ?? 2000;
    final m = int.tryParse(parts[1]) ?? 1;
    final d = int.tryParse(parts[2]) ?? 1;

    final dt = DateTime(y, m, d);
    const names = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    return names[dt.weekday - 1];
  }

  @override
  Widget build(BuildContext context) {
    return DragTarget<DragTaskData>(
   
      onWillAcceptWithDetails: (details) => true,

      onAcceptWithDetails: (details) {
        final data = details.data;
        onMove(data.taskId, data.fromDateIso, dayIso);
      },

      builder: (context, candidate, rejected) {
        final isHovering = candidate.isNotEmpty;

        return Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: isHovering ? const Color(0xFFEFE2D4) : const Color(0xFFFDFBF8),
            borderRadius: BorderRadius.circular(18),
            border: Border.all(
              color: isHovering ? const Color(0xFFB08968) : const Color(0xFFE7DED5),
            ),
            boxShadow: const [
              BoxShadow(
                blurRadius: 16,
                offset: Offset(0, 10),
                color: Color(0x14000000),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // date
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: const Color(0xFFEADFD5),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  '${_weekdayFromIso(dayIso)} • ${_prettyFromIso(dayIso)}',
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF3B2E25),
                  ),
                ),
              ),

              const SizedBox(height: 10),

              //  drop area 
              Expanded(
                child: Container(
                  width: double.infinity,
                  color: Colors.transparent, // makes the whole area droppable
                  child: tasks.isEmpty
                      ? Center(
                          child: Text(
                            isHovering ? 'drop here' : 'no tasks yet',
                            style: const TextStyle(color: Colors.black45),
                          ),
                        )
                      : ListView.separated(
                          padding: EdgeInsets.zero,
                          itemCount: tasks.length,
                          separatorBuilder: (_, __) => const SizedBox(height: 10),
                          itemBuilder: (context, index) {
                            final task = tasks[index];
                            return TaskCard(
                              task: task,
                              onToggle: (v) => onToggle(task.id, v),
                              onDelete: () => onDelete(task.id),
                            );
                          },
                        ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
//