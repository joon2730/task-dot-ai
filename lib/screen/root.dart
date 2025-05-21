import 'package:flutter/material.dart';

// import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import 'package:tasket/provider/service_provider.dart';
import 'package:tasket/widget/bar/snackbar.dart';
import 'package:tasket/screen/home.dart';
import 'package:tasket/screen/login.dart';

class Root extends HookConsumerWidget {
  const Root({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userAsync = ref.watch(userStreamProvider);

    // Move ScaffoldMessenger logic out of build phase using Future.microtask
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 300),
      transitionBuilder:
          (child, animation) =>
              FadeTransition(opacity: animation, child: child),
      child: userAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(topSnackbar("Authentication failed."));
          return const LoginScreen(key: ValueKey('login'));
        },
        data: (user) {
          if (user == null) {
            return const LoginScreen(key: ValueKey('login'));
          } else {
            return const HomeScreen(key: ValueKey('home'));
          }
        },
      ),
    );
  }
}
