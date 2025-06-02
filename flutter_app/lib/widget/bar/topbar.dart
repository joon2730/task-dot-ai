import 'package:flutter/material.dart';

import 'package:intl/intl.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:flutter/cupertino.dart';

import 'package:tasket/widget/popup/menu.dart';
import 'package:tasket/provider/task_provider.dart';

class TopBar extends HookConsumerWidget {
  final bool innerBoxIsScrolled;

  const TopBar({super.key, required this.innerBoxIsScrolled});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final totalTasksAsync = ref.watch(taskProvider);

    Map<int, Widget> selections = {
      0: Text(
        'List',
        style: Theme.of(context).textTheme.headlineSmall?.copyWith(
          color: Theme.of(context).colorScheme.surface,
        ),
      ),
      1: Text(
        'Calendar',
        style: Theme.of(context).textTheme.headlineSmall?.copyWith(
          color: Theme.of(context).colorScheme.surface,
        ),
      ),
    };

    return SliverAppBar(
      toolbarHeight: 100,
      forceElevated: innerBoxIsScrolled,
      flexibleSpace: Padding(
        padding: EdgeInsets.symmetric(horizontal: 16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Text(
                      // DateFormat('E, MMM d').format(DateTime.now()),
                      'All Tasks',
                      style: Theme.of(
                        context,
                      ).textTheme.headlineLarge?.copyWith(
                        color: Theme.of(context).colorScheme.onSurface,
                      ),
                    ),
                  ],
                ),
                Row(
                  children: [
                    IconButton(
                      onPressed: () {},
                      icon: Icon(
                        Symbols.history_2,
                        size: 26,
                        color: Theme.of(context).colorScheme.onSurface,
                        weight: 600,
                      ),
                    ),
                    IconButton(
                      onPressed: () {},
                      icon: Icon(
                        Symbols.account_circle_filled,
                        size: 26,
                        color: Theme.of(context).colorScheme.onSurface,
                        weight: 600,
                      ),
                    ),
                  ],
                ),
              ],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                CupertinoSlidingSegmentedControl<int>(
                  groupValue: 0,
                  backgroundColor: Theme.of(context).colorScheme.surfaceDim,
                  thumbColor: Theme.of(context).colorScheme.surface,
                  children: selections.map(
                    (key, value) => MapEntry(
                      key,
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16.0),
                        child: Icon(
                          key == 0
                              ? Symbols.table_rows_rounded
                              : Symbols.calendar_today_rounded,
                          color:
                              key == 0
                                  ? Theme.of(
                                    context,
                                  ).colorScheme.onSurfaceVariant
                                  : Theme.of(
                                    context,
                                  ).colorScheme.onSurfaceVariant,
                          size: 18,
                          weight: 800,
                        ),
                      ),
                    ),
                  ),
                  onValueChanged: (int? index) {
                    // TODO: handle value change
                  },
                ),
                TextButton(
                  onPressed: () {},
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Icon(
                        Symbols.filter_list_rounded,
                        size: 22,
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                        weight: 600,
                      ),
                      SizedBox(width: 6),
                      Text(
                        'Filter',
                        style: Theme.of(context).textTheme.headlineSmall,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
