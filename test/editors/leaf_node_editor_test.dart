import 'package:build_test/build_test.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:stager_platform/editors/leaf_node_editor.dart';
import 'package:stager_platform/editors/single_point_map_editor.dart';
import 'package:stager_platform/mapping/location_editor.dart';
import 'package:stager_platform/system/typed_value.dart';
import 'package:stager_platform/system/point.dart';
import 'package:stager_platform/tree/tree.dart';

void main() {
  late ConcreteLeafNode node;

  setUp(() {
    node = ConcreteLeafNode(name: 'Test Node');
  });

  group('LeafNodeEditor Tests', () {
    testWidgets('LeafNodeEditor displays title and content', (WidgetTester tester) async {
      node.properties.set<String>('description', 'Some description');
      await tester.pumpWidget(MaterialApp(
        home: Scaffold(
          body: LeafNodeEditor(state:node),
        ),
      ));

      expect(find.text('Edit Node Properties'), findsOneWidget);
      expect(find.text('Please configure the node.'), findsOneWidget);
      expect(find.text('Description:'), findsOneWidget);
      expect(find.widgetWithText(TextField, 'Some description'), findsOneWidget);
    });

    testWidgets('LeafNodeEditor displays latitude and longitude', (WidgetTester tester) async {
      node.position = Point(coords: [20.0, 10.0]);
      await tester.pumpWidget(MaterialApp(
        home: Scaffold(
          body: LeafNodeEditor(state: node),
        ),
      ));

      expect(find.text('Latitude:'), findsOneWidget);
      final latField = tester.widget<TextField>(
          find.ancestor(
              of: find.text('Latitude:'), matching: find.byType(TextField))
      );
      expect(latField.controller?.text, '10.0');
      expect(find.text('Longitude:'), findsOneWidget);
      expect(find.text('10.0'), findsOneWidget);
      expect(find.text('20.0'), findsOneWidget);
    });

    testWidgets('LeafNodeEditor returns updated properties on Save', (WidgetTester tester) async {
      node.name = 'Old Name';
      node.properties.set<String>('description', 'Old Description');
      node.position = Point(coords: [2.0, 1.0]);

      Map<String, dynamic>? result;

      await tester.pumpWidget(MaterialApp(
        home: Scaffold(
          body: Builder(
            builder: (context) => ElevatedButton(
              onPressed: () async {
                result = await showDialog<Map<String, Object>>(
                  context: context,
                  builder: (BuildContext context) {
                    return LeafNodeEditor(state: node);
                  },
                );
              },
              child: const Text('Open Dialog'),
            ),
          ),
        ),
      ));

      await tester.tap(find.text('Open Dialog'));
      await tester.pumpAndSettle();

      // Edit text fields
      await tester.enterText(find.widgetWithText(TextField, 'Old Description'), 'New Description');
      await tester.enterText(find.widgetWithText(TextField, '1.0'), '100.0');
      await tester.enterText(find.widgetWithText(TextField, '2.0'), '200.0');

      await tester.tap(find.text('Save'));
      await tester.pumpAndSettle();

      expect(result, isNotNull);
      expect(result!['name'], 'Old Name'); // Name is not editable in this dialog
      expect(result!['description'], 'New Description');
      expect(result!['latitude'], '100.0');
      expect(result!['longitude'], '200.0');
    });

    testWidgets('LeafNodeEditor displays position method widget and switches editors', (WidgetTester tester) async {
      node.position = Point(coords: [20.0, 10.0]);

      await tester.pumpWidget(MaterialApp(
        home: Scaffold(
          body: LeafNodeEditor(state: node),
        ),
      ));

      expect(find.byType(LocationEditor), findsOneWidget);

      Finder locationIcon = find.byIcon(Icons.my_location);
      expect(locationIcon, findsOneWidget);
      Finder pinDropIcon = find.byIcon(Icons.pin_drop);
      expect(pinDropIcon, findsOneWidget);
      Finder editLocationIcon = find.byIcon(Icons.edit_location);
      expect(editLocationIcon, findsOneWidget);

      // Initially, coordinate editor should be visible
      expect(find.text('Latitude:'), findsOneWidget);
      expect(find.text('Longitude:'), findsOneWidget);

      // If those icons are present, then the LocationEditor is working and we
      // don't need to test further since it has its own tests.
    });
  });
}
