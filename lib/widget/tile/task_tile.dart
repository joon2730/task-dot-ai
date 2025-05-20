import 'package:flutter/material.dart';

import 'package:material_symbols_icons/symbols.dart';

// import 'package:tasket/app/constants.dart';
import 'package:tasket/model/task.dart';
import 'package:tasket/util/format.dart';
import 'package:tasket/widget/list_view/subtask_list_view.dart';
import 'package:tasket/widget/btn/check_btn.dart';
import 'package:tasket/widget/label/icon_label.dart';
import 'package:tasket/widget/label/box_label.dart';

class TaskTile extends StatefulWidget {
  final Task task;
  final VoidCallback onComplete;

  const TaskTile({super.key, required this.task, required this.onComplete});

  @override
  State<TaskTile> createState() => _TaskTileState();
}

class _TaskTileState extends State<TaskTile> with TickerProviderStateMixin {
  bool _selected = false;
  double _opacity = 1.0;

  late final AnimationController _controller;
  late final Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _fadeAnimation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final task = widget.task;

    if (task.isCompleted) {
      Future.delayed(const Duration(seconds: 1), () {
        if (!task.isCompleted || !mounted) return;
        setState(() {
          _opacity = 0.0;
        });
        widget.onComplete();
      });
    }
    return AnimatedOpacity(
      duration: const Duration(milliseconds: 400),
      opacity: _opacity,
      child: Container(
        decoration: const BoxDecoration(
          border: Border(
            bottom: BorderSide(color: Color(0xFFE0E0E0), width: 0.5),
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // main title
            InkWell(
              borderRadius: BorderRadius.circular(8),
              onTap: () {
                setState(() {
                  _selected = !_selected;
                  if (_selected) {
                    _controller.forward();
                  } else {
                    task.isNew = false;
                    task.isUpdated = false;
                    _controller.reverse();
                  }
                });
              },
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    CheckButton(
                      size: 28,
                      isChecked: task.isCompleted,
                      onChanged: (isChecked) {
                        setState(() {
                          task.isCompleted = isChecked;
                          _opacity = isChecked ? 0.4 : 1.0;
                        });
                      },
                    ),
                    SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              if (task.isNew)
                                BoxLabel(
                                  text: 'new',
                                  color: const Color.fromARGB(255, 220, 165, 0),
                                ),
                              if (task.isUpdated)
                                BoxLabel(
                                  text: 'updated',
                                  color: Colors.deepOrange,
                                ),

                              AnimatedDefaultTextStyle(
                                duration: Duration(milliseconds: 100),
                                curve: Curves.easeInOut,
                                style: Theme.of(context).textTheme.titleMedium!,
                                child: Text(task.title),
                              ),
                            ],
                          ),
                          if (task.note != null) ...[
                            AnimatedSize(
                              duration: const Duration(milliseconds: 200),
                              curve: Curves.easeInCirc,
                              alignment: Alignment.topLeft,
                              child: Text(
                                task.note!,
                                maxLines: _selected ? null : 1,
                                overflow:
                                    _selected
                                        ? TextOverflow.visible
                                        : TextOverflow.ellipsis,
                                style: Theme.of(context).textTheme.bodySmall,
                              ),
                            ),
                          ],
                          if (task.subtasks != null)
                            IconLabel(
                              icon: Symbols.format_list_bulleted,
                              text:
                                  "${task.uncompletedSubtasksCount} uncompleted",
                            ),
                          if (task.dueOn != null)
                            IconLabel(
                              icon: Symbols.calendar_clock,
                              text:
                                  (_selected)
                                      ? task.formalFormatDueOn
                                      : '${task.readableFormatDueOn} | ${task.formatDueIn}',
                            ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            if (task.subtasks != null && task.subtasks!.isNotEmpty)
              AnimatedSize(
                duration: const Duration(milliseconds: 200),
                curve: Curves.easeInCirc,
                child: SizeTransition(
                  sizeFactor: _fadeAnimation,
                  axisAlignment: -1.0,
                  child: FadeTransition(
                    opacity: _fadeAnimation,
                    child: Container(
                      padding: const EdgeInsets.only(
                        left: 16,
                        right: 16,
                        bottom: 8,
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          const SizedBox(width: 40),
                          Expanded(
                            child: SubtaskListView(
                              task.subtasks!,
                              onChanged: (completedCounter) {
                                print(completedCounter);
                                final isCompleted =
                                    completedCounter == task.subtasks!.length;
                                setState(() {
                                  task.isCompleted = isCompleted;
                                  _opacity = isCompleted ? 0.4 : 1.0;
                                });
                              },
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
