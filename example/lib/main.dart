import 'package:flutter/material.dart';
import 'package:stager_platform/editors/location_editor.dart';

/// This is a class for manually testing widgets in Stager. It is not used
/// by clients or in any final products. Its sole purpose is to enable local
/// testing with hot reloading and debugging of widgets in Stager without
/// cobbling together solutions in client apps.
///
/// Edit the build widget as needed. Nothing is sacred in this class unless
/// it is so marked.

void main() {
  runApp(const UITestRigApp());
}

class UITestRigApp extends StatelessWidget {
  const UITestRigApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Stager Platform Example',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.red),
        useMaterial3: true,
      ),
      home: const UITestRigHomePage(title: 'Stager Platform Example'),
    );
  }
}

class UITestRigHomePage extends StatefulWidget {
  const UITestRigHomePage({super.key, required this.title});

  final String title;

  @override
  State<UITestRigHomePage> createState() => _UITestRigHomePageState();
}

class _UITestRigHomePageState extends State<UITestRigHomePage> {

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.primary,
        title: Text(widget.title),
      ),
      body: const LocationEditor(),
    );
  }
}
