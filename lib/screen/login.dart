import 'package:flutter/material.dart';

import 'package:hooks_riverpod/hooks_riverpod.dart';
// import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

import 'package:tasket/provider/service_provider.dart';
import 'package:tasket/widget/btn/login_btn.dart';

class LoginScreen extends HookConsumerWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final auth = ref.read(authServiceProvider);

    return Scaffold(
      body: Container(
        padding: const EdgeInsets.all(30),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const FlutterLogo(size: 150),
            const SizedBox(height: 50),
            LoginButton(
              icon: FontAwesomeIcons.google,
              text: 'Sign in with Google',
              loginMethod: auth.googleLogin,
              color: Colors.white,
            ),
            const SizedBox(height: 20),
            LoginButton(
              icon: FontAwesomeIcons.userNinja,
              text: 'Continue as Guest',
              loginMethod: auth.anonLogin,
              color: Colors.grey,
            ),
          ],
        ),
      ),
    );
  }
}
