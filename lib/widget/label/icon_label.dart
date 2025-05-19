import 'package:flutter/material.dart';

import 'package:tasket/app/constants.dart';

class IconLabel extends StatelessWidget {
  const IconLabel({super.key, required this.text, required this.icon});

  final String text;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: AppFontSizes.xs, weight: 800, fill: 0),
        const SizedBox(width: 4),
        Text(text, style: Theme.of(context).textTheme.titleSmall),
      ],
    );
  }
}
