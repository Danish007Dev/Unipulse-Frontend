import 'package:intl/intl.dart';

class ResearchUpdate {
  final int id;
  final String title;
  final String summary;
  final DateTime publicationDate;
  final String url;
  final String? authors;
  final String? institution;
  final String? category;
  final int daysSincePublication;

  ResearchUpdate({
    required this.id,
    required this.title,
    required this.summary,
    required this.publicationDate,
    required this.url,
    this.authors,
    this.institution,
    this.category,
    required this.daysSincePublication,
  });

  factory ResearchUpdate.fromJson(Map<String, dynamic> json) {
    return ResearchUpdate(
      id: json['id'],
      title: json['title'],
      summary: json['summary'],
      publicationDate: DateTime.parse(json['publication_date']),
      url: json['url'],
      authors: json['authors'],
      institution: json['institution'],
      category: json['category'],
      daysSincePublication: json['days_since_publication'],
    );
  }

  String get formattedPublicationDate => DateFormat('MMM d, yyyy').format(publicationDate);
  
  String get recencyText {
    if (daysSincePublication == 0) {
      return 'Published today';
    } else if (daysSincePublication == 1) {
      return 'Published yesterday';
    } else {
      return 'Published $daysSincePublication days ago';
    }
  }
}