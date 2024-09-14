import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:http/http.dart' as http;

import '../models/message_model.dart';
import '../providers/user_providers.dart';
import '../utils/api_keys.dart';
import '../utils/constants.dart';

class ChatbotAPIService {
  /// Sends to receive prompts from OpenAI
  /// Uses ChatGPT model
  Future<MessageModel> getChatResponse({required Ref ref, required String senderId}) async {
    try {
      final user = ref.read(userModelStateProvider)!;
      final onExploration = ref.watch(onExplorationStateProvider);
      final messages = ref.read(previousMessagesStateProvider);

      final headers = {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer ${ApiKeys.openAISecretKey}',
      };

      final body = jsonEncode({
        'model': Constants.chatModelName,
        'messages': messages,
        'max_tokens': (user.subscribed || onExploration) ? null : 300,
      });

      final url = Uri.parse(Constants.apiURL);
      final response = await http.post(url, headers: headers, body: body);

      if (kDebugMode) {
        print(response.body);
        print('Messages Length: ${messages.length}');
        for (var el in messages) {
          print('Message: $el');
        }
      }

      MessageModel messageModel;
      if (response.statusCode == 200) {
        String message = jsonDecode(response.body)['choices'][0]['message']['content'];
        messageModel = _createMessageModel(senderId: senderId, message: message);
      } else {
        messageModel = _createMessageModel(senderId: senderId, message: Constants.chatErrorMessage);
      }

      return messageModel;
    } catch (e) {
      if (kDebugMode) {
        print('ChatbotAPIService.getChatResponse: Http Error: $e');
      }

      final messageModel = _createMessageModel(senderId: senderId, message: Constants.chatErrorMessage);
      return messageModel;
    }
  }

  /// Sends to receive images from OpenAI
  /// Uses DALL-E model
  Future<String> getImageResponse({required String prompt}) async {
    return 'DALL-E';
  }

  /// Creates a message model
  MessageModel _createMessageModel({required String senderId, required String message}) {
    return MessageModel(
      message: message.trim(),
      senderId: senderId,
      createdAt: DateTime.now(),
    );
  }
}
