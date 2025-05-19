import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:hooks_riverpod/hooks_riverpod.dart';

import 'package:tasket/model/task.dart';
import 'package:tasket/model/task_patch.dart';

class DataService {
  String userId;

  DataService({required this.userId});

  CollectionReference<Map<String, dynamic>> get _taskCollection =>
      FirebaseFirestore.instance
          .collection('users')
          .doc(userId)
          .collection('tasks');

  Future<List<Task>> loadTasks() async {
    final snapshot =
        await _taskCollection.orderBy('createdAt', descending: true).get();

    return snapshot.docs.map((doc) {
      final data = {...doc.data(), 'id': doc.id};
      return Task.fromJson(data);
    }).toList();
  }

  Future<List<Task>> applyPatch(TaskPatch patch, List<Task> tasks) async {
    if (patch.isCreate) {
      return await createTask(patch, tasks);
    } else if (patch.isUpdate) {
      return await updateTask(patch, tasks);
    } else {
      throw ArgumentError('Unsupported operation: ${patch.op}');
    }
  }

  /// Create a new task using a TaskPatch
  Future<List<Task>> createTask(TaskPatch patch, List<Task> tasks) async {
    final docRef = _taskCollection.doc();
    final id = docRef.id;
    await docRef.set(patch.toJson());
    final json = {...patch.toJson(), 'id': id};
    return [
      Task.fromJson(json)
        ..isNew = true
        ..inList = false,
      ...tasks,
    ];
  }

  /// Update an existing task using a TaskPatch
  Future<List<Task>> updateTask(TaskPatch patch, List<Task> tasks) async {
    final index = tasks.indexWhere((task) => task.id == patch.id!);
    if (index == -1) throw StateError('Target task not found');
    final target = tasks[index];
    await _taskCollection.doc(patch.id!).update(patch.toJson(target));
    target.applyPatch(patch);
    tasks.removeAt(index);
    return [target..isUpdated = true, ...tasks];
  }

  Future<void> deleteTask(String id) async {
    _taskCollection.doc(id).delete();
  }
}
