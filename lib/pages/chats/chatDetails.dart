import 'package:byhands/pages/chats/chat_bubble.dart';
import 'package:byhands/pages/chats/chat_service.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:supabase_flutter/supabase_flutter.dart' as prefix;

class ChatDetailScreen extends StatefulWidget {
  final String username;

  const ChatDetailScreen({super.key, required this.username});

  @override
  State<ChatDetailScreen> createState() => _ChatDetailScreenState();
}

class _ChatDetailScreenState extends State<ChatDetailScreen> {
  List<Map<String, dynamic>> messages = [];
  final _formKey = GlobalKey<FormState>();
  final _messageController = TextEditingController();
  final prefix.SupabaseClient supabase = prefix.Supabase.instance.client;
  final ChatService _chatService = ChatService();
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
  String Username = "";

  @override
  void initState() {
    super.initState();
    fetchUsername();
  }

  Future<void> fetchUsername() async {
    final User? user = FirebaseAuth.instance.currentUser;
    final String? email = user?.email;

    if (email == null) {
      setState(() {
        Username = "No user logged in";
      });
      return;
    }

    final response =
        await supabase
            .from('User')
            .select('Username')
            .eq('Email', email)
            .maybeSingle();

    setState(() {
      Username = response?['Username'] ?? "Unknown User";
    });
  }

  void sendMessage() async {
    if (_messageController.text.isNotEmpty) {
      await _chatService.sendMessage(
        widget.username,
        _messageController.text,
        Username,
      );
      // clear the controller
      _messageController.clear();
    }
  }

  @override
  void dispose() {
    _messageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.username),
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.popAndPushNamed(context, '/Chats');
          },
        ),
      ),
      body: Column(
        children: [
          //messages
          Expanded(child: _buildMessageList()),
          // user input
          _buildMessageInput(),
        ],
      ),
    );
  }

  // build message list
  Widget _buildMessageList() {
    if (Username.isEmpty) {
      return Center(child: CircularProgressIndicator());
    }

    return StreamBuilder(
      stream: _chatService.getMessages(
        username: Username,
        otherUsername: widget.username,
      ),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Text('Error ${snapshot.error}');
        }

        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Text('Loading...');
        }

        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return const Text("No messages yet.");
        }

        return ListView(
          reverse: true,
          children:
              snapshot.data!.docs
                  .map((document) => _buildMessageItem(document))
                  .toList(),
        );
      },
    );
  }

  // build message item
  Widget _buildMessageItem(DocumentSnapshot document) {
    Map<String, dynamic> data = document.data() as Map<String, dynamic>;
    DateTime dateTime = data['Timestamp'].toDate();
    final formattedTime = DateFormat(
      'hh:mm a',
    ).format(dateTime); // e.g. 03:45 PM
    final formattedDate = DateFormat(
      'MMM d, yyyy',
    ).format(dateTime); // e.g. Apr 14, 2025
    // align the messages toright or left
    var alignment =
        (data['senderEmail'] == _firebaseAuth.currentUser!.email)
            ? Alignment.centerRight
            : Alignment.bottomLeft;
    return Container(
      alignment: alignment,
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          crossAxisAlignment:
              (data['senderEmail'] == _firebaseAuth.currentUser!.email)
                  ? CrossAxisAlignment.end
                  : CrossAxisAlignment.start,
          mainAxisAlignment:
              (data['senderEmail'] == _firebaseAuth.currentUser!.email)
                  ? MainAxisAlignment.end
                  : MainAxisAlignment.start,
          children: [
            Text(
              data['senderUsername'],
              style: Theme.of(context).textTheme.labelMedium,
            ),
            SizedBox(height: 3),
            ChatBubble(message: data['message']),
            Text(
              '$formattedDate - $formattedTime',
              style: Theme.of(context).textTheme.labelSmall,
            ),
          ],
        ),
      ),
    );
  }

  // build message input
  Widget _buildMessageInput() {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          Form(
            key: _formKey,
            child: TextFormField(
              controller: _messageController,
              decoration: InputDecoration(
                labelText: 'Enter Message',
                suffixIcon: IconButton(
                  onPressed: sendMessage,
                  icon: const Icon(Icons.send_rounded, color: Colors.grey),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
