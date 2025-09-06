import 'package:flutter/material.dart'; //from claude starred file , provider with minimal fix 
import 'fac_post_model.dart';
import 'fac_post_service.dart';
import '../../models/course_model.dart';
import '../../models/semester_model.dart';

class FacultyDashboardProvider extends ChangeNotifier {
  final List<Post> _posts = [];
  List<Course> _courses = [];
  List<Semester> _semesters = [];

  Course? _selectedCourse;
  Semester? _selectedSemester;

  bool _isLoading = false;
  bool _hasMore = true;
  int _currentPage = 1;
  final int _pageSize = 10;

  List<Post> get posts => _posts;
  List<Course> get courses => _courses;
  List<Semester> get semesters => _semesters;
  Course? get selectedCourse => _selectedCourse;
  Semester? get selectedSemester => _selectedSemester;
  bool get isLoading => _isLoading;
  bool get hasMore => _hasMore;

  FacultyDashboardProvider() {
    // Don't initialize automatically
  }

  Future<void> initDashboard() async {
    // Only call this from initState with addPostFrameCallback
    await fetchCourses();
    await fetchPosts(refresh: true);
  }

  void selectCourse(Course? course) {
    _selectedCourse = course;
    _selectedSemester = null;
    _semesters = [];
    _hasMore = true;
    _posts.clear(); // Optional: avoids stale posts during switch
    notifyListeners();
    
    // Schedule these operations for after this frame
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (course != null) fetchSemesters(course.id);
      fetchPosts(refresh: true);
    });
  }

  void selectSemester(Semester? semester) {
    _selectedSemester = semester;
    notifyListeners();
    
    // Schedule for after this frame
    WidgetsBinding.instance.addPostFrameCallback((_) {
      fetchPosts(refresh: true);
    });
  }

  Future<void> fetchCourses() async {
    _courses = await PostService.getCourses();
    notifyListeners();
  }

  Future<void> fetchSemesters(int courseId) async {
    _semesters = await PostService.getSemesters(courseId);
    notifyListeners();
  }

  Future<void> fetchPosts({bool refresh = false}) async {
    if (refresh) {
      _posts.clear();
      _currentPage = 1;
      _hasMore = true;
      notifyListeners();
    }

    if (!_hasMore || _isLoading) return;

    _isLoading = true;
    notifyListeners();

    try {
      final newPosts = await PostService.getFacultyPosts(
        
        page: _currentPage,
        courseId: _selectedCourse?.id,
        semesterId: _selectedSemester?.id,
      );

      _posts.addAll(newPosts);
      _hasMore = newPosts.length == _pageSize;
      _currentPage++;
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> createPost(PostCreateData data) async {
    final result = await PostService.createPost(data);
    if (result.success) {
      await fetchPosts(refresh: true);
    }
    return result.success;
  }

  void resetFilters() {
    _selectedCourse = null;
    _selectedSemester = null;
    _semesters = [];
    
    // Schedule for after this frame
    WidgetsBinding.instance.addPostFrameCallback((_) {
      fetchPosts(refresh: true);
    });
    
    notifyListeners();
  }

  Future<void> deletePost(BuildContext context, int postId) async {
    print('🔄 Provider: Starting delete for post $postId');
  try {
    // Show loading indicator
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Deleting post...'),
          duration: Duration(seconds: 1),
        ),
      );
    }
    
    final success = await PostService.deletePost(postId);
    
    // Schedule UI updates to happen after the current build cycle
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (success) {
        // Remove the post from the list
        final beforeCount = _posts.length;
        _posts.removeWhere((p) => p.id == postId);
        final afterCount = _posts.length;
        print('🔄 Provider: Posts before: $beforeCount, after: $afterCount');


        notifyListeners();
        print('🔄 Provider: notifyListeners called');
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Post deleted successfully'),
              backgroundColor: Colors.green,
              duration: Duration(seconds: 2),
            ),
          );
        }
      } else if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Failed to delete post'),
            backgroundColor: Colors.red,
            duration: Duration(seconds: 2),
          ),
        );
      }
    });
  } catch (e) {
    // Handle any unexpected errors
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: ${e.toString()}'),
          backgroundColor: Colors.red,
          duration: Duration(seconds: 2),
        ),
      );
    }
  }
}

}
