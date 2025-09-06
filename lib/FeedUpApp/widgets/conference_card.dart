import 'package:flutter/material.dart';
import '../models/conference.dart';
import '../screens/webview_screen.dart';

class ConferenceCard extends StatefulWidget {
  final Conference conference;

  const ConferenceCard({
    Key? key,
    required this.conference,
  }) : super(key: key);

  @override
  State<ConferenceCard> createState() => _ConferenceCardState();
}

class _ConferenceCardState extends State<ConferenceCard> {
  bool _isExpanded = false;

  @override
  Widget build(BuildContext context) {
    final conference = widget.conference;
    final hasLongDescription = conference.description.length > 150;
    
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Title
            Text(
              conference.title,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            
            // Date and Status
            Row(
              children: [
                Icon(
                  Icons.calendar_today,
                  size: 16,
                  color: Colors.grey[600],
                ),
                const SizedBox(width: 4),
                Text(
                  '${conference.formattedStartDate} - ${conference.formattedEndDate}',
                  style: TextStyle(
                    color: Colors.grey[600],
                    fontSize: 14,
                  ),
                ),
                const Spacer(),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: _getStatusColor(conference.daysUntil),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    conference.statusText,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            
            // Location
            Row(
              children: [
                Icon(
                  Icons.location_on,
                  size: 16,
                  color: Colors.grey[600],
                ),
                const SizedBox(width: 4),
                Expanded(
                  child: Text(
                    conference.location,
                    style: TextStyle(
                      color: Colors.grey[600],
                      fontSize: 14,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            
            // Description
            if (conference.description.isNotEmpty) ...[
              Text(
                _isExpanded || !hasLongDescription
                    ? conference.description
                    : '${conference.description.substring(0, 150)}...',
                style: const TextStyle(fontSize: 14),
              ),
              if (hasLongDescription) ...[
                const SizedBox(height: 8),
                GestureDetector(
                  onTap: () {
                    setState(() {
                      _isExpanded = !_isExpanded;
                    });
                  },
                  child: Text(
                    _isExpanded ? 'Show less' : 'Read more',
                    style: TextStyle(
                      color: Theme.of(context).primaryColor,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ],
            
            // Topics
            if (conference.topics != null && conference.topics!.isNotEmpty) ...[
              const SizedBox(height: 12),
              Wrap(
                spacing: 6,
                runSpacing: 6,
                children: conference.topics!.split(',').take(3).map((topic) {
                  return Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: Theme.of(context).primaryColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      topic.trim(),
                      style: TextStyle(
                        color: Theme.of(context).primaryColor,
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  );
                }).toList(),
              ),
            ],
            
            // Deadline info
            if (conference.deadlineSubmission != null) ...[
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.orange.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.orange.withOpacity(0.3)),
                ),
                child: Row(
                  children: [
                    const Icon(
                      Icons.schedule,
                      size: 16,
                      color: Colors.orange,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      conference.deadlineText,
                      style: const TextStyle(
                        color: Colors.orange,
                        fontWeight: FontWeight.w500,
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
              ),
            ],
            
            const SizedBox(height: 12),
            
            // Action buttons
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton.icon(
                  onPressed: () => _shareConference(conference),
                  icon: const Icon(Icons.share, size: 16),
                  label: const Text('Share'),
                  style: TextButton.styleFrom(
                    foregroundColor: Colors.grey[600],
                  ),
                ),
                const SizedBox(width: 8),
                ElevatedButton.icon(
                  onPressed: () => _openConferenceWebsite(context, conference),
                  icon: const Icon(Icons.open_in_new, size: 16),
                  label: const Text('Visit Website'),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
  
  Color _getStatusColor(int daysUntil) {
    if (daysUntil < 0) return Colors.grey;
    if (daysUntil == 0) return Colors.green;
    if (daysUntil <= 30) return Colors.orange;
    return Colors.blue;
  }
  
  void _shareConference(Conference conference) {
    // Implement share functionality
    // final text = '${conference.title}\n${conference.formattedStartDate} - ${conference.formattedEndDate}\n${conference.location}\n${conference.websiteUrl}';
    // You can use share_plus package here
    // Share.share(text);
  }
  
  void _openConferenceWebsite(BuildContext context, Conference conference) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => WebViewScreen(
          url: conference.websiteUrl,
          title: conference.title,
        ),
      ),
    );
  }
}