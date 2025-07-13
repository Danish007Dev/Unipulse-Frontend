import 'package:hive/hive.dart';
import '../../FeedUpApp/models/article.dart';

part 'ai_response_bookmark.g.dart';

@HiveType(typeId: 2) // Use a unique typeId
class AiResponseBookmark extends HiveObject {
  @HiveField(0)
  final int id;

  @HiveField(1)
  final String question;

  @HiveField(2)
  final String answer;

  @HiveField(3)
  final DateTime createdAt;

  @HiveField(4)
  final Article originalArticle;

  AiResponseBookmark({
    required this.id,
    required this.question,
    required this.answer,
    required this.createdAt,
    required this.originalArticle,
  });

  factory AiResponseBookmark.fromMap(Map<String, dynamic> map) {
    return AiResponseBookmark(
      id: map['id'],
      question: map['question'],
      answer: map['answer'],
      createdAt: DateTime.parse(map['created_at']),
      originalArticle: Article.fromMap(map['original_article']),
    );
  }
}