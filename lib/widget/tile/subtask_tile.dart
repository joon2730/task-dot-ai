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
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.baseline,
                  textBaseline: TextBaseline.alphabetic,
                  children: [
                    SizedBox(
                      width: 14,
                      child: Transform.translate(
                        offset: Offset(0, -4),
                        child: Icon(
                          Icons.circle,
                          size: 6,
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ),
                    SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        widget.subtask.title,
                        softWrap: true,
                        overflow: TextOverflow.visible,
                        style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                          decoration:
                              isCompleted
                                  ? TextDecoration.lineThrough
                                  : TextDecoration.none,
                          color:
                              isCompleted
                                  ? Theme.of(
                                    context,
                                  ).colorScheme.onSurfaceVariant
                                  : Theme.of(
                                    context,
                                  ).textTheme.bodyLarge?.color,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          SizedBox(
            width: 28,
            child: CheckButton(
              isChecked: isCompleted,
              onChanged: (isChecked) {
                setState(() {
                  isCompleted = isChecked;
                });
                widget.subtask.isCompleted = isChecked;
                widget.onChanged?.call(isChecked);
              },
              size: 28,
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }
}
