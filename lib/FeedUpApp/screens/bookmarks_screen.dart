import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/bookmark_provider.dart';
import '../widgets/article_card.dart'; // Your article card widget

class BookmarksScreen extends StatelessWidget {
  const BookmarksScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<BookmarkProvider>(
      builder: (context, bookmarkProvider, child) {
        final bookmarks = bookmarkProvider.bookmarks;
        if (bookmarks.isEmpty) {
          return const Center(
            child: Text('No bookmarks yet.'),
          );
        }
        return ListView.builder(
          itemCount: bookmarks.length,
          itemBuilder: (context, index) {
            return ArticleCard(article: bookmarks[index]);
          },
        );
      },
    );
  }
}
