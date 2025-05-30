import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import 'package:hooks_riverpod/hooks_riverpod.dart';
// import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

import 'package:tasket/provider/service_provider.dart';
import 'package:tasket/widget/btn/login_btn.dart';
import 'package:tasket/app/constants.dart';
import 'package:tasket/util/alert.dart';
import 'package:tasket/util/exception.dart';

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

    Future<void> handleSigninSignup(
      Future<UserCredential> Function() loginMethod,
    ) async {
      try {
        final userCredential = await loginMethod();
        if (context.mounted) {
          if (userCredential.additionalUserInfo?.isNewUser ?? false) {
            showInfoAlert(context, 'Welcome!');
            await ref.read(dataServiceProvider)!.insertDemoTasks();
          } else {
            showInfoAlert(context, 'Successfully signed in!');
          }
        }
      } catch (e) {
        if (context.mounted) {
          handleException(context, e);
        }
        return;
      }
    }

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
                          Container(
                            padding: EdgeInsets.symmetric(
                              vertical: 4,
                              horizontal: 16,
                            ),
                            decoration: BoxDecoration(
                              color: AppColors.primary,
                              borderRadius: BorderRadius.horizontal(
                                right: Radius.circular(18),
                              ),
                            ),
                            child: Text(
                              'Tasket',
                              style: Theme.of(
                                context,
                              ).textTheme.displayLarge?.copyWith(
                                color: Theme.of(context).colorScheme.onPrimary,
                              ),
                            ),
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
                                        color: Color(0xFF787878),
                                      ),
                                      text: Text(
                                        'Continue with Google',
                                        style:
                                            Theme.of(
                                              context,
                                            ).textTheme.bodyMedium,
                                      ),
                                      onPressed: () async {
                                        await handleSigninSignup(
                                          auth.googleLogin,
                                        );
                                      },
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
                                      onPressed: () async {
                                        await handleSigninSignup(
                                          auth.appleLogin,
                                        );
                                      },
                                      backgroundColor: Color(0xFF787878),
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
