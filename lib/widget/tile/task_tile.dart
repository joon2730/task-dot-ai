import 'package:flutter/material.dart';

import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:flutter_hooks/flutter_hooks.dart';

import 'package:tasket/model/task.dart';
import 'package:tasket/provider/task_provider.dart';
import 'package:tasket/provider/focus_node_provider.dart';
import 'package:tasket/widget/list_view/subtask_list_view.dart';
import 'package:tasket/widget/btn/check_btn.dart';
import 'package:tasket/widget/label/icon_label.dart';
import 'package:tasket/widget/label/box_label.dart';

class TaskTile extends HookConsumerWidget {
  final Task task;

  const TaskTile({super.key, required this.task});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final task = this.task;
    final selectedTask = ref.watch(selectedTaskProvider);
    final expanded = useState(false);
    final toComplete = useState(false);
    final update = useState(0);
    final controller = useAnimationController(
      duration: const Duration(milliseconds: 300),
    );
    final fadeAnimation = CurvedAnimation(
      parent: controller,
      curve: Curves.easeInOut,
    );
    expanded.value =
        expanded.value ||
        (task.isNew || task.isUpdated || selectedTask?.id == task.id);

    useEffect(() {
      if (expanded.value) {
        controller.forward();
      } else {
        controller.reverse();
      }
      return null;
    }, [expanded.value]);

    useEffect(() {
      if (toComplete.value) {
        Future.delayed(const Duration(seconds: 1), () {
          if (context.mounted) {
            if (!toComplete.value) return;
            if (ref.read(selectedTaskProvider)?.id == task.id) {
              ref.read(selectedTaskProvider.notifier).state = null;
            }
            ref.read(taskProvider.notifier).completeTask(task);
          }
        });
      }
      return null;
    }, [toComplete.value]);

    return AnimatedOpacity(
      duration: const Duration(milliseconds: 400),
      opacity: (toComplete.value) ? 0.4 : 1.0,
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
                task.isNew = false;
                task.isUpdated = false;
                FocusManager.instance.primaryFocus?.unfocus();
                expanded.value = !expanded.value;
                ref.read(selectedTaskProvider.notifier).state = null;
              },
              child: Slidable(
                key: ValueKey(task.id),
                startActionPane: ActionPane(
                  motion: const DrawerMotion(),
                  extentRatio: 0.2,
                  children: [
                    SlidableAction(
                      onPressed: (context) {
                        if (ref.read(selectedTaskProvider)?.id == task.id) {
                          ref.read(selectedTaskProvider.notifier).state = null;
                        }
                        ref.read(taskProvider.notifier).deleteTask(task);
                      },
                      backgroundColor: Theme.of(context).colorScheme.error,
                      icon: Symbols.cancel,
                    ),
                  ],
                ),
                endActionPane: ActionPane(
                  motion: const DrawerMotion(),
                  extentRatio: 0.2,
                  children: [
                    SlidableAction(
                      onPressed: (context) {
                        if (ref.read(selectedTaskProvider)?.id == task.id) {
                          ref.read(selectedTaskProvider.notifier).state = null;
                        } else {
                          ref.read(selectedTaskProvider.notifier).state = task;
                          ref.read(inputBoxFocusNodeProvider).requestFocus();
                        }
                      },
                      backgroundColor: Theme.of(context).colorScheme.secondary,
                      icon: Symbols.edit,
                      // label: 'Edit',
                    ),
                  ],
                ),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 250),
                  curve: Curves.easeInOut,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  color: Theme.of(context).colorScheme.surface,
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      CheckButton(
                        size: 28,
                        isChecked: toComplete.value,
                        onChanged: (isChecked) {
                          toComplete.value = isChecked;
                        },
                        color: Theme.of(context).colorScheme.primaryFixedDim,
                      ),
                      SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                AnimatedSize(
                                  duration: const Duration(milliseconds: 200),
                                  curve: Curves.easeInCirc,
                                  alignment: Alignment.topLeft,
                                  child: Text(
                                    task.title,
                                    softWrap: true,
                                    overflow:
                                        expanded.value
                                            ? TextOverflow.visible
                                            : TextOverflow.ellipsis,
                                    maxLines: expanded.value ? null : 2,
                                    style:
                                        Theme.of(context).textTheme.titleMedium,
                                  ),
                                ),
                                if (task.isNew) ...[
                                  SizedBox(width: 6),
                                  BoxLabel(
                                    Text(
                                      "new",
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 12,
                                        fontWeight: FontWeight.w800,
                                      ),
                                    ),
                                    color:
                                        Theme.of(context).colorScheme.primary,
                                  ),
                                ],
                                if (task.isUpdated) ...[
                                  SizedBox(width: 6),
                                  BoxLabel(
                                    Text(
                                      "edited",
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 12,
                                        fontWeight: FontWeight.w800,
                                      ),
                                    ),
                                    color:
                                        Theme.of(context).colorScheme.secondary,
                                  ),
                                ],
                                if (ref.read(selectedTaskProvider)?.id ==
                                    task.id) ...[
                                  SizedBox(width: 6),
                                  Icon(
                                    Symbols.edit,
                                    color:
                                        Theme.of(context).colorScheme.secondary,
                                    size: 22,
                                    weight: 600,
                                  ),
                                  Icon(
                                    Symbols.close,
                                    color:
                                        Theme.of(context).colorScheme.secondary,
                                    size: 14,
                                    weight: 900,
                                  ),
                                ],
                                if (task.subtasks != null) ...[
                                  SizedBox(width: 2),
                                  Icon(
                                    Symbols.keyboard_arrow_down_rounded,
                                    color:
                                        Theme.of(context).colorScheme.onSurface,
                                    size: 16,
                                    weight: 600,
                                  ),
                                ],
                              ],
                            ),
                            if (task.note != null) ...[
                              AnimatedSize(
                                duration: const Duration(milliseconds: 200),
                                curve: Curves.easeInCirc,
                                alignment: Alignment.topLeft,
                                child: Text(
                                  task.note!,
                                  maxLines: expanded.value ? null : 1,
                                  overflow:
                                      expanded.value
                                          ? TextOverflow.visible
                                          : TextOverflow.ellipsis,
                                  style: Theme.of(context).textTheme.bodySmall,
                                ),
                              ),
                            ],
                            if (task.subtasks != null &&
                                task.subtasks!.isNotEmpty)
                              IconLabel(
                                icon: Symbols.format_list_bulleted,
                                text:
                                    "${task.uncompletedSubtasksCount} uncompleted",
                              ),
                            if (task.repeat != null)
                              IconLabel(
                                icon: Symbols.autorenew,
                                text:
                                    (expanded.value)
                                        ? task.repeat!.longFormatRepeatRule
                                        : task.repeat!.shortFormatRepeatRule,
                              ),
                            if (task.dueOn != null)
                              IconLabel(
                                icon: Symbols.calendar_clock,
                                text: task.displayFormatDueOn,
                              ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            if (task.subtasks != null && task.subtasks!.isNotEmpty)
              AnimatedSize(
                duration: const Duration(milliseconds: 200),
                curve: Curves.easeInCirc,
                child: SizeTransition(
                  sizeFactor: fadeAnimation,
                  axisAlignment: -1.0,
                  child: FadeTransition(
                    opacity: fadeAnimation,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 4,
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          const SizedBox(width: 40),
                          Expanded(
                            child: SubtaskListView(
                              task.subtasks!,
                              onChanged: (completedCounter) {
                                // handle save subtask change
                                update.value++;
                                task.logModified('subtasks');
                                ref
                                    .read(taskProvider.notifier)
                                    .updateTask(task);
                                // handle task completion
                                final isCompleted =
                                    completedCounter == task.subtasks!.length;
                                toComplete.value = isCompleted;
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
