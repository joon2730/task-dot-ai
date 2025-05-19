import 'package:flutter/material.dart';

// import 'package:material_symbols_icons/symbols.dart';

import 'package:tasket/widget/tile/subtask_tile.dart';

class SubtaskListView extends StatelessWidget {
  final List<Map> subtasks;

  const SubtaskListView({super.key, required this.subtasks});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        ...List.generate(subtasks.length, (index) {
          final subtask = subtasks[index];
          return SubtaskTile(subtask: subtask);
        }),
      ],
    );
  }
}
