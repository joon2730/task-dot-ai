import 'package:hooks_riverpod/hooks_riverpod.dart';

import 'package:tasket/model/task.dart';
import 'package:tasket/model/task_list.dart';

// Our Notifier that reacts to changes in counterProvider
class TaskListNotifier extends Notifier<TaskList?> {
  @override
  TaskList? build() {
    return null;
  }

  void initialize(List<Task> tasks) {
    state = TaskList.initiate(tasks: tasks);
  }

  void insertTask(Task task) {
    if (state != null) {
      state = state!.insert(task);
    }
  }

  void removeTask(Task task) {
    if (state != null) {
      state = state!.remove(task);
    }
  }

  void updateTask(Task task) {
    if (state != null) {
      final newState = state!.update(task);
      if (newState != null) state = newState;
    }
  }
}

final taskListProvider = NotifierProvider<TaskListNotifier, TaskList?>(
  TaskListNotifier.new,
);
