enum ChatMessageType { user, bot, error }

class ChatMessage {
  final String text;
  final ChatMessageType type;
  bool isBookmarked; 
  final String? originalQuestion; 

  ChatMessage({
    required this.text,
    required this.type,
    this.isBookmarked = false,
    this.originalQuestion,
  });
}