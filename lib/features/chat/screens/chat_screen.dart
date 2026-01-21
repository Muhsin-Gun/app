import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:sizer/sizer.dart';
import '../../../../providers/auth_provider.dart';
import '../../../../providers/message_provider.dart';
import '../../../../models/message_model.dart';
import '../../../../widgets/custom_image_widget.dart';

class ChatScreen extends StatefulWidget {
  final String otherUserId;
  final String otherUserName;
  final String? bookingId;

  const ChatScreen({
    super.key,
    required this.otherUserId,
    required this.otherUserName,
    this.bookingId,
  });

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<MessageProvider>().loadConversationMessages(
        widget.otherUserId,
        bookingId: widget.bookingId,
      );
    });
  }

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _sendMessage() {
    final text = _messageController.text.trim();
    if (text.isEmpty) return;

    final authProvider = context.read<AuthProvider>();
    final messageProvider = context.read<MessageProvider>();

    messageProvider.sendMessage(
      receiverId: widget.otherUserId,
      content: text,
      bookingId: widget.bookingId,
      senderName: authProvider.userModel?.name,
      senderPhotoUrl: authProvider.userModel?.photoUrl,
    ).then((success) {
      if (success) {
        _messageController.clear();
        _scrollToBottom();
      }
    });
  }

  void _scrollToBottom() {
    if (_scrollController.hasClients) {
      _scrollController.animateTo(0, duration: const Duration(milliseconds: 300), curve: Curves.easeOut);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Scaffold(
      appBar: AppBar(
        titleSpacing: 0,
        title: Row(
          children: [
            CustomAvatarWidget(imageUrl: null, fallbackText: widget.otherUserName[0], radius: 20),
            const SizedBox(width: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(widget.otherUserName, style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 16)),
                const Text('Online', style: TextStyle(color: Colors.green, fontSize: 10, fontWeight: FontWeight.bold)),
              ],
            ),
          ],
        ),
        actions: [
          IconButton(icon: const Icon(Icons.call_rounded), onPressed: () {}),
          IconButton(icon: const Icon(Icons.videocam_rounded), onPressed: () {}),
          const SizedBox(width: 8),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: Consumer<MessageProvider>(
              builder: (context, provider, _) {
                final messages = provider.messages;
                if (provider.isLoading && messages.isEmpty) return const Center(child: CircularProgressIndicator());
                if (messages.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.chat_bubble_outline_rounded, size: 64, color: theme.colorScheme.outlineVariant),
                        const SizedBox(height: 16),
                        const Text('Start a conversation', style: TextStyle(fontWeight: FontWeight.bold)),
                      ],
                    ),
                  );
                }

                return ListView.builder(
                  controller: _scrollController,
                  reverse: true,
                  padding: const EdgeInsets.all(20),
                  itemCount: messages.length,
                  itemBuilder: (context, index) {
                    final msg = messages[index];
                    final isMe = msg.senderId == context.read<AuthProvider>().userId;
                    return _MessageBubble(message: msg, isMe: isMe);
                  },
                );
              },
            ),
          ),
          _buildInputArea(theme),
        ],
      ),
    );
  }

  Widget _buildInputArea(ThemeData theme) {
    return Container(
      padding: EdgeInsets.fromLTRB(16, 12, 16, 12 + MediaQuery.of(context).padding.bottom),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        boxShadow: [
          BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 10, offset: const Offset(0, -5)),
        ],
      ),
      child: Row(
        children: [
          Container(
            decoration: BoxDecoration(color: theme.colorScheme.primary.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(12)),
            child: IconButton(onPressed: () {}, icon: Icon(Icons.add_rounded, color: theme.colorScheme.primary)),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                color: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
                borderRadius: BorderRadius.circular(28),
                border: Border.all(color: theme.colorScheme.outlineVariant.withValues(alpha: 0.3)),
              ),
              child: TextField(
                controller: _messageController,
                decoration: const InputDecoration(
                  hintText: 'Type a message...',
                  hintStyle: TextStyle(fontSize: 14),
                  border: InputBorder.none,
                ),
                onSubmitted: (_) => _sendMessage(),
              ),
            ),
          ),
          const SizedBox(width: 12),
          GestureDetector(
            onTap: _sendMessage,
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                gradient: LinearGradient(colors: [theme.colorScheme.primary, theme.colorScheme.secondary]),
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(color: theme.colorScheme.primary.withValues(alpha: 0.3), blurRadius: 8, offset: const Offset(0, 4)),
                ],
              ),
              child: const Icon(Icons.send_rounded, color: Colors.white, size: 20),
            ),
          ),
        ],
      ),
    );
  }
}

class _MessageBubble extends StatelessWidget {
  final MessageModel message;
  final bool isMe;
  const _MessageBubble({required this.message, required this.isMe});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Align(
        alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
        child: Column(
          crossAxisAlignment: isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
              constraints: BoxConstraints(maxWidth: 78.w),
              decoration: BoxDecoration(
                gradient: isMe ? LinearGradient(
                  colors: [theme.colorScheme.primary, theme.colorScheme.primary.withValues(alpha: 0.85)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ) : null,
                color: isMe ? null : theme.colorScheme.surface,
                borderRadius: BorderRadius.only(
                  topLeft: const Radius.circular(24),
                  topRight: const Radius.circular(24),
                  bottomLeft: Radius.circular(isMe ? 24 : 4),
                  bottomRight: Radius.circular(isMe ? 4 : 24),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: isMe ? 0.1 : 0.05),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
                border: isMe ? null : Border.all(color: theme.colorScheme.outlineVariant.withValues(alpha: 0.4)),
              ),
              child: Text(
                message.text,
                style: TextStyle(
                  color: isMe ? Colors.white : theme.colorScheme.onSurface,
                  fontSize: 15,
                  fontWeight: FontWeight.w500,
                  letterSpacing: 0.2,
                ),
              ),
            ),
            const SizedBox(height: 6),
            Padding(
              padding: EdgeInsets.only(right: isMe ? 8 : 0, left: isMe ? 0 : 8),
              child: Text(
                DateFormat('h:mm a').format(message.createdAt),
                style: theme.textTheme.labelSmall?.copyWith(
                  fontSize: 10,
                  color: theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.7),
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      ).animate().fadeIn(duration: 400.ms, curve: Curves.easeOut).slideX(begin: isMe ? 0.05 : -0.05, end: 0, curve: Curves.easeOut),
    );
  }
}
