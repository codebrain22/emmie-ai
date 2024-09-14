import 'package:flutter/material.dart';

import '../../utils/theme.dart';

class BottomSheetBar extends StatelessWidget {
  final double bottom;

  const BottomSheetBar({
    super.key,
    this.bottom = 20,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: InkWell(
        hoverColor: Colors.green,
        onTap: () => Navigator.of(context).pop(),
        child: Container(
          width: 45,
          height: 5,
          margin: EdgeInsets.only(bottom: bottom),
          decoration: BoxDecoration(
            color: AppColors.textFaded,
            borderRadius: BorderRadius.circular(50),
          ),
        ),
      ),
    );
  }
}
