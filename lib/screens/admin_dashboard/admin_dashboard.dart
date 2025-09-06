import 'package:flutter/material.dart';

class AdminDashboardScreen extends StatelessWidget {
  const AdminDashboardScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      child: Scaffold(
      appBar: AppBar(title: const Text("Admin Dashboard"),
      actions: const [
      //  LogoutButton(), // 🟢 Add this button on all dashboards
    ],
      ),
      body: const Center(child: Text("Welcome, Admin!")),
      
    )
    );
  }
}

