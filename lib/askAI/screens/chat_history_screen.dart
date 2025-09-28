import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:intl/intl.dart';
import '../models/chat_history_session.dart';
import 'ask_ai_screen.dart';

class ChatHistoryScreen extends StatelessWidget {
  const ChatHistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('History'),
      ),
      body: ValueListenableBuilder<Box<ChatHistorySession>>(
        valueListenable: Hive.box<ChatHistorySession>('chat_history').listenable(),
        builder: (context, box, _) {
          final sessions = box.values.toList()..sort((a, b) => b.updatedAt.compareTo(a.updatedAt));

          if (sessions.isEmpty) {
            return const Center(child: Text('Your chat history is empty.'));
          }

          return ListView.builder(
            itemCount: sessions.length,
            itemBuilder: (context, index) {
              final session = sessions[index];
              final firstQuestion = session.messages.first.text;
              
              // Simple relative time for grouping, can be made more complex
              final timeAgo = _formatDate(session.updatedAt);

              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Optional: Add date headers like in the image
                  Padding(
                    padding: const EdgeInsets.only(top: 16.0, left: 16.0, bottom: 4.0),
                    child: Text(timeAgo, style: Theme.of(context).textTheme.labelSmall),
                  ),
                  ListTile(
                    title: Text(firstQuestion),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => AskAiScreen(
                            article: session.article,
                            existingSessionId: session.id, // Pass session ID to load it
                          ),
                        ),
                      );
                    },
                  ),
                ],
              );
            },
          );
        },
      ),
    );
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);
    if (difference.inDays > 30) {
      return DateFormat.yMMMd().format(date);
    } else if (difference.inDays > 1) {
      return '${difference.inDays} days ago';
    } else if (difference.inDays == 1) {
      return 'Yesterday';
    } else {
      return 'Today';
    }
  }
}