import 'package:flutter/material.dart';
// import 'package:provider/provider.dart';
// import '../services/auth_provider.dart';
import '../services/feedup_auth_service.dart';

class CreateFeedUpPasswordDialog extends StatefulWidget {
  const CreateFeedUpPasswordDialog({super.key});

  @override
  State<CreateFeedUpPasswordDialog> createState() => _CreateFeedUpPasswordDialogState();
}

class _CreateFeedUpPasswordDialogState extends State<CreateFeedUpPasswordDialog> {
  final _passwordController = TextEditingController();
  bool _isLoading = false;

  Future<void> _setPassword() async {
    if (_passwordController.text.length < 8) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Password must be at least 8 characters.')),
      );
      return;
    }
    setState(() => _isLoading = true);

    final success = await FeedUpAuthService().setFeedUpPassword(_passwordController.text);

    setState(() => _isLoading = false);

    if (success && mounted) {
      Navigator.of(context).pop(); // Close the dialog
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('FeedUp password created successfully!')),
      );
    } else if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to set password. Please try again later.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Create FeedUp Password'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text('To use FeedUp features separately in the future, please create a password.'),
          const SizedBox(height: 16),
          TextField(
            controller: _passwordController,
            obscureText: true,
            decoration: const InputDecoration(labelText: 'New Password'),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Skip for Now'),
        ),
        _isLoading
            ? const CircularProgressIndicator()
            : ElevatedButton(
                onPressed: _setPassword,
                child: const Text('Save Password'),
              ),
      ],
    );
  }
}