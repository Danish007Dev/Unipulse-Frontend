import 'package:flutter/material.dart';
import '../../askAI/models/ai_response_bookmark.dart';
import '../screens/ask_ai_screen.dart';

class AiBookmarkTile extends StatelessWidget {
  final AiResponseBookmark bookmark;

  const AiBookmarkTile({super.key, required this.bookmark});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
      child: InkWell(
        onTap: () {
          // Navigate back to the chat screen for that article
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => AskAiScreen(article: bookmark.originalArticle),
            ),
          );
        },
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                bookmark.question,
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
              const SizedBox(height: 8),
              Text(
                bookmark.answer,
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(color: Colors.grey.shade400),
              ),
              const Divider(height: 24),
              Row(
                children: [
                  const Icon(Icons.article_outlined, size: 16, color: Colors.grey),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'From: ${bookmark.originalArticle.title}',
                      style: const TextStyle(fontStyle: FontStyle.italic, color: Colors.grey),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  const Icon(Icons.arrow_forward_ios, size: 14, color: Colors.grey),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}