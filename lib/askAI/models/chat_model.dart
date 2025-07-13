import 'package:hive/hive.dart';

part 'chat_model.g.dart';

@HiveType(typeId: 3) // Use a new, unique typeId
enum ChatMessageType {
  @HiveField(0)
  user,
  @HiveField(1)
  bot,
  @HiveField(2)
  error
}

@HiveType(typeId: 4) // Use a new, unique typeId
class ChatMessage extends HiveObject {
  @HiveField(0)
  String text;

  @HiveField(1)
  ChatMessageType type;

  @HiveField(2)
  bool isBookmarked;

  @HiveField(3)
  String? originalQuestion;

  ChatMessage({
    required this.text,
    required this.type,
    this.isBookmarked = false,
    this.originalQuestion,
  });
}