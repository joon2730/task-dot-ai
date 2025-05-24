import 'package:flutter/material.dart';

import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:flutter_hooks/flutter_hooks.dart';

// import 'package:tasket/app/constants.dart';
import 'package:tasket/provider/task_provider.dart';
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
    child: TaskTile(task: removedTask, onComplete: () {}),
  );
}

class TaskListView extends HookConsumerWidget {
  const TaskListView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final listKey = useMemoized(() => GlobalKey<AnimatedListState>());
    final taskList = useState<TaskList?>(null);

    Future<void> handleRefresh() async {
      // Simulate a network call or update
      taskList.value = null;
      await ref.read(taskProvider.notifier).refresh();
    }

    useEffect(() {
      final taskAsync = ref.read(taskProvider);
      if (taskAsync.hasValue) {
        final tasks = taskAsync.value!;
        // print(tasks.map((e) => e.title).toList());
        // This block only sets taskList.value once, when it is null (first load).
        if (taskList.value == null) {
          taskList.value = TaskList(
            listKey: listKey,
            removedTaskBuilder: removedTaskBuilder,
            initialTasks: tasks..sort((a, b) => a.compareTo(b, method: 'auto')),
          );
        } else {
          // This block runs on subsequent updates, but only adds tasks not already in the list.
          final newTasks = tasks.where((task) => !task.inList);
          for (final newTask in newTasks) {
            taskList.value!.insertAt(0, newTask);
          }
        }
      }
      return null;
    }, [ref.watch(taskProvider)]);

    Widget buildItem(
      BuildContext context,
      int index,
      Animation<double> animation,
    ) {
      final task = taskList.value![index];
      return SizeTransition(
        sizeFactor: animation,
        child: TaskTile(
          key: ValueKey(task.id),
          task: task,
          onComplete: () {
            final removedTask = taskList.value!.removeAt(
              taskList.value!.indexOf(task),
            );
            ref.read(taskProvider.notifier).completeTask(removedTask);
          },
        ),
      );
    }

    if (taskList.value == null) {
      return const Center(child: CircularProgressIndicator());
    } else {
      return RefreshIndicator(
        onRefresh: handleRefresh,
        displacement: 120, // How far to pull before trigger
        edgeOffset: 80,
        color: Theme.of(context).colorScheme.primary,
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        child: AnimatedList(
          key: listKey,
          initialItemCount: taskList.value!.length,
          itemBuilder: buildItem,
          physics: const BouncingScrollPhysics(),
        ),
      );
    }
  }
}
