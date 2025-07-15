// refactored StudentPostTile to remove the local isSaved state and rely instead on the source of truth from the parent/provider
import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:path/path.dart' as path;
import 'stu_post_model.dart';
import '/widgets/simple_image_viewer.dart';

class StudentPostTile extends StatelessWidget {
  final Post post;
  final VoidCallback onBookmarkToggled;

  const StudentPostTile({
    Key? key,
    required this.post,
    required this.onBookmarkToggled,
  }) : super(key: key);


  Future<void> _openFile(String? url, BuildContext context) async {
    if (url == null || url.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No file URL available')),
      );
      return;
    }

    try {
      // Check if it's an image file based on URL or path
      bool isImageFile = url.toLowerCase().endsWith('.jpg') ||
          url.toLowerCase().endsWith('.jpeg') ||
          url.toLowerCase().endsWith('.png') ||
          url.toLowerCase().endsWith('.gif') ||
          url.contains('images/'); // Check if URL contains images path

      if (isImageFile) {
        // Open image in our custom viewer
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
        return;
      }

      // Handle other file types (PDFs, docs, etc.)
      final Uri uri = Uri.parse(url);

      final bool launched = await launchUrl(
        uri,
        mode: LaunchMode.externalApplication,
      );

      if (!launched) {
        // Fallback
        final bool fallbackLaunched = await launchUrl(
          uri,
          mode: LaunchMode.platformDefault,
        );

        if (!fallbackLaunched) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Could not open file: $url')),
          );
        }
      }
    } catch (e) {
      debugPrint('Error opening file: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error opening file: $e')),
      );
    }
  }

  String _getFileName(String? url) {
    if (url == null || url.isEmpty) return 'document';
    return path.basename(Uri.parse(url).path);
  }

  IconData _getFileIcon(String? url) {
    if (url == null || url.isEmpty) return Icons.insert_drive_file;
    final ext = path.extension(url).toLowerCase();

    switch (ext) {
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
            /// Top row: Content + bookmark icon
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
                  icon: Icon(
                    post.isSaved ? Icons.bookmark : Icons.bookmark_border,
                    color: post.isSaved ? Colors.blue : Colors.grey,
                  ),
                  onPressed: onBookmarkToggled,
                  tooltip: post.isSaved ? 'Unsave' : 'Save',
                ),
              ],
            ),

            /// Image display section
            if (post.imageUrl != null && post.imageUrl!.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(top: 8.0),
                child: GestureDetector(
                  onTap: () => _openFile(post.imageUrl, context),
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Theme.of(context).brightness == Brightness.dark 
                                         ? Colors.grey.withOpacity(0.3) 
                                         : Colors.grey[300]!),
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: CachedNetworkImage(
                        imageUrl: post.imageUrl!,
                        placeholder: (context, url) => Container(
                          height: 200,
                          color: Theme.of(context).brightness == Brightness.dark 
                              ? Colors.grey[800] 
                              : Colors.grey[200],
                          child: const Center(child: CircularProgressIndicator()),
                        ),
                        errorWidget: (context, url, error) {
                          debugPrint('Error loading image: $error');
                          return GestureDetector(
                            onTap: () => _openFile(post.imageUrl, context),
                            child: Container(
                              height: 200,
                              color: Theme.of(context).brightness == Brightness.dark 
                                  ? Colors.grey[800] 
                                  : Colors.grey[200],
                              child: Center(
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(Icons.broken_image, 
                                         color: Theme.of(context).brightness == Brightness.dark 
                                             ? Colors.white70 
                                             : Colors.black54, 
                                         size: 40),
                                    const SizedBox(height: 8),
                                    Text('Image failed to load. Tap to try again.',
                                         style: TextStyle(
                                           color: Theme.of(context).brightness == Brightness.dark 
                                               ? Colors.white70 
                                               : Colors.black54,
                                         )),
                                  ],
                                ),
                              ),
                            ),
                          );
                        },
                        fit: BoxFit.cover,
                        width: double.infinity,
                        height: 200,
                      ),
                    ),
                  ),
                ),
              ),

            /// File download section
            if (post.fileUrl != null && post.fileUrl!.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(top: 8.0),
                child: InkWell(
                  onTap: () => _openFile(post.fileUrl, context),
                  borderRadius: BorderRadius.circular(8),
                  child: Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.grey[100],
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.grey[300]!),
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
                                _getFileName(post.fileUrl),
                                style: const TextStyle(color: Colors.blue),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              Text(
                                'Tap to open',
                                style: TextStyle(color: Colors.grey[600], fontSize: 12),
                              ),
                            ],
                          ),
                        ),
                        const Icon(Icons.open_in_new, size: 16),
                      ],
                    ),
                  ),
                ),
              ),

            /// Date
            const SizedBox(height: 8),
            Text(
              post.createdAt.toLocal().toString().split('.').first,
              style: const TextStyle(color: Colors.grey),
            ),
          ],
        ),
      ),
    );
  }
}


