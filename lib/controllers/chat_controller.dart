import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/cupertino.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../models/chat_model.dart';
import '../models/message_model.dart';
import '../repository/chat_repository.dart';
import '../utils/helpers.dart';
import '../utils/theme.dart';

class ChatsController extends StateNotifier<ChatsState> {
  final ChatRepository _chatsRepo;
  final Ref _ref;

  ChatsController({required ChatRepository chatsRepo, required Ref ref})
      : _chatsRepo = chatsRepo,
        _ref = ref,
        super(const ChatsStateInitial());

  /// Returns an instance of CollectionReference of chats.
  /// Used to access a collection and interact with it (i.e get, save document).
  Stream<QuerySnapshot> getChats({required BuildContext context, required String userId}) {
    try {
      return _chatsRepo.getChats(userId: userId);
    } catch (e) {
      NotificationHandler(
        context: context,
        icon: CupertinoIcons.exclamationmark_circle,
        color: AppColors.errorRed,
        message: CommonHelpers(exception: '$e').getExceptionMessage(),
      ).showSnackBar();
      return const Stream.empty();
    }
  }

  /// Gets conversation messages collection between two users from the database.
  /// Detects changes when the messages collection changes.
  Stream<QuerySnapshot<Map<String, dynamic>>> getMessages({required ChatModel chat}) {
    try {
      return _chatsRepo.getMessages(chat: chat);
    } catch (e) {
      throw Exception(e);
    }
  }

  /// Returns an instance of CollectionReference of contacts.
  /// Used to access a collection and interact with it (i.e get, save document).
  Future<QuerySnapshot> getContacts() async {
    try {
      final contactsQuerySnapshot = await _chatsRepo.getContacts();
      return contactsQuerySnapshot;
    } catch (e) {
      throw Exception(e);
    }
  }

  /// Gets a conversation collection between two users from the database.
  void sendMessage({
    required BuildContext context,
    required MessageModel messageModel,
    required String chatBotId,
    required String chatBotName,
    required String userId,
  }) async {
    try {
      await _chatsRepo.sendMessage(
        ref: _ref,
        messageModel: messageModel,
        chatBotId: chatBotId,
        chatBotName: chatBotName,
        userId: userId,
      );
    } catch (e) {
      // ignore: use_build_context_synchronously
      NotificationHandler(
        context: context,
        icon: CupertinoIcons.exclamationmark_circle,
        color: AppColors.errorRed,
        message: CommonHelpers(exception: '$e').getExceptionMessage(),
      ).showSnackBar();
      return;
    }
  }

  /// Clear all the messages in a specific chat collection.
  Future<void> clearMessages({required BuildContext context, required String userId, required String chatBotId}) async {
    try {
      await _chatsRepo.clearMessages(userId: userId, chatBotId: chatBotId, updateChat: true);
    } catch (e) {
      // ignore: use_build_context_synchronously
      NotificationHandler(
        context: context,
        icon: CupertinoIcons.exclamationmark_circle,
        color: AppColors.errorRed,
        message: CommonHelpers(exception: '$e').getExceptionMessage(),
      ).showSnackBar();
    }
  }

  /// Delete chat.
  Future<void> deleteChat({required BuildContext context, required String userId, required String chatBotId}) async {
    try {
      await _chatsRepo.deleteChat(userId: userId, chatBotId: chatBotId);
    } catch (e) {
      // ignore: use_build_context_synchronously
      NotificationHandler(
        context: context,
        icon: CupertinoIcons.exclamationmark_circle,
        color: AppColors.errorRed,
        message: CommonHelpers(exception: '$e').getExceptionMessage(),
      ).showSnackBar();
    }
  }
}

/// Chats state.
class ChatsState extends Equatable {
  const ChatsState();

  @override
  List<Object> get props => [];
}

// States
class ChatsStateInitial extends ChatsState {
  const ChatsStateInitial();

  @override
  List<Object> get props => [];
}

class ChatsStateLoading extends ChatsState {
  const ChatsStateLoading();

  @override
  List<Object> get props => [];
}

class ChatsStateSuccess extends ChatsState {
  const ChatsStateSuccess();

  @override
  List<Object> get props => [];
}

class ChatsStateError extends ChatsState {
  final String error;

  const ChatsStateError(this.error);

  @override
  List<Object> get props => [error];
}
