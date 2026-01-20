import 'package:flutter/foundation.dart';
import '../core/app_config.dart';
import '../models/message_model.dart';
import '../models/user_model.dart';
import '../services/message_service.dart';

class MessageProvider extends ChangeNotifier {
  final MessageService _messageService = MessageService();

  // Private variables
  List<MessageModel> _messages = [];
  List<Map<String, dynamic>> _conversations = [];
  bool _isLoading = false;
  String? _errorMessage;
  int _unreadCount = 0;
  String _currentConversationId = '';
  String _currentUserId = '';
  Map<String, bool> _typingIndicators = {};

  // Getters
  List<MessageModel> get messages => _messages;
  List<Map<String, dynamic>> get conversations => _conversations;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  int get unreadCount => _unreadCount;
  String get currentConversationId => _currentConversationId;
  Map<String, bool> get typingIndicators => _typingIndicators;

  // Initialize message provider for user
  void initializeMessages(String userId) {
    try {
      AppConfig.log('Initializing MessageProvider for user: $userId');
      
      _currentUserId = userId;
      _loadConversations();
      _loadUnreadCount();
      
      AppConfig.log('MessageProvider initialized successfully');
    } catch (e) {
      AppConfig.logError('Failed to initialize MessageProvider', e);
      _setError('Failed to initialize messages');
    }
  }

  // Load conversation messages
  void loadConversationMessages(String otherUserId, {String? bookingId}) {
    try {
      AppConfig.log('Loading conversation messages with user: $otherUserId');
      
      _currentConversationId = bookingId ?? _generateConversationId(_currentUserId, otherUserId);
      
      _messageService.getConversationMessages(_currentUserId, otherUserId, bookingId: bookingId).listen(
        (messages) {
          _messages = messages;
          _clearError();
          notifyListeners();
        },
        onError: (error) {
          AppConfig.logError('Error in messages stream', error);
          _setError('Failed to load messages');
        },
      );
      
      // Mark conversation as read
      _markConversationAsRead(otherUserId);
      
    } catch (e) {
      AppConfig.logError('Failed to load conversation messages', e);
      _setError('Failed to load messages');
    }
  }

  // Load booking messages
  void loadBookingMessages(String bookingId) {
    try {
      AppConfig.log('Loading booking messages for booking: $bookingId');
      
      _currentConversationId = bookingId;
      
      _messageService.getBookingMessages(bookingId).listen(
        (messages) {
          _messages = messages;
          _clearError();
          notifyListeners();
        },
        onError: (error) {
          AppConfig.logError('Error in booking messages stream', error);
          _setError('Failed to load booking messages');
        },
      );
      
    } catch (e) {
      AppConfig.logError('Failed to load booking messages', e);
      _setError('Failed to load booking messages');
    }
  }

  // Send text message
  Future<bool> sendMessage({
    required String receiverId,
    required String content,
    String? bookingId,
    String? senderName,
    String? senderPhotoUrl,
  }) async {
    try {
      _clearError();
      
      AppConfig.log('Sending message to: $receiverId');
      
      final messageId = await _messageService.sendMessage(
        senderId: _currentUserId,
        receiverId: receiverId,
        content: content,
        bookingId: bookingId,
        senderName: senderName,
        senderPhotoUrl: senderPhotoUrl,
      );
      
      if (messageId != null) {
        AppConfig.log('Message sent successfully');
        return true;
      } else {
        _setError('Failed to send message');
        return false;
      }
    } catch (e) {
      AppConfig.logError('Failed to send message', e);
      _setError('Failed to send message');
      return false;
    }
  }

  // Send image message
  Future<bool> sendImageMessage({
    required String receiverId,
    required String imageUrl,
    String? bookingId,
    String? caption,
    String? senderName,
    String? senderPhotoUrl,
  }) async {
    try {
      _clearError();
      
      AppConfig.log('Sending image message to: $receiverId');
      
      final messageId = await _messageService.sendImageMessage(
        senderId: _currentUserId,
        receiverId: receiverId,
        imageUrl: imageUrl,
        bookingId: bookingId,
        caption: caption,
        senderName: senderName,
        senderPhotoUrl: senderPhotoUrl,
      );
      
      if (messageId != null) {
        AppConfig.log('Image message sent successfully');
        return true;
      } else {
        _setError('Failed to send image message');
        return false;
      }
    } catch (e) {
      AppConfig.logError('Failed to send image message', e);
      _setError('Failed to send image message');
      return false;
    }
  }

  // Send file message
  Future<bool> sendFileMessage({
    required String receiverId,
    required String fileUrl,
    required String fileName,
    String? bookingId,
    String? senderName,
    String? senderPhotoUrl,
  }) async {
    try {
      _clearError();
      
      AppConfig.log('Sending file message to: $receiverId');
      
      final messageId = await _messageService.sendFileMessage(
        senderId: _currentUserId,
        receiverId: receiverId,
        fileUrl: fileUrl,
        fileName: fileName,
        bookingId: bookingId,
        senderName: senderName,
        senderPhotoUrl: senderPhotoUrl,
      );
      
      if (messageId != null) {
        AppConfig.log('File message sent successfully');
        return true;
      } else {
        _setError('Failed to send file message');
        return false;
      }
    } catch (e) {
      AppConfig.logError('Failed to send file message', e);
      _setError('Failed to send file message');
      return false;
    }
  }

  // Mark message as read
  Future<bool> markMessageAsRead(String messageId) async {
    try {
      final success = await _messageService.markMessageAsRead(messageId);
      if (success) {
        _loadUnreadCount(); // Refresh unread count
      }
      return success;
    } catch (e) {
      AppConfig.logError('Failed to mark message as read', e);
      return false;
    }
  }

  // Mark conversation as read
  Future<bool> _markConversationAsRead(String otherUserId) async {
    try {
      final success = await _messageService.markConversationAsRead(_currentUserId, otherUserId);
      if (success) {
        _loadUnreadCount(); // Refresh unread count
      }
      return success;
    } catch (e) {
      AppConfig.logError('Failed to mark conversation as read', e);
      return false;
    }
  }

  // Search messages
  Future<List<MessageModel>> searchMessages(String query) async {
    try {
      AppConfig.log('Searching messages with query: $query');
      return await _messageService.searchMessages(_currentUserId, query);
    } catch (e) {
      AppConfig.logError('Failed to search messages', e);
      return [];
    }
  }

  // Delete message
  Future<bool> deleteMessage(String messageId) async {
    try {
      AppConfig.log('Deleting message: $messageId');
      
      final success = await _messageService.deleteMessage(messageId, _currentUserId);
      
      if (success) {
        AppConfig.log('Message deleted successfully');
        return true;
      } else {
        _setError('Failed to delete message');
        return false;
      }
    } catch (e) {
      AppConfig.logError('Failed to delete message', e);
      _setError('Failed to delete message');
      return false;
    }
  }

  // Block user
  Future<bool> blockUser(String userId) async {
    try {
      AppConfig.log('Blocking user: $userId');
      
      final success = await _messageService.blockUser(_currentUserId, userId);
      
      if (success) {
        AppConfig.log('User blocked successfully');
        _loadConversations(); // Refresh conversations
        return true;
      } else {
        _setError('Failed to block user');
        return false;
      }
    } catch (e) {
      AppConfig.logError('Failed to block user', e);
      _setError('Failed to block user');
      return false;
    }
  }

  // Unblock user
  Future<bool> unblockUser(String userId) async {
    try {
      AppConfig.log('Unblocking user: $userId');
      
      final success = await _messageService.unblockUser(_currentUserId, userId);
      
      if (success) {
        AppConfig.log('User unblocked successfully');
        _loadConversations(); // Refresh conversations
        return true;
      } else {
        _setError('Failed to unblock user');
        return false;
      }
    } catch (e) {
      AppConfig.logError('Failed to unblock user', e);
      _setError('Failed to unblock user');
      return false;
    }
  }

  // Check if user is blocked
  Future<bool> isUserBlocked(String userId) async {
    try {
      return await _messageService.isUserBlocked(_currentUserId, userId);
    } catch (e) {
      AppConfig.logError('Failed to check if user is blocked', e);
      return false;
    }
  }

  // Set typing indicator
  Future<void> setTypingIndicator(String conversationId, bool isTyping) async {
    try {
      _typingIndicators[conversationId] = isTyping;
      notifyListeners();
      
      await _messageService.setTypingIndicator(_currentUserId, conversationId, isTyping);
      
      // Auto-clear typing indicator after 3 seconds
      if (isTyping) {
        Future.delayed(const Duration(seconds: 3), () {
          _typingIndicators[conversationId] = false;
          notifyListeners();
        });
      }
    } catch (e) {
      AppConfig.logError('Failed to set typing indicator', e);
    }
  }

  // Get typing status for conversation
  bool isUserTyping(String conversationId) {
    return _typingIndicators[conversationId] ?? false;
  }

  // Get message statistics
  Future<Map<String, dynamic>> getMessageStatistics() async {
    try {
      return await _messageService.getMessageStatistics(_currentUserId);
    } catch (e) {
      AppConfig.logError('Failed to get message statistics', e);
      return {};
    }
  }

  // Load conversations
  Future<void> _loadConversations() async {
    try {
      _setLoading(true);
      
      _conversations = await _messageService.getConversationsForUser(_currentUserId);
      
      AppConfig.log('Loaded ${_conversations.length} conversations');
    } catch (e) {
      AppConfig.logError('Failed to load conversations', e);
      _setError('Failed to load conversations');
    } finally {
      _setLoading(false);
    }
  }

  // Load unread count
  Future<void> _loadUnreadCount() async {
    try {
      _unreadCount = await _messageService.getUnreadMessageCount(_currentUserId);
      notifyListeners();
    } catch (e) {
      AppConfig.logError('Failed to load unread count', e);
    }
  }

  // Refresh conversations
  Future<void> refreshConversations() async {
    await _loadConversations();
    await _loadUnreadCount();
  }

  // Clear current conversation
  void clearCurrentConversation() {
    _messages.clear();
    _currentConversationId = '';
    notifyListeners();
  }

  // Get unread count for specific conversation
  Future<int> getConversationUnreadCount(String otherUserId) async {
    try {
      return await _messageService.getUnreadMessageCount(_currentUserId, otherUserId);
    } catch (e) {
      AppConfig.logError('Failed to get conversation unread count', e);
      return 0;
    }
  }

  // Get conversation by user ID
  Map<String, dynamic>? getConversationByUserId(String userId) {
    try {
      return _conversations.firstWhere(
        (conversation) {
          final message = conversation['message'] as MessageModel;
          final otherUser = conversation['otherUser'] as UserModel?;
          return otherUser?.uid == userId;
        },
      );
    } catch (e) {
      return null;
    }
  }

  // Generate conversation ID
  String _generateConversationId(String userId1, String userId2) {
    final participants = [userId1, userId2]..sort();
    return participants.join('_');
  }

  // Get last message for conversation
  MessageModel? getLastMessageForConversation(String otherUserId) {
    final conversation = getConversationByUserId(otherUserId);
    return conversation?['message'] as MessageModel?;
  }

  // Check if conversation exists
  bool hasConversationWith(String userId) {
    return getConversationByUserId(userId) != null;
  }

  // Get conversation participants
  List<UserModel> getConversationParticipants() {
    return _conversations
        .map((conversation) => conversation['otherUser'] as UserModel?)
        .where((user) => user != null)
        .cast<UserModel>()
        .toList();
  }

  // Helper methods
  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  void _setError(String error) {
    _errorMessage = error;
    notifyListeners();
  }

  void _clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  @override
  void dispose() {
    AppConfig.log('Disposing MessageProvider');
    super.dispose();
  }
}