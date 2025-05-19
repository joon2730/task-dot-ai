import 'package:flutter/material.dart';

import 'package:tasket/widget/btn/check_btn.dart';

class SubtaskTile extends StatefulWidget {
  const SubtaskTile({super.key, required this.subtask});

  final Map subtask;

  @override
  State<SubtaskTile> createState() => _SubtaskTileState();
}

class _SubtaskTileState extends State<SubtaskTile> {
  late bool isChecked;

  @override
  void initState() {
    super.initState();
    isChecked = widget.subtask['isChecked'];
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
                      widget.subtask['title']!,
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        decoration:
                            isChecked
                                ? TextDecoration.lineThrough
                                : TextDecoration.none,
                        color:
                            isChecked
                                ? Theme.of(context).colorScheme.onSurfaceVariant
                                : Theme.of(context).textTheme.bodyLarge?.color,
                      ),
                    ),
                  ],
                ),
                SizedBox(
                  width: 28,
                  child: CheckButton(
                    isChecked: isChecked,
                    onChanged: (val) {
                      setState(() {
                        isChecked = val;
                      });
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
