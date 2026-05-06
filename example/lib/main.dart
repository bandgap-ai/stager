import 'package:flutter/material.dart';
import 'package:stager_platform/mapping/location_editor.dart';
import 'package:stager_platform/mapping/map_editor.dart';
import 'package:stager_platform/mapping/map_state.dart';
import 'package:stager_platform/mapping/single_point_map_editor.dart';
import 'package:stager_platform/site_state.dart';
import 'package:latlong2/latlong.dart';

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
  late final MapState _mapState;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    _mapState = MapState(SiteState());
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
            Tab(icon: Icon(Icons.map_rounded), text: 'Location Editor Widget'),
            Tab(icon: Icon(Icons.map_outlined), text: 'Stager Map Editor'),
            Tab(icon: Icon(Icons.brightness_5_sharp), text: 'Tab 3'),
            Tab(icon: Icon(Icons.brightness_5_sharp), text: 'Single Point Map Editor'),
          ],
        )
      ),
      body: Padding(
        padding: EdgeInsets.all(8.0),
        child: TabBarView(
          controller: _tabController,
          children: <Widget>[
            // The content for each tab. Load the location and geo services
            // first.
            Center(child: LocationEditor()),
            Center(child: MapEditor(state:_mapState)),
            Center(
              child: Stack(
                alignment: Alignment.center,
                children: [
                  // The "bottom" widget
                  Container(
                    color: Colors.blue,
                    width: 300,
                    height: 300,
                    child: const Center(child: Text("Background Layer")),
                  ),
                  // The "top" widget (the overlay)
                  Opacity(
                    opacity: 0.8,
                    child: Container(
                      color: Colors.red,
                      width: 200,
                      height: 200,
                      child: const Center(
                        child: Text(
                          "Overlay Effect",
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Center(child: SinglePointMapEditor(centerPosition: LatLng(0.0,0.0), onPointChanged: (LatLng p1) {  },)),
          ],
        ),
      ),
    );
  }
}
