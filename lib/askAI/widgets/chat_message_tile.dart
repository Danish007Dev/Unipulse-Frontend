import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../providers/ask_ai_provider.dart';
import '../models/chat_model.dart';

class ChatMessageTile extends StatelessWidget {
  final ChatMessage message;

  const ChatMessageTile({super.key, required this.message});

  @override
  Widget build(BuildContext context) {
    final isUserMessage = message.type == ChatMessageType.user;
    final isErrorMessage = message.type == ChatMessageType.error;

    return Align(
      alignment: isUserMessage ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 6.0, horizontal: 12.0),
        padding: const EdgeInsets.all(12.0),
        decoration: BoxDecoration(
          color: isUserMessage
              ? Theme.of(context).colorScheme.primaryContainer
              : isErrorMessage
                  ? Colors.red.shade100
                  : Theme.of(context).colorScheme.surfaceVariant,
          borderRadius: BorderRadius.circular(16.0),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              message.text,
              style: TextStyle(
                color: isErrorMessage ? Colors.red.shade900 : null,
              ),
            ),
            if (!isUserMessage && !isErrorMessage) ...[
              const SizedBox(height: 8),
              const Divider(),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // TODO: Implement bookmark functionality
                  IconButton(
                    icon: Icon(
                      message.isBookmarked ? Icons.bookmark : Icons.bookmark_border,
                      size: 20,
                      color: message.isBookmarked ? Theme.of(context).colorScheme.primary : null,
                    ),
                    onPressed: () {
                      // Call the provider to handle the logic
                      Provider.of<AskAiProvider>(context, listen: false).toggleBookmark(message);
                    },
                    tooltip: 'Bookmark Response',
                  ),
                  IconButton(
                    icon: const Icon(Icons.copy, size: 20),
                    onPressed: () {
                      Clipboard.setData(ClipboardData(text: message.text));
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Copied to clipboard')),
                      );
                    },
                    tooltip: 'Copy',
                  ),
                  // TODO: Implement share functionality
                  IconButton(
                    icon: const Icon(Icons.share, size: 20),
                    onPressed: () {
                       // Placeholder for share action
                    },
                    tooltip: 'Share',
                  ),
                ],
              )
            ]
          ],
        ),
      ),
    );
  }
}