import 'package:flutter/material.dart';

// import 'package:hooks_riverpod/hooks_riverpod.dart';
// import 'package:flutter_hooks/flutter_hooks.dart';

// import 'package:tasket/app/constants.dart';
import 'package:tasket/widget/bar/topbar.dart';
import 'package:tasket/widget/list_view/task_list_view.dart';

class TaskBoard extends StatelessWidget {
  const TaskBoard({super.key});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: NestedScrollView(
        headerSliverBuilder:
            (context, innerBoxIsScrolled) => [
              TopBar(innerBoxIsScrolled: innerBoxIsScrolled),
            ],
        body: TaskListView(),
      ),
    );
  }
}
