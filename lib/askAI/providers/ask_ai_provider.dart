import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import '../../FeedUpApp/models/article.dart';
import '../models/chat_history_session.dart';
import '../models/chat_model.dart';
import '../services/ask_ai_service.dart';

class AskAiProvider with ChangeNotifier {
  final int articleId;
  final Article article; // Keep the full article object
  String? sessionId; // Can be null for new chats

  final AskAiService _aiService = AskAiService();
  final Box<ChatHistorySession> _historyBox = Hive.box<ChatHistorySession>('chat_history');
  ChatHistorySession? _currentSession;

  AskAiProvider({required this.articleId, required this.article, this.sessionId}) {
    _loadSessionOrFetchQuestions();
  }

  List<ChatMessage> _messages = [];
  List<String> _initialQuestions = [];
  bool _isLoading = true;
  bool _isResponding = false;

  List<ChatMessage> get messages => _messages;
  List<String> get initialQuestions => _initialQuestions;
  bool get isLoading => _isLoading;
  bool get isResponding => _isResponding;

  void _loadSessionOrFetchQuestions() {
    if (sessionId != null) {
      // Load existing chat
      _currentSession = _historyBox.values.firstWhere((s) => s.id == sessionId);
      _messages = _currentSession!.messages;
      _isLoading = false;
      notifyListeners();
    } else {
      // Start a new chat
      fetchInitialQuestions();
    }
  }

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

    final userMessage = ChatMessage(text: query, type: ChatMessageType.user);
    _messages.add(userMessage);
    _isResponding = true;
    notifyListeners();

    try {
      final answer = await _aiService.getAiResponse(articleId, query);
      final botMessage = ChatMessage(
        text: answer,
        type: ChatMessageType.bot,
        originalQuestion: query,
      );
      _messages.add(botMessage);
      await _saveChatToHistory(); // Save after getting a response
    } catch (e) {
      _messages.add(ChatMessage(text: "Sorry, I couldn't get a response.", type: ChatMessageType.error));
    } finally {
      _isResponding = false;
      notifyListeners();
    }
  }

  Future<void> _saveChatToHistory() async {
    if (_currentSession == null) {
      // This is a new chat, create a session
      _currentSession = ChatHistorySession(
        article: article,
        messages: _messages,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );
      // The session ID is generated in the constructor
      sessionId = _currentSession!.id;
    } else {
      // This is an existing chat, update it
      _currentSession!.messages = _messages;
      _currentSession!.updatedAt = DateTime.now();
    }
    // Put (insert or update) the session in the Hive box
    await _historyBox.put(_currentSession!.id, _currentSession!);
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