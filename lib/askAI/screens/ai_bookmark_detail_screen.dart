import 'package:flutter/material.dart';
import '../models/ai_response_bookmark.dart';

class AiBookmarkDetailScreen extends StatelessWidget {
  final AiResponseBookmark bookmark;

  const AiBookmarkDetailScreen({super.key, required this.bookmark});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Bookmarked Response'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // The Question
            Text(
              bookmark.question,
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const Divider(height: 24.0),
            // The Answer, formatted to look like the image
            _buildFormattedAnswer(context, bookmark.answer),
          ],
        ),
      ),
    );
  }

  /// A helper widget to format the answer, mimicking the bullet points from the image.
  Widget _buildFormattedAnswer(BuildContext context, String answer) {
    // Split the answer by newlines to handle multi-line responses.
    final lines = answer.split('\n').where((line) => line.trim().isNotEmpty).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: lines.map((line) {
        // Check if the line looks like a bullet point.
        final isBulletPoint = line.trim().startsWith('*') || line.trim().startsWith('-');
        final text = isBulletPoint ? line.trim().substring(1).trim() : line;

        if (isBulletPoint) {
          return Padding(
            padding: const EdgeInsets.only(bottom: 12.0),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Padding(
                  padding: EdgeInsets.only(top: 8.0, right: 10.0),
                  child: Icon(Icons.circle, size: 6),
                ),
                Expanded(
                  child: Text(
                    text,
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(height: 1.4),
                  ),
                ),
              ],
            ),
          );
        } else {
          // Render as a normal paragraph.
          return Padding(
            padding: const EdgeInsets.only(bottom: 12.0),
            child: Text(
              text,
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(height: 1.4),
            ),
          );
        }
      }).toList(),
    );
  }
}