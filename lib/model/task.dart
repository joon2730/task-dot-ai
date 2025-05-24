import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:flutter/foundation.dart';

import 'package:intl/intl.dart';

import 'package:tasket/model/subtask.dart';
import 'package:tasket/model/repeat.dart';
import 'package:tasket/util/format.dart';

class Task {
  String _title;
  String? _id;
  String? _note;
  DateTime? _dueOn;
  bool? _hasTime;
  RepeatRule? _repeat;
  List<Subtask>? _subtasks;
  DateTime _createdAt;
  DateTime _updatedAt;
  // not saved to db
  bool isNew;
  bool isUpdated;
  bool inList;
  bool isCompleted;
  final Map<String, bool> _isFieldModified = {};

  Task({
    required String title,
    String? id,
    DateTime? dueOn,
    RepeatRule? repeat,
    bool? hasTime,
    String? note,
    List<Subtask>? subtasks,
    DateTime? createdAt,
    DateTime? updatedAt,
    this.isCompleted = false,
    this.isNew = false,
    this.isUpdated = false,
    this.inList = true, // for listview
  }) : _id = id,
       _title = title,
       _note = note,
       _dueOn = dueOn,
       _hasTime = hasTime,
       _subtasks = subtasks,
       _repeat = repeat,
       _createdAt = createdAt ?? DateTime.now(),
       _updatedAt = updatedAt ?? DateTime.now();

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
      note: json['note'],
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
    void push(String fieldName, dynamic value) {
      if (isModified(fieldName)) {
        data[fieldName] = value;
        logStored(fieldName);
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

  void update(Map<String, dynamic> json) {
    isUpdated = true;

    title = json['title'] ?? title;
    note = json['note'] ?? note;

    final dueOnRaw = json['dueOn'];
    if (dueOnRaw != null && dueOnRaw is String) {
      dueOn = DateTime.tryParse(dueOnRaw); // if null delete dueOn field
      hasTime = dueOnRaw.contains('T') && dueOnRaw.length > 10;
    }

    final subtasksRaw = json['subtasks'];
    if (subtasksRaw != null) {
      if (subtasksRaw is List && subtasksRaw.every((e) => e is String)) {
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
      repeat =
          (json['repeat']['frequency'] != "null")
              ? RepeatRule.create(json['repeat']) // deleted if null
              : null;
      if (repeat != null) {
        dueOn = repeat!.getNextOccurrence(repeat!.startDate ?? DateTime.now());
        hasTime = repeat!.time != null;
      }
    }
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
      if (subtasksRaw is List && subtasksRaw.every((e) => e is String)) {
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
      inList: false,
    );
  }

  String toPrompt() {
    final data = <String, dynamic>{'id': id, 'title': title};
    if (dueOn != null) {
      data['dueOn'] = formalFormatDueOn;
    }
    if (note != null) data['note'] = note;
    if (subtasks != null) {
      data['subtasks'] = subtasks!.map((subtask) => subtask.title).toList();
    }
    if (repeat != null) {
      data['repeat'] = repeat!.toPrompt();
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

    return isPast ? '$format overdue' : 'in $format';
  }

  String get formatDueOn {
    if (dueOn == null) return '';
    return formatDateTime(dueOn!, hasTime!);
  }

  String get readableFormatDueOn {
    if (dueOn == null) return '';
    final time = hasTime! ? DateFormat('h:mm a').format(dueOn!) : '';
    return '${readableDayLabel(dueOn!)}${hasTime! ? ', $time' : ''}';
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

  /// Helpers for toStore
  /// -----------------------------------
  bool isModified(String field) {
    return _isFieldModified[field] ?? true;
  }

  void logModified(String field) {
    _isFieldModified[field] = true;
  }

  void logStored(String field) {
    _isFieldModified[field] = false;
  }

  /// Getter and Setter for private fields
  /// -----------------------------------
  String get title => _title;
  String? get id => _id;
  String? get note => _note;
  DateTime? get dueOn => _dueOn;
  bool? get hasTime => _hasTime;
  List<Subtask>? get subtasks => _subtasks;
  RepeatRule? get repeat => _repeat;
  DateTime get createdAt => _createdAt;
  DateTime get updatedAt => _updatedAt;

  set id(String? value) {
    if (_id != value) {
      _id = value;
      logModified('id');
    }
  }

  set title(String value) {
    if (_title != value) {
      _title = value;
      logModified('title');
    }
  }

  set note(String? value) {
    if (_note != value) {
      _note = value;
      logModified('note');
    }
  }

  set dueOn(DateTime? value) {
    if (_dueOn != value) {
      _dueOn = value;
      logModified('dueOn');
    }
  }

  set hasTime(bool? value) {
    if (_hasTime != value) {
      _hasTime = value;
      logModified('hasTime');
    }
  }

  set subtasks(List<Subtask>? value) {
    if (_subtasks != value) {
      _subtasks = value;
      logModified('subtasks');
    }
  }

  set repeat(RepeatRule? value) {
    if (_repeat != value) {
      _repeat = value;
      logModified('repeat');
    }
  }
}
