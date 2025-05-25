import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'stu_dashboard_provider.dart';
import 'stu_post_tile.dart';
import '../../widgets/logout_button.dart';
import 'stu_saved_posts_screen.dart';

class StudentDashboardScreen extends StatefulWidget {
  const StudentDashboardScreen({Key? key}) : super(key: key);

  @override
  State<StudentDashboardScreen> createState() => _StudentDashboardScreenState();
}

class _StudentDashboardScreenState extends State<StudentDashboardScreen> {
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();

    // Fetch posts initially
    Future.microtask(() {
      context.read<StudentDashboardProvider>().fetchInitialPosts();
    });

    // Infinite scroll
    _scrollController.addListener(() {
      if (_scrollController.position.pixels >= _scrollController.position.maxScrollExtent - 100) {
        context.read<StudentDashboardProvider>().fetchMorePosts();
      }
    });
  }


  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<StudentDashboardProvider>();

    return PopScope(
      canPop: false,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Student Dashboard'),
          actions: const [LogoutButton()],
        ),
        drawer: Drawer(
          child: ListView(
            padding: EdgeInsets.zero,
            children: [
              const DrawerHeader(
                decoration: BoxDecoration(color: Colors.blue),
                child: Text('Menu', style: TextStyle(color: Colors.white, fontSize: 24)),
              ),
              ListTile(
                leading: const Icon(Icons.bookmark),
                title: const Text('Saved Posts'),
                onTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(builder: (_) => const SavedPostsScreen()),
                  );
                },
              ),
            ],
          ),
        ),
        body: RefreshIndicator(
          onRefresh: provider.fetchInitialPosts,
          child: ListView.builder(
            controller: _scrollController,
            itemCount: provider.posts.length + (provider.hasMore ? 1 : 0),
            itemBuilder: (context, index) {
              if (index < provider.posts.length) {
                final post = provider.posts[index];
                return StudentPostTile(
                  post: post,
                  onBookmarkToggled: () {
                    provider.toggleSaveStatus(post.id);
                  },
                );
              } else {
                return const Padding(
                  padding: EdgeInsets.all(16),
                  child: Center(child: CircularProgressIndicator()),
                );
              }
            },
          ),
        ),
      ),
    );
  }
}


// import 'package:flutter/material.dart';
// import 'stu_dashboard_provider.dart';

// import 'stu_post_tile.dart';
// import '../../widgets/logout_button.dart';
// import 'stu_saved_posts_screen.dart'; // You'll implement this separately

// class StudentDashboardScreen extends StatefulWidget {
//   const StudentDashboardScreen({Key? key}) : super(key: key);

//   @override
//   State<StudentDashboardScreen> createState() => _StudentDashboardScreenState();
// }

// class _StudentDashboardScreenState extends State<StudentDashboardScreen> {
//   final ScrollController _scrollController = ScrollController();
//   final StudentDashboardProvider _provider = StudentDashboardProvider();

//   @override
//   void initState() {
//     super.initState();
//     _provider.fetchInitialPosts();

//     _scrollController.addListener(() {
//       if (_scrollController.position.pixels >= _scrollController.position.maxScrollExtent - 100) {
//         _provider.fetchMorePosts();
//       }
//     });
//   }

//   @override
//   Widget build(BuildContext context) {
//     return PopScope(
//       canPop: false,
//       child: Scaffold(
//         appBar: AppBar(
//           title: const Text('Student Dashboard'),
//           //automaticallyImplyLeading: false,
//           actions: const [LogoutButton()],
//         ),
//         drawer: Drawer(
//           child: ListView(
//             padding: EdgeInsets.zero,
//             children: [
//               const DrawerHeader(
//                 decoration: BoxDecoration(
//                   color: Colors.blue,
//                 ),
//                 child: Text('Menu', style: TextStyle(color: Colors.white, fontSize: 24)),
//               ),
//               ListTile(
//                 leading: const Icon(Icons.bookmark),
//                 title: const Text('Saved Posts'),
//                 onTap: () {
//                   Navigator.of(context).push(
//                     MaterialPageRoute(builder: (_) => const SavedPostsScreen()),
//                   );
//                 },
//               ),
//             ],
//           ),
//         ),
//         body: AnimatedBuilder(
//           animation: _provider,
//           builder: (context, _) {
//             return RefreshIndicator(
//               onRefresh: _provider.fetchInitialPosts,
//               child: ListView.builder(
//                 controller: _scrollController,
//                 itemCount: _provider.posts.length + (_provider.hasMore ? 1 : 0),
//                 itemBuilder: (context, index) {
//                   if (index < _provider.posts.length) {
//                     return StudentPostTile(
//                       post: _provider.posts[index]
//                       );
//                   } else {
//                     return const Padding(
//                       padding: EdgeInsets.all(16),
//                       child: Center(child: CircularProgressIndicator()),
//                     );
//                   }
//                 },
//               ),
//             );
//           },
//         ),
//       ),
//     );
//   }
// }





// // screens/student_dashboard/student_dashboard_screen.dart
// import 'package:flutter/material.dart';
// import 'package:flutter_app/screens/student_dashboard/stu_post_service.dart';
// import 'stu_post_model.dart';

// import 'stu_post_tile.dart';
// import '../../widgets/logout_button.dart';

// class StudentDashboardScreen extends StatefulWidget {
//   const StudentDashboardScreen({Key? key}) : super(key: key);

//   @override
//   State<StudentDashboardScreen> createState() => _StudentDashboardScreenState();
// }
//   class _StudentDashboardScreenState extends State<StudentDashboardScreen> {
//   final ScrollController _scrollController = ScrollController();
//   final List<Post> _posts = [];
//   String? _nextUrl;
//   bool _isLoading = false;
//   bool _hasMore = true;

//   @override
//   void initState() {
//     super.initState();
//     _fetchInitialPosts();

//     _scrollController.addListener(() {
//       if (_scrollController.position.pixels >= _scrollController.position.maxScrollExtent - 100) {
//         _fetchMorePosts();
//       }
//     });
//   }

//   Future<void> _fetchInitialPosts() async {
//     setState(() => _isLoading = true);
//     try {
//       final response = await StudentPostService.fetchPostsForStudent();
//       setState(() {
//         _posts.clear();
//         _posts.addAll(response.posts);
//         _nextUrl = response.next;
//         _hasMore = _nextUrl != null;
//       });
//     } catch (e) {
//       // show error snackbar if needed
//     } finally {
//       setState(() => _isLoading = false);
//     }
//   }

//   Future<void> _fetchMorePosts() async {
//     if (_isLoading || !_hasMore) return;
//     setState(() => _isLoading = true);
//     try {
//       final response = await StudentPostService.fetchPostsForStudent(url: _nextUrl);
//       setState(() {
//         _posts.addAll(response.posts);
//         _nextUrl = response.next;
//         _hasMore = _nextUrl != null;
//       });
//     } catch (e) {
//       // handle error
//     } finally {
//       setState(() => _isLoading = false);
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return PopScope(
//       canPop: false,
//       child: Scaffold(
//         appBar: AppBar(
//           title: const Text('Student Dashboard'),
//           automaticallyImplyLeading: false,
//           actions: const [LogoutButton()],
//         ),
//         body: RefreshIndicator(
//           onRefresh: _fetchInitialPosts,
//           child: ListView.builder(
//             controller: _scrollController,
//             itemCount: _posts.length + (_hasMore ? 1 : 0),
//             itemBuilder: (context, index) {
//               if (index < _posts.length) {
//                 return StudentPostTile(post: _posts[index]);
//               } else {
//                 return const Padding(
//                   padding: EdgeInsets.all(16),
//                   child: Center(child: CircularProgressIndicator()),
//                 );
//               }
//             },
//           ),
//         ),
//       ),
//     );
//   }
// }

