import 'package:flutter/material.dart';
import 'login_screen.dart';

class RoleSelectionScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Select Role')),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          _buildRoleButton(context, 'student'),
          _buildRoleButton(context, 'faculty'),
          _buildRoleButton(context, 'admin'),
        ],
      ),
    );
  }

  Widget _buildRoleButton(BuildContext context, String role) {
    return ElevatedButton(
      onPressed: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => LoginScreen(user_type: role)),
        );
      },
      child: Text('Login as $role'),
    );
  }
}
