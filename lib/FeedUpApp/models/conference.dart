import 'package:intl/intl.dart';

class Conference {
  final int id;
  final String title;
  final String description;
  final DateTime startDate;
  final DateTime endDate;
  final String location;
  final String websiteUrl;
  final DateTime? deadlineSubmission;
  final DateTime? deadlineNotification;
  final String? topics;
  final int daysUntil;

  Conference({
    required this.id,
    required this.title,
    required this.description,
    required this.startDate,
    required this.endDate,
    required this.location,
    required this.websiteUrl,
    this.deadlineSubmission,
    this.deadlineNotification,
    this.topics,
    required this.daysUntil,
  });

  factory Conference.fromJson(Map<String, dynamic> json) {
    return Conference(
      id: json['id'],
      title: json['title'],
      description: json['description'] ?? '',
      startDate: DateTime.parse(json['start_date']),
      endDate: DateTime.parse(json['end_date']),
      location: json['location'],
      websiteUrl: json['website_url'],
      deadlineSubmission: json['deadline_submission'] != null 
          ? DateTime.parse(json['deadline_submission']) 
          : null,
      deadlineNotification: json['deadline_notification'] != null 
          ? DateTime.parse(json['deadline_notification']) 
          : null,
      topics: json['topics'],
      daysUntil: json['days_until'],
    );
  }

  String get formattedStartDate => DateFormat('MMM d, yyyy').format(startDate);
  String get formattedEndDate => DateFormat('MMM d, yyyy').format(endDate);

  String get statusText {
    if (daysUntil > 0) {
      return 'In $daysUntil days';
    } else if (daysUntil == 0) {
      return 'Happening now';
    } else {
      return 'Ended';
    }
  }

  String get deadlineText {
    if (deadlineSubmission == null) return 'No deadline info';
    
    final now = DateTime.now();
    if (deadlineSubmission!.isBefore(now)) {
      return 'Deadline passed';
    } else {
      final daysLeft = deadlineSubmission!.difference(now).inDays;
      return 'Submit in $daysLeft days';
    }
  }
}