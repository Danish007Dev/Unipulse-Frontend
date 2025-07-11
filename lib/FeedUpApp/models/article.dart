import 'package:hive/hive.dart';

part 'article.g.dart'; // This file will be generated

@HiveType(typeId: 0)
class Article extends HiveObject {
  @HiveField(0)
  final String id; // Unique ID from API, used as Hive key

  @HiveField(1)
  final String title;

  @HiveField(2)
  final String summary;

  @HiveField(3)
  final String sourceName;

  @HiveField(4)
  final String? generatedPrompt;

  @HiveField(5)
  final String sourceUrl;

  @HiveField(6)
  final List<String> tags;

  Article({
    required this.id,
    required this.title,
    required this.summary,
    required this.sourceName,
    this.generatedPrompt,
    required this.sourceUrl,
    required this.tags,
  });

  factory Article.fromJson(Map<String, dynamic> json) {
    return Article(
      id: json['id'].toString(), // IMPORTANT: Assuming your API provides a unique 'id'
      title: json['title'] ?? 'No Title',
      summary: json['summary'] ?? '',
      sourceName: json['source_name'] ?? 'Unknown Source',
      generatedPrompt: json['generated_prompt'],
      sourceUrl: json['source_url'] ?? '',
      tags: List<String>.from(json['tag_suggestions'] ?? []),
    );
  }
}
