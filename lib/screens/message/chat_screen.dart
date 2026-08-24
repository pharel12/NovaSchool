import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import 'package:novaschool/models/teacher_model.dart';
import 'package:novaschool/services/chat_service.dart';

class ChatScreen extends StatefulWidget {
  final TeacherModel teacher;

  const ChatScreen({
  super.key,
  required this.teacher,
  });

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

  class _ChatScreenState extends State<ChatScreen> {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  final ChatService _chatService = ChatService();

  int? _conversationId;

  List<dynamic> _messages = [];

  bool _loading = true;

  Future<void> _sendMessage() async {
    final text = _messageController.text.trim();

    if (text.isEmpty) return;

    try {
      if (_conversationId == null) return;
      await _chatService.sendMessage(
        conversationId: _conversationId!,
        content: text,
      );

      _messageController.clear();

      await _loadMessages();

      Future.delayed(
        const Duration(milliseconds: 200),
            () {
          if (_scrollController.hasClients) {
            _scrollController.animateTo(
              _scrollController.position.maxScrollExtent,
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeOut,
            );
          }
        },
      );
    } catch (e) {
      debugPrint(e.toString());
    }
  }

  Future<void> _initializeChat() async {
    try {
      _conversationId = await _chatService.startConversation(
        teacherId: widget.teacher.id,
        teacherName: widget.teacher.username,
      );

      await _loadMessages();
    } catch (e) {
      debugPrint(e.toString());
    }

    if (mounted) {
      setState(() {
        _loading = false;
      });
    }
  }


  Future<void> _loadMessages() async {
    if (_conversationId == null) return;

    final data = await _chatService.getMessages(
      _conversationId!,
    );

    if (mounted) {
      setState(() {
        _messages = data;
      });
    }
  }


  @override
  void initState() {
    super.initState();
    _initializeChat();
  }

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: const Color(0xFFF8FAFD),
        appBar: AppBar(
          elevation: 0,
          backgroundColor: const Color(0xFF123D92),
          foregroundColor: Colors.white,
          titleSpacing: 0,
          title: Row(
            children: [
              CircleAvatar(
                backgroundImage: widget.teacher.avatar != null
                ? NetworkImage(widget.teacher.avatar!)
                    : null,
                child: widget.teacher.avatar == null
                ? const Icon(Icons.person)
                    : null,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.teacher.username,
                      style: const TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      ),
                    ),
                    Text(
                      widget.teacher.courses.isNotEmpty
                        ? widget.teacher.courses.first.courseName
                        : "Enseignant",
                      style: const TextStyle(fontSize: 12, color: Colors.white70),
                    ),
                  ],
                ),
              )
            ],
          ),
        ),
        body: _loading
            ? const Center(
              child: CircularProgressIndicator(),
            )
            : Column(
          children: [
            Expanded(
              child: ListView.builder(
                controller: _scrollController,
                padding: const EdgeInsets.all(15),
                itemCount: _messages.length,
                itemBuilder: (_, index) {
                  final msg = _messages[index];
                  final isMe = msg["sender_name"] != widget.teacher.username;
                  final heure = DateFormat(
                    "HH:mm",
                  ).format(
                    DateTime.parse(msg["created_at"]),
                  );
                  return Align(
                    alignment: isMe
                    ? Alignment.centerRight
                        : Alignment.centerLeft,
                    child: Container(
                      margin: const EdgeInsets.symmetric(vertical: 5),
                      padding: const EdgeInsets.all(12),
                      constraints: BoxConstraints(
                        maxWidth: MediaQuery.of(context).size.width * .75,
                      ),
                      decoration: BoxDecoration(
                        color: isMe ? const Color(0xFFE2EAFF) : Colors.white,
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            msg["content"],
                            style: TextStyle(
                              color: Colors.black87,
                            ),
                          ),
                          const SizedBox(height: 5),
                          Text(heure)
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),

            SafeArea(
            child: Container(
            padding: const EdgeInsets.fromLTRB(16, 10, 16, 14),
            decoration: const BoxDecoration(color: Colors.white),
            child: Row(
            children: [
            Expanded(
            child: TextField(
            controller: _messageController,
            decoration: InputDecoration(
            hintText: "Votre message...",
            filled: true,
            fillColor: const Color(0xFFFDFDFF),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(30), borderSide: const BorderSide(color: Color(0xFFE1E5EE))),
            enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(30), borderSide: const BorderSide(color: Color(0xFFE1E5EE))),
            contentPadding:
            const EdgeInsets.symmetric(horizontal: 20),
            ),
            ),
            ),

            const SizedBox(width: 10),

            CircleAvatar(
            radius: 25,
            backgroundColor: const Color(0xFF1E5FE8),
            child: IconButton(
            icon: const Icon(Icons.send, color: Colors.white),
            onPressed: _sendMessage,
            ),
            )
            ],
            ),
            ),
            )
          ],
        ),
    );
  }
}
