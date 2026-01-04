import 'package:flutter/material.dart';

// shown when there are no tasks yet
class EmptyState extends StatelessWidget {
  const EmptyState({super.key});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Text(
          'no tasks yet',
          style: Theme.of(context).textTheme.bodyMedium,
        ),
      ),
    );
  }
}
