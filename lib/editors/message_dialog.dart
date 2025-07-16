import 'package:flutter/material.dart';

/// A reusable dialog to post a message to the user.
///
/// Displays an [AlertDialog] with a specified [title] and [content].
class MessageDialog extends StatelessWidget {
  final String title;
  final String content;

  const MessageDialog({
    super.key,
    required this.title,
    required this.content,
  });

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(title),
      content: Text(content),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(false),
          child: const Text('OK'),
        ),
      ],
    );
  }
}
