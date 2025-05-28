import 'package:flutter/material.dart';

import 'package:material_symbols_icons/symbols.dart';

void showErrorAlert(BuildContext context, String message) {
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Row(
        children: [
          Icon(
            Symbols.error,
            size: 20,
            color: Theme.of(context).colorScheme.onErrorContainer,
          ),
          SizedBox(width: 6),
          Text(
            message,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Theme.of(context).colorScheme.onErrorContainer,
            ),
          ),
        ],
      ),
      backgroundColor: Theme.of(context).colorScheme.errorContainer,
      duration: Duration(seconds: 6),
    ),
  );
}

void showInfoAlert(BuildContext context, String message) {
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Row(
        children: [
          Icon(
            Symbols.info,
            size: 20,
            color: Theme.of(context).colorScheme.onPrimary,
          ),
          SizedBox(width: 6),
          Text(
            message,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Theme.of(context).colorScheme.onPrimary,
            ),
          ),
        ],
      ),
      backgroundColor: Theme.of(context).colorScheme.primary,
      duration: Duration(seconds: 4),
    ),
  );
}
