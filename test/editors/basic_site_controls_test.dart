import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:stager/editors/basic_site_controls.dart';
import 'package:stager/editors/site_controls.dart';
import 'package:stager/site_state.dart';
import 'mock_editor_factory.dart';

void main() {

  late SiteState state;
  late SiteControls siteControls;
  late MockEditorFactory editorFactory;

  setUp(() {
    state = SiteState();
    editorFactory = MockEditorFactory();
    siteControls = BasicSiteControls(editorFactory);
  });

  group('BasicSiteControls', ()
  {
    testWidgets('Should open the Add Node dialog', (WidgetTester tester) async {

      // Reset the editor factory just in case
      editorFactory.reset();

      // Create a minimal Material App. This is actually easier than mocking or
      // faking it and it gives us additional testing options.
      await tester.pumpWidget(
        MaterialApp(
          home: Builder(
            builder: (context) => siteControls.buildAddNodeControl(context, state),
                ),
          ),
      );
      // Make sure to press the button! >:-D
      await tester.tap(find.byType(IconButton));
      await tester.pumpAndSettle();

      // First check the factory was called
      expect(editorFactory.addNodeCalled, isTrue);
    });
  });
}