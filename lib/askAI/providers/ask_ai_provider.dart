import 'package:flutter/material.dart';
import '../models/chat_model.dart';
import '../services/ask_ai_service.dart'; // Import the new service

class AskAiProvider with ChangeNotifier {
  final int articleId;
  final AskAiService _aiService = AskAiService(); // Instantiate the service

  AskAiProvider({required this.articleId}) {
    fetchInitialQuestions();
  }

  List<ChatMessage> _messages = [];
  List<String> _initialQuestions = [];
  bool _isLoading = true;
  bool _isResponding = false;

  List<ChatMessage> get messages => _messages;
  List<String> get initialQuestions => _initialQuestions;
  bool get isLoading => _isLoading;
  bool get isResponding => _isResponding;

  // The _getToken method is no longer needed as DioClient handles it automatically.

  Future<void> fetchInitialQuestions() async {
    _isLoading = true;
    notifyListeners();
    try {
      _initialQuestions = await _aiService.fetchInitialQuestions(articleId);
    } catch (e) {
      _messages.add(ChatMessage(text: "Failed to connect to the AI assistant. Please check your connection.", type: ChatMessageType.error));
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> sendMessage(String query) async {
    if (query.isEmpty || _isResponding) return;

    _messages.add(ChatMessage(text: query, type: ChatMessageType.user));
    _isResponding = true;
    notifyListeners();

    try {
      final answer = await _aiService.getAiResponse(articleId, query);
      _messages.add(ChatMessage(
        text: answer,
        type: ChatMessageType.bot,
        originalQuestion: query,
      ));
    } catch (e) {
      _messages.add(ChatMessage(text: "Sorry, I couldn't get a response. Please try again.", type: ChatMessageType.error));
    } finally {
      _isResponding = false;
      notifyListeners();
    }
  }

  Future<void> toggleBookmark(ChatMessage message) async {
    if (message.type != ChatMessageType.bot || message.originalQuestion == null) return;

    try {
      final isNowBookmarked = await _aiService.toggleBookmark(
        articleId: articleId,
        question: message.originalQuestion!,
        answer: message.text,
      );
      message.isBookmarked = isNowBookmarked;
    } catch (e) {
      // Optionally show an error to the user via a snackbar
      debugPrint("Error toggling bookmark: $e");
    } finally {
      notifyListeners();
    }
  }
}