import 'package:flutter/material.dart';
import 'stu_post_model.dart';
import 'stu_post_service.dart';
import 'stu_post_tile.dart';
import 'stu_dashboard_provider.dart';
import '../../utils/toast_util.dart';
import 'package:provider/provider.dart';

class SavedPostsScreen extends StatefulWidget {
  const SavedPostsScreen({super.key});

  @override
  State<SavedPostsScreen> createState() => _SavedPostsScreenState();
}

class _SavedPostsScreenState extends State<SavedPostsScreen> {
  final List<Post> _savedPosts = [];
  final ScrollController _scrollController = ScrollController();
  String? _nextUrl;
  bool _isLoading = false;
  bool _hasMore = true;

  @override
  void initState() {
    super.initState();
    _fetchSavedPosts();

    _scrollController.addListener(() {
      if (_scrollController.position.pixels >= _scrollController.position.maxScrollExtent - 100) {
        _fetchMoreSavedPosts();
      }
    });
  }

  Future<void> _fetchSavedPosts() async {
    setState(() => _isLoading = true);
    try {
      final response = await StudentPostService.fetchSavedPosts(isSavedOnly: true);
      setState(() {
        _savedPosts
          ..clear()
          ..addAll(response.posts);
        _nextUrl = response.next;
        _hasMore = _nextUrl != null;
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Failed to fetch saved posts.")),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _fetchMoreSavedPosts() async {
    if (_isLoading || !_hasMore) return;
    setState(() => _isLoading = true);
    try {
      final response = await StudentPostService.fetchSavedPosts(
        url: _nextUrl,
        isSavedOnly: true,
      );
      setState(() {
        _savedPosts.addAll(response.posts);
        _nextUrl = response.next;
        _hasMore = _nextUrl != null;
      });
    } catch (e) {
      // Optional: handle error
    } finally {
      setState(() => _isLoading = false);
    }
  }

  // void _handleBookmarkToggle(int postId) {
  //   setState(() {
  //     _savedPosts.removeWhere((post) => post.id == postId);
  //   });
  //   ScaffoldMessenger.of(context).showSnackBar(
  //     const SnackBar(content: Text("Removed from saved posts")),
  //   );
  // }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Saved Posts'),
      ),
      body: RefreshIndicator(
        onRefresh: _fetchSavedPosts,
        child: ListView.builder(
          controller: _scrollController,
          itemCount: _savedPosts.length + (_hasMore ? 1 : 0),
          itemBuilder: (context, index) {
            if (index < _savedPosts.length) {
               final post = _savedPosts[index];
              return StudentPostTile(
                post: post,
                //onBookmarkToggled: () => _handleBookmarkToggle(post.id),
                onBookmarkToggled: () async {
                  final provider = Provider.of<StudentDashboardProvider>(context, listen: false);
                  final isStillSaved = await provider.toggleSaveStatus(post.id);
                  if (!isStillSaved) {
                    setState(() {
                      _savedPosts.removeWhere((p) => p.id == post.id);
                    });
                    showToast('Removed from saved posts');
                    } else {
                    showToast('Saved');
                    }
                }
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
    );
  }
}
