// In Dart (Flutter), we use model classes (a.k.a. POJOs) to structure and decode 
//JSON data that we get from the backend API. It's not a "model" like Django models 
//saved in a database — it's just a Dart class used to represent API responses cleanly.

//This is how Flutter knows how to convert the JSON you get from Django into a usable Dart object.

class Post {
  final int id;
  
  final String content;
  final String courseId;
  final String semesterId;
  final String? fileUrl;
  final String? imageUrl;

  //final String postedBy;
  //final String createdAt;
  final DateTime createdAt;
  final bool isSaved; 

  Post({
    required this.id,
    
    required this.content,
    this.fileUrl,
    this.imageUrl,
    required this.courseId,
    required this.semesterId,
    //required this.postedBy,
    required this.createdAt,
    required this.isSaved, 
  });

  factory Post.fromJson(Map<String, dynamic> json) {
    return Post(
      id: json['id'],
      
      content: json['content']?? 'NO CONTENT',
      courseId: json['course_name'],
      semesterId: json['semester_name'],
      fileUrl: json['document'],
      imageUrl: json['image'],
    
      //postedBy: json['posted_by']?? 'Unknown',// currently not sent by backend 
      //createdAt: json['created_at'],
      createdAt: DateTime.parse(json['created_at']),
      //isSaved: json['saved'] ?? false,// ❌ incorrect key since api sends "is_saved"
      isSaved: json['is_saved'] == true,
 
    );
  }

  Post copyWith({
    int? id,
    String? content,
    String? courseId,
    String? semesterId,
    String? fileUrl,
    String? imageUrl,
    DateTime? createdAt,
    bool? isSaved,
  }) {
    return Post(
      id: id ?? this.id,
      content: content ?? this.content,
      courseId: courseId ?? this.courseId,
      semesterId: semesterId ?? this.semesterId,
      fileUrl: fileUrl ?? this.fileUrl,
      imageUrl: imageUrl ?? this.imageUrl,
      createdAt: createdAt ?? this.createdAt,
      isSaved: isSaved ?? this.isSaved,
    );
  }

}


// using a PaginatedPosts class to represent paginated results
// Saved posts are also paginated in the same format (results + next), so reuse it.
class PaginatedPosts {
  final List<Post> posts;
  final String? next;

  PaginatedPosts({required this.posts, this.next});
}

