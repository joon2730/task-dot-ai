import 'package:flutter/material.dart';

import 'package:tasket/widget/btn/check_btn.dart';
import 'package:tasket/model/subtask.dart';

class SubtaskTile extends StatefulWidget {
  final Subtask subtask;
  final ValueChanged<bool>? onChanged;

  const SubtaskTile(this.subtask, {super.key, this.onChanged});

  @override
  State<SubtaskTile> createState() => _SubtaskTileState();
}

class _SubtaskTileState extends State<SubtaskTile> {
  late bool isCompleted;

  @override
  void initState() {
    super.initState();
    isCompleted = widget.subtask.isCompleted;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Expanded(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Row(
                  children: [
                    SizedBox(
                      width: 14,
                      child: Icon(
                        Icons.circle,
                        size: 6,
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                    ),
                    SizedBox(width: 12),
                    Text(
                      widget.subtask.title,
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        decoration:
                            isCompleted
                                ? TextDecoration.lineThrough
                                : TextDecoration.none,
                        color:
                            isCompleted
                                ? Theme.of(context).colorScheme.onSurfaceVariant
                                : Theme.of(context).textTheme.bodyLarge?.color,
                      ),
                    ),
                  ],
                ),
                SizedBox(
                  width: 28,
                  child: CheckButton(
                    isChecked: isCompleted,
                    onChanged: (isChecked) {
                      setState(() {
                        isCompleted = isChecked;
                      });
                      widget.onChanged?.call(isChecked);
                      widget.subtask.isCompleted = isChecked;
                    },
                    size: 28,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
