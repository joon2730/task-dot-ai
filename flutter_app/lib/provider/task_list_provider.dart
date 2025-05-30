import 'package:flutter/material.dart';

import 'package:hooks_riverpod/hooks_riverpod.dart';

import 'package:tasket/model/task.dart';
import 'package:tasket/model/task_list.dart';
import 'package:tasket/widget/tile/task_tile.dart';

Widget removedTaskBuilder(
  Task removedTask,
  BuildContext context,
  Animation<double> animation,
) {
  return SizeTransition(
    sizeFactor: animation,
    child: TaskTile(task: removedTask),
  );
}

final listKeyProvider = Provider<GlobalKey<AnimatedListState>>((ref) {
  return GlobalKey<AnimatedListState>();
});

// Our Notifier that reacts to changes in counterProvider
class TaskListNotifier extends Notifier<TaskList?> {
  @override
  TaskList? build() {
    return null;
  }

  void initialize(List<Task> tasks) {
    state = TaskList(
      listKey: ref.watch(listKeyProvider),
      removedTaskBuilder: removedTaskBuilder,
      initialTasks: tasks..sort((a, b) => a.compareTo(b, method: 'auto')),
    );
  }

  void insertTask(Task task) {
    if (state != null) {
      state!.insertAt(0, task);
    }
  }

  void removeTask(Task task) {
    if (state != null) {
      state!.removeAt(state!.indexOf(task));
    }
  }
}

final taskListProvider = NotifierProvider<TaskListNotifier, TaskList?>(
  TaskListNotifier.new,
);
