import 'package:flutter/material.dart';
import '../../utils/theme.dart';

class OnboardingPageWidget extends StatefulWidget {
  final String headingText;
  final String bodyText;
  final String imagePath;

  const OnboardingPageWidget({Key? key, required this.headingText, required this.bodyText, required this.imagePath}) : super(key: key);

  @override
  State<OnboardingPageWidget> createState() => _OnboardingPageWidgetState();
}

class _OnboardingPageWidgetState extends State<OnboardingPageWidget> {
  late Image image;

  @override
  void initState() {
    super.initState();
    image = Image.asset(widget.imagePath);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    precacheImage(image.image, context);
  }

  @override
  Widget build(BuildContext context) {
    final mediaQuery = MediaQuery.of(context).size;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 50).copyWith(
        bottom: 80,
      ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Center(
              child: Container(
                height: mediaQuery.height * 0.4,
                decoration: BoxDecoration(
                  image: DecorationImage(image: image.image),
                ),
              ),
            ),
            const SizedBox(height: 20),
            Text(
              widget.headingText,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: AppColors.primary,
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 15),
            Text(
              widget.bodyText,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: AppColors.textFaded,
                fontSize: 14,
                fontWeight: FontWeight.w400,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
