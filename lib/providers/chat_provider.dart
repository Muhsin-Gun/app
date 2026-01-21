import 'package:flutter/foundation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/message_model.dart';

class ChatProvider extends ChangeNotifier {
  final _firestore = FirebaseFirestore.instance;

  Stream<List<MessageModel>> getMessagesStream(String userA, String userB) {
    return _firestore
        .collection('messages')
        .orderBy('createdAt')
        .snapshots()
        .map((snapshot) => snapshot.docs.map((doc) {
              return MessageModel.fromDocument(doc);
            }).toList());
  }

  Future<void> sendMessage(String senderId, String receiverId, String text) async {
    final message = MessageModel(
      id: '',
      senderId: senderId,
      receiverId: receiverId,
      text: text,
      createdAt: DateTime.now(),
    );

    await _firestore.collection('messages').add(message.toMap());
  }
}
