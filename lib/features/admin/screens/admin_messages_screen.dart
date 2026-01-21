import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sizer/sizer.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../../providers/message_provider.dart';
import '../../../../providers/auth_provider.dart';
import '../../../../models/message_model.dart';
import '../../../../models/user_model.dart';
import '../../../../routing/app_router.dart';
import '../../../../widgets/custom_icon_widget.dart';
import '../../../../widgets/custom_image_widget.dart';

class AdminMessagesScreen extends StatelessWidget {
  const AdminMessagesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('Messages', style: TextStyle(fontWeight: FontWeight.w900)),
        centerTitle: false,
      ),
      body: Consumer<MessageProvider>(
        builder: (context, provider, _) {
          final conversations = provider.conversations;

          if (provider.isLoading && conversations.isEmpty) {
            return const Center(child: CircularProgressIndicator());
          }

          if (conversations.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                   Icon(Icons.forum_rounded, size: 64, color: theme.colorScheme.outlineVariant),
                   SizedBox(height: 2.h),
                   const Text('No active conversations', style: TextStyle(fontWeight: FontWeight.bold)),
                ],
              ),
            );
          }

          return ListView.separated(
            padding: EdgeInsets.symmetric(horizontal: 5.w, vertical: 2.h),
            itemCount: conversations.length,
            separatorBuilder: (context, index) => const Divider(),
            itemBuilder: (context, index) {
              final conv = conversations[index];
              final MessageModel lastMessage = conv['message'];
              final UserModel? otherUser = conv['otherUser'];
              final int unreadCount = conv['unreadCount'] ?? 0;
              final name = otherUser?.name ?? 'User';

              return ListTile(
                contentPadding: EdgeInsets.zero,
                leading: CustomAvatarWidget(
                  imageUrl: otherUser?.photoUrl,
                  fallbackText: name[0],
                  radius: 28,
                ),
                title: Text(name, style: const TextStyle(fontWeight: FontWeight.w900)),
                subtitle: Text(lastMessage.text, maxLines: 1, overflow: TextOverflow.ellipsis),
                trailing: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(_formatTime(lastMessage.createdAt), style: theme.textTheme.bodySmall),
                    if (unreadCount > 0)
                      Container(
                        margin: const EdgeInsets.only(top: 4),
                        padding: const EdgeInsets.all(6),
                        decoration: BoxDecoration(color: theme.colorScheme.primary, shape: BoxShape.circle),
                        child: Text(unreadCount.toString(), style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold)),
                      ),
                  ],
                ),
                onTap: () {
                  final authProvider = context.read<AuthProvider>();
                  Navigator.pushNamed(
                    context,
                    '/chat',
                    arguments: {
                      'otherUserId': otherUser?.uid ?? (lastMessage.senderId == authProvider.userId ? lastMessage.receiverId : lastMessage.senderId),
                      'otherUserName': name,
                    },
                  );
                },
              ).animate().fadeIn(delay: (index * 50).ms).slideX(begin: 0.05, end: 0);
            },
          );
        },
      ),
    );
  }

  String _formatTime(DateTime dt) {
    final now = DateTime.now();
    if (now.difference(dt).inDays == 0) {
      return '${dt.hour}:${dt.minute.toString().padLeft(2, '0')}';
    }
    return '${dt.day}/${dt.month}';
  }
}
