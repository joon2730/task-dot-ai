import 'package:flutter/material.dart';

class LoginButton extends StatelessWidget {
  final Color backgroundColor;
  final Icon icon;
  final Text text;
  final VoidCallback onPressed;

  const LoginButton({
    super.key,
    required this.text,
    required this.icon,
    required this.backgroundColor,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      child: SizedBox(
        width: double.infinity,
        child: ElevatedButton(
          style: TextButton.styleFrom(
            padding: const EdgeInsets.all(24),
            backgroundColor: backgroundColor,
          ),
          onPressed: onPressed,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              icon,
              text,
              const Opacity(opacity: 0, child: Icon(Icons.arrow_forward)),
            ],
          ),
        ),
      ),
    );
  }
}
