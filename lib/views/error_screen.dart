import 'package:flutter/material.dart';

import '../utils/constants.dart';
import '../utils/theme.dart';

class ErrorScreen extends StatefulWidget {
  static const routeName = 'error-screen';
  final String title;
  final String message;
  final String description;

  // final String message;
  const ErrorScreen({
    Key? key,
    this.title = '',
    this.message = '',
    this.description = '',
  }) : super(key: key);

  @override
  State<ErrorScreen> createState() => _ErrorScreenState();
}

class _ErrorScreenState extends State<ErrorScreen> {
  late Image image;

  @override
  void initState() {
    super.initState();
    image = Image.asset(Constants.errorImage);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    precacheImage(image.image, context);
  }

  @override
  Widget build(BuildContext context) {
    final mediaQuery = MediaQuery.of(context).size;

    return Scaffold(
        backgroundColor: Theme.of(context).cardColor,
        appBar: AppBar(
          automaticallyImplyLeading: false,
          iconTheme: Theme.of(context).iconTheme,
          backgroundColor: Colors.transparent,
          elevation: 0,
          title: Text(widget.title),
        ),
        body: Container(
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surface,
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(20),
              topRight: Radius.circular(20),
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 15),
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Center(
                    child: Container(
                      height: mediaQuery.height * 0.45,
                      decoration: BoxDecoration(
                        image: DecorationImage(image: image.image),
                      ),
                    ),
                  ),
                  Center(
                    child: Text(
                      widget.message,
                      style: const TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),
                  Center(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 10),
                      child: Text(
                        widget.description,
                        textAlign: TextAlign.center,
                        style: const TextStyle(fontSize: 13, color: AppColors.textFaded),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ));
  }
}
