import 'package:flutter/material.dart';

// import 'package:material_symbols_icons/symbols.dart';

import 'package:tasket/widget/tile/subtask_tile.dart';
import 'package:tasket/model/subtask.dart';

class SubtaskListView extends StatelessWidget {
  final List<Subtask> subtasks;
  final ValueChanged<int>? onChanged;

  const SubtaskListView(this.subtasks, {super.key, this.onChanged});

  @override
  Widget build(BuildContext context) {
    int completedCounter =
        subtasks.where((subtask) => subtask.isCompleted == true).length;

    return Column(
      children: [
        ...List.generate(subtasks.length, (index) {
          final subtask = subtasks[index];
          return SubtaskTile(
            subtask,
            onChanged: (val) {
              if (val) {
                completedCounter++;
              } else {
                completedCounter--;
              }
              onChanged?.call(completedCounter);
            },
          );
        }),
      ],
    );
  }
}
