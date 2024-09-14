import 'package:emmie/views/chat_helper.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../models/chatbot_model.dart';
import '../../models/message_model.dart';
import '../../providers/user_providers.dart';
import '../../utils/helpers.dart';
import '../../utils/theme.dart';

class MessageOwnTile extends HookConsumerWidget {
  final String message;
  final String messageDate;
  final List<MessageModel> messages;
  final ChatbotModel contact;
  final String searchQuery;

  const MessageOwnTile({
    super.key,
    required this.message,
    required this.messageDate,
    required this.messages,
    required this.contact,
    this.searchQuery = '',
  });

  static const _borderRadius = 12.0;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isMatchingQuery = searchQuery.isNotEmpty && message.toLowerCase().contains(searchQuery);
    final textController = useTextEditingController(text: message);

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10.0),
      child: Align(
        alignment: Alignment.centerRight,
        child: SizedBox(
          width: MediaQuery.of(context).size.width * 0.8,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Container(
                decoration: const BoxDecoration(
                    color: AppColors.primary,
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(_borderRadius),
                      bottomLeft: Radius.circular(_borderRadius),
                      bottomRight: Radius.circular(_borderRadius),
                    )),
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    vertical: 15.0,
                    horizontal: 15.0,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        message,
                        style: isMatchingQuery
                            ? const TextStyle(
                                backgroundColor: Colors.yellowAccent,
                                color: AppColors.textFaded,
                              )
                            : const TextStyle(color: AppColors.textLight),
                      ),
                      const SizedBox(height: 10),
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            messageDate,
                            style: const TextStyle(
                              color: AppColors.textLight,
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
                              color: AppColors.textLight,
                              //weight: 5,
                              size: 15.0,
                            ),
                          ),
                          const SizedBox(width: 8.0),
                          InkWell(
                            onTap: () {
                              final user = ref.watch(userModelStateProvider);
                              final chatHelper = ChatHelper(
                                userId: user!.id,
                                chatBotId: contact.id,
                                chatBotName: contact.name,
                                messages: messages,
                              );
                              chatHelper.sendMessageHandler(context: context, ref: ref, textController: textController);
                            },
                            child: const Icon(
                              CupertinoIcons.refresh_thick,
                              color: AppColors.textLight,
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
