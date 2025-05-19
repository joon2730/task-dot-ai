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
    final taskListAsync = ref.watch(taskProvider);
    final listKey = useMemoized(() => GlobalKey<AnimatedListState>());
    final taskList = useState<TaskList?>(null);

    useEffect(() {
      if (taskListAsync.hasValue) {
        if (taskList.value == null) {
          final tasks = taskListAsync.value!;
          taskList.value = TaskList(
            listKey: listKey,
            removedTaskBuilder: removedTaskBuilder,
            initialTasks: tasks..sort((a, b) => a.compareTo(b, method: 'auto')),
          );
        } else {
          final newTasks = taskListAsync.value!.where((task) => !task.inList);
          for (final newTask in newTasks) {
            taskList.value!.insertAt(0, newTask);
          }
        }
      }
      return null;
    }, [taskListAsync]);

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
            final removedTask = taskList.value!.removeAt(index);
            ref.read(taskProvider.notifier).deleteTask(removedTask.id);
          },
        ),
      );
    }

    return taskListAsync.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error:
          (error, stackTrace) =>
              const Center(child: Text('Something went wrong')),
      data: (_) {
        if (taskList.value == null) {
          return const Center(child: CircularProgressIndicator());
        }
        return AnimatedList(
          key: listKey,
          initialItemCount: taskList.value!.length,
          itemBuilder: buildItem,
          physics: const BouncingScrollPhysics(),
        );
      },
    );
  }
}
