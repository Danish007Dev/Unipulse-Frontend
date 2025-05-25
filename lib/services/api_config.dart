// This file contains the API configuration for the application.

class ApiConfig {
  // Auth & Public
  static const String requestOtp = '/views/request-otp/';
  static const String verifyOtp = '/views/verify-otp/';
  static const String departments = '/views/departments/';
  static const String tokenRefresh = '/token/refresh/';

  // Student
  static const String studentPosts = '/views/student/posts/';
  static const String toggleSavePost = '/views/student/posts/save/';
  static const String savedPosts = '/views/student/saved-posts/';

  // Faculty
  static const String facultyCourses = '/views/faculty/courses/';
  static const String facultyPosts = '/views/faculty/posts/';
  static const String createFacultyPost = '/views/faculty/posts/create/';

  // Dynamic Routes for Faculty
  static String courseSemesters(int courseId) =>
      '/views/course/$courseId/semesters/';

  static String deleteFacultyPost(int postId) =>
      '/views/faculty/posts/$postId/';
}
