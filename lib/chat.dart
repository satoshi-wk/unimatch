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
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';

import 'chat_history.dart';

Future<String> callOpenAI(String text) async {
  String url = 'https://api.openai.com/v1/chat/completions';
  String apiKey = dotenv.get("OPENAI_API_KEY");

  Map<String, String> headers = {
    'Content-Type': 'application/json',
    'Authorization': 'Bearer $apiKey'
  };

  Map<String, dynamic> body = {
    'model': 'gpt-3.5-turbo',
    'max_tokens': 100,
    'temperature': 0.9,
    'messages': [
      {'role': 'system', 'content': 'You are a helpful AI assistant.'},
      {'role': 'user', 'content': text}
    ],
  };

  var response = await http.post(
    Uri.parse(url),
    headers: headers,
    body: json.encode(body),
  );

  if (response.statusCode == 200) {
    var data = json.decode(response.body);
    var chatMessage = data['choices'][0]['message']['content'];
    return Future<String>.value(chatMessage);
  } else {
    print(
        'Failed to call OpenAI API: ${response.statusCode}, ${response.body}');
    return Future<String>.value('Failed to call OpenAI API');
  }
}

class ChatRoom extends StatefulWidget {
  final String chatId;

  const ChatRoom({Key? key, this.chatId = ''}) : super(key: key);

  @override
  ChatRoomState createState() => ChatRoomState();
}

class ChatRoomState extends State<ChatRoom> {
  late final Uuid uuid = Uuid();
  static final String uid = FirebaseAuth.instance.currentUser?.uid ?? '';
  final CollectionReference historyCollection =
      FirebaseFirestore.instance.collection('chat_history');
  final List<types.Message> _messages = [];
  final _user = types.User(id: uid, role: types.Role.user);
  final _bot = types.User(id: 'bot', role: types.Role.agent);
  late final String _chatId;

  @override
  void initState() {
    super.initState();
    _chatId = widget.chatId.isNotEmpty ? widget.chatId : 'chat-' + uuid.v4();
    if (widget.chatId.isNotEmpty) {
      _fetchChatHistory();
    } else {
      // create new collection
      historyCollection
          .doc(uid)
          .collection('chats')
          .doc(_chatId)
          .set({'createdAt': FieldValue.serverTimestamp()}).catchError(
              (error) => print("Failed to create chat history: $error"));
    }
  }

  Future<void> _fetchChatHistory() async {
    final chatHistory = await historyCollection
        .doc(uid)
        .collection('chats')
        .doc(_chatId)
        .collection('messages')
        .get();
    for (var doc in chatHistory.docs) {
      final data = doc.data();
      final message = types.TextMessage(
        author: data['role'] == 'agent' ? _bot : _user,
        createdAt: data['createdAt'],
        id: doc.id,
        text: data['content'],
      );
      _messages.insert(0, message);
    }
    setState(() {});
  }

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(
          title: Text('Chat Room'),
          leading: BackButton(
            onPressed: () {
              Navigator.pop(context);
            },
          ),
        ),
        body: Chat(
          user: _user,
          messages: _messages,
          onSendPressed: _handleSendPressed,
          theme: DarkChatTheme(),
          // showUserAvatars: true,
          // showUserNames: true,
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

    Future<String> apiResponce = callOpenAI(message.text);
    apiResponce.then((value) {
      final responseMessage = types.TextMessage(
        author: _bot,
        createdAt: DateTime.now().millisecondsSinceEpoch,
        id: "message-" + DateTime.now().toIso8601String() + "-" + uuid.v4(),
        text: value,
      );

      _addMessage(responseMessage);
    });
  }

  void storeChatHistory(types.Message message) {
    final chatHistory = {
      'role': message.author.role == types.Role.user ? 'user' : 'agent',
      'content': message is types.TextMessage ? message.text : '',
      'timestamp': FieldValue.serverTimestamp(),
      'createdAt': message.createdAt,
    };

    historyCollection
        .doc(uid)
        .collection('chats')
        .doc(_chatId)
        .collection('messages')
        .doc(message.id)
        .set(chatHistory)
        .catchError((error) => print("Failed to add chat history: $error"));
  }
}
