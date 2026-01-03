import 'package:flutter/material.dart';

/// widget shown when there are no tasks
class emptyState extends StatelessWidget {
  const emptyState({super.key});

  @override
  Widget build(BuildContext context) {
    return const Card(
      // card gives a clear visual container
      child: Padding(
        // spacing inside the card
        padding: EdgeInsets.all(16),

        // message shown when the task list is empty
        child: Text(
          'no tasks yet',
        ),
      ),
    );
  }
}

