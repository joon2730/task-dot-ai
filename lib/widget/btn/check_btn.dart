import 'package:flutter/material.dart';
import 'package:material_symbols_icons/symbols.dart';

class CheckButton extends StatelessWidget {
  final ValueChanged<bool>? onChanged;
  final double? size;
  final bool isChecked;
  final Color color;

  const CheckButton({
    super.key,
    required this.isChecked,
    required this.color,
    this.onChanged,
    this.size,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => onChanged?.call(!isChecked),
      child: AnimatedSwitcher(
        duration: const Duration(milliseconds: 250),
        transitionBuilder:
            (child, animation) =>
                ScaleTransition(scale: animation, child: child),
        child: Icon(
          isChecked
              ? Symbols.radio_button_checked
              : Symbols.radio_button_unchecked,
          key: ValueKey(isChecked),
          color: color,
          size: size ?? 28,
          weight: 800,
        ),
      ),
    );
  }
}
