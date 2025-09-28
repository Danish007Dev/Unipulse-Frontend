import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:path/path.dart' as path;
import 'fac_post_model.dart';
import '/widgets/simple_image_viewer.dart';
import '/utils/logger.dart';


class PostTile extends StatelessWidget {
  final Post post;
  final VoidCallback onDelete;

  const PostTile({
    Key? key,
    required this.post,
    required this.onDelete,
  }) : super(key: key);

  
  void _confirmDelete(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Delete Post'),
        content: const Text('Are you sure you want to delete this post?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
            ),
            onPressed: () {
              Navigator.pop(context); // Close dialog
              onDelete(); // Call deletion callback
            },
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  String _getFileNameFromUrl(String? url) {
    if (url == null || url.isEmpty) return 'document';
    try {
      return path.basename(Uri.parse(url).path);
    } catch (e) {
      return 'document';
    }
  }

  Future<void> _openFile(String? url, BuildContext context) async {
    if (url == null || url.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No file URL available')),
      );
      return;
    }
    
    appLogger.i('Opening file: $url');
    
    // Check if it's an image or document
    bool isImage = url.toLowerCase().endsWith('.jpg') || 
                  url.toLowerCase().endsWith('.jpeg') || 
                  url.toLowerCase().endsWith('.png') || 
                  url.toLowerCase().endsWith('.gif') ||
                  url.contains('images/');  // Check if URL contains images path
                  
    if (isImage) {
      // Use our simple image viewer for images
      if (context.mounted) {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => SimpleImageViewer(
              imageUrl: url,
              title: 'Post Image',
            ),
          ),
        );
      }
    } else {
      // For documents like PDFs, try to open with URL launcher
      try {
        final Uri uri = Uri.parse(url);
        final bool launched = await launchUrl(
          uri,
          mode: LaunchMode.externalApplication,
        );
        
        if (!launched) {
          appLogger.w('Could not launch URL with external app, trying platform default');
          final bool fallbackLaunched = await launchUrl(
            uri,
            mode: LaunchMode.platformDefault,
          );
          
          if (!fallbackLaunched) {
            appLogger.e('Could not launch URL: $url');
            if (context.mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Could not open file: $url')),
              );
            }
          }
        }
      } catch (e) {
        appLogger.e('Error opening URL: $url', error: e);
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error opening file: $e')),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 3,
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Text(
                    post.content,
                    style: const TextStyle(fontSize: 16),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.delete, color: Colors.red),
                  onPressed: () => _confirmDelete(context),
                  tooltip: 'Delete Post',
                ),
              ],
            ),
            
            // Display image if available
            if (post.imageUrl != null && post.imageUrl!.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(top: 8.0),
                child: GestureDetector(
                  onTap: () => _openFile(post.imageUrl, context),
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.grey.withOpacity(0.3)),
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: Image.network(
                        post.imageUrl!,
                        loadingBuilder: (context, child, loadingProgress) {
                          if (loadingProgress == null) return child;
                          return Container(
                            height: 200,
                            color: Colors.grey[800],
                            child: Center(
                              child: CircularProgressIndicator(
                                value: loadingProgress.expectedTotalBytes != null
                                    ? loadingProgress.cumulativeBytesLoaded / 
                                      loadingProgress.expectedTotalBytes!
                                    : null,
                              ),
                            ),
                          );
                        },
                        errorBuilder: (context, error, stackTrace) {
                          appLogger.e('Error loading image in tile', error: error);
                          return Container(
                            height: 100,
                            color: Colors.grey[800],
                            child: const Center(
                              child: Icon(Icons.broken_image, color: Colors.white70, size: 40),
                            ),
                          );
                        },
                        fit: BoxFit.cover,
                        height: 200,
                      ),
                    ),
                  ),
                ),
              ),
            
            // Display document if available
            if (post.fileUrl != null && post.fileUrl!.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(top: 8.0),
                child: InkWell(
                  onTap: () => _openFile(post.fileUrl, context),
                  borderRadius: BorderRadius.circular(8),
                  child: Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.grey.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.grey.withOpacity(0.3)),
                    ),
                    child: Row(
                      children: [
                        Icon(_getFileIcon(post.fileUrl), color: Colors.blue),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                _getFileNameFromUrl(post.fileUrl),
                                style: const TextStyle(color: Colors.blue),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              Text(
                                'Tap to open',
                                style: TextStyle(color: Colors.grey[400], fontSize: 12),
                              ),
                            ],
                          ),
                        ),
                        const Icon(Icons.open_in_new, size: 16, color: Colors.grey),
                      ],
                    ),
                  ),
                ),
              ),
            
            const SizedBox(height: 8),
            Text(
              post.createdAt.toLocal().toString().split('.').first,
              style: TextStyle(color: Colors.grey[500], fontSize: 12),
            ),
          ],
        ),
      ),
    );
  }
  
  IconData _getFileIcon(String? url) {
    if (url == null || url.isEmpty) return Icons.insert_drive_file;
    
    final String extension = path.extension(url).toLowerCase();
    
    // Return specific icon based on file extension
    switch (extension) {
      case '.pdf':
        return Icons.picture_as_pdf;
      case '.doc':
      case '.docx':
        return Icons.description;
      case '.xls':
      case '.xlsx':
        return Icons.table_chart;
      case '.ppt':
      case '.pptx':
        return Icons.slideshow;
      case '.txt':
        return Icons.text_snippet;
      case '.zip':
      case '.rar':
        return Icons.folder_zip;
      default:
        return Icons.insert_drive_file;
    }
  }
}
