// Add this to techhub_main_wrapper.dart
import 'package:flutter/material.dart';
import '../../screens/role_selection.dart';
import 'feed_main_screen.dart';

class FeedupMainWrapper extends StatefulWidget {
  const FeedupMainWrapper({super.key});

  @override
  State<FeedupMainWrapper> createState() => _FeedupMainWrapperState();
}

class _FeedupMainWrapperState extends State<FeedupMainWrapper> {
  int _index = 0;

  final List<Widget> _screens =  [
    RoleSelectionScreen(),
    FeedUpScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _screens[_index],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _index,
        onTap: (i) => setState(() => _index = i),
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.login), label: 'Login'),
          BottomNavigationBarItem(icon: Icon(Icons.bolt), label: 'Feedup'),
        ],
      ),
    );
  }
}