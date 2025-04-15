import 'package:byhands/pages/chats/message.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter/material.dart';

class ChatService extends ChangeNotifier {
  // get instance of auth and firebase
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  String username = "";

  //send message
  Future<void> sendMessage(
    String recevierUsername,
    String message,
    String senderUsername,
  ) async {
    // get current user info
    final String currentUserEmail = _firebaseAuth.currentUser!.email.toString();
    final Timestamp timestamp = Timestamp.now();

    // create new massege
    Message newMessage = Message(
      timestamp: timestamp,
      message: message,
      receiverUsername: recevierUsername,
      senderEmail: currentUserEmail,
      senderUsername: senderUsername,
    );

    //constauct chat room id from current user id and receiver id stored to ensure uniquness
    List<String> usernames = [senderUsername, recevierUsername];
    usernames.sort();
    String chatRoomId = usernames.join("_");

    // add new message to the database
    await _firestore
        .collection('chat_rooms')
        .doc(chatRoomId)
        .collection('messages')
        .add(newMessage.toMap());
  }

  Stream<QuerySnapshot> getMessages({
    required String username,
    required String otherUsername,
  }) {
    List<String> usernames = [username, otherUsername];
    usernames.sort();
    String chatRoomId = usernames.join("_");
    Stream<QuerySnapshot> messages =
        _firestore
            .collection('chat_rooms')
            .doc(chatRoomId)
            .collection("messages")
            .orderBy("Timestamp", descending: true)
            .snapshots();
    return messages;
  }
}
