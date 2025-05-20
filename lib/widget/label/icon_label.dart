import 'package:flutter/material.dart';

import 'package:tasket/app/constants.dart';

class IconLabel extends StatelessWidget {
  const IconLabel({super.key, required this.text, required this.icon});

  final String text;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.max,
      children: [
        Icon(icon, size: AppFontSizes.xs, weight: 800, fill: 0),
        const SizedBox(width: 4),
        AnimatedSwitcher(
          duration: const Duration(milliseconds: 500),
          transitionBuilder: (Widget child, Animation<double> animation) {
            final offsetAnimation = Tween<Offset>(
              begin: const Offset(0, 0.15),
              end: Offset.zero,
            ).animate(
              CurvedAnimation(parent: animation, curve: Curves.easeInOut),
            );

            return SlideTransition(
              position: offsetAnimation,
              child: FadeTransition(
                opacity: CurvedAnimation(
                  parent: animation,
                  curve: Curves.easeInOut,
                ),
                child: child,
              ),
            );
          },
          child: SizedBox(
            key: ValueKey(text),
            width: 300,
            child: Text(text, style: Theme.of(context).textTheme.titleSmall),
          ),
        ),
      ],
    );
  }
}
