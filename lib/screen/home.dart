import 'package:flutter/material.dart';

import 'package:tasket/widget/input_box.dart';
import 'package:tasket/widget/task_board.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        FocusScope.of(context).unfocus();
      },
      behavior:
          HitTestBehavior.opaque, // ensures taps go through empty space too
      child: Scaffold(
        appBar: AppBar(toolbarHeight: 0),
        // body: Center(child: Text('hello!')),
        body: Column(
          children: [
            // Top: Horizontally scrollable note posting area
            TaskBoard(),
            // Bottom: Chat-like input field
            InputBox(),
          ],
        ),
      ),
    );
  }
}
