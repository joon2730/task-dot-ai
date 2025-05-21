import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import 'package:material_symbols_icons/symbols.dart';
import 'package:tasket/provider/service_provider.dart';

class GeneralMenu extends HookConsumerWidget {
  const GeneralMenu({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Container(
      padding: const EdgeInsets.only(top: 42.0),
      alignment: Alignment.topRight,
      child: Material(
        borderRadius: BorderRadius.circular(16),
        elevation: 4,
        color: Colors.white,
        child: IntrinsicWidth(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8.0),
                child: ListTile(
                  dense: true,
                  leading: Icon(
                    Symbols.logout,
                    size: 20,
                    color: Theme.of(context).colorScheme.onSurface,
                  ),
                  title: Text(
                    "Sign out",
                    style: TextStyle(
                      fontSize: 14,
                      color: Theme.of(context).colorScheme.onSurface,
                    ),
                  ),
                  onTap: () {
                    Navigator.pop(context);
                    ref.read(authServiceProvider).signOut();
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
