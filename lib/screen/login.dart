import 'package:flutter/material.dart';

import 'package:hooks_riverpod/hooks_riverpod.dart';
// import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
// import 'package:material_symbols_icons/symbols.dart';

import 'package:google_fonts/google_fonts.dart';

import 'package:tasket/provider/service_provider.dart';
import 'package:tasket/widget/btn/login_btn.dart';

import 'package:tasket/app/constants.dart';

class LoginScreen extends StatefulHookConsumerWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  double _opacity = 0.0;
  bool signInVisible = false;

  @override
  void initState() {
    super.initState();
    Future.delayed(Duration(milliseconds: 100), () {
      setState(() {
        _opacity = 1.0;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    final auth = ref.read(authServiceProvider);

    return Scaffold(
      body: GestureDetector(
        onTap: () {
          setState(() {
            signInVisible = true;
          });
        },
        child: Container(
          width: double.infinity,
          height: double.infinity,
          color: Colors.transparent,
          child: Stack(
            children: [
              Padding(
                padding: const EdgeInsets.all(30),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    AnimatedOpacity(
                      opacity: _opacity,
                      duration: Duration(milliseconds: 1000),
                      curve: Curves.easeInCirc,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Task.ai',
                            style: Theme.of(context).textTheme.displayLarge,
                          ),
                          SizedBox(height: 10),
                          Text(
                            'Tasks made simple,\nPowered by AI.',
                            style: Theme.of(context).textTheme.displayMedium,
                          ),
                        ],
                      ),
                    ),
                    AnimatedSize(
                      duration: Duration(milliseconds: 800),
                      curve: Curves.easeOut,
                      child:
                          signInVisible
                              ? AnimatedSlide(
                                offset: Offset(0, 0),
                                duration: Duration(milliseconds: 800),
                                curve: Curves.easeOut,
                                child: Column(
                                  children: [
                                    const SizedBox(height: 180),
                                    LoginButton(
                                      icon: Icon(
                                        FontAwesomeIcons.google,
                                        size: 24,
                                      ),
                                      text: Text(
                                        'Continue with Google',
                                        style:
                                            Theme.of(
                                              context,
                                            ).textTheme.bodyMedium,
                                      ),
                                      loginMethod: auth.googleLogin,
                                      backgroundColor: Colors.white,
                                    ),
                                    const SizedBox(height: 20),
                                    LoginButton(
                                      icon: Icon(
                                        FontAwesomeIcons.apple,
                                        size: 24,
                                        color: Colors.white,
                                      ),
                                      text: Text(
                                        'Continue with Apple',
                                        style: Theme.of(context)
                                            .textTheme
                                            .bodyMedium!
                                            .copyWith(color: Colors.white),
                                      ),
                                      loginMethod: auth.anonLogin,
                                      backgroundColor: Color(0xFF979797),
                                    ),
                                  ],
                                ),
                              )
                              : SizedBox.shrink(),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
