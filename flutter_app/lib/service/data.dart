import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:hooks_riverpod/hooks_riverpod.dart';

import 'package:tasket/model/task.dart';
import 'package:tasket/util/exception.dart';

class DataService {
  String userId;

  DataService({required this.userId});

  CollectionReference<Map<String, dynamic>> get _taskCollection =>
      FirebaseFirestore.instance
          .collection('users')
          .doc(userId)
          .collection('tasks');

  Future<List<Task>> loadTasks() async {
    try {
      final snapshot = await _taskCollection
          .orderBy('createdAt', descending: true)
          .get()
          .timeout(
            Duration(seconds: 10),
            onTimeout: () {
              throw DataException('Firestore request timed out');
            },
          );

      return snapshot.docs.map((doc) {
        final data = {...doc.data(), 'id': doc.id};
        return Task.fromStore(data);
      }).toList();
    } catch (e, _) {
      throw DataException('Failed to load tasks.');
    }
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

  Future<void> insertDemoTasks() async {
    final demoTasks = demos.map((e) => Task.create(e)).toList().reversed;
    for (final demoTask in demoTasks) {
      await createTask(demoTask);
    }
  }
}

const demos = [
  {
    "title": "⏰ Study Math (Recurring Task)",
    "repeat": {
      "frequency": "weekly",
      "interval": 1,
      "weekdays": ["mon", "wed", "fri"],
      "startDate": "2025-06-01",
      "endDate": "2025-06-30",
      "time": "19:00",
    },
    "note":
        "This task repeats every Monday, Wednesday, and Friday at 7:00 PM in June. Due dates and repeats keep you organized!",
  },
  {
    "title": "🌍 Plan a Trip (With Checklist)",
    "subtasks": [
      "Book flight tickets",
      "Reserve hotel",
      "Pack suitcase",
      "Check passport",
    ],
    "note":
        "Add checklist steps for multi-part tasks. Tap each one as you finish!",
  },
  {
    "title": "✏️ Swipe to Edit or Delete",
    "note":
        "Swipe right on this task to quickly edit. Swipe left to instantly delete. (Go ahead and try it!)",
  },
  {
    "title": "✔️ Check Off a Completed Task",
    "subtasks": ["Tap the check button to mark done"],
    "note": "When you finish, tap the checkmark to complete your task!",
  },
  {
    "title": "💡 Try Creating Your Own Task!",
    "note":
        "Type any to-do or idea in the box below and Tasket will organize it for you.",
  },
];
