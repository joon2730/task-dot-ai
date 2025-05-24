import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:hooks_riverpod/hooks_riverpod.dart';

import 'package:tasket/model/task.dart';

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
      return Task.fromStore(data);
    }).toList();
  }

  Future<void> updatetTask(Task task) async {
    await _taskCollection.doc(task.id).update(task.toStore());
  }

  Future<void> createTask(Task task) async {
    final docRef = _taskCollection.doc();
    task.id = docRef.id;
    await _taskCollection.doc(task.id).set(task.toStore());
  }

  void deleteTask(String id) {
    _taskCollection.doc(id).delete();
  }
}
