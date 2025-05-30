import 'package:flutter/material.dart';
import 'package:tasket/model/task.dart';

typedef RemovedTaskBuilder =
    Widget Function(
      Task task,
      BuildContext context,
      Animation<double> animation,
    );

class TaskList {
  TaskList({
    required this.listKey,
    required this.removedTaskBuilder,
    Iterable<Task>? initialTasks,
  }) : _tasks = List<Task>.from(initialTasks ?? <Task>[]);

  final GlobalKey<AnimatedListState> listKey;
  final RemovedTaskBuilder removedTaskBuilder;
  final List<Task> _tasks;

  AnimatedListState? get _animatedList => listKey.currentState;

  void insertAt(int index, Task task) {
    _tasks.insert(index, task);
    _animatedList?.insertItem(index);
  }

  Task removeAt(int index) {
    final Task removedTask = _tasks.removeAt(index);
    _animatedList?.removeItem(
      index,
      (context, animation) =>
          removedTaskBuilder(removedTask, context, animation),
    );
    return removedTask;
  }

  int get length => _tasks.length;

  Task operator [](int index) => _tasks[index];

  int indexOf(Task task) => _tasks.indexWhere((t) => t.id == task.id);

  List<Task> get tasks => List.unmodifiable(_tasks);
}
