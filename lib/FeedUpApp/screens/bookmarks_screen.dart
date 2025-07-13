import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/bookmark_provider.dart';
import '../../askAI/providers/ai_bookmark_provider.dart';
import '../widgets/article_card.dart';
import '../../askAI/widgets/ai_bookmark_tile.dart'; // We will create this next

class BookmarksScreen extends StatelessWidget {
  const BookmarksScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        // We use a nested AppBar inside the Scaffold body for tabs
        appBar: AppBar(
          flexibleSpace: const Column(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              TabBar(
                tabs: [
                  Tab(text: 'Articles'),
                  Tab(text: 'AI Responses'),
                ],
              ),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            // Tab 1: Article Bookmarks
            Consumer<BookmarkProvider>(
              builder: (context, provider, child) {
                if (provider.isLoading && provider.bookmarks.isEmpty) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (provider.bookmarks.isEmpty) {
                  return const Center(child: Text('No bookmarked articles yet.'));
                }
                return ListView.builder(
                  itemCount: provider.bookmarks.length,
                  itemBuilder: (context, index) => ArticleCard(article: provider.bookmarks[index]),
                );
              },
            ),
            // Tab 2: AI Response Bookmarks
            Consumer<AiBookmarkProvider>(
              builder: (context, provider, child) {
                if (provider.isLoading && provider.bookmarks.isEmpty) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (provider.bookmarks.isEmpty) {
                  return const Center(child: Text('No bookmarked AI responses yet.'));
                }
                return ListView.builder(
                  itemCount: provider.bookmarks.length,
                  itemBuilder: (context, index) {
                    // This widget needs to be created
                    return AiBookmarkTile(bookmark: provider.bookmarks[index]);
                  },
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
