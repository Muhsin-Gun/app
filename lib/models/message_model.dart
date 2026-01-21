
import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:cloud_firestore/cloud_firestore.dart';

class MessageModel {
  final String id;
  final String senderId;
  final String receiverId;
  final String text; // mapped to content in service
  final DateTime createdAt; // mapped to timestamp in service
  final String? bookingId;
  final String messageType;
  final bool isRead;
  final String? senderName;
  final String? senderPhotoUrl;
  final String? attachmentUrl;
  final String? attachmentType;

  MessageModel({
    required this.id,
    required this.senderId,
    required this.receiverId,
    required this.text,
    required this.createdAt,
    this.bookingId,
    this.messageType = 'text',
    this.isRead = false,
    this.senderName,
    this.senderPhotoUrl,
    this.attachmentUrl,
    this.attachmentType,
  });

  // Alias getters to fix errors in MessageService
  String get content => text;
  DateTime get timestamp => createdAt;

  factory MessageModel.fromMap(String id, Map<String, dynamic> data) {
    return MessageModel(
      id: id,
      senderId: data['senderId'] ?? '',
      receiverId: data['receiverId'] ?? '',
      text: data['text'] ?? data['content'] ?? '',
      createdAt: data['createdAt'] is Timestamp 
          ? (data['createdAt'] as Timestamp).toDate()
          : data['timestamp'] is Timestamp
              ? (data['timestamp'] as Timestamp).toDate()
              : data['createdAt'] != null 
                  ? DateTime.parse(data['createdAt'].toString()) 
                  : DateTime.now(),
      bookingId: data['bookingId'],
      messageType: data['messageType'] ?? 'text',
      isRead: data['isRead'] ?? false,
      senderName: data['senderName'],
      senderPhotoUrl: data['senderPhotoUrl'],
      attachmentUrl: data['attachmentUrl'],
      attachmentType: data['attachmentType'],
    );
  }

  factory MessageModel.fromDocument(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return MessageModel.fromMap(doc.id, data);
  }

  Map<String, dynamic> toMap() {
    return {
      'senderId': senderId,
      'receiverId': receiverId,
      'text': text,
      'content': text, // duplicate for compatibility
      'createdAt': createdAt.toIso8601String(),
      'timestamp': createdAt, // for Firestore collation
      'bookingId': bookingId,
      'messageType': messageType,
      'isRead': isRead,
      'senderName': senderName,
      'senderPhotoUrl': senderPhotoUrl,
      'attachmentUrl': attachmentUrl,
      'attachmentType': attachmentType,
    };
  }

  String getConversationId() {
    return senderId.hashCode <= receiverId.hashCode 
        ? '${senderId}_$receiverId' 
        : '${receiverId}_$senderId';
  }

  bool matchesSearch(String query) {
    return text.toLowerCase().contains(query.toLowerCase());
  }
}
