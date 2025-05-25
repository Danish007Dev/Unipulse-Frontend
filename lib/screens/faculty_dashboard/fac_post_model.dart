
import 'package:file_picker/file_picker.dart';


class Post {
  final int id;
  final String content;
  final DateTime createdAt;
  final String? fileUrl;
  final String? imageUrl;

  Post({
    required this.id,
    required this.content,
    required this.createdAt,
    this.fileUrl,
    this.imageUrl,
  });

  factory Post.fromJson(Map<String, dynamic> json) {
    return Post(
      id: json['id'],
      content: json['content']?? 'NO CONTENT',
      createdAt: DateTime.parse(json['created_at']),
      fileUrl: json['document'],
      imageUrl: json['image'],
    );
  }
}

class PostCreateData {
  
  final String content;    
  final int? courseId;
  final int? semesterId;
  final PlatformFile? document;
  final PlatformFile? image;

  PostCreateData({
    
    required this.content,
    this.courseId,
    this.semesterId,
    this.document,
    this.image,
  });
}