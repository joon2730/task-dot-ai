import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:intl/intl.dart';

import 'package:tasket/model/subtask.dart';
import 'package:tasket/model/repeat.dart';
import 'package:tasket/util/format.dart';

class Task {
  String title;
  String? id;
  String? note;
  DateTime? dueOn;
  bool? hasTime;
  RepeatRule? repeat;
  List<Subtask>? subtasks;
  DateTime createdAt;
  DateTime updatedAt;
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
      dueOn: json['dueOn']?.toDate().toLocal(),
      hasTime: json['hasTime'] as bool?,
      note:
          ((json['note'] as String?)?.trim().isEmpty ?? true)
              ? null
              : (json['note'] as String).trim(),
      subtasks:
          (json['subtasks'] as List?)?.map((e) => Subtask.fromJson(e)).toList(),
      repeat:
          (json['repeat'] != null)
              ? RepeatRule.fromStore(json['repeat'])
              : null,
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
    final dueRaw = json['dueOn'];
    if (dueRaw != null && dueRaw is String) {
      dueOn = DateTime.tryParse(dueRaw); // if null delete dueOn field
      hasTime = dueRaw.contains('T') && dueRaw.length > 10;
    }

    List<Subtask>? subtasks;
    final subtasksRaw = json['subtasks'];
    if (subtasksRaw != null) {
      if (subtasksRaw is List &&
          subtasksRaw.every((e) => e is String && subtasksRaw.isNotEmpty)) {
        subtasks =
            List<String>.from(
              subtasksRaw,
            ).map((title) => Subtask(title)).toList();
      }
    }

    RepeatRule? repeat;
    if (json['repeat'] != null) {
      repeat = RepeatRule.create(json['repeat']);
      dueOn = repeat.getNextOccurrence(repeat.startDate ?? DateTime.now());
      hasTime = repeat.time != null;
    }

    return Task(
      title: title,
      note: note,
      dueOn: dueOn,
      hasTime: hasTime,
      subtasks: subtasks,
      repeat: repeat,
      isNew: true,
    );
  }

  void update(Map<String, dynamic> json) {
    isUpdated = true;

    title = json['title'] ?? title;
    note = json['note'] ?? note;

    final dueOnRaw = json['dueOn'];
    if (dueOnRaw != null && dueOnRaw is String) {
      dueOn = DateTime.tryParse(dueOnRaw); // if null delete dueOn field
      hasTime = dueOnRaw.contains('T') && dueOnRaw.length > 10;
      repeat = null;
    }

    final subtasksRaw = json['subtasks'];
    if (subtasksRaw != null) {
      if (subtasksRaw is List &&
          subtasksRaw.every((e) => e is String) &&
          subtasksRaw.isNotEmpty) {
        final patch =
            List<String>.from(
              subtasksRaw,
            ).map((title) => Subtask(title)).toList();
        if (subtasks == null) {
          subtasks = patch;
        } else {
          subtasks!.addAll(patch);
        }
      }
    }

    if (json['repeat'] != null) {
      if (repeat != null) {
        repeat!.update(json['repeat']);
      } else {
        repeat = RepeatRule.create(json['repeat']); // deleted if null
      }
      dueOn = repeat!.getNextOccurrence(repeat!.startDate ?? DateTime.now());
      hasTime = repeat!.time != null;
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
