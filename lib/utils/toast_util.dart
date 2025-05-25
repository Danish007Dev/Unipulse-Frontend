import 'package:flutter/material.dart';

void showToast(String message, {Color bgColor = Colors.black87}) {
  final context = navigatorKey.currentContext;
  if (context == null) return;

  ScaffoldMessenger.of(context).hideCurrentSnackBar();
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Text(message),
      backgroundColor: bgColor,
      behavior: SnackBarBehavior.floating,
    ),
  );
}

// This needs to be initialized in your app (main.dart)
final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();
