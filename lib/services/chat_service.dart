import 'dart:convert';

import '../core/constants/api_constants.dart';
import '../core/network/api_client.dart';

class ChatService {
  Future<int> startConversation({
    required int teacherId,
    required String teacherName,
  }) async {
    final response = await ApiClient().post(
      ApiConstants.chatStart,
      body: {
        "teacher_id": teacherId,
        "teacher_name": teacherName,
      },
    );

    if (response.statusCode != 200) {
      throw Exception("Impossible de créer la conversation");
    }

    final data = jsonDecode(response.body);

    return data["conversation_id"];
  }

  Future<void> sendMessage({
    required int conversationId,
    required String content,
  }) async {
    final response = await ApiClient().post(
      ApiConstants.chatSend,
      body: {
        "conversation_id": conversationId,
        "content": content,
      },
    );

    if (response.statusCode != 201) {
      throw Exception("Impossible d'envoyer le message");
    }
  }

  Future<Map<String, dynamic>> getConversation(int id) async {
    final response = await ApiClient().get(
      "${ApiConstants.chatConversations}$id/",
    );

    if (response.statusCode != 200) {
      throw Exception("Conversation introuvable");
    }

    return jsonDecode(response.body);
  }

  Future<List<dynamic>> getMessages(int conversationId) async {
    final response = await ApiClient().get(
      "${ApiConstants.chatConversations}$conversationId/messages/",
    );

    if (response.statusCode != 200) {
      throw Exception("Impossible de récupérer les messages");
    }

    return jsonDecode(response.body);
  }
}