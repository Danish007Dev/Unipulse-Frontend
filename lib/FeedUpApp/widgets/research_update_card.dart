import 'package:flutter/material.dart';
import '../models/research_update.dart';
import '../screens/webview_screen.dart';

class ResearchUpdateCard extends StatefulWidget {
  final ResearchUpdate research;

  const ResearchUpdateCard({
    Key? key,
    required this.research,
  }) : super(key: key);

  @override
  State<ResearchUpdateCard> createState() => _ResearchUpdateCardState();
}

class _ResearchUpdateCardState extends State<ResearchUpdateCard> {
  bool _isExpanded = false;

  @override
  Widget build(BuildContext context) {
    final research = widget.research;
    final hasLongSummary = research.summary.length > 200;
    
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
              research.title,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            
            // Metadata row
            Row(
              children: [
                // Category badge
                if (research.category != null) ...[
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: _getCategoryColor(research.category!),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      research.category!,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                ],
                
                // Publication date
                Icon(
                  Icons.schedule,
                  size: 14,
                  color: Colors.grey[600],
                ),
                const SizedBox(width: 4),
                Text(
                  research.recencyText,
                  style: TextStyle(
                    color: Colors.grey[600],
                    fontSize: 12,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            
            // Summary
            Text(
              _isExpanded || !hasLongSummary
                  ? research.summary
                  : '${research.summary.substring(0, 200)}...',
              style: const TextStyle(fontSize: 14, height: 1.4),
            ),
            
            // Read more/less button
            if (hasLongSummary) ...[
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
            
            // Authors and Institution
            if (research.authors != null || research.institution != null) ...[
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.grey.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (research.authors != null) ...[
                      Row(
                        children: [
                          Icon(
                            Icons.person,
                            size: 14,
                            color: Colors.grey[600],
                          ),
                          const SizedBox(width: 4),
                          Expanded(
                            child: Text(
                              research.authors!,
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey[700],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                    if (research.institution != null) ...[
                      if (research.authors != null) const SizedBox(height: 4),
                      Row(
                        children: [
                          Icon(
                            Icons.school,
                            size: 14,
                            color: Colors.grey[600],
                          ),
                          const SizedBox(width: 4),
                          Expanded(
                            child: Text(
                              research.institution!,
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey[700],
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
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
                  onPressed: () => _shareResearch(research),
                  icon: const Icon(Icons.share, size: 16),
                  label: const Text('Share'),
                  style: TextButton.styleFrom(
                    foregroundColor: Colors.grey[600],
                  ),
                ),
                const SizedBox(width: 8),
                ElevatedButton.icon(
                  onPressed: () => _openResearchPaper(context, research),
                  icon: const Icon(Icons.open_in_new, size: 16),
                  label: const Text('Read Paper'),
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
  
  Color _getCategoryColor(String category) {
    switch (category.toLowerCase()) {
      case 'machine learning':
      case 'ai':
        return Colors.purple;
      case 'computer vision':
        return Colors.blue;
      case 'natural language processing':
      case 'nlp':
        return Colors.green;
      case 'cybersecurity':
        return Colors.red;
      case 'software engineering':
        return Colors.orange;
      case 'distributed systems':
        return Colors.teal;
      case 'human-computer interaction':
      case 'hci':
        return Colors.pink;
      case 'data science':
        return Colors.indigo;
      case 'algorithms':
        return Colors.brown;
      default:
        return Colors.grey;
    }
  }
  
  void _shareResearch(ResearchUpdate research) {
    // Implement share functionality
    // final text = '${research.title}\n${research.formattedPublicationDate}\n${research.url}';
    // You can use share_plus package here
    // Share.share(text);
  }
  
  void _openResearchPaper(BuildContext context, ResearchUpdate research) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => WebViewScreen(
          url: research.url,
          title: research.title,
        ),
      ),
    );
  }
}