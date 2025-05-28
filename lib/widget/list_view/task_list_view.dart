import 'package:flutter/material.dart';

import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
// import 'package:flutter_hooks/flutter_hooks.dart';

import 'package:tasket/provider/task_list_provider.dart';
import 'package:tasket/model/task_list.dart';
import 'package:tasket/provider/task_provider.dart';
import 'package:tasket/widget/tile/task_tile.dart';

class TaskListView extends HookConsumerWidget {
  const TaskListView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    TaskList? taskList = ref.watch(taskListProvider); // just watch tasklist,

    Widget buildItem(
      BuildContext context,
      int index,
      Animation<double> animation,
    ) {
      final task = taskList![index];
      return SizeTransition(
        sizeFactor: animation,
        child: TaskTile(key: ValueKey(task.id), task: task),
      );
    }

    if (taskList == null) {
      return const Center(child: CircularProgressIndicator());
    } else {
      return RefreshIndicator(
        onRefresh: ref.read(taskProvider.notifier).refresh,
        displacement: 120, // How far to pull before trigger
        edgeOffset: 80,
        color: Theme.of(context).colorScheme.primary,
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        child: SlidableAutoCloseBehavior(
          child: AnimatedList(
            key: ref.read(listKeyProvider),
            initialItemCount: taskList.length,
            itemBuilder: buildItem,
            physics: const BouncingScrollPhysics(),
          ),
        ),
      );
    }
  }
}
