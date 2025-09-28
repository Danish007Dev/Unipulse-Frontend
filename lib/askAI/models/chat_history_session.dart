import 'package:hive/hive.dart';
import '../../FeedUpApp/models/article.dart';
import 'chat_model.dart';

part 'chat_history_session.g.dart';

@HiveType(typeId: 5) // Use a new, unique typeId
class ChatHistorySession extends HiveObject {
  @HiveField(0)
  late String id; // Unique identifier for the session

  @HiveField(1)
  final Article article;

  @HiveField(2)
  List<ChatMessage> messages;

  @HiveField(3)
  final DateTime createdAt;

  @HiveField(4)
  DateTime updatedAt;

  ChatHistorySession({
    required this.article,
    required this.messages,
    required this.createdAt,
    required this.updatedAt,
  }) {
    // A unique ID based on the article and creation time
    id = 'chat_${article.id}_${createdAt.millisecondsSinceEpoch}';
  }
}