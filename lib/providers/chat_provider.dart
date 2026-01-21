import 'package:flutter/foundation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/message_model.dart';

class ChatProvider extends ChangeNotifier {
  final _firestore = FirebaseFirestore.instance;

  // Stream of messages for a specific conversation
  Stream<List<MessageModel>> getMessagesStream(String userA, String userB) {
    final conversationId = _getConversationId(userA, userB);
    
    return _firestore
        .collection('messages')
        .where('conversationId', isEqualTo: conversationId)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs.map((doc) {
              return MessageModel.fromDocument(doc);
            }).toList());
  }

  // Get a list of all conversations for the current user
  Stream<List<MessageModel>> getUserConversations(String userId) {
    return _firestore
        .collection('messages')
        .where('participants', arrayContains: userId)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) {
          final Map<String, MessageModel> latestMessages = {};
          
          for (var doc in snapshot.docs) {
            final msg = MessageModel.fromDocument(doc);
            final convId = msg.getConversationId();
            if (!latestMessages.containsKey(convId)) {
              latestMessages[convId] = msg;
            }
          }
          
          return latestMessages.values.toList();
        });
  }

  Future<void> sendMessage(String senderId, String receiverId, String text) async {
    final conversationId = _getConversationId(senderId, receiverId);
    
    final message = MessageModel(
      id: '',
      senderId: senderId,
      receiverId: receiverId,
      text: text,
      createdAt: DateTime.now(),
      messageType: 'text',
      isRead: false,
    );

    final messageData = message.toMap();
    messageData['conversationId'] = conversationId;
    messageData['participants'] = [senderId, receiverId];
    
    // Add to Firestore using server timestamp for better ordering
    messageData['createdAt'] = FieldValue.serverTimestamp();
    messageData['timestamp'] = FieldValue.serverTimestamp();

    await _firestore.collection('messages').add(messageData);
  }

  String _getConversationId(String u1, String u2) {
    return u1.hashCode <= u2.hashCode ? '${u1}_$u2' : '${u2}_$u1';
  }
}
