import 'package:flutter/material.dart';

class BoxLabel extends StatelessWidget {
  const BoxLabel(this.content, {super.key, this.color = Colors.black});

  final Widget content;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return AnimatedSize(
      duration: Duration(milliseconds: 600),
      curve: Curves.easeInCirc,
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 4.0, vertical: 1.0),
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(12.0),
            ),
            alignment: Alignment.center,
            child: content,
          ),
          SizedBox(width: 4),
        ],
      ),
    );
  }
}
