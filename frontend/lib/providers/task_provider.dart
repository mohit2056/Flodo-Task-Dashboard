import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/task_model.dart';
import '../services/api_service.dart';
import 'search_provider.dart'; // 👇 Ye import bohot zaroori tha 👇

final apiServiceProvider = Provider((ref) => ApiService());

final taskListProvider = AsyncNotifierProvider<TaskNotifier, List<Task>>(() {
  return TaskNotifier();
});

class TaskNotifier extends AsyncNotifier<List<Task>> {
  @override
  FutureOr<List<Task>> build() async {
    return ref.read(apiServiceProvider).fetchTasks();
  }

  Future<void> addTask(Task task) async {
    final apiService = ref.read(apiServiceProvider);
    try {
      final newTask = await apiService.createTask(task);
      if (state.hasValue) {
        state = AsyncData([...state.value!, newTask]);
      }
    } catch (e, stackTrace) {
      state = AsyncError(e, stackTrace);
      rethrow;
    }
  }

  Future<void> updateTask(int id, Task task) async {
    final apiService = ref.read(apiServiceProvider);
    try {
      final updatedTask = await apiService.updateTask(id, task);
      if (state.hasValue) {
        state = AsyncData([
          for (final t in state.value!)
            if (t.id == id) updatedTask else t
        ]);
      }
    } catch (e, stackTrace) {
      state = AsyncError(e, stackTrace);
      rethrow;
    }
  }

  Future<void> removeTask(int id) async {
    final apiService = ref.read(apiServiceProvider);
    try {
      await apiService.deleteTask(id);
      if (state.hasValue) {
        state = AsyncData(state.value!.where((t) => t.id != id).toList());
      }
    } catch (e, stackTrace) {
      state = AsyncError(e, stackTrace);
      rethrow;
    }
  }
}

// ==========================================
// 👇 THE FILTER PROVIDER 👇
// ==========================================
final filteredTasksProvider = Provider((ref) {
  final allTasksAsync = ref.watch(taskListProvider);
  final searchQuery = ref.watch(searchQueryProvider).toLowerCase();
  final statusFilter = ref.watch(statusFilterProvider);

  return allTasksAsync.whenData((tasks) {
    return tasks.where((task) {
      final matchesSearch = task.title.toLowerCase().contains(searchQuery) || 
                            task.description.toLowerCase().contains(searchQuery);
      final matchesStatus = statusFilter == "All" || task.status == statusFilter;
      
      return matchesSearch && matchesStatus;
    }).toList();
  });
});