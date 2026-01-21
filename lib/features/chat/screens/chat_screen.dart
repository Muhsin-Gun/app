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
      padding: EdgeInsets.fromLTRB(20, 12, 20, 12 + MediaQuery.of(context).padding.bottom),
      decoration: BoxDecoration(color: theme.colorScheme.surface, border: Border(top: BorderSide(color: theme.colorScheme.outlineVariant.withValues(alpha: 0.5)))),
      child: Row(
        children: [
          IconButton(onPressed: () {}, icon: const Icon(Icons.add_rounded)),
          Expanded(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(color: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.5), borderRadius: BorderRadius.circular(24)),
              child: TextField(
                controller: _messageController,
                decoration: const InputDecoration(hintText: 'Message...', border: InputBorder.none),
                onSubmitted: (_) => _sendMessage(),
              ),
            ),
          ),
          const SizedBox(width: 12),
          CircleAvatar(
            backgroundColor: theme.colorScheme.primary,
            child: IconButton(onPressed: _sendMessage, icon: const Icon(Icons.send_rounded, color: Colors.white, size: 20)),
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
      padding: const EdgeInsets.only(bottom: 8),
      child: Align(
        alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
        child: Column(
          crossAxisAlignment: isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              constraints: BoxConstraints(maxWidth: 75.w),
              decoration: BoxDecoration(
                color: isMe ? theme.colorScheme.primary : theme.colorScheme.surface,
                borderRadius: BorderRadius.only(
                  topLeft: const Radius.circular(20),
                  topRight: const Radius.circular(20),
                  bottomLeft: Radius.circular(isMe ? 20 : 4),
                  bottomRight: Radius.circular(isMe ? 4 : 20),
                ),
                border: isMe ? null : Border.all(color: theme.colorScheme.outlineVariant.withValues(alpha: 0.5)),
              ),
              child: Text(message.text, style: TextStyle(color: isMe ? Colors.white : Colors.black, fontSize: 16)),
            ),
            const SizedBox(height: 4),
            Text(DateFormat('h:mm a').format(message.createdAt), style: theme.textTheme.labelSmall?.copyWith(fontSize: 9)),
          ],
        ),
      ).animate().fadeIn(duration: 200.ms).slideX(begin: isMe ? 0.1 : -0.1, end: 0),
    );
  }
}
