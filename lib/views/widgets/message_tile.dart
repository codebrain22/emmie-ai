import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:share_plus/share_plus.dart';

import '../../utils/helpers.dart';
import '../../utils/theme.dart';

class MessageTile extends ConsumerWidget {
  final String message;
  final String messageDate;
  final String searchQuery;

  const MessageTile({
    super.key,
    required this.message,
    required this.messageDate,
    this.searchQuery = '',
  });

  static const _borderRadius = 12.0;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isMatchingQuery = searchQuery.isNotEmpty && message.toLowerCase().contains(searchQuery);

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10.0),
      child: Align(
        alignment: Alignment.centerLeft,
        child: SizedBox(
          width: MediaQuery.of(context).size.width * 0.8,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                decoration: BoxDecoration(
                  color: Theme.of(context).cardColor,
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(_borderRadius),
                    topRight: Radius.circular(_borderRadius),
                    bottomRight: Radius.circular(_borderRadius),
                  ),
                ),
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    vertical: 15.0,
                    horizontal: 15.0,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      isMatchingQuery
                          ? Text(
                              message,
                              style: isMatchingQuery
                                  ? const TextStyle(
                                      backgroundColor: Colors.yellowAccent,
                                      color: AppColors.textFaded,
                                    )
                                  : const TextStyle(),
                            )
                          : Text(message),
                      const SizedBox(height: 20),
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            messageDate,
                            style: const TextStyle(
                              color: AppColors.textFaded,
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          if (message.length <= 13)
                            const SizedBox(width: 40)
                          else if (message.length > 13 && message.length <= 26)
                            const SizedBox(width: 130)
                          else
                            const Spacer(),
                          InkWell(
                            onTap: () {
                              Clipboard.setData(ClipboardData(text: message));
                              NotificationHandler(
                                context: context,
                                icon: Icons.check_circle_outline_rounded,
                                color: AppColors.successGreen,
                                message: AppLocalizations.of(context)!.messageCopied,
                              ).showSnackBar();
                            },
                            child: const Icon(
                              Icons.copy,
                              size: 15.0,
                            ),
                          ),
                          const SizedBox(width: 8.0),
                          InkWell(
                            onTap: () {
                              Share.share(
                                message,
                                subject: 'Hey there! Check this out from Emmie AI! 🤖',
                              );
                            },
                            child: const Icon(
                              Icons.share,
                              size: 15.0,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
