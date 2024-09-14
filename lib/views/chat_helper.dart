import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:purchases_flutter/purchases_flutter.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import '../models/message_model.dart';
import '../providers/chats_providers.dart';
import '../providers/emmie_providers.dart';
import '../providers/user_providers.dart';
import '../utils/helpers.dart';
import '../utils/theme.dart';
import 'account_activation_screen.dart';
import 'widgets/purchases_widget.dart';

class ChatHelper {
  final String userId;
  final String chatBotId;
  final String chatBotName;
  final List<MessageModel> messages;

  const ChatHelper({
    required this.userId,
    required this.chatBotId,
    required this.chatBotName,
    required this.messages,
  });

  /// Prepares for a message to be send to the api.
  /// Created for resuability as used in more than one places.
  void sendMessageHandler({
    required BuildContext context,
    required WidgetRef ref,
    required TextEditingController textController,
  }) {
    // Check if message state provider has previous messages
    if (ref.read(previousMessagesStateProvider).isEmpty) {
      final instructions = ref.read(chatbotInstructions);

      final result = CommonHelpers.getPreviousMessages(
        userId: userId,
        chatbotInstructions: instructions,
        messages: messages,
      );
      ref.read(previousMessagesStateProvider.notifier).state = result;
    }

    final currentLanguageCode = ref.watch(settingsModelStateProvider).language;
    final hasInternet = ref.watch(internetStateProvider);
    String currentUserLanguage = ref.read(languageCodesProvider)[currentLanguageCode]!.title;

    // Check internet connection
    if (hasInternet) {
      final message = textController.text.trim();
      final system = {"role": "system", "content": "You must reply in $currentUserLanguage language"};

      final previousMessages = ref.read(previousMessagesStateProvider);
      previousMessages.add(system);
      previousMessages.add({'role': 'user', 'content': message});

      ref.read(previousMessagesStateProvider.notifier).state = previousMessages;

      final messageModel = MessageModel(
        message: message,
        senderId: userId,
        createdAt: DateTime.now(),
      );
      // send the message.
      sendMessage(context: context, ref: ref, messageModel: messageModel);
      textController.text = '';
      // Close the keyboard
      FocusScope.of(context).unfocus();
    } else {
      NotificationHandler(
        context: context,
        icon: CupertinoIcons.wifi_exclamationmark,
        color: AppColors.errorRed,
        message: AppLocalizations.of(context)!.noInternetConnection,
      ).showSnackBar();
    }
  }

  /// Sends a message to the api for response.
  void sendMessage({
    required BuildContext context,
    required WidgetRef ref,
    required MessageModel messageModel,
  }) async {
    final user = ref.read(userModelStateProvider);
    final onExploration = ref.watch(onExplorationStateProvider);

    final chatsController = ref.read(chatsControllerStateNotifierProvider.notifier);
    final userController = ref.read(userControllerStateNotifierProvider.notifier);

    final offers = ref.watch(emmieAiPremiumOffers);
    final packages = offers.map((offer) => offer.availablePackages).expand((package) => package).toList();

    if (user != null) {
      if (!user.active) {
        Navigator.of(context).pushNamed(AccountActivationScreen.routeName);
      } else {
        if (!user.subscribed && !onExploration) {
          if (user.freeMessages > 0) {
            chatsController.sendMessage(
              context: context,
              messageModel: messageModel,
              chatBotId: chatBotId,
              chatBotName: chatBotName,
              userId: userId,
              // prevMessages: prevMessages,
            );

            await userController.updateUserFreeMessageCount();
          } else {
            _subscriptionPaywallBottomSheet(context: context, packages: packages);
          }
        } else {
          chatsController.sendMessage(
            context: context,
            messageModel: messageModel,
            chatBotId: chatBotId,
            chatBotName: chatBotName,
            userId: userId,
            // prevMessages: prevMessages,
          );
        }
      }
    }
  }

  /// Subscription paywall bottom sheet.
  Future<dynamic> _subscriptionPaywallBottomSheet({required BuildContext context, required List<Package> packages}) {
    return showModalBottomSheet(
      // useSafeArea: true,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(10),
          topRight: Radius.circular(10),
        ),
      ),
      backgroundColor: Theme.of(context).cardColor,
      context: context,
      builder: (_) => SizedBox(
        child: SingleChildScrollView(
          child: PremiumOffers(packages: packages),
        ),
      ),
    );
  }
}
