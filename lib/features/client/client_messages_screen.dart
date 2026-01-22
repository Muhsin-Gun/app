import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sizer/sizer.dart';
import '../../core/theme.dart';
import '../../providers/auth_provider.dart';
import '../../widgets/custom_icon_widget.dart';
import '../../widgets/custom_image_widget.dart';
import '../chat/chat_screen.dart';

class ClientMessagesScreen extends StatelessWidget {
  const ClientMessagesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    // Mock conversations
    final conversations = [
      Conversation(
        id: '1',
        otherUserName: 'John the Plumber',
        otherUserPhotoUrl: null,
        lastMessage: 'I\'ll be there at 2 PM',
        timestamp: DateTime.now().subtract(const Duration(minutes: 15)),
        unreadCount: 2,
      ),
      Conversation(
        id: '2',
        otherUserName: 'Admin Support',
        otherUserPhotoUrl: null,
        lastMessage: 'Your booking has been confirmed',
        timestamp: DateTime.now().subtract(const Duration(hours: 3)),
        unreadCount: 0,
      ),
      Conversation(
        id: '3',
        otherUserName: 'Sarah - Cleaner',
        otherUserPhotoUrl: null,
        lastMessage: 'Thank you for your feedback!',
        timestamp: DateTime.now().subtract(const Duration(days: 1)),
        unreadCount: 0,
      ),
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Messages'),
        actions: [
          IconButton(
            icon: const CustomIconWidget(iconName: 'add', size: 24),
            onPressed: () {
              _showNewConversationDialog(context);
            },
          ),
        ],
      ),
      body: conversations.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CustomIconWidget(
                    iconName: 'chat_bubble_outline',
                    color: theme.colorScheme.onSurfaceVariant.withOpacity(0.5),
                    size: 60,
                  ),
                  SizedBox(height: 2.h),
                  Text(
                    'No messages yet',
                    style: theme.textTheme.titleMedium?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                  SizedBox(height: 1.h),
                  Text(
                    'Start a conversation with service providers',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant.withOpacity(0.7),
                    ),
                  ),
                ],
              ),
            )
          : ListView.builder(
              itemCount: conversations.length,
              itemBuilder: (context, index) {
                final conversation = conversations[index];
                return _ConversationTile(conversation: conversation);
              },
            ),
    );
  }

  void _showNewConversationDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('New Conversation'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Start a conversation with:'),
            SizedBox(height: 16),
            ListTile(
              leading: Icon(Icons.support_agent),
              title: Text('Customer Support'),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => ChatScreen(
                      conversationId: 'support',
                      otherUserName: 'Customer Support',
                    ),
                  ),
                );
              },
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
        ],
      ),
    );
  }
}

class _ConversationTile extends StatelessWidget {
  final Conversation conversation;

  const _ConversationTile({required this.conversation});

  String _formatTimestamp(DateTime timestamp) {
    final now = DateTime.now();
    final difference = now.difference(timestamp);

    if (difference.inDays == 0) {
      if (difference.inHours == 0) {
        return '${difference.inMinutes}m ago';
      }
      return '${difference.inHours}h ago';
    } else if (difference.inDays == 1) {
      return 'Yesterday';
    } else if (difference.inDays < 7) {
      return '${difference.inDays}d ago';
    } else {
      return '${difference.inDays ~/ 7}w ago';
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return ListTile(
      contentPadding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.h),
      leading: Stack(
        children: [
          CustomAvatarWidget(
            imageUrl: conversation.otherUserPhotoUrl,
            fallbackText: conversation.otherUserName,
            radius: 28,
          ),
          if (conversation.unreadCount > 0)
            Positioned(
              right: 0,
              top: 0,
              child: Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: theme.colorScheme.error,
                  shape: BoxShape.circle,
                ),
                constraints: const BoxConstraints(
                  minWidth: 20,
                  minHeight: 20,
                ),
                child: Center(
                  child: Text(
                    conversation.unreadCount > 9 ? '9+' : '${conversation.unreadCount}',
                    style: TextStyle(
                      color: theme.colorScheme.onError,
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
      title: Text(
        conversation.otherUserName,
        style: theme.textTheme.titleMedium?.copyWith(
          fontWeight: conversation.unreadCount > 0 ? FontWeight.bold : FontWeight.normal,
        ),
      ),
      subtitle: Text(
        conversation.lastMessage,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: theme.textTheme.bodyMedium?.copyWith(
          color: conversation.unreadCount > 0
              ? theme.colorScheme.onSurface
              : theme.colorScheme.onSurfaceVariant,
          fontWeight: conversation.unreadCount > 0 ? FontWeight.w600 : FontWeight.normal,
        ),
      ),
      trailing: Text(
        _formatTimestamp(conversation.timestamp),
        style: theme.textTheme.bodySmall?.copyWith(
          color: conversation.unreadCount > 0
              ? theme.colorScheme.primary
              : theme.colorScheme.onSurfaceVariant,
          fontWeight: conversation.unreadCount > 0 ? FontWeight.w600 : FontWeight.normal,
        ),
      ),
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ChatScreen(
              conversationId: conversation.id,
              otherUserName: conversation.otherUserName,
              otherUserPhotoUrl: conversation.otherUserPhotoUrl,
            ),
          ),
        );
      },
    );
  }
}

class Conversation {
  final String id;
  final String otherUserName;
  final String? otherUserPhotoUrl;
  final String lastMessage;
  final DateTime timestamp;
  final int unreadCount;

  Conversation({
    required this.id,
    required this.otherUserName,
    this.otherUserPhotoUrl,
    required this.lastMessage,
    required this.timestamp,
    required this.unreadCount,
  });
}
