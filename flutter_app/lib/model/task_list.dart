import 'package:flutter/foundation.dart';

import 'package:tasket/model/task.dart';
import 'package:tasket/model/list_item.dart';

@immutable
final class TaskList {
  final String groupMethod;
  final List<Task> _tasks;
  final List<ListItem> _items;

  const TaskList._({
    required List<Task> tasks,
    required List<ListItem> items,
    required this.groupMethod,
  }) : _tasks = tasks,
       _items = items;

  factory TaskList.initiate({
    required List<Task> tasks,
    String groupMethod = 'date',
  }) {
    tasks.sort((a, b) => a.compareTo(b, method: groupMethod));
    return TaskList._(
      tasks: tasks,
      items: _buildList(tasks, groupMethod),
      groupMethod: groupMethod,
    );
  }

  static List<ListItem> _buildList(List<Task> tasks, String groupMethod) {
    final List<ListItem> list = [];
    String? prevGroup;
    for (final task in tasks) {
      String curGroup =
          groupMethod == 'date' ? task.dateGroup : task.priorityGroup;
      if (curGroup != prevGroup) list.add(HeaderItem(curGroup));
      list.add(task);
      prevGroup = curGroup;
    }
    return list;
  }

  String groupOf(Task task) {
    if (groupMethod == 'date') {
      return task.dateGroup;
    } else {
      // (groupMethod == 'priority')
      return task.priorityGroup;
    }
  }

  TaskList insert(Task task) {
    final updatedTasks = List<Task>.from(_tasks);
    int insertIndex = updatedTasks.indexWhere(
      (t) => task.compareTo(t, method: groupMethod) < 0,
    );
    if (insertIndex == -1) {
      updatedTasks.add(task);
    } else {
      updatedTasks.insert(insertIndex, task);
    }
    final updatedItems = _buildList(updatedTasks, groupMethod);
    return TaskList._(
      tasks: updatedTasks,
      items: updatedItems,
      groupMethod: groupMethod,
    );
  }

  TaskList remove(Task task) {
    final updatedTasks = List<Task>.from(_tasks)..remove(task);
    final updatedItems = List<ListItem>.from(_items)..remove(task);
    return TaskList._(
      tasks: updatedTasks,
      items: updatedItems,
      groupMethod: groupMethod,
    );
  }

  TaskList? update(Task task) {
    int index = _tasks.indexWhere(
      (t) => task.compareTo(t, method: groupMethod) < 0,
    );
    if (_tasks[index] != task) {
      _tasks.remove(task);
      return insert(task);
    }
    return null;
  }

  int get totalTasks => _tasks.length;

  int get length => _items.length;

  List<ListItem> get items => List.unmodifiable(_items);
}
