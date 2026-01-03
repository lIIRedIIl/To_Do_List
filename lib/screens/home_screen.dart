import 'package:flutter/material.dart';

class homeScreen extends StatelessWidget {
  const homeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // top bar of the app
      appBar: AppBar(
        title: const Text('to do list'),
      ),

      // button in the bottom right corner
      // this will be used to add new tasks later
      floatingActionButton: FloatingActionButton(
        onPressed: () {},
        child: const Icon(Icons.add),
      ),

      // main page content
      body: Padding(
        // adds spacing around the content
        padding: const EdgeInsets.all(16),

        // vertical layout
        child: Column(
          // aligns children to the left
          crossAxisAlignment: CrossAxisAlignment.start,

          children: const [
            // section title
            Text(
              'today',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w600,
              ),
            ),

            // space between title and card
            SizedBox(height: 12),

            // card shown when there are no tasks
            Card(
              child: Padding(
                padding: EdgeInsets.all(16),
                child: Text('no tasks yet'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
