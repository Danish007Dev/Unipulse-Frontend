import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:path/path.dart' as path;
import 'fac_post_model.dart';


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
      debugPrint('[PostTile] URL does not have http/https prefix?: $url');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No file URL available')),
      );
      return;
    }
    
    // Debug information
    debugPrint('Attempting to open file: $url');
    
    try {
      final Uri uri = Uri.parse(url);
      debugPrint('[PostTile] Parsed URI: $uri');
      if (await canLaunchUrl(uri)) {
        debugPrint('[PostTile] Can launch URL: $url');
        final bool launched = await launchUrl(uri, mode: LaunchMode.externalApplication);
        debugPrint('[PostTile] Launch result: $launched');

        if (!launched) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Could not open file: $url')),
          );
        }
      } else {
        debugPrint('[PostTile] Cannot launch URL: $url');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Cannot handle this file type: $url')),
        );
        debugPrint('Could not launch $url');
      }
    } catch (e) {
      debugPrint('[PostTile] Error parsing or opening URL: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error opening file: ${e.toString()}')),
      );
      debugPrint('Error opening file: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    if (post.fileUrl == null) {
      debugPrint('[PostTile] No file URL found for this post!');
    } else {
      debugPrint('[PostTile] File URL present: ${post.fileUrl}');
    }
    debugPrint('[PostTile] File URL check: ${post.fileUrl}');
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
                padding: const EdgeInsets.symmetric(vertical: 8.0),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: CachedNetworkImage(
                    imageUrl: post.imageUrl!,
                    placeholder: (context, url) => const Center(
                      child: SizedBox(
                        height: 50,
                        width: 50,
                        child: CircularProgressIndicator(),
                      ),
                    ),
                    errorWidget: (context, url, error) => Container(
                      height: 100,
                      color: Colors.grey[200],
                      child: const Center(
                        child: Icon(Icons.broken_image, size: 40),
                      ),
                    ),
                    fit: BoxFit.cover,
                    width: double.infinity,
                    height: 200,
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
                                _getFileNameFromUrl(post.fileUrl),
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
            
            const SizedBox(height: 8),
            Text(
              post.createdAt.toLocal().toString().split('.').first, // Format date nicer
              style: const TextStyle(color: Colors.grey),
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








// class PostTile extends StatelessWidget {
//   final Post post;
//   final VoidCallback onDelete;

//   const PostTile({
//     Key? key,
//     required this.post,
//     required this.onDelete,
//   }) : super(key: key);

//   void _confirmDelete(BuildContext context) {
//     showDialog(
//       context: context,
//       builder: (_) => AlertDialog(
//         title: const Text('Delete Post'),
//         content: const Text('Are you sure you want to delete this post?'),
//         actions: [
//           TextButton(
//             onPressed: () => Navigator.pop(context),
//             child: const Text('Cancel'),
//           ),
//           ElevatedButton(
//             style: ElevatedButton.styleFrom(
//               backgroundColor: Colors.red,
//             ),
//             onPressed: () {
//               Navigator.pop(context); // Close dialog
//               onDelete(); // Call deletion callback
//             },
//             child: const Text('Delete'),
//           ),
//         ],
//       ),
//     );
//   }

//   String _getFileNameFromUrl(String? url) {
//     if (url == null || url.isEmpty) return 'Document';
//     try {
//       return path.basename(Uri.parse(url).path);
//     } catch (e) {
//       return 'Document';
//     }
//   }

//   Future<void> _openFile(String? url) async {
//     if (url == null || url.isEmpty) return;
    
//     final Uri uri = Uri.parse(url);
//     if (await canLaunchUrl(uri)) {
//       await launchUrl(uri, mode: LaunchMode.externalApplication);
//     } else {
//       debugPrint('Could not launch $url');
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Card(
//       elevation: 3,
//       margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
//       shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
//       child: Padding(
//         padding: const EdgeInsets.all(16),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             Row(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 Expanded(
//                   child: Text(
//                     post.content,
//                     style: const TextStyle(fontSize: 16),
//                   ),
//                 ),
//                 IconButton(
//                   icon: const Icon(Icons.delete, color: Colors.red),
//                   onPressed: () => _confirmDelete(context),
//                   tooltip: 'Delete Post',
//                 ),
//               ],
//             ),
            
//             // Display image if available
//             if (post.imageUrl != null && post.imageUrl!.isNotEmpty)
//               Padding(
//                 padding: const EdgeInsets.symmetric(vertical: 8.0),
//                 child: ClipRRect(
//                   borderRadius: BorderRadius.circular(8),
//                   child: CachedNetworkImage(
//                     imageUrl: post.imageUrl!,
//                     placeholder: (context, url) => const Center(
//                       child: SizedBox(
//                         height: 50,
//                         width: 50,
//                         child: CircularProgressIndicator(),
//                       ),
//                     ),
//                     errorWidget: (context, url, error) => Container(
//                       height: 100,
//                       color: Colors.grey[200],
//                       child: const Center(
//                         child: Icon(Icons.broken_image, size: 40),
//                       ),
//                     ),
//                     fit: BoxFit.cover,
//                     width: double.infinity,
//                     height: 200,
//                   ),
//                 ),
//               ),
            
//             // Display document if available
//             if (post.fileUrl != null && post.fileUrl!.isNotEmpty)
//               Padding(
//                 padding: const EdgeInsets.only(top: 8.0),
//                 child: InkWell(
//                   onTap: () => _openFile(post.fileUrl),
//                   borderRadius: BorderRadius.circular(8),
//                   child: Container(
//                     padding: const EdgeInsets.all(12),
//                     decoration: BoxDecoration(
//                       color: Colors.grey[100],
//                       borderRadius: BorderRadius.circular(8),
//                       border: Border.all(color: Colors.grey[300]!),
//                     ),
//                     child: Row(
//                       children: [
//                         const Icon(Icons.insert_drive_file, color: Colors.blue),
//                         const SizedBox(width: 8),
//                         Expanded(
//                           child: Text(
//                             _getFileNameFromUrl(post.fileUrl),
//                             style: const TextStyle(color: Colors.blue),
//                             maxLines: 1,
//                             overflow: TextOverflow.ellipsis,
//                           ),
//                         ),
//                         const Icon(Icons.open_in_new, size: 16),
//                       ],
//                     ),
//                   ),
//                 ),
//               ),
            
//             const SizedBox(height: 8),
//             Text(
//               post.createdAt.toLocal().toString().split('.').first, // Format date nicer
//               style: const TextStyle(color: Colors.grey),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }


// import 'package:flutter/material.dart';
// import 'package:open_filex/open_filex.dart';
// import 'package:cached_network_image/cached_network_image.dart';
// import 'package:url_launcher/url_launcher.dart';
// import 'fac_post_model.dart';

// class PostTile extends StatelessWidget {
//   final Post post;
//   final VoidCallback onDelete;

//   const PostTile({
//     super.key,
//     required this.post,
//     required this.onDelete,
//   });

//   void _confirmDelete(BuildContext context) {
//     showDialog(
//       context: context,
//       builder: (_) => AlertDialog(
//         title: const Text('Delete Post'),
//         content: const Text('Are you sure you want to delete this post?'),
//         actions: [
//           TextButton(
//             onPressed: () => Navigator.pop(context),
//             child: const Text('Cancel'),
//           ),
//           ElevatedButton(
//             style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
//             onPressed: () {
//               Navigator.pop(context);
//               onDelete();
//             },
//             child: const Text('Delete'),
//           ),
//         ],
//       ),
//     );
//   }

//   void _openFile(BuildContext context, String url) async {
//     try {
//       final uri = Uri.parse(url);
//       if (url.toLowerCase().endsWith('.pdf') || url.toLowerCase().endsWith('.doc')) {
//         final result = await OpenFilex.open(uri.toString());
//         if (result.type != ResultType.done) {
//           ScaffoldMessenger.of(context).showSnackBar(
//             const SnackBar(content: Text('Could not open the file.')),
//           );
//         }
//       } else {
//         // fallback open in browser
//         if (await canLaunchUrl(uri)) {
//           await launchUrl(uri, mode: LaunchMode.externalApplication);
//         } else {
//           ScaffoldMessenger.of(context).showSnackBar(
//             const SnackBar(content: Text('No app found to open the file.')),
//           );
//         }
//       }
//     } catch (e) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(content: Text('Error opening file: $e')),
//       );
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Card(
//       elevation: 3,
//       margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
//       shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
//       child: Padding(
//         padding: const EdgeInsets.all(16),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             // Content + delete button
//             Row(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 Expanded(
//                   child: Text(
//                     post.content,
//                     style: const TextStyle(fontSize: 16),
//                   ),
//                 ),
//                 IconButton(
//                   icon: const Icon(Icons.delete, color: Colors.red),
//                   onPressed: () => _confirmDelete(context),
//                   tooltip: 'Delete Post',
//                 ),
//               ],
//             ),

//             const SizedBox(height: 8),

//             // File preview row
//             if (post.imageUrl != null || post.fileUrl != null)
//               Row(
//                 children: [
//                   if (post.imageUrl != null)
//                     GestureDetector(
//                       onTap: () => _openFile(context, post.imageUrl!),
//                       child: ClipRRect(
//                         borderRadius: BorderRadius.circular(8),
//                         child: CachedNetworkImage(
//                           imageUrl: post.imageUrl!,
//                           height: 80,
//                           width: 80,
//                           fit: BoxFit.cover,
//                           placeholder: (ctx, url) => const CircularProgressIndicator(),
//                           errorWidget: (ctx, url, err) => const Icon(Icons.broken_image),
//                         ),
//                       ),
//                     ),
//                   const SizedBox(width: 12),
//                   if (post.fileUrl != null)
//                     GestureDetector(
//                       onTap: () => _openFile(context, post.fileUrl!),
//                       child: Container(
//                         padding: const EdgeInsets.all(8),
//                         decoration: BoxDecoration(
//                           color: Colors.blue.shade100,
//                           borderRadius: BorderRadius.circular(8),
//                         ),
//                         child: Row(
//                           children: const [
//                             Icon(Icons.insert_drive_file, color: Colors.blue),
//                             SizedBox(width: 8),
//                             Text("Open Document"),
//                           ],
//                         ),
//                       ),
//                     ),
//                 ],
//               ),

//             const SizedBox(height: 10),

//             Text(
//               post.createdAt.toLocal().toString(),
//               style: const TextStyle(color: Colors.grey),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }
