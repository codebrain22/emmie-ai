import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';

import '../providers/emmie_providers.dart';
import '../utils/constants.dart';
import '../utils/enums.dart';
import '../utils/helpers.dart';
import '../utils/theme.dart';
import 'auth_screen.dart';
import 'widgets/onboarding_page_widget.dart';

class OnboardingScreen extends ConsumerStatefulWidget {
  const OnboardingScreen({Key? key}) : super(key: key);

  @override
  OnboardingScreenState createState() => OnboardingScreenState();
}

class OnboardingScreenState extends ConsumerState<OnboardingScreen> {
  final _pageController = PageController();
  bool _onLastPage = false;

  void _completeOnboarding() {
    Navigator.of(context).pushReplacementNamed(AuthScreen.routeName);
    ref.read(userOnboardedStateProvider.notifier).update((state) => true);
    SharedPreference(key: Constants.userOnboarded, valueType: ValueType.boolean, value: true).setSharedPreferenceData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0.0,
        actions: [
          TextButton(
            onPressed: _completeOnboarding,
            child: Text(
              _onLastPage ? 'Get Started' : 'Skip',
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: AppColors.primary,
                fontSize: 17,
                fontWeight: FontWeight.bold,
              ),
            ),
          )
        ],
      ),
      body: Stack(
        children: [
          PageView(
            controller: _pageController,
            onPageChanged: (index) => setState(() => _onLastPage = index == 2),
            children: const [
              OnboardingPageWidget(
                headingText: 'Your Personal AI Assistant Awaits',
                bodyText:
                    'Meet Emmie AI, your smart chatbot companion. Ask anything with just a few taps for quick, reliable information and support, all at your fingertips.',
                imagePath: Constants.onboardingPageOneImage,
              ),
              OnboardingPageWidget(
                headingText: 'Access To Adevanced Features',
                bodyText:
                    'Enjoy unlimited chatting with advanced features like text-to-speech, speech-to-text, image text recognition, and multiple languages for a versatile communication experience.',
                imagePath: Constants.onboardingPageTwoImage,
              ),
              OnboardingPageWidget(
                headingText: 'Access To Chat History',
                bodyText: 'Rest assured that all your conversations with Emmie AI are securely saved and accessible whenever you need them.',
                imagePath: Constants.onboardingPageThreeImage,
              ),
            ],
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Container(
              alignment: const Alignment(0, 0.8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  SmoothPageIndicator(
                    controller: _pageController,
                    effect: const ExpandingDotsEffect(
                      activeDotColor: AppColors.primary,
                    ),
                    count: 3,
                  ),
                  GestureDetector(
                    onTap: () {
                      if (_onLastPage) {
                        _completeOnboarding();
                      } else {
                        _pageController.nextPage(
                          duration: const Duration(milliseconds: 500),
                          curve: Curves.easeIn,
                        );
                      }
                    },
                    child: Container(
                      decoration: const BoxDecoration(shape: BoxShape.circle, color: AppColors.primary),
                      child: const Padding(
                        padding: EdgeInsets.all(12.5),
                        child: Icon(
                          CupertinoIcons.forward,
                          color: AppColors.textLight,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          )
        ],
      ),
    );
  }
}
