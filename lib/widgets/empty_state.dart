import 'package:flutter/material.dart';

/// shown when a day has no tasks
class EmptyState extends StatelessWidget {
  const EmptyState({super.key});

  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.all(12),
      child: Text('no tasks yet'),
    );
  }
}
