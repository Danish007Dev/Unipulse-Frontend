import 'package:flutter/material.dart';
import 'stu_post_model.dart';
import 'stu_post_service.dart';

class StudentDashboardProvider extends ChangeNotifier {
  final List<Post> _posts = [];
  String? _nextUrl;
  
  bool _isLoading = false;
  bool get isLoading => _isLoading;

  List<Post> get posts => _posts;
  bool get hasMore => _nextUrl != null;

  Future<void> fetchInitialPosts() async {
    _isLoading = true;
    notifyListeners();
    try {
      final response = await StudentPostService.fetchPostsForStudent();
      _posts
        ..clear()
        ..addAll(response.posts);
      _nextUrl = response.next;
    } catch (e) {
      // Optional: handle error
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> fetchMorePosts() async {
    if (_isLoading || _nextUrl == null) return;
    _isLoading = true;
    notifyListeners();
    try {
      final response = await StudentPostService.fetchPostsForStudent(url: _nextUrl);
      _posts.addAll(response.posts);
      _nextUrl = response.next;
    } catch (e) {
      // Optional: handle error
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  //   Future<void> toggleSaveStatus(int postId) async {
  //   try {
  //     await StudentPostService.toggleSavePost(postId);

  //     // Update local post's isSaved field
  //     final index = _posts.indexWhere((p) => p.id == postId);
  //     if (index != -1) {
  //       _posts[index] = _posts[index].copyWith(isSaved: !_posts[index].isSaved);
  //       notifyListeners();
  //     }
  //   } catch (e) {
  //     debugPrint('Error toggling save status: $e');
  //     rethrow;
  //   }
  // }
  Future<bool> toggleSaveStatus(int postId) async {
  try {
    await StudentPostService.toggleSavePost(postId);

    final index = _posts.indexWhere((p) => p.id == postId);
    if (index != -1) {
      final updated = _posts[index].copyWith(isSaved: !_posts[index].isSaved);
      _posts[index] = updated;
      notifyListeners();
      return updated.isSaved;
    }

    // If not found in list, just return true/false
    return false;
  } catch (e) {
    debugPrint('Error toggling save status: $e');
    rethrow;
  }
}



}
