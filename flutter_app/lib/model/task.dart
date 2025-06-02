import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:intl/intl.dart';

import 'package:tasket/model/subtask.dart';
import 'package:tasket/model/repeat.dart';
import 'package:tasket/model/list_item.dart';
import 'package:tasket/util/format.dart';

class Task extends ListItem {
  String title;
  String? id;
  String? note;
  DateTime? dueOn;
  bool? hasTime;
  RepeatRule? repeat;
  List<Subtask>? subtasks;
  DateTime createdAt;
  DateTime updatedAt;
  int priority; // top: 1 | normal: 0 | low: -1
  // not saved to db
  bool isNew;
  bool isUpdated;
  bool isCompleted;

  Task({
    required this.title,
    this.id,
    this.dueOn,
    this.repeat,
    this.hasTime,
    this.note,
    this.subtasks,
    this.isCompleted = false,
    this.isNew = false,
    this.isUpdated = false,
    this.priority = 0,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) : createdAt = createdAt ?? DateTime.now(),
       updatedAt = updatedAt ?? DateTime.now();

  factory Task.fromStore(Map<String, dynamic> json) {
    return Task(
      id: json['id'],
      title: json['title'],
      createdAt:
          (json['createdAt'] is Timestamp)
              ? (json['createdAt'] as Timestamp).toDate()
              : DateTime.now(),
      updatedAt:
          (json['updatedAt'] is Timestamp)
              ? (json['updatedAt'] as Timestamp).toDate()
              : DateTime.now(),
      dueOn: (json['dueOn'] as Timestamp?)?.toDate().toLocal(),
      hasTime: json['hasTime'] as bool?,
      note: json['note'] as String?,
      subtasks:
          (json['subtasks'] as List?)?.map((e) => Subtask.fromJson(e)).toList(),
      repeat:
          (json['repeat'] != null)
              ? RepeatRule.fromStore(json['repeat'])
              : null,
      priority: (json['priority'] != null) ? json['priority'] : 0,
    );
  }

  Map<String, dynamic> toStore() {
    final data = <String, dynamic>{};
    void push(String name, dynamic value) {
      if (value != null) {
        data[name] = value;
      }
    }

    if (isNew) {
      data['createdAt'] = createdAt;
      data['updatedAt'] = updatedAt;
    }
    if (isUpdated) {
      data['updatedAt'] = updatedAt;
    }
    push('title', title);
    push('note', note);
    push('dueOn', dueOn);
    push('hasTime', hasTime);
    push('dueOn', dueOn);
    push('subtasks', subtasks?.map((subtask) => subtask.toJson()).toList());
    push('repeat', repeat?.toStore());
    return data;
  }

  factory Task.create(Map<String, dynamic> json) {
    final title = json['title'];
    final note = json['note'];

    DateTime? dueOn;
    bool? hasTime;
    if (json['dueOn'] != null && json['dueOn'] is String) {
      dueOn = DateTime.tryParse(json['dueOn']); // if null delete dueOn field
      hasTime = json['dueOn'].contains('T') && json['dueOn'].length > 10;
    }

    List<Subtask>? subtasks;
    if (json['subtasks'] != null &&
        json['subtasks'] is List &&
        json['subtasks'].every(
          (e) => e is String && json['subtasks'].isNotEmpty,
        )) {
      subtasks = json['subtasks'].map((title) => Subtask(title)).toList();
    }

    RepeatRule? repeat;
    if (json['repeat'] != null) {
      repeat = RepeatRule.create(json['repeat']);
      dueOn = repeat.getNextOccurrence(repeat.startDate ?? DateTime.now());
      hasTime = repeat.time != null;
    }

    int priority = (json['priority'] != null) ? json['priority'] : 0;

    return Task(
      title: title,
      note: note,
      dueOn: dueOn,
      hasTime: hasTime,
      subtasks: subtasks,
      repeat: repeat,
      priority: priority,
      isNew: true,
    );
  }

  void update(Map<String, dynamic> json) {
    isUpdated = true;

    title = json['title'] ?? title; // prevent null

    if (json.containsKey('note')) note = json['note'];

    if (json.containsKey('dueOn')) {
      if (json['dueOn'] != null && json['dueOn'] is String) {
        dueOn = DateTime.tryParse(json['dueOn']); // if null delete dueOn field
        hasTime = json['dueOn'].contains('T') && json['dueOn'].length > 10;
        repeat = null;
      } else {
        dueOn = null;
      }
    }

    if (json.containsKey('subtasks')) {
      if (json['subtasks'] != null &&
          json['subtasks'] is List &&
          json['subtasks'].every((e) => e is String) &&
          json['subtasks'].isNotEmpty) {
        final patch = json['subtasks'].map((title) => Subtask(title)).toList();
        if (subtasks == null) {
          subtasks = patch;
        } else {
          subtasks!.addAll(patch);
        }
      }
    }

    if (json.containsKey('repeat')) {
      if (json['repeat'] != null) {
        if (repeat != null) {
          repeat!.update(json['repeat']);
        } else {
          repeat = RepeatRule.create(json['repeat']); // deleted if null
        }
        dueOn = repeat!.getNextOccurrence(repeat!.startDate ?? DateTime.now());
        hasTime = repeat!.time != null;
      } else {
        repeat = null;
      }
    }

    if (json.containsKey('priority')) {
      final val = json['priority'];
      if (val == -1 || val == 1) {
        priority = val;
      } else if (val == 0) {
        priority = 0;
      }
    }
  }

  @override
  String toString() {
    final data = <String, dynamic>{'id': id, 'title': title};
    if (dueOn != null) {
      data['dueOn'] = formalFormatDueOn;
    }
    if (note != null) data['note'] = note;
    if (subtasks != null) {
      data['subtasks'] = subtasks!.map((subtask) => subtask.title).toList();
    }
    if (repeat != null) {
      data['repeat'] = repeat!.toString();
    }
    return data.toString();
  }

  Duration get age {
    return DateTime.now().difference(createdAt);
  }

  Duration? get dueIn => dueOn?.difference(DateTime.now());

  String get formatDueIn {
    if (dueIn == null) return '';

    final isPast = dueIn!.isNegative;
    final format = readableTimeDelta(dueOn!, hasTime!);

    if (format == 'now') return 'now';
    return isPast ? '$format overdue' : 'in $format';
  }

  String get formatDueOn {
    if (dueOn == null) return '';
    return formatDateTime(dueOn!, hasTime!);
  }

  String get displayFormatDueOn {
    if (dueOn == null) return '';
    final time = hasTime! ? DateFormat('h:mm a').format(dueOn!) : '';
    return '${readableDate(dueOn!)}${hasTime! ? ' • $time' : ''} | $formatDueIn';
  }

  String get formalFormatDueOn {
    if (dueOn == null) return '';
    return formatDateTime(dueOn!, hasTime!);
  }

  int get uncompletedSubtasksCount {
    if (subtasks == null) return 0;
    return subtasks!.where((subtask) => subtask.isCompleted == false).length;
  }

  int compareTo(
    Task other, {
    String method = 'date', // 'date' | 'priority'
  }) {
    if (method == 'date') {
      if (dueOn == null && other.dueOn != null) return 1;
      if (dueOn != null && other.dueOn == null) return -1;
      if (dueOn != null && other.dueOn != null) {
        final cmp = dueOn!.compareTo(other.dueOn!);
        if (cmp != 0) return cmp;
      }
      // fall back to priority
      if (priority != other.priority) {
        return (priority > other.priority) ? -1 : 1;
      }
      // fall back to createdAt
      return createdAt.compareTo(other.createdAt);
    } else if (method == 'priority') {
      if (priority != other.priority) {
        return (priority > other.priority) ? -1 : 1;
      }
      // fall back to date
      if (dueOn == null && other.dueOn != null) return 1;
      if (dueOn != null && other.dueOn == null) return -1;
      if (dueOn != null && other.dueOn != null) {
        final cmp = dueOn!.compareTo(other.dueOn!);
        if (cmp != 0) return cmp;
      }
      return createdAt.compareTo(other.createdAt);
    }
    // fall back to createdAt
    return createdAt.compareTo(other.createdAt);
  }

  String get dateGroup {
    if (dueOn == null) return 'Undated';

    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final tomorrow = today.add(const Duration(days: 1));

    final due = DateTime(dueOn!.year, dueOn!.month, dueOn!.day);

    if (due.isBefore(today)) {
      return 'Past Due';
    } else if (due.isAtSameMomentAs(today)) {
      return 'Today';
    } else if (due.isAtSameMomentAs(tomorrow)) {
      return 'Tomorrow';
    }

    final endOfWeek = today.add(
      Duration(days: DateTime.sunday - today.weekday),
    );
    if (due.isBefore(endOfWeek.add(const Duration(days: 1)))) {
      return 'This week';
    }

    final startOfNextWeek = endOfWeek.add(const Duration(days: 1));
    final endOfNextWeek = startOfNextWeek.add(const Duration(days: 6));
    if (!due.isBefore(startOfNextWeek) && !due.isAfter(endOfNextWeek)) {
      return 'Next week';
    }

    final endOfMonth = DateTime(
      today.year,
      today.month + 1,
      1,
    ).subtract(const Duration(days: 1));
    if (due.isBefore(endOfMonth.add(const Duration(days: 1)))) {
      return 'This month';
    }

    final startOfNextMonth = DateTime(today.year, today.month + 1, 1);
    final endOfNextMonth = DateTime(
      today.year,
      today.month + 2,
      1,
    ).subtract(const Duration(days: 1));
    if (!due.isBefore(startOfNextMonth) && !due.isAfter(endOfNextMonth)) {
      return 'Next month';
    }

    return 'Later';
  }

  String get priorityGroup {
    if (priority == 1) {
      return 'Top priority';
    } else if (priority == -1) {
      return 'Low priority';
    } else {
      return 'Normal priority';
    }
  }

  @override
  Object get itemId => id!;
}
