import 'package:hooks_riverpod/hooks_riverpod.dart';

import 'package:tasket/provider/service_provider.dart';
import 'package:tasket/model/task.dart';
import 'package:tasket/model/task_patch.dart';

class TaskNotifier extends AsyncNotifier<List<Task>> {
  @override
  Future<List<Task>> build() async {
    final dataSevice = ref.read(dataServiceProvider)!; // must be logged in
    return await dataSevice.loadTasks();
  }

  Future<void> applyTaskPatches(List<TaskPatch> patches) async {
    final dataSevice = ref.read(dataServiceProvider)!;
    if (state.hasValue) {
      var current = state.value!;
      for (final patch in patches) {
        current = await dataSevice.applyPatch(patch, current);
      }
      state = AsyncValue.data(current);
    }
  }

  Future<void> deleteTask(String id) async {
    final dataSevice = ref.read(dataServiceProvider)!;
    dataSevice.deleteTask(id);
    if (state.hasValue) {
      state = AsyncValue.data(
        state.value!.where((task) => task.id != id).toList(),
      );
    }
  }
}

final taskProvider = AsyncNotifierProvider<TaskNotifier, List<Task>>(
  TaskNotifier.new,
);
