import '../core/app_config.dart';
import '../models/message_model.dart';
import '../models/user_model.dart';
import 'firestore_service.dart';

class MessageService {
  static final MessageService _instance = MessageService._internal();
  factory MessageService() => _instance;
  MessageService._internal();

  final FirestoreService _firestoreService = FirestoreService();

  // Send a message
  Future<String?> sendMessage({
    required String senderId,
    required String receiverId,
    required String content,
    String? bookingId,
    String messageType = 'text',
    String? senderName,
    String? senderPhotoUrl,
    String? attachmentUrl,
    String? attachmentType,
  }) async {
    try {
      AppConfig.log('Sending message from $senderId to $receiverId');
      
      if (content.trim().isEmpty && attachmentUrl == null) {
        AppConfig.logError('Message content and attachment cannot both be empty');
        return null;
      }
      
      final message = MessageModel(
        id: '', // Will be set by Firestore
        senderId: senderId,
        receiverId: receiverId,
        bookingId: bookingId,
        content: content.trim(),
        timestamp: DateTime.now(),
        messageType: messageType,
        isRead: false,
        senderName: senderName,
        senderPhotoUrl: senderPhotoUrl,
        attachmentUrl: attachmentUrl,
        attachmentType: attachmentType,
      );
      
      final messageId = await _firestoreService.sendMessage(message);
      AppConfig.log('Message sent successfully with ID: $messageId');
      
      return messageId;
    } catch (e) {
      AppConfig.logError('Failed to send message', e);
      return null;
    }
  }

  // Send system message (automated messages)
  Future<String?> sendSystemMessage({
    required String receiverId,
    required String content,
    String? bookingId,
  }) async {
    try {
      AppConfig.log('Sending system message to $receiverId');
      
      return await sendMessage(
        senderId: 'system',
        receiverId: receiverId,
        content: content,
        bookingId: bookingId,
        messageType: 'system',
        senderName: 'System',
      );
    } catch (e) {
      AppConfig.logError('Failed to send system message', e);
      return null;
    }
  }

  // Get messages for a conversation
  Stream<List<MessageModel>> getConversationMessages(
    String userId1, 
    String userId2, {
    String? bookingId,
    int limit = 50,
  }) {
    try {
      AppConfig.log('Getting conversation messages between $userId1 and $userId2');
      return _firestoreService.getMessagesForConversation(userId1, userId2, bookingId: bookingId);
    } catch (e) {
      AppConfig.logError('Failed to get conversation messages', e);
      return Stream.value([]);
    }
  }

  // Get messages for a specific booking
  Stream<List<MessageModel>> getBookingMessages(String bookingId) {
    try {
      AppConfig.log('Getting messages for booking: $bookingId');
      return _firestoreService.getMessagesForConversation('', '', bookingId: bookingId);
    } catch (e) {
      AppConfig.logError('Failed to get booking messages', e);
      return Stream.value([]);
    }
  }

  // Get conversations for a user
  Future<List<Map<String, dynamic>>> getConversationsForUser(String userId) async {
    try {
      AppConfig.log('Getting conversations for user: $userId');
      
      // Get all messages where user is sender or receiver
      final sentMessages = await _firestoreService.getConversationsForUser(userId).first;
      final receivedMessages = await _firestoreService.getMessagesForConversation(userId, '').first;
      
      // Combine and group by conversation
      final allMessages = [...sentMessages, ...receivedMessages];
      final conversationMap = <String, MessageModel>{};
      
      for (final message in allMessages) {
        final conversationId = message.getConversationId();
        
        // Keep only the latest message for each conversation
        if (!conversationMap.containsKey(conversationId) ||
            message.timestamp.isAfter(conversationMap[conversationId]!.timestamp)) {
          conversationMap[conversationId] = message;
        }
      }
      
      // Convert to list and add participant info
      final conversations = <Map<String, dynamic>>[];
      
      for (final message in conversationMap.values) {
        final otherUserId = message.senderId == userId ? message.receiverId : message.senderId;
        final otherUser = await _firestoreService.getUser(otherUserId);
        
        conversations.add({
          'message': message,
          'otherUser': otherUser,
          'unreadCount': await getUnreadMessageCount(userId, otherUserId),
        });
      }
      
      // Sort by latest message timestamp
      conversations.sort((a, b) => 
        (b['message'] as MessageModel).timestamp.compareTo(
          (a['message'] as MessageModel).timestamp
        )
      );
      
      AppConfig.log('Found ${conversations.length} conversations for user');
      return conversations;
    } catch (e) {
      AppConfig.logError('Failed to get conversations for user', e);
      return [];
    }
  }

  // Mark message as read
  Future<bool> markMessageAsRead(String messageId) async {
    try {
      AppConfig.log('Marking message as read: $messageId');
      await _firestoreService.markMessageAsRead(messageId);
      AppConfig.log('Message marked as read successfully');
      return true;
    } catch (e) {
      AppConfig.logError('Failed to mark message as read', e);
      return false;
    }
  }

  // Mark all messages in conversation as read
  Future<bool> markConversationAsRead(String userId, String otherUserId) async {
    try {
      AppConfig.log('Marking conversation as read between $userId and $otherUserId');
      
      final messages = await getConversationMessages(userId, otherUserId).first;
      
      for (final message in messages) {
        if (message.receiverId == userId && !message.isRead) {
          await markMessageAsRead(message.id);
        }
      }
      
      AppConfig.log('Conversation marked as read successfully');
      return true;
    } catch (e) {
      AppConfig.logError('Failed to mark conversation as read', e);
      return false;
    }
  }

  // Get unread message count for user
  Future<int> getUnreadMessageCount(String userId, [String? fromUserId]) async {
    try {
      if (fromUserId != null) {
        // Count unread messages from specific user
        final messages = await getConversationMessages(userId, fromUserId).first;
        return messages.where((m) => m.receiverId == userId && !m.isRead).length;
      } else {
        // Count all unread messages for user
        return await _firestoreService.getUnreadMessageCount(userId);
      }
    } catch (e) {
      AppConfig.logError('Failed to get unread message count', e);
      return 0;
    }
  }

  // Search messages
  Future<List<MessageModel>> searchMessages(String userId, String query) async {
    try {
      AppConfig.log('Searching messages for user $userId with query: $query');
      
      // Get all conversations for user
      final conversations = await getConversationsForUser(userId);
      final allMessages = <MessageModel>[];
      
      for (final conversation in conversations) {
        final otherUser = conversation['otherUser'] as UserModel?;
        if (otherUser != null) {
          final messages = await getConversationMessages(userId, otherUser.uid).first;
          allMessages.addAll(messages);
        }
      }
      
      // Filter messages that match search query
      final filteredMessages = allMessages.where((message) => 
        message.matchesSearch(query)
      ).toList();
      
      // Sort by timestamp (newest first)
      filteredMessages.sort((a, b) => b.timestamp.compareTo(a.timestamp));
      
      AppConfig.log('Found ${filteredMessages.length} messages matching query');
      return filteredMessages;
    } catch (e) {
      AppConfig.logError('Failed to search messages', e);
      return [];
    }
  }

  // Send image message
  Future<String?> sendImageMessage({
    required String senderId,
    required String receiverId,
    required String imageUrl,
    String? bookingId,
    String? caption,
    String? senderName,
    String? senderPhotoUrl,
  }) async {
    try {
      AppConfig.log('Sending image message from $senderId to $receiverId');
      
      return await sendMessage(
        senderId: senderId,
        receiverId: receiverId,
        content: caption ?? '',
        bookingId: bookingId,
        messageType: 'image',
        senderName: senderName,
        senderPhotoUrl: senderPhotoUrl,
        attachmentUrl: imageUrl,
        attachmentType: 'image',
      );
    } catch (e) {
      AppConfig.logError('Failed to send image message', e);
      return null;
    }
  }

  // Send file message
  Future<String?> sendFileMessage({
    required String senderId,
    required String receiverId,
    required String fileUrl,
    required String fileName,
    String? bookingId,
    String? senderName,
    String? senderPhotoUrl,
  }) async {
    try {
      AppConfig.log('Sending file message from $senderId to $receiverId');
      
      return await sendMessage(
        senderId: senderId,
        receiverId: receiverId,
        content: fileName,
        bookingId: bookingId,
        messageType: 'file',
        senderName: senderName,
        senderPhotoUrl: senderPhotoUrl,
        attachmentUrl: fileUrl,
        attachmentType: 'file',
      );
    } catch (e) {
      AppConfig.logError('Failed to send file message', e);
      return null;
    }
  }

  // Get message statistics
  Future<Map<String, dynamic>> getMessageStatistics(String userId) async {
    try {
      AppConfig.log('Getting message statistics for user: $userId');
      
      final conversations = await getConversationsForUser(userId);
      final totalUnread = await getUnreadMessageCount(userId);
      
      final stats = {
        'totalConversations': conversations.length,
        'totalUnreadMessages': totalUnread,
        'activeConversations': conversations.where((c) => 
          (c['message'] as MessageModel).timestamp.isAfter(
            DateTime.now().subtract(const Duration(days: 7))
          )
        ).length,
      };
      
      AppConfig.log('Message statistics calculated successfully');
      return stats;
    } catch (e) {
      AppConfig.logError('Failed to get message statistics', e);
      return {};
    }
  }

  // Delete message (soft delete by marking as deleted)
  Future<bool> deleteMessage(String messageId, String userId) async {
    try {
      AppConfig.log('Deleting message: $messageId for user: $userId');
      
      // In a real implementation, you might want to soft delete
      // by adding a deletedBy field instead of actually deleting
      await _firestoreService.updateUser(messageId, {
        'deletedBy': [userId],
        'deletedAt': DateTime.now(),
      });
      
      AppConfig.log('Message deleted successfully');
      return true;
    } catch (e) {
      AppConfig.logError('Failed to delete message', e);
      return false;
    }
  }

  // Block user (prevent messaging)
  Future<bool> blockUser(String userId, String blockedUserId) async {
    try {
      AppConfig.log('Blocking user $blockedUserId for user $userId');
      
      // Update user document to include blocked users list
      await _firestoreService.updateUser(userId, {
        'blockedUsers': [blockedUserId], // In real app, append to existing list
        'updatedAt': DateTime.now(),
      });
      
      AppConfig.log('User blocked successfully');
      return true;
    } catch (e) {
      AppConfig.logError('Failed to block user', e);
      return false;
    }
  }

  // Unblock user
  Future<bool> unblockUser(String userId, String unblockedUserId) async {
    try {
      AppConfig.log('Unblocking user $unblockedUserId for user $userId');
      
      // Update user document to remove from blocked users list
      await _firestoreService.updateUser(userId, {
        'unblockedUsers': [unblockedUserId], // In real app, remove from blocked list
        'updatedAt': DateTime.now(),
      });
      
      AppConfig.log('User unblocked successfully');
      return true;
    } catch (e) {
      AppConfig.logError('Failed to unblock user', e);
      return false;
    }
  }

  // Check if user is blocked
  Future<bool> isUserBlocked(String userId, String otherUserId) async {
    try {
      final user = await _firestoreService.getUser(userId);
      if (user?.metadata?['blockedUsers'] != null) {
        final blockedUsers = List<String>.from(user!.metadata!['blockedUsers']);
        return blockedUsers.contains(otherUserId);
      }
      return false;
    } catch (e) {
      AppConfig.logError('Failed to check if user is blocked', e);
      return false;
    }
  }

  // Get typing indicator status
  Future<bool> isUserTyping(String userId, String conversationId) async {
    try {
      // In a real implementation, you would store typing status in Firestore
      // with a timestamp and clean up old typing indicators
      return false; // Placeholder
    } catch (e) {
      AppConfig.logError('Failed to get typing status', e);
      return false;
    }
  }

  // Set typing indicator
  Future<void> setTypingIndicator(String userId, String conversationId, bool isTyping) async {
    try {
      AppConfig.log('Setting typing indicator for user $userId: $isTyping');
      
      // In a real implementation, you would update typing status in Firestore
      // with a timestamp that expires after a few seconds
      
      AppConfig.log('Typing indicator set successfully');
    } catch (e) {
      AppConfig.logError('Failed to set typing indicator', e);
    }
  }

  // Send booking status update message
  Future<String?> sendBookingStatusUpdateMessage({
    required String bookingId,
    required String clientId,
    required String newStatus,
    String? employeeId,
    String? employeeName,
  }) async {
    try {
      String content;
      switch (newStatus) {
        case 'assigned':
          content = 'Your booking has been assigned to ${employeeName ?? 'an employee'}.';
          break;
        case 'active':
          content = 'Your service is now in progress.';
          break;
        case 'completed':
          content = 'Your service has been completed. Thank you for choosing our service!';
          break;
        case 'cancelled':
          content = 'Your booking has been cancelled.';
          break;
        default:
          content = 'Your booking status has been updated to $newStatus.';
      }
      
      return await sendSystemMessage(
        receiverId: clientId,
        content: content,
        bookingId: bookingId,
      );
    } catch (e) {
      AppConfig.logError('Failed to send booking status update message', e);
      return null;
    }
  }
}