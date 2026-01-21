
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../../core/theme.dart';
import '../../../../core/app_colors.dart';
import '../../chat/screens/chat_screen.dart';

class AdminMessagesScreen extends StatelessWidget {
  const AdminMessagesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // In a real scalability scenario, you'd have a separate 'conversations' collection
    // For this MVP, we query unique senders from 'messages' or just list Users who are 'client'
    // Let's list clients for simplicity as "Start Chat" or "View Chat"
    
    return Scaffold(
      appBar: AppBar(title: const Text('Messages')),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('users')
            .where('role', isEqualTo: 'client')
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          final docs = snapshot.data?.docs ?? [];

          if (docs.isEmpty) {
            return const Center(child: Text('No clients found to chat with.'));
          }

          return ListView.builder(
            itemCount: docs.length,
            itemBuilder: (context, index) {
              final data = docs[index].data() as Map<String, dynamic>;
              final userId = docs[index].id;
              final email = data['email'] ?? '';
              final name = data['name'] ?? 'Unknown User';

              return ListTile(
                leading: CircleAvatar(
                  backgroundColor: AppTheme.primaryColor.withValues(alpha: 0.1),
                  child: Text(name[0].toUpperCase()),
                ),
                title: Text(name),
                subtitle: Text(email),
                trailing: const Icon(Icons.chat_bubble_outline),
                onTap: () {
                  // Navigate to chat with this specific user
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => ChatScreen(
                        otherUserId: userId,
                        otherUserName: name,
                      ),
                    ),
                  );
                },
              );
            },
          );
        },
      ),
    );
  }
}
