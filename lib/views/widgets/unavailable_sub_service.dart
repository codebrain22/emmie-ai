import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import '../../utils/theme.dart';
import 'bottom_sheet_bar.dart';

class UnavailableSubService extends StatelessWidget {
  const UnavailableSubService({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 15).copyWith(top: 10, bottom: 15),
      child: Column(
        children: [
          const BottomSheetBar(),
          Center(
            child: Text(
              AppLocalizations.of(context)!.subscriptionsrvsUnavailableTitle,
              style: const TextStyle(fontSize: 18, color: AppColors.primary, fontWeight: FontWeight.bold),
            ),
          ),
          const SizedBox(height: 15),
          Text(
            AppLocalizations.of(context)!.subscriptionsrvsUnavailableMessage,
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 14),
          ),
        ],
      ),
    );
  }
}
