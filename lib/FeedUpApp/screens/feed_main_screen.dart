import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/feed_provider.dart';
import '../widgets/article_card.dart';

class FeedUpScreen extends StatefulWidget {
  const FeedUpScreen({super.key});

  @override
  State<FeedUpScreen> createState() => _FeedUpScreenState();
}

class _FeedUpScreenState extends State<FeedUpScreen> {
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  void _onScroll() {
    if (_scrollController.position.pixels >= _scrollController.position.maxScrollExtent - 300) {
      // Use the provider to fetch more articles
      context.read<FeedProvider>().fetchArticles();
    }
  }

  @override
  Widget build(BuildContext context) {
    // Watch the provider for changes
    final feedProvider = context.watch<FeedProvider>();
    final articles = feedProvider.articles;

    return RefreshIndicator(
      onRefresh: () => context.read<FeedProvider>().refresh(),
      child: ListView.builder(
        controller: _scrollController,
        itemCount: articles.length + (feedProvider.hasMore ? 1 : 0),
        itemBuilder: (context, index) {
          if (index < articles.length) {
            return ArticleCard(article: articles[index]);
          } else {
            return const Padding(
              padding: EdgeInsets.all(24),
              child: Center(child: CircularProgressIndicator()),
            );
          }
        },
      ),
    );
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    super.dispose();
  }
}
