import 'package:flutter/foundation.dart';

import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:tasket/model/task.dart';

@immutable
class TaskPatch {
  final String op; // 'create' or 'update'
  final String? id;
  final String? title;
  final DateTime? dueOn;
  final bool? hasTime;
  final String? note;
  final List<String>? subtasks;

  const TaskPatch({
    required this.op,
    this.id,
    this.title,
    this.dueOn,
    this.hasTime,
    this.note,
    this.subtasks,
  });

  factory TaskPatch.fromJson(String op, Map<String, dynamic> json) {
    final id = json['id'];
    if (op == 'update' && id == null) {
      throw FormatException('Missing "id" for update operation');
    }

    final title = json['title'];
    if (op == 'create' && title == null) {
      throw FormatException('Missing "title" for create operation');
    }

    final dueRaw = json['dueOn'];
    DateTime? dueOn;
    bool? hasTime;
    if (dueRaw != null && dueRaw is String) {
      dueOn = DateTime.tryParse(dueRaw);
      if (dueOn == null) throw FormatException('Invalid due format');
      hasTime = dueRaw.contains('T') && dueRaw.length > 10;
    }

    final subtasksRaw = json['subtasks'];
    List<String>? subtasks;
    if (subtasksRaw != null) {
      if (subtasksRaw is! List || subtasksRaw.any((e) => e is! String)) {
        throw FormatException('subtasks must be a list of strings');
      }
      subtasks = List<String>.from(subtasksRaw);
    }

    return TaskPatch(
      op: op,
      id: id,
      title: title,
      dueOn: dueOn,
      hasTime: hasTime,
      note: json['note'],
      subtasks: subtasks,
    );
  }

  /// Convert to Firestore-compatible map
  Map<String, dynamic> toJson([Task? origin]) {
    final data = <String, dynamic>{};

    if (title != null) data['title'] = title;
    if (dueOn != null) data['dueOn'] = Timestamp.fromDate(dueOn!.toUtc());
    if (hasTime != null) data['hasTime'] = hasTime;
    if (note != null) data['note'] = note;
    if (subtasks != null) {
      data['subtasks'] =
          subtasks!
              .map<Map<String, Object>>(
                (title) => {'title': title, 'isChecked': false},
              )
              .toList();
      if (origin != null && origin.subtasks != null) {
        data['subtasks'].addAll(origin.subtasks);
      }
    }

    if (op == 'create') data['createdAt'] = FieldValue.serverTimestamp();
    data['updatedAt'] = FieldValue.serverTimestamp();

    return data;
  }

  bool get isCreate => op == 'create';
  bool get isUpdate => op == 'update';
}
