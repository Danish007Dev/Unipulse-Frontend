import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'stu_dashboard_provider.dart';
import 'stu_post_tile.dart';

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

    return RefreshIndicator(
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
    );
  }
}


