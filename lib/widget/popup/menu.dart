import 'package:flutter/material.dart';

import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';

import 'package:material_symbols_icons/symbols.dart';
import 'package:tasket/provider/service_provider.dart';
import 'package:tasket/widget/tile/menu_tile.dart';

Future<void> openWebPage(String url) async {
  final uri = Uri.parse(url);
  if (await canLaunchUrl(uri)) {
    await launchUrl(uri, mode: LaunchMode.externalApplication);
  } else {
    throw 'Could not launch $url';
  }
}

class GeneralMenu extends HookConsumerWidget {
  const GeneralMenu({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Container(
      padding: const EdgeInsets.only(top: 48.0),
      alignment: Alignment.topRight,
      child: Material(
        borderRadius: BorderRadius.circular(16),
        elevation: 2,
        color: Colors.white,
        child: IntrinsicWidth(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              MenuTile(
                icon: Symbols.menu_book_rounded,
                title: "Quick guide",
                iconSize: 20,
                onTap: () {
                  Navigator.pop(context);
                  openWebPage(
                    'https://www.notion.so/Quick-Guide-to-Task-ai-1fe01fbc826b801eb34dd382aad5531f#1ff01fbc826b806094bffc822bb12537',
                  );
                },
              ),
              Divider(
                indent: 16.0,
                endIndent: 16.0,
                height: 1,
                color: Theme.of(context).colorScheme.shadow,
                thickness: 2,
              ),
              MenuTile(
                icon: Symbols.logout,
                title: "Sign out",
                iconSize: 20,
                onTap: () {
                  Navigator.pop(context);
                  ref.read(authServiceProvider).signOut();
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
