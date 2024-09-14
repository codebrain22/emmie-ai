import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:grouped_list/grouped_list.dart';

import '../../models/chatbot_model.dart';
import '../../models/message_model.dart';
import '../../providers/user_providers.dart';
import '../../utils/helpers.dart';
import 'data_label.dart';
import 'message_loader.dart';
import 'message_own_tile.dart';
import 'message_tile.dart';

class MessageList extends StatefulHookConsumerWidget {
  final List<MessageModel> messages;
  final ChatbotModel contact;
  final String userId;
  final String searchQuery;

  const MessageList({
    super.key,
    required this.messages,
    required this.contact,
    required this.userId,
    this.searchQuery = '',
  });

  @override
  MessageListWidget createState() => MessageListWidget();
}

class MessageListWidget extends ConsumerState<MessageList> {
  @override
  void initState() {
    super.initState();
    // Checks is its a new day and award user free messages.
    if (widget.messages.isNotEmpty) {
      final userLastMessageDate = widget.messages.lastWhere((message) => message.senderId == widget.userId).createdAt;
      ref.read(userControllerStateNotifierProvider.notifier).awardFreeMessages(userLastMessageDate: userLastMessageDate);
    }
  }

  @override
  Widget build(BuildContext context) {
    // ListView scroll controller hook
    final scrollController = useScrollController();
    // Scroll to the end of the list view
    WidgetsBinding.instance.addPostFrameCallback((_) => scrollController.jumpTo(scrollController.position.maxScrollExtent));

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 15).copyWith(bottom: 10),
      child: GroupedListView<MessageModel, DateTime>(
        controller: scrollController,
        elements: widget.messages,
        groupBy: (message) => DateTime(
          message.createdAt.year,
          message.createdAt.month,
          message.createdAt.day,
        ),
        groupHeaderBuilder: (message) => DateLabel(
          label: DateFormatter.getMessageDateLabel(message.createdAt),
        ),
        indexedItemBuilder: (context, element, index) {
          String messageDate = DateFormatter.formatDate(widget.messages[index].createdAt);
          bool isLastMessageFromSender = index == widget.messages.length - 1 && widget.messages[index].senderId == widget.userId;

          return Column(
            children: [
              SizedBox(
                child: widget.messages[index].senderId == widget.userId
                    ? MessageOwnTile(
                        message: widget.messages[index].message,
                        messageDate: messageDate,
                        messages: widget.messages,
                        contact: widget.contact,
                        searchQuery: widget.searchQuery,
                      ).animate().fadeIn(duration: 1.seconds)
                    : MessageTile(
                        message: widget.messages[index].message,
                        messageDate: messageDate,
                        searchQuery: widget.searchQuery,
                      ).animate().fadeIn(duration: 1.seconds),
              ),
              if (isLastMessageFromSender) const MessageLoader(),
            ],
          );
        },
      ),
    );
  }
}
