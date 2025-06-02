import 'package:flutter/material.dart';

import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
// import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:implicitly_animated_reorderable_list_2/implicitly_animated_reorderable_list_2.dart';
import 'package:implicitly_animated_reorderable_list_2/transitions.dart';

import 'package:tasket/provider/task_list_provider.dart';
import 'package:tasket/provider/task_provider.dart';
import 'package:tasket/model/task.dart';
import 'package:tasket/model/list_item.dart';
import 'package:tasket/model/task_list.dart';
import 'package:tasket/widget/tile/task_tile.dart';

class TaskListView extends HookConsumerWidget {
  const TaskListView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    TaskList? taskList = ref.watch(taskListProvider); // just watch tasklist,

    Widget buildItem(ListItem item) {
      if (item is Task) {
        final task = item;
        return TaskTile(key: ValueKey(task.id), task: task);
      } else if (item is HeaderItem) {
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Text(
            item.title,
            style: Theme.of(context).textTheme.labelMedium,
          ),
        );
      }
      return SizedBox.shrink(); // exception
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
          child: ImplicitlyAnimatedList<ListItem>(
            items: taskList.items,
            areItemsTheSame: (a, b) => a.itemId == b.itemId,
            itemBuilder: (context, animation, item, index) {
              return SizeFadeTransition(
                sizeFraction: 0.7,
                curve: Curves.easeInOut,
                animation: animation,
                child: buildItem(item),
              );
            },
            removeItemBuilder: (context, animation, item) {
              return SizeFadeTransition(
                sizeFraction: 0.7,
                curve: Curves.easeInOut,
                animation: animation,
                child: buildItem(item),
              );
            },
          ),
        ),
      );
    }
  }
}
