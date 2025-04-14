import 'package:cloud_firestore/cloud_firestore.dart';

class Message {
  final String senderUsername;
  final String senderEmail;
  final String receiverUsername;
  final String message;
  final Timestamp timestamp;

  Message({
    required this.timestamp,
    required this.message,
    required this.receiverUsername,
    required this.senderEmail,
    required this.senderUsername,
  });

  // convert to a map
  Map<String, dynamic> toMap() {
    return {
      'senderUsername': senderUsername,
      'senderEmail': senderEmail,
      'receiverUsername': receiverUsername,
      'message': message,
      'Timestamp': timestamp,
    };
  }
}
