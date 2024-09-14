import 'package:flutter/material.dart';

import '../../utils/theme.dart';

class DateLabel extends StatelessWidget {
  final String label;
  final double topSize;
  final double bottomSize;

  const DateLabel({
    super.key,
    required this.label,
    this.topSize = 8.0,
    this.bottomSize = 8.0,
  });

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.topCenter,
      child: Padding(
        padding: EdgeInsets.only(top: topSize, bottom: bottomSize),
        child: Container(
          decoration: BoxDecoration(color: Theme.of(context).cardColor, borderRadius: BorderRadius.circular(5)),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 5.0, horizontal: 12.0),
            child: Text(
              label,
              style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.textFaded),
            ),
          ),
        ),
      ),
    );
  }
}
