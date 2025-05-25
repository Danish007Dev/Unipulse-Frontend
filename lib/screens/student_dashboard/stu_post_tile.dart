// refactored StudentPostTile to remove the local isSaved state and rely instead on the source of truth from the parent/provider
import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:path/path.dart' as path;
import 'stu_post_model.dart';
//import 'stu_post_service.dart';

class StudentPostTile extends StatelessWidget {
  final Post post;
  final VoidCallback onBookmarkToggled;

  const StudentPostTile({
    Key? key,
    required this.post,
    required this.onBookmarkToggled,
  }) : super(key: key);

  // Future<void> _toggleSaveStatus(BuildContext context) async {
  //   try {
  //     await StudentPostService.toggleSavePost(post.id);
  //     onBookmarkToggled(); // Notify parent/provider to update state
  //   } catch (e) {
  //     debugPrint('Error toggling save: $e');
  //     ScaffoldMessenger.of(context).showSnackBar(
  //       const SnackBar(content: Text('Failed to update saved status')),
  //     );
  //   }
  // }

  Future<void> _openFile(String? url, BuildContext context) async {
    if (url == null || url.isEmpty) return;

    try {
      final Uri uri = Uri.parse(url);
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Cannot open file: $url')),
        );
      }
    } catch (e) {
      debugPrint('Error opening file: $e');
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

            /// Image preview
            if (post.imageUrl != null && post.imageUrl!.isNotEmpty)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 8.0),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: CachedNetworkImage(
                    imageUrl: post.imageUrl!,
                    placeholder: (context, url) => const Center(
                      child: SizedBox(height: 50, width: 50, child: CircularProgressIndicator()),
                    ),
                    errorWidget: (context, url, error) => Container(
                      height: 100,
                      color: Colors.grey[200],
                      child: const Center(child: Icon(Icons.broken_image, size: 40)),
                    ),
                    fit: BoxFit.cover,
                    width: double.infinity,
                    height: 200,
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




// import 'package:flutter/material.dart';
// import 'package:cached_network_image/cached_network_image.dart';
// import 'package:url_launcher/url_launcher.dart';
// import 'package:path/path.dart' as path;
// import 'stu_post_model.dart';
// import 'stu_post_service.dart'; // You’ll need to implement save/unsave APIs here

// class StudentPostTile extends StatefulWidget {
//   final Post post;

//   const StudentPostTile({Key? key, required this.post}) : super(key: key);

//   @override
//   State<StudentPostTile> createState() => _StudentPostTileState();
// }

// class _StudentPostTileState extends State<StudentPostTile> {
//   late bool isSaved;

//   @override
//   void initState() {
//     super.initState();
//     isSaved = widget.post.isSaved;
//   }

//   Future<void> _toggleSaveStatus() async {
//     try {
//       if (isSaved) {
//         await StudentPostService.toggleSavePost(widget.post.id);
//         setState(() => isSaved = false);
//       } else {
//         await StudentPostService.toggleSavePost(widget.post.id);
//         setState(() => isSaved = true);
//       }
//     } catch (e) {
//       debugPrint('Error toggling save: $e');
//       ScaffoldMessenger.of(context).showSnackBar(
//         const SnackBar(content: Text('Failed to update saved status')),
//       );
//     }
//   }

//   Future<void> _openFile(String? url) async {
//     if (url == null || url.isEmpty) return;

//     try {
//       final Uri uri = Uri.parse(url);
//       if (await canLaunchUrl(uri)) {
//         await launchUrl(uri, mode: LaunchMode.externalApplication);
//       } else {
//         ScaffoldMessenger.of(context).showSnackBar(
//           SnackBar(content: Text('Cannot open file: $url')),
//         );
//       }
//     } catch (e) {
//       debugPrint('Error opening file: $e');
//     }
//   }

//   String _getFileName(String? url) {
//     if (url == null || url.isEmpty) return 'document';
//     return path.basename(Uri.parse(url).path);
//   }

//   IconData _getFileIcon(String? url) {
//     if (url == null || url.isEmpty) return Icons.insert_drive_file;
//     final ext = path.extension(url).toLowerCase();

//     switch (ext) {
//       case '.pdf':
//         return Icons.picture_as_pdf;
//       case '.doc':
//       case '.docx':
//         return Icons.description;
//       case '.xls':
//       case '.xlsx':
//         return Icons.table_chart;
//       case '.ppt':
//       case '.pptx':
//         return Icons.slideshow;
//       case '.txt':
//         return Icons.text_snippet;
//       case '.zip':
//       case '.rar':
//         return Icons.folder_zip;
//       default:
//         return Icons.insert_drive_file;
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
//             /// Top row: Content + bookmark icon
//             Row(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 Expanded(
//                   child: Text(
//                     widget.post.content,
//                     style: const TextStyle(fontSize: 16),
//                   ),
//                 ),
//                 IconButton(
//                   icon: Icon(
//                     isSaved ? Icons.bookmark : Icons.bookmark_border,
//                     color: isSaved ? Colors.blue : Colors.grey,
//                   ),
//                   onPressed: _toggleSaveStatus,
//                   tooltip: isSaved ? 'Unsave' : 'Save',
//                 ),
//               ],
//             ),

//             /// Image preview
//             if (widget.post.imageUrl != null && widget.post.imageUrl!.isNotEmpty)
//               Padding(
//                 padding: const EdgeInsets.symmetric(vertical: 8.0),
//                 child: ClipRRect(
//                   borderRadius: BorderRadius.circular(8),
//                   child: CachedNetworkImage(
//                     imageUrl: widget.post.imageUrl!,
//                     placeholder: (context, url) => const Center(
//                       child: SizedBox(height: 50, width: 50, child: CircularProgressIndicator()),
//                     ),
//                     errorWidget: (context, url, error) => Container(
//                       height: 100,
//                       color: Colors.grey[200],
//                       child: const Center(child: Icon(Icons.broken_image, size: 40)),
//                     ),
//                     fit: BoxFit.cover,
//                     width: double.infinity,
//                     height: 200,
//                   ),
//                 ),
//               ),

//             /// File download section
//             if (widget.post.fileUrl != null && widget.post.fileUrl!.isNotEmpty)
//               Padding(
//                 padding: const EdgeInsets.only(top: 8.0),
//                 child: InkWell(
//                   onTap: () => _openFile(widget.post.fileUrl),
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
//                         Icon(_getFileIcon(widget.post.fileUrl), color: Colors.blue),
//                         const SizedBox(width: 8),
//                         Expanded(
//                           child: Column(
//                             crossAxisAlignment: CrossAxisAlignment.start,
//                             children: [
//                               Text(
//                                 _getFileName(widget.post.fileUrl),
//                                 style: const TextStyle(color: Colors.blue),
//                                 maxLines: 1,
//                                 overflow: TextOverflow.ellipsis,
//                               ),
//                               Text(
//                                 'Tap to open',
//                                 style: TextStyle(color: Colors.grey[600], fontSize: 12),
//                               ),
//                             ],
//                           ),
//                         ),
//                         const Icon(Icons.open_in_new, size: 16),
//                       ],
//                     ),
//                   ),
//                 ),
//               ),

//             /// Date
//             const SizedBox(height: 8),
//             Text(
//               widget.post.createdAt.toLocal().toString().split('.').first,
//               style: const TextStyle(color: Colors.grey),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }



// // screens/student_dashboard/post_tile.dart
// import 'package:flutter/material.dart';
// import 'package:flutter_app/screens/student_dashboard/stu_post_service.dart';
// import 'stu_post_model.dart';
// import 'package:url_launcher/url_launcher.dart';


// class PostTile extends StatefulWidget {
//   final Post post;

//   const PostTile({Key? key, required this.post}) : super(key: key);

//   @override
//   State<PostTile> createState() => _PostTileState();
// }

// class _PostTileState extends State<PostTile> {
//   late bool isSaved;

//   @override
//   void initState() {
//     super.initState();
//     isSaved = widget.post.isSaved;
//   }

//   Future<void> toggleSave() async {
//     final success = await StudentPostService.savePost(widget.post.id);
//     if (success) {
//       setState(() {
//         isSaved = true; // Currently only allow saving, no unsave
//       });
//       ScaffoldMessenger.of(context).showSnackBar(
//         const SnackBar(content: Text('Post saved')),
//       );
//     } else {
//       ScaffoldMessenger.of(context).showSnackBar(
//         const SnackBar(content: Text('Error saving post')),
//       );
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Card(
//       margin: const EdgeInsets.all(12),
//       child: Padding(
//         padding: const EdgeInsets.all(16),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             // Text(widget.post.title,
//             //     style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
//             const SizedBox(height: 8),
//             Text(widget.post.content),
//             if (widget.post.fileUrl != null) ...[
//               const SizedBox(height: 12),
//               TextButton(
//                 onPressed: () async {
//                   final uri = Uri.parse(widget.post.fileUrl!);
//                   if (await canLaunchUrl(uri)) {
//                     await launchUrl(uri, mode: LaunchMode.externalApplication);
//                     } else {
//                     ScaffoldMessenger.of(context).showSnackBar(
//                       const SnackBar(content: Text('Could not open file')),
//                     );
//                   }
//                 },
//                 child: const Text('View Attachment'),
//               )
//             ],
//             const SizedBox(height: 8),

//             // Save button - optional now
//             // ElevatedButton(
//             //   onPressed: toggleSave,
//             //   child: const Text('Save'),
//             // ),

//             Align(
//               alignment: Alignment.centerRight,
//               child: IconButton(
//                 icon: Icon(isSaved ? Icons.bookmark : Icons.bookmark_border),
//                 onPressed: toggleSave,
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }
