import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../models/chat_model.dart';
import '../models/message_model.dart';
import '../providers/chats_providers.dart';
import '../providers/emmie_providers.dart';
import '../services/chatbot_api_service.dart';
import '../utils/constants.dart';
import '../utils/firebase_exceptions.dart';

class ChatRepository {
  final FirebaseFirestore _firestore;
  final ChatbotAPIService _apiService;

  ChatRepository({required FirebaseFirestore firestore, required ChatbotAPIService apiService})
      : _firestore = firestore,
        _apiService = apiService;

  /// Returns an instance of CollectionReference of chats.
  /// Used to access a collection and interact with it (i.e get, save document).
  CollectionReference get _users {
    return _firestore.collection(Constants.users);
  }

  /// Returns an instance of CollectionReference of contacts.
  /// Used to access a collection and interact with it (i.e get, save document).
  CollectionReference get _contacts {
    return _firestore.collection(Constants.contactsCollection);
  }

  /// Gets all the chats for the user from the database.
  /// Updates everytime the chats list data changes.
  Stream<QuerySnapshot> getChats({required String userId}) {
    final chats = _users.doc(userId).collection(Constants.chats).orderBy(Constants.chatChangedAt, descending: true).snapshots();
    return chats;
  }

  /// Gets conversation messages collection between two users.
  /// Detects changes when the messages collection changes.
  Stream<QuerySnapshot<Map<String, dynamic>>> getMessages({required ChatModel chat}) {
    try {
      final messages = _users
          .doc(chat.userId)
          .collection(Constants.chats)
          .doc(chat.chatBotId)
          .collection(Constants.messages)
          .orderBy(Constants.messageCreateAt, descending: false)
          .snapshots();

      return messages;
    } on FirebaseException catch (e) {
      final exception = getFirestoreException(e);
      throw Exception(exception.message);
    }
  }

  /// Gets all the contacts (chatbots). for current use
  Future<QuerySnapshot> getContacts() async {
    final contacts = await _contacts.get();
    return contacts;
  }

  /// Sends messages from the current user to the chat buddy.
  Future<void> sendMessage({
    required Ref ref,
    required MessageModel messageModel,
    required String chatBotId,
    required String chatBotName,
    required String userId,
  }) async {
    try {
      final newChat = await _users.doc(userId).collection(Constants.chats).doc(chatBotId).get();
      // Check that a chat already exists or create a new one if it does not.
      ChatModel chatModel = ChatModel(
        userId: userId,
        chatBotId: chatBotId,
        chatBotName: chatBotName,
        changedAt: DateTime.now(),
        lastMessage: messageModel.message,
      );

      if (!newChat.exists) {
        await _users.doc(userId).collection(Constants.chats).doc(chatBotId).set(chatModel.toMap());
      }

      // Save message.
      final messages = _users.doc(userId).collection(Constants.chats).doc(chatBotId).collection(Constants.messages);
      await messages.add(messageModel.toMap());
      // Show typing indicator.
      ref.read(typingIndicatorStateProvider.notifier).update((state) => true);
      // Update chat.
      final chat = _users.doc(userId).collection(Constants.chats).doc(chatBotId);
      chat.update(chatModel.toMap()).asStream();
      // Invoke chatbot for a reply
      final response = await _apiService.getChatResponse(ref: ref, senderId: chatBotId);
      // Cancel typing indicator.
      ref.read(typingIndicatorStateProvider.notifier).update((state) => false);
      // Save reply.
      await messages.add(response.toMap());

      await _speakResponse(ref: ref, message: response.message);
      chatModel = ChatModel(
        userId: userId,
        chatBotId: chatBotId,
        chatBotName: chatBotName,
        changedAt: DateTime.now(),
        lastMessage: response.message,
      );

      chat.update(chatModel.toMap()).asStream();
    } on FirebaseException catch (e) {
      final exception = getFirestoreException(e);
      throw Exception(exception.message);
    }
  }

  /// Speaks responses to the user
  Future<void> _speakResponse({required Ref ref, required String message}) async {
    final userSettings = ref.read(settingsModelStateProvider);
    if (userSettings.voiceAssistanceEnabled) {
      await ref.read(textToSpeechProvider).speak(message);
    }
  }

  /// Clear all the messages in a specific chat collection.
  Future<void> clearMessages({required String userId, required String chatBotId, required bool updateChat}) async {
    try {
      // Delete messages in batch.
      WriteBatch batch = _firestore.batch();

      // Get messages.
      final messageDocuments = await _users.doc(userId).collection(Constants.chats).doc(chatBotId).collection(Constants.messages).get();
      // Prepare delete operion.
      if (messageDocuments.size > 0) {
        for (var document in messageDocuments.docs) {
          batch.delete(document.reference);
        }

        // Update chat last message.
        // The purpose of this flag is to minimize the number of writes to the database.
        if (updateChat) {
          _users.doc(userId).collection(Constants.chats).doc(chatBotId).update({Constants.chatLastMessage: ''});
        }
      }
      // Commit batch
      return batch.commit();
    } on FirebaseException catch (e) {
      final exception = getFirestoreException(e);
      throw Exception(exception.message);
    }
  }

  /// Deletes user chat.
  Future<void> deleteChat({required String userId, required String chatBotId}) async {
    try {
      // Get chat.
      final chat = _users.doc(userId).collection(Constants.chats).doc(chatBotId);
      // Delete messages first
      clearMessages(userId: userId, chatBotId: chatBotId, updateChat: false);
      // Delete chat.
      chat.delete();
    } on FirebaseException catch (e) {
      final exception = getFirestoreException(e);
      throw Exception(exception.message);
    }
  }
}
