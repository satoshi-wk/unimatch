import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'chat.dart';

class ChatHistoryPage extends StatefulWidget {
  @override
  _ChatHistoryPageState createState() => _ChatHistoryPageState();
}

class _ChatHistoryPageState extends State<ChatHistoryPage> {
  final String uid = FirebaseAuth.instance.currentUser?.uid ?? '';
  final CollectionReference historyCollection =
      FirebaseFirestore.instance.collection('chat_history');
  final List<String> _selectedChatIds = [];
  bool _deleteMode = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Chat History'),
        actions: <Widget>[
          IconButton(
            icon: Icon(_deleteMode ? Icons.done : Icons.delete),
            onPressed: () {
              if (_deleteMode) {
                for (String chatId in _selectedChatIds) {
                  historyCollection
                      .doc(uid)
                      .collection('chats')
                      .doc(chatId)
                      .delete();
                }
              }
              setState(() {
                _deleteMode = !_deleteMode;
                _selectedChatIds.clear();
              });
            },
          ),
        ],
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: historyCollection.doc(uid).collection('chats').snapshots(),
        builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
          if (snapshot.hasError) {
            return Text('Something went wrong');
          }

          // if (snapshot.connectionState == ConnectionState.waiting) {
          //   return Text("Loading...");
          // }

          return ListView(
            children: snapshot.data?.docs.map((DocumentSnapshot document) {
                  String chatId = document.id;
                  return ListTile(
                    trailing: _deleteMode
                        ? Checkbox(
                            value: _selectedChatIds.contains(chatId),
                            onChanged: (bool? value) {
                              setState(() {
                                value == true
                                    ? _selectedChatIds.add(chatId)
                                    : _selectedChatIds.remove(chatId);
                              });
                            },
                          )
                        : null,
                    title: Text(chatId),
                    tileColor: _selectedChatIds.contains(chatId)
                        ? Colors.grey[700]
                        : null,
                    onTap: _deleteMode
                        ? () {
                            setState(() {
                              _selectedChatIds.contains(chatId)
                                  ? _selectedChatIds.remove(chatId)
                                  : _selectedChatIds.add(chatId);
                            });
                          }
                        : () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => ChatRoom(chatId: chatId),
                              ),
                            );
                          },
                  );
                }).toList() ??
                [],
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => ChatRoom(), // Replace with your ChatRoom
            ),
          );
        },
        child: Icon(Icons.add),
      ),
    );
  }
}
