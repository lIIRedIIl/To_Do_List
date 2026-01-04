import 'package:flutter/material.dart';

// a simple widget shown when a day has no tasks
class EmptyState extends StatelessWidget {
  final String message;

  const EmptyState({super.key, required this.message});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.04),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.black.withOpacity(0.08)),
      ),
      child: Text(
        message,
        style: TextStyle(color: Colors.black.withOpacity(0.6)),
      ),
    );
  }
}
