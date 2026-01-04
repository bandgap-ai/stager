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
  runApp(const StagerPlatformExampleApp());
}

class StagerPlatformExampleApp extends StatelessWidget {
  const StagerPlatformExampleApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Stager Platform Example',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.red),
        useMaterial3: true,
      ),
      home: const StagerPlatformExampleHomePage(title: 'Stager Platform Example'),
    );
  }
}

class StagerPlatformExampleHomePage extends StatefulWidget {
  const StagerPlatformExampleHomePage({super.key, required this.title});
  final String title;

  @override
  State<StagerPlatformExampleHomePage> createState() => _StagerPlatformExampleHomePageState();
}

class _StagerPlatformExampleHomePageState extends
  State<StagerPlatformExampleHomePage> with SingleTickerProviderStateMixin {
  late final TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.primary,
        title: Text(widget.title, style: TextStyle(color: Theme.of(context).colorScheme.onPrimary)),
        bottom: TabBar(
          controller: _tabController,
          labelColor: Theme.of(context).colorScheme.onPrimary,
          unselectedLabelColor: Theme.of(context).colorScheme.onPrimary.withAlpha(179),
          indicatorColor: Theme.of(context).colorScheme.onPrimary,
          tabs: [
            // Start with the geographic information services tab
            Tab(icon: Icon(Icons.map_rounded), text: 'GIS'),
            Tab(icon: Icon(Icons.beach_access_sharp), text: 'Tab 2'),
            Tab(icon: Icon(Icons.brightness_5_sharp), text: 'Tab 3'),
          ],
        )
      ),
      body: Padding(
        padding: EdgeInsets.all(8.0),
        child: TabBarView(
          controller: _tabController,
          children: const <Widget>[
            // The content for each tab. Load the location and geo services
            // first.
            Center(child: LocationEditor()),
            Center(child: Text("It's rainy here")),
            Center(child: Text("It's sunny here")),
          ],
        ),
      ),
    );
  }
}
