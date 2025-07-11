import 'package:flutter/material.dart';

class AskAiScreen extends StatelessWidget {
  const AskAiScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Ask AI'),
      ),
      body: const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.smart_toy_outlined, size: 80, color: Colors.blue),
            SizedBox(height: 20),
            Text(
              'AI Features Coming Soon!',
              style: TextStyle(fontSize: 22),
            ),
          ],
        ),
      ),
    );
  }
}