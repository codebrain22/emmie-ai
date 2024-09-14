import 'dart:io';

import 'package:emmie/providers/user_providers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../controllers/auth_controller.dart';
import '../providers/auth_providers.dart';
import '../utils/constants.dart';
import '../utils/helpers.dart';
import '../utils/theme.dart';
import 'account_activation_screen.dart';
import 'chat_screen.dart';

class AuthScreen extends HookConsumerWidget {
  static const routeName = 'auth-screen';

  const AuthScreen({super.key});

  /// Signs user in with Google.
  void _signInWithGoogle({required BuildContext context, required WidgetRef ref}) {
    ref.read(authControllerStateNotifierProvider.notifier).signInWithGoogle(context: context);
  }

  /// Signs user in with Facebook.
  Future<void> _signInWithFacebook({required BuildContext context, required WidgetRef ref}) async {
    await ref.read(authControllerStateNotifierProvider.notifier).signInWithFacebook(context: context);
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final mediaQuery = MediaQuery.of(context).size;

    final isLoading = useState(false);
    final isLoginWithGoogle = useState(false);
    final isLoginWithFacebook = useState(false);
    final isLoginWithTwitter = useState(false);

    final sizedBox = SizedBox(height: mediaQuery.height * 0.04);

    ref.listen<AuthState>(authControllerStateNotifierProvider, (prevState, currState) {
      if (currState is AuthStateLoading) {
        isLoading.value = true;
      } else if (currState is AuthStateSuccess) {
        final user = ref.read(userModelStateProvider);
        if (user!.active) {
          Navigator.of(context).pushReplacementNamed(ChatScreen.routeName);
        } else {
          Navigator.of(context).pushReplacementNamed(AccountActivationScreen.routeName);
        }
      } else if (currState is AuthStateError) {
        isLoading.value = false;
        isLoginWithGoogle.value = false;
        isLoginWithFacebook.value = false;
        isLoginWithTwitter.value = false;
      }
    });

    return Scaffold(
      backgroundColor: AppColors.textLight,
      body: SingleChildScrollView(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Stack(
              alignment: Alignment.center,
              children: [
                ClipPath(
                  clipper: WaveClipper(),
                  child: Container(
                    color: AppColors.primary,
                    height: mediaQuery.height * 0.6,
                  ),
                ),
                Positioned(
                  top: mediaQuery.height * 0.2,
                  child: SizedBox(
                    width: 120,
                    height: 120,
                    child: Opacity(
                      opacity: 1,
                      child: Image.asset(
                        Constants.emmieIconAlt,
                        color: AppColors.textLight,
                      ),
                    ),
                  ),
                ),
                Positioned(
                  top: mediaQuery.height * 0.4,
                  child: const Text(
                    'Welcome to Emmie AI',
                    style: TextStyle(
                      color: AppColors.textLight,
                      fontSize: 25,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(height: 10.0),
                Positioned(
                  top: mediaQuery.height * 0.45,
                  child: const Text(
                    'Choose your sign in method to continue',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 14, color: AppColors.textLight),
                  ),
                ),
              ],
            ),
            SizedBox(
              height: mediaQuery.height * 0.02,
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 15),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // CONTINUE WITH GOOGLE
                  _socialLoginButton(
                    context: context,
                    ref: ref,
                    label: 'Continue with Google',
                    icon: Constants.googleImage,
                    mediaQuery: mediaQuery,
                    isLoading: isLoading,
                    isLoginWithSocialLogin: isLoginWithGoogle,
                    signIn: _signInWithGoogle,
                  ),
                  sizedBox,
                  // CONTINUE WITH FACEBOOK
                  _socialLoginButton(
                    context: context,
                    ref: ref,
                    label: 'Continue with Facebook',
                    icon: Constants.facebookImage,
                    mediaQuery: mediaQuery,
                    isLoading: isLoading,
                    isLoginWithSocialLogin: isLoginWithFacebook,
                    signIn: _signInWithFacebook,
                  ),
                  sizedBox,
                  SizedBox(height: mediaQuery.height * 0.09),
                  InkWell(
                    onTap: () {
                      if (Platform.isAndroid) {
                        CommonHelpers().launchApp(
                          context: context,
                          appUrl: Constants.emmieAiTermsAndConditions,
                        );
                      } else {
                        CommonHelpers().launchApp(
                          context: context,
                          appUrl: '',
                        );
                      }
                    },
                    child: const Center(
                      child: Text(
                        Constants.emmieAiDeclaration,
                        textAlign: TextAlign.center,
                        style: TextStyle(color: AppColors.textFaded, fontSize: 12),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Triggers a certain social login method.
  /// Social login button widget.
  ElevatedButton _socialLoginButton({
    required BuildContext context,
    required WidgetRef ref,
    required String label,
    required String icon,
    required Size mediaQuery,
    required ValueNotifier<bool> isLoading,
    required ValueNotifier<bool> isLoginWithSocialLogin,
    required void Function({required BuildContext context, required WidgetRef ref}) signIn,
  }) {
    return ElevatedButton(
      onPressed: () {
        isLoginWithSocialLogin.value = true;
        signIn(context: context, ref: ref);
      },
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.white70,
        minimumSize: Size(mediaQuery.width, mediaQuery.height * 0.08),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
        elevation: 0,
      ),
      child: isLoading.value && isLoginWithSocialLogin.value
          ? NotificationHandler(context: context, color: AppColors.textDark).showLoader()
          : Center(
              child: Container(
                constraints: const BoxConstraints(maxWidth: 250.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Image.asset(icon, width: 25),
                    const SizedBox(width: 20.0),
                    Text(label, style: const TextStyle(color: AppColors.textDark)),
                  ],
                ),
              ),
            ),
    );
  }
}

class WaveClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    double width = size.width;
    double height = size.height - 100;

    var path = Path();

    path.lineTo(0, height);
    path.quadraticBezierTo(width * 0.5, height + 100, width, height);
    path.lineTo(width, 0);

    return path;
  }

  @override
  bool shouldReclip(covariant CustomClipper<Path> oldClipper) {
    return true;
  }
}
