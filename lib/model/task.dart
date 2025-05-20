import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:intl/intl.dart';

import 'package:tasket/model/task_patch.dart';
import 'package:tasket/model/subtask.dart';
import 'package:tasket/util/format.dart';

class Task {
  String title;
  String id;
  DateTime createdAt;
  DateTime updatedAt;
  DateTime? dueOn;
  bool? hasTime;
  String? note;
  List<Subtask>? subtasks;
  // not saved to db
  bool isNew;
  bool isUpdated;
  bool inList;
  bool isCompleted;

  Task({
    required this.title,
    required this.id,
    required this.createdAt,
    required this.updatedAt,
    this.dueOn,
    this.hasTime,
    this.note,
    this.subtasks,
    this.isCompleted = false,
    this.isNew = false,
    this.isUpdated = false,
    this.inList = true, // for listview
  });

  factory Task.fromJson(Map<String, dynamic> json) {
    return Task(
      title: json['title'],
      id: json['id'],
      createdAt:
          (json['createdAt'] is Timestamp)
              ? (json['createdAt'] as Timestamp).toDate()
              : DateTime.now(),
      updatedAt:
          (json['updatedAt'] is Timestamp)
              ? (json['updatedAt'] as Timestamp).toDate()
              : DateTime.now(),
      dueOn: json['dueOn']?.toDate().toLocal(),
      hasTime: json['hasTime'] as bool?,
      note: json['note'],
      subtasks:
          (json['subtasks'] as List?)?.map((e) => Subtask.fromJson(e)).toList(),
    );
  }

  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{'id': id, 'title': title};
    if (dueOn != null) {
      data['dueOn'] = DateFormat('yyyy-MM-ddTHH:mm').format(dueOn!);
    }
    if (note != null) data['note'] = note;
    if (subtasks != null) {
      data['subtasks'] = subtasks!.map((subtask) => subtask.title).toList();
    }
    return data;
  }

  @override
  String toString() {
    return toJson().toString();
  }

  void applyPatch(TaskPatch patch) {
    title = patch.title ?? title;
    dueOn = patch.dueOn ?? dueOn;
    note = patch.note ?? note;
    if (patch.subtasks != null) {
      subtasks =
          (subtasks ?? [])
            ..addAll(patch.subtasks!.map((title) => Subtask(title)).toList());
    }
  }

  Duration get age {
    return DateTime.now().difference(createdAt);
  }

  Duration? get dueIn => dueOn?.difference(DateTime.now());

  String get formatDueIn {
    if (dueIn == null) return '';

    final isPast = dueIn!.isNegative;
    final format = formatDurationUnit(dueOn!, hasTime!);

    return isPast ? '$format overdue' : 'in $format';
  }

  String get formatDueOn {
    if (dueOn == null) return '';
    return formatDateTime(dueOn!, hasTime!);
  }

  String get readableFormatDueOn {
    if (dueOn == null) return '';
    final time = hasTime! ? DateFormat('h:mm a').format(dueOn!) : '';
    return '${formatRelativeWeekday(dueOn!)}${hasTime! ? ', $time' : ''}';
  }

  String get formalFormatDueOn {
    if (dueOn == null) return '';
    return formatDateTime(dueOn!, hasTime!);
  }

  int get uncompletedSubtasksCount {
    if (subtasks == null) return 0;
    return subtasks!.where((subtask) => subtask.isCompleted == false).length;
  }

  int get priorityScore {
    if (dueOn != null) {
      // has due date
      return 20160 - dueIn!.inMinutes; // 10080 = a week
    } else {
      // No due date
      return (age.inMinutes / (age.inHours % 6 + 1))
          .round(); // resurface periodically
    }
  }

  int compareTo(Task other, {String method = 'auto'}) {
    switch (method) {
      case 'auto':
      default:
        return other.priorityScore - priorityScore;
    }
  }
}
