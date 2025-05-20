import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import 'package:tasket/util/format.dart';
import 'package:tasket/widget/popup/menu.dart';
import 'package:tasket/provider/task_provider.dart';

class TopBar extends HookConsumerWidget {
  final bool innerBoxIsScrolled;

  const TopBar({super.key, required this.innerBoxIsScrolled});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tasksAsync = ref.watch(taskProvider);
    return SliverAppBar(
      toolbarHeight: 86,
      forceElevated: innerBoxIsScrolled,
      flexibleSpace: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextButton(
                style: TextButton.styleFrom(
                  foregroundColor: Theme.of(context).colorScheme.onPrimary,
                ),
                onPressed: () {},
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          formatReadableDate(DateTime.now()),
                          style: Theme.of(context).textTheme.headlineLarge,
                        ),
                        if (tasksAsync.hasValue)
                          Text(
                            '${tasksAsync.value?.length} total tasks',
                            style: Theme.of(context).textTheme.headlineSmall,
                          ),
                      ],
                    ),
                    // SizedBox(
                    //   width: 24,
                    //   height: 32,
                    //   child: Icon(
                    //     Icons.keyboard_arrow_down,
                    //     size: 20,
                    //     color: Theme.of(context).colorScheme.primary,
                    //   ),
                    // ),
                  ],
                ),
              ),
              IconButton(
                padding: EdgeInsets.zero,
                icon: Icon(
                  Icons.more_vert,
                  size: 24,
                  color: Theme.of(context).colorScheme.primary,
                ),
                onPressed: () {
                  FocusManager.instance.primaryFocus?.unfocus();
                  showDialog(
                    context: context,
                    barrierColor: Colors.transparent,
                    builder:
                        (context) =>
                            FocusScope(autofocus: false, child: GeneralMenu()),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
