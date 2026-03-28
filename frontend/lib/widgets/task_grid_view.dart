import 'package:flutter/material.dart';
import '../models/task_model.dart';
import 'task_card.dart';

class TaskGridView extends StatelessWidget {
  final List<Task> tasks;
  final VoidCallback onCelebration;

  const TaskGridView({super.key, required this.tasks, required this.onCelebration});

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 4,
        crossAxisSpacing: 24,
        mainAxisSpacing: 24,
        childAspectRatio: 0.85,
      ),
      itemCount: tasks.length,
      itemBuilder: (context, index) {
        return TaskCard(
          task: tasks[index],
          onCelebration: onCelebration,
        );
      },
    );
  }
}