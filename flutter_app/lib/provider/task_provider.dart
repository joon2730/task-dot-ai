import 'package:hooks_riverpod/hooks_riverpod.dart';

import 'package:tasket/provider/service_provider.dart';
import 'package:tasket/provider/task_list_provider.dart';
import 'package:tasket/model/task.dart';

class TaskNotifier extends AsyncNotifier<int> {
  @override
  Future<int> build() async {
    final dataSevice = ref.read(dataServiceProvider)!; // must be logged in
    final tasks = await dataSevice.loadTasks();
    ref.read(taskListProvider.notifier).initialize(tasks);

    return tasks.length;
  }

  void createTask(Task task) {
    if (state.hasValue) {
      ref.read(taskListProvider.notifier).insertTask(task);
      state = AsyncValue.data(state.value! + 1);
      final dataSevice = ref.read(dataServiceProvider)!;
      dataSevice.createTask(task);
    }
  }

  void updateTask(Task task) {
    final dataSevice = ref.read(dataServiceProvider)!;
    dataSevice.updatetTask(task);
  }

  void completeTask(Task task) {
    ref.read(taskListProvider.notifier).removeTask(task);
    state = AsyncValue.data(state.value! - 1);
    final dataSevice = ref.read(dataServiceProvider)!;
    // handle repetition
    if (task.repeat != null) {
      final nextDue = task.repeat!.getNextOccurrence(
        task.dueOn ?? DateTime.now(),
        inclusive: false,
      );
      if (nextDue != null) {
        task.dueOn = nextDue;
        ref.read(taskListProvider.notifier).insertTask(task..isNew = true);
        state = AsyncValue.data(state.value! + 1);
        dataSevice.updatetTask(task);
        return;
      }
    }
    dataSevice.deleteTask(task.id!);
  }

  void deleteTask(Task task) {
    ref.read(taskListProvider.notifier).removeTask(task);
    final dataSevice = ref.read(dataServiceProvider)!;
    state = AsyncValue.data(state.value! - 1);
    dataSevice.deleteTask(task.id!);
  }

  Future<void> refresh() async {
    final dataSevice = ref.read(dataServiceProvider)!; // must be logged in
    final tasks = await dataSevice.loadTasks();
    state = AsyncValue.data(tasks.length);
    ref.read(taskListProvider.notifier).initialize(tasks);
    ref.read(selectedTaskProvider.notifier).state = null;
  }
}

final taskProvider = AsyncNotifierProvider<TaskNotifier, int>(TaskNotifier.new);

final selectedTaskProvider = StateProvider<Task?>((_) => null);
