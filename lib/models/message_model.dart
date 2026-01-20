import 'package:cloud_firestore/cloud_firestore.dart';

class MessageModel {
  final String id;
  final String senderId;
  final String receiverId;
  final String? bookingId;
  final String content;
  final DateTime timestamp;
  final String messageType;
  final bool isRead;
  final String? senderName;
  final String? senderPhotoUrl;
  final String? attachmentUrl;
  final String? attachmentType;
  final Map<String, dynamic>? metadata;

  MessageModel({
    required this.id,
    required this.senderId,
    required this.receiverId,
    this.bookingId,
    required this.content,
    required this.timestamp,
    this.messageType = 'text',
    this.isRead = false,
    this.senderName,
    this.senderPhotoUrl,
    this.attachmentUrl,
    this.attachmentType,
    this.metadata,
  });

  // Convert MessageModel to Map for Firestore
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'senderId': senderId,
      'receiverId': receiverId,
      'bookingId': bookingId,
      'content': content,
      'timestamp': Timestamp.fromDate(timestamp),
      'messageType': messageType,
      'isRead': isRead,
      'senderName': senderName,
      'senderPhotoUrl': senderPhotoUrl,
      'attachmentUrl': attachmentUrl,
      'attachmentType': attachmentType,
      'metadata': metadata,
    };
  }

  // Create MessageModel from Firestore document
  factory MessageModel.fromMap(Map<String, dynamic> map) {
    return MessageModel(
      id: map['id'] ?? '',
      senderId: map['senderId'] ?? '',
      receiverId: map['receiverId'] ?? '',
      bookingId: map['bookingId'],
      content: map['content'] ?? '',
      timestamp: (map['timestamp'] as Timestamp?)?.toDate() ?? DateTime.now(),
      messageType: map['messageType'] ?? 'text',
      isRead: map['isRead'] ?? false,
      senderName: map['senderName'],
      senderPhotoUrl: map['senderPhotoUrl'],
      attachmentUrl: map['attachmentUrl'],
      attachmentType: map['attachmentType'],
      metadata: map['metadata'],
    );
  }

  // Create MessageModel from Firestore DocumentSnapshot
  factory MessageModel.fromDocument(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    data['id'] = doc.id; // Ensure ID is set from document ID
    return MessageModel.fromMap(data);
  }

  // Copy with method for updating message data
  MessageModel copyWith({
    String? id,
    String? senderId,
    String? receiverId,
    String? bookingId,
    String? content,
    DateTime? timestamp,
    String? messageType,
    bool? isRead,
    String? senderName,
    String? senderPhotoUrl,
    String? attachmentUrl,
    String? attachmentType,
    Map<String, dynamic>? metadata,
  }) {
    return MessageModel(
      id: id ?? this.id,
      senderId: senderId ?? this.senderId,
      receiverId: receiverId ?? this.receiverId,
      bookingId: bookingId ?? this.bookingId,
      content: content ?? this.content,
      timestamp: timestamp ?? this.timestamp,
      messageType: messageType ?? this.messageType,
      isRead: isRead ?? this.isRead,
      senderName: senderName ?? this.senderName,
      senderPhotoUrl: senderPhotoUrl ?? this.senderPhotoUrl,
      attachmentUrl: attachmentUrl ?? this.attachmentUrl,
      attachmentType: attachmentType ?? this.attachmentType,
      metadata: metadata ?? this.metadata,
    );
  }

  // Message type checks
  bool get isTextMessage => messageType == 'text';
  bool get isImageMessage => messageType == 'image';
  bool get isFileMessage => messageType == 'file';
  bool get isSystemMessage => messageType == 'system';

  // Check if message has attachment
  bool get hasAttachment => attachmentUrl != null && attachmentUrl!.isNotEmpty;

  // Get display content (truncated if too long)
  String get displayContent {
    if (isSystemMessage) return content;
    if (hasAttachment) {
      switch (messageType) {
        case 'image':
          return '📷 Image';
        case 'file':
          return '📎 File attachment';
        default:
          return content.isNotEmpty ? content : 'Attachment';
      }
    }
    
    if (content.length <= 100) return content;
    return '${content.substring(0, 100)}...';
  }

  // Get formatted timestamp
  String get formattedTime {
    final now = DateTime.now();
    final difference = now.difference(timestamp);
    
    if (difference.inDays > 0) {
      if (difference.inDays == 1) {
        return 'Yesterday ${timestamp.hour}:${timestamp.minute.toString().padLeft(2, '0')}';
      } else if (difference.inDays < 7) {
        return '${_getDayName(timestamp.weekday)} ${timestamp.hour}:${timestamp.minute.toString().padLeft(2, '0')}';
      } else {
        return '${timestamp.day}/${timestamp.month}/${timestamp.year}';
      }
    } else if (difference.inHours > 0) {
      return '${timestamp.hour}:${timestamp.minute.toString().padLeft(2, '0')}';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes}m ago';
    } else {
      return 'Just now';
    }
  }

  // Get relative time (e.g., "2 minutes ago")
  String get relativeTime {
    final now = DateTime.now();
    final difference = now.difference(timestamp);
    
    if (difference.inDays > 0) {
      return '${difference.inDays} day${difference.inDays > 1 ? 's' : ''} ago';
    } else if (difference.inHours > 0) {
      return '${difference.inHours} hour${difference.inHours > 1 ? 's' : ''} ago';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes} minute${difference.inMinutes > 1 ? 's' : ''} ago';
    } else {
      return 'Just now';
    }
  }

  // Helper method to get day name
  String _getDayName(int weekday) {
    switch (weekday) {
      case 1: return 'Monday';
      case 2: return 'Tuesday';
      case 3: return 'Wednesday';
      case 4: return 'Thursday';
      case 5: return 'Friday';
      case 6: return 'Saturday';
      case 7: return 'Sunday';
      default: return '';
    }
  }

  // Get sender initials for avatar
  String get senderInitials {
    if (senderName == null || senderName!.isEmpty) return '?';
    
    final nameParts = senderName!.split(' ');
    if (nameParts.length >= 2) {
      return '${nameParts[0][0]}${nameParts[1][0]}'.toUpperCase();
    }
    return senderName![0].toUpperCase();
  }

  // Check if message is from current user
  bool isFromUser(String currentUserId) {
    return senderId == currentUserId;
  }

  // Validate message data
  bool get isValid {
    return id.isNotEmpty &&
           senderId.isNotEmpty &&
           receiverId.isNotEmpty &&
           content.isNotEmpty &&
           ['text', 'image', 'file', 'system'].contains(messageType);
  }

  // Get conversation ID (consistent regardless of sender/receiver order)
  String getConversationId() {
    final participants = [senderId, receiverId]..sort();
    return participants.join('_');
  }

  // Check if message matches search query
  bool matchesSearch(String query) {
    final lowerQuery = query.toLowerCase();
    return content.toLowerCase().contains(lowerQuery) ||
           (senderName?.toLowerCase().contains(lowerQuery) ?? false);
  }

  @override
  String toString() {
    return 'MessageModel(id: $id, senderId: $senderId, receiverId: $receiverId, content: ${content.length > 50 ? '${content.substring(0, 50)}...' : content}, timestamp: $timestamp)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is MessageModel &&
           other.id == id &&
           other.senderId == senderId &&
           other.receiverId == receiverId &&
           other.content == content &&
           other.timestamp == timestamp &&
           other.messageType == messageType;
  }

  @override
  int get hashCode {
    return id.hashCode ^
           senderId.hashCode ^
           receiverId.hashCode ^
           content.hashCode ^
           timestamp.hashCode ^
           messageType.hashCode;
  }
}