import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ESCorrectorPage extends StatefulWidget {
  @override
  _ESCorrectorPageState createState() => _ESCorrectorPageState();
}

class _ESCorrectorPageState extends State<ESCorrectorPage> {
  final TextEditingController _chatController = TextEditingController();
  List<String> _messages = [];
  final CollectionReference chatCollection = FirebaseFirestore.instance.collection('chats');

  Future<void> _sendMessage(String message, String sender) async {
    chatCollection.add({
      'message': message,
      'sender': sender,
      'timestamp': DateTime.now(),
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('ES自動添削サービス')),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              itemCount: _messages.length,
              itemBuilder: (context, index) => ListTile(
                title: Text(_messages[index]),
                leading: CircleAvatar(child: Text((index % 2 == 0) ? 'U' : 'B')),
              ),
            ),
          ),
          Container(
            padding: EdgeInsets.all(8.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _chatController,
                    decoration: InputDecoration(hintText: 'Type a message'),
                    onSubmitted: (message) {
                      setState(() {
                        // User message
                        _messages.add(message);
                        _sendMessage(message, 'U');

                        // Bot response
                        _messages.add(message);
                        _sendMessage(message, 'B');
                      });
                      _chatController.clear();
                    },
                  ),
                ),
                IconButton(
                  icon: Icon(Icons.send),
                  onPressed: () {
                    setState(() {
                      // User message
                      _messages.add(_chatController.text);
                      _sendMessage(_chatController.text, 'U');

                      // Bot response
                      _messages.add(_chatController.text);
                      _sendMessage(_chatController.text, 'B');
                    });
                    _chatController.clear();
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}



/*
class HomePage extends StatelessWidget {
  final _auth = FirebaseAuth.instance;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Home'),
        actions: [
          IconButton(
            icon: Icon(Icons.logout),
            onPressed: () async {
              await _auth.signOut();
            },
          ),
        ],
      ),
      body: Center(
        child: Text('Welcome, ${_auth.currentUser!.email}!'),
      ),
    );
  }
}
*/