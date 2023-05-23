import 'dart:convert';
import 'dart:io';
import 'dart:math';
import 'package:uuid/uuid.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_chat_types/flutter_chat_types.dart' as types;
import 'package:flutter_chat_ui/flutter_chat_ui.dart';

String randomString() {
  final random = Random.secure();
  final values = List<int>.generate(16, (i) => random.nextInt(255));
  return base64UrlEncode(values);
}

class ChatRoom extends StatefulWidget {
  const ChatRoom({Key? key}) : super(key: key);

  @override
  ChatRoomState createState() => ChatRoomState();
}

class ChatRoomState extends State<ChatRoom> {
  late final Uuid uuid = Uuid();
  static final String uid = FirebaseAuth.instance.currentUser?.uid ?? '';
  final CollectionReference historyCollection = FirebaseFirestore.instance.collection('chat_history');
  final List<types.Message> _messages = [];
  final _user = types.User(id: uid, role: types.Role.user);
  final _bot = types.User(id: 'bot', role: types.Role.agent);
  late final String _chatId = 'chat-' + uuid.v4();

  @override
  Widget build(BuildContext context) => Scaffold(
        body: Chat(
          user: _user,
          messages: _messages,
          onSendPressed: _handleSendPressed,
          theme: DarkChatTheme(),
          showUserAvatars: true,
          showUserNames: true,
        ),
      );

  void _addMessage(types.Message message) {
    setState(() {
      _messages.insert(0, message);
    });
    storeChatHistory(message);
  }

  void _handleSendPressed(types.PartialText message) {
    final textMessage = types.TextMessage(
      author: _user,
      createdAt: DateTime.now().millisecondsSinceEpoch,
      id: "message-" + DateTime.now().toIso8601String() + "-" + uuid.v4(),
      text: message.text,
    );

    _addMessage(textMessage);

    final responseMessage = types.TextMessage(
      author: _bot,
      createdAt: DateTime.now().millisecondsSinceEpoch,
      id: "message-" + DateTime.now().toIso8601String() + "-" + uuid.v4(),
      text: message.text,
    );

    _addMessage(responseMessage);

  }

  void storeChatHistory(types.Message message) {
    final chatHistory = {
      'role': message.author.role.toString(),
      'content': message is types.TextMessage ? message.text : '',
      'timestamp': FieldValue.serverTimestamp(),
    };

    historyCollection
      .doc(uid)
      .collection(_chatId)
      .doc(message.id)
      .set(chatHistory)
      .catchError((error) => print("Failed to add chat history: $error"));
  }
}
