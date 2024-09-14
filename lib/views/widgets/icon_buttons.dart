import 'package:flutter/material.dart';

import '../../utils/theme.dart';

class IconButtons extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  const IconButtons({super.key, required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Theme.of(context).cardColor,
      borderRadius: BorderRadius.circular(6),
      child: InkWell(
        borderRadius: BorderRadius.circular(6),
        splashColor: AppColors.iconRed,
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(6),
          child: Icon(
            icon,
            size: 20,
            color: AppColors.iconLight,
          ),
        ),
      ),
    );
  }
}
