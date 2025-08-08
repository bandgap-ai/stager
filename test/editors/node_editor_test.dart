import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:stager/editors/node_editor.dart';
import 'package:stager/editors/single_point_map_editor.dart';
import 'package:stager/tree/concrete_leaf_node.dart';
import 'package:stager/tree/tree.dart';

void main() {
  late ConcreteLeafNode node;
  late NodeProperties testProperties;

  setUp(() {
    node = ConcreteLeafNode(id: 'test_id', name: 'Test Node');
    testProperties = node.properties;
  });

  group('NodeEditor Tests', () {
    testWidgets('NodeEditor displays title and content', (WidgetTester tester) async {
      testProperties.setProperty('name', 'Test Node');
      testProperties.setProperty('description', 'Some description');
      await tester.pumpWidget(MaterialApp(
        home: Scaffold(
          body: NodeEditor(state:node),
        ),
      ));

      expect(find.text('Edit Node Properties'), findsOneWidget);
      expect(find.text('Please configure the site information.'), findsOneWidget);
      expect(find.text('Description:'), findsOneWidget);
      expect(find.widgetWithText(TextField, 'Some description'), findsOneWidget);
    });

    testWidgets('NodeEditor displays latitude and longitude', (WidgetTester tester) async {
      testProperties.setProperty('latitude', 10.0);
      testProperties.setProperty('longitude', 20.0);
      await tester.pumpWidget(MaterialApp(
        home: Scaffold(
          body: NodeEditor(state: node),
        ),
      ));

      expect(find.text('Latitude:'), findsOneWidget);
      expect(find.text('Longitude:'), findsOneWidget);
      expect(find.widgetWithText(TextField, '10.0'), findsOneWidget);
      expect(find.widgetWithText(TextField, '20.0'), findsOneWidget);
    });

    testWidgets('NodeEditor returns updated properties on Save', (WidgetTester tester) async {
      testProperties.setProperty('name', 'Old Name');
      testProperties.setProperty('description', 'Old Description');
      testProperties.setProperty('latitude', 1.0);
      testProperties.setProperty('longitude', 2.0);

      Map<String, dynamic>? result;

      await tester.pumpWidget(MaterialApp(
        home: Scaffold(
          body: Builder(
            builder: (context) => ElevatedButton(
              onPressed: () async {
                result = await showDialog<Map<String, dynamic>>(
                  context: context,
                  builder: (BuildContext context) {
                    return NodeEditor(state: node);
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
      expect(result!['latitude'], 100.0);
      expect(result!['longitude'], 200.0);
    });

    testWidgets('NodeEditor displays position method widget and switches editors', (WidgetTester tester) async {
      testProperties.setProperty('latitude', 10.0);
      testProperties.setProperty('longitude', 20.0);

      await tester.pumpWidget(MaterialApp(
        home: Scaffold(
          body: NodeEditor(state: node),
        ),
      ));

      // Verify SegmentedButton is displayed
      expect(find.byType(SegmentedButton<bool>), findsOneWidget);
      expect(find.text('Input Coordinates'), findsOneWidget);
      expect(find.text('Select on Map'), findsOneWidget);

      // Initially, coordinate editor should be visible
      expect(find.text('Latitude:'), findsOneWidget);
      expect(find.text('Longitude:'), findsOneWidget);
      expect(find.widgetWithText(TextField, '10.0'), findsOneWidget);
      expect(find.widgetWithText(TextField, '20.0'), findsOneWidget);
      expect(find.byType(SinglePointMapEditor), findsNothing);

      // Tap "Select on Map"
      await tester.tap(find.text('Select on Map'));
      await tester.pump();

      // Map editor should be visible, coordinate editor should be gone
      expect(find.byType(SinglePointMapEditor), findsOneWidget);
      expect(find.text('Latitude:'), findsNothing);
      expect(find.text('Longitude:'), findsNothing);

      // Tap "Input Coordinates"
      await tester.tap(find.text('Input Coordinates'));
      await tester.pump();

      // Coordinate editor should be visible again
      expect(find.text('Latitude:'), findsOneWidget);
      expect(find.text('Longitude:'), findsOneWidget);
      expect(find.byType(SinglePointMapEditor), findsNothing);
    });
  });
}
