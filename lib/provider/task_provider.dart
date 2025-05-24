import 'package:hooks_riverpod/hooks_riverpod.dart';

import 'package:tasket/provider/service_provider.dart';
import 'package:tasket/model/task.dart';

class TaskNotifier extends AsyncNotifier<List<Task>> {
  @override
  Future<List<Task>> build() async {
    final dataSevice = ref.read(dataServiceProvider)!; // must be logged in
    return await dataSevice.loadTasks();
  }

  void createTask(Task task) {
    state = AsyncValue.data([task]);
    final dataSevice = ref.read(dataServiceProvider)!;
    dataSevice.createTask(task);
  }

  void updateTask(Task task) {
    final dataSevice = ref.read(dataServiceProvider)!;
    dataSevice.updatetTask(task);
  }

  void completeTask(Task task) {
    final dataSevice = ref.read(dataServiceProvider)!;
    if (task.repeat != null) {
      // handle repetition
      final nextDue = task.repeat!.getNextOccurrence(
        task.dueOn ?? DateTime.now(),
      );
      if (nextDue != null) {
        task.dueOn = nextDue;
        state = AsyncValue.data([
          task
            ..inList = false
            ..isNew = true,
        ]);
        dataSevice.updatetTask(task);
        return;
      }
    }
    state = AsyncValue.data([]);
    dataSevice.deleteTask(task.id!);
  }

  Future<void> refresh() async {
    final dataSevice = ref.read(dataServiceProvider)!; // must be logged in
    state = AsyncValue.data(await dataSevice.loadTasks());
    ref.read(selectedTaskProvider.notifier).state = null;
  }
}

final taskProvider = AsyncNotifierProvider<TaskNotifier, List<Task>>(
  TaskNotifier.new,
);

final selectedTaskProvider = StateProvider<Task?>((_) => null);
