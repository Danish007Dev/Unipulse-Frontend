import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../FeedUpApp/models/article.dart';
import '../providers/ask_ai_provider.dart';
import '../widgets/chat_message_tile.dart';
import 'chat_history_screen.dart'; // Import the history screen

class AskAiScreen extends StatelessWidget {
  final Article article;
  final String? existingSessionId; // Add this optional parameter

  const AskAiScreen({
    super.key,
    required this.article,
    this.existingSessionId, // Add to constructor
  });

  @override
  Widget build(BuildContext context) {
    // Wrap the screen with the provider
    return ChangeNotifierProvider(
      // Pass all required parameters to the provider
      create: (_) => AskAiProvider(
        articleId: int.parse(article.id),
        article: article, // Pass the full article object
        sessionId: existingSessionId, // Pass the session ID if it exists
      ),
      child: Consumer<AskAiProvider>(
        builder: (context, provider, child) {
          return Scaffold(
            appBar: AppBar(
              title: Text('Ask AI: ${article.title}', overflow: TextOverflow.ellipsis),
              leading: IconButton(
                icon: const Icon(Icons.history),
                tooltip: 'Chat History',
                onPressed: () {
                  // Navigate to the new history screen
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const ChatHistoryScreen()),
                  );
                },
              ),
            ),
            body: Column(
              children: [
                // Question Capsules
                _buildQuestionCapsules(context, provider),
                const Divider(height: 1),
                // Chat Message List
                Expanded(
                  child: _buildMessagesList(provider),
                ),
                const Divider(height: 1),
                // Input Bar
                _buildChatInputBar(context, provider),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildQuestionCapsules(BuildContext context, AskAiProvider provider) {
    if (provider.isLoading) {
      return const Padding(
        padding: EdgeInsets.all(16.0),
        child: Center(child: LinearProgressIndicator()),
      );
    }
    if (provider.initialQuestions.isEmpty) return const SizedBox.shrink();

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 12.0),
      child: Row(
        children: provider.initialQuestions.map((question) {
          return Padding(
            padding: const EdgeInsets.only(right: 8.0),
            child: ActionChip(
              label: Text(question),
              onPressed: provider.isResponding ? null : () => provider.sendMessage(question),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildMessagesList(AskAiProvider provider) {
    // Use the new ChatMessageTile widget
    return ListView.builder(
      padding: const EdgeInsets.all(8.0),
      reverse: false, // Set to true if you want new messages at the bottom
      itemCount: provider.messages.length,
      itemBuilder: (context, index) {
        final message = provider.messages[index];
        return ChatMessageTile(message: message);
      },
    );
  }

  Widget _buildChatInputBar(BuildContext context, AskAiProvider provider) {
    final textController = TextEditingController();
    return Padding(
      padding: const EdgeInsets.all(12.0),
      child: Row(
        children: [
          // IconButton(
          //   icon: const Icon(Icons.help_outline),
          //   tooltip: 'Recent Questions',
          //   onPressed: () { /* TODO */ },
          // ),
          Expanded(
            child: TextField(
              controller: textController,
              decoration: InputDecoration(
                hintText: provider.isResponding ? 'AI is typing...' : 'Ask a follow-up...',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(20.0),
                  borderSide: BorderSide.none,
                ),
                filled: true,
              ),
              enabled: !provider.isResponding,
              onSubmitted: (value) {
                provider.sendMessage(value);
                textController.clear();
              },
            ),
          ),
          const SizedBox(width: 8),
          IconButton(
            icon: provider.isResponding ? const SizedBox(width: 24, height: 24, child: CircularProgressIndicator(strokeWidth: 2.5)) : const Icon(Icons.send),
            onPressed: provider.isResponding ? null : () {
              provider.sendMessage(textController.text);
              textController.clear();
            },
          ),
        ],
      ),
    );
  }
}