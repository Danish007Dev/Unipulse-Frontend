import 'package:flutter/material.dart';
import 'chat_history_screen.dart'; // Import the history screen

class AskAiLandingScreen extends StatelessWidget {
  const AskAiLandingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold( // Wrap with Scaffold to add an AppBar
      appBar: AppBar(
        // title: const Text("Ask AI"),
        actions: [
          IconButton(
            icon: const Icon(Icons.history),
            tooltip: 'Chat History',
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const ChatHistoryScreen()),
              );
            },
          ),
        ],
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.smart_toy_outlined,
                size: 80,
                color: Theme.of(context).colorScheme.primary,
              ),
              const SizedBox(height: 24),
              Text(
                'Meet Your AI Assistant',
                style: Theme.of(context).textTheme.headlineSmall,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              Text(
                'To start a conversation, go to the FeedUp tab, find an article you\'re interested in, and tap the AI icon on the article card.',
                style: Theme.of(context).textTheme.bodyLarge,
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}