// Authentication repository provider.
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:emmie/providers/firebase_providers.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../controllers/chat_controller.dart';
import '../models/chat_model.dart';
import '../models/chatbot_model.dart';
import '../repository/chat_repository.dart';
import '../services/chatbot_api_service.dart';
import '../utils/helpers.dart';
import 'emmie_providers.dart';

// Chats repository provider.
final chatRepositoryProvider = Provider<ChatRepository>(
  (ref) => ChatRepository(
    firestore: ref.read(firestoreProvider),
    apiService: ChatbotAPIService(),
  ),
);

// Authentication controller provider.
final chatsControllerStateNotifierProvider = StateNotifierProvider<ChatsController, ChatsState>(
  ((ref) => ChatsController(chatsRepo: ref.read(chatRepositoryProvider), ref: ref)),
);

final contactsFutureProvider = FutureProvider<QuerySnapshot>((ref) async {
  final contactsCollection = ref.watch(chatsControllerStateNotifierProvider.notifier).getContacts();
  // Preload contactsStateProvide with contacts(ChatbotModels)
  final List<ChatbotModel> contacts = DataTransformer<ChatbotModel>(
    collection: await contactsCollection,
    fromMap: (dataMap) => ChatbotModel.fromMap(dataMap),
  ).transformData();
  ref.read(contactsStateProvider.notifier).state = contacts;
  return contactsCollection;
});

// Messages stream provider.
final messagesStreamProvider = StreamProvider.autoDispose.family(
  (ref, ChatModel chat) {
    return ref.watch(chatsControllerStateNotifierProvider.notifier).getMessages(chat: chat);
  },
);

// Listens when the chatbot is typing.
final typingIndicatorStateProvider = StateProvider((ref) => false);

// Text to speech provider
final textToSpeechProvider = StateProvider<FlutterTts>((ref) {
  final speech = FlutterTts();
  final currentLanguageCode = ref.watch(settingsModelStateProvider).language;
  speech.setVoice({'name': 'en-gb-x-fis#female_1-local', 'locale': currentLanguageCode});
  speech.setLanguage(currentLanguageCode);
  
  return speech;
});

// Text to speech state provider
final voiceEnabledStateProvider = StateProvider((ref) => false);
