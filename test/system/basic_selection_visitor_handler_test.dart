import 'package:flutter_test/flutter_test.dart';
import 'package:stager_platform/system/basic_selection_visitor_handler.dart';
import 'package:stager_platform/system/selection.dart';
import 'package:stager_platform/system/selection_visitor.dart';

class FakeSelectionVisitor implements SelectionVisitor<int> {

  bool _wasVisited = false;

  bool get wasVisited => _wasVisited;

  void reset() {
    _wasVisited = false;
  }

  @override
  void visit(int element) {
    _wasVisited = true;
  }
}

class SecondFakeSelectionVisitor implements SelectionVisitor<String> {

  bool _wasVisited = false;

  bool get wasVisited => _wasVisited;

  void reset() {
    _wasVisited = false;
  }

  @override
  void visit(String element) {
    _wasVisited = true;
  }
}

void main() {
  group('Basic Selection Visitor Handler Tests', () {
    test('Check registration and visitation', () {
      BasicSelectionVisitorHandler handler = BasicSelectionVisitorHandler();
      int testInt = 10000;
      Selection<int> firstSelection = Selection<int>();
      firstSelection.value = testInt;
      String testString = 'Days';
      Selection<String> secondSelection = Selection<String>();
      secondSelection.value = testString;

      // Register the first fake
      FakeSelectionVisitor fakeVisitor = FakeSelectionVisitor();
      handler.register(int, fakeVisitor);

      // Check visitation
      handler.visit(firstSelection);
      expect(fakeVisitor.wasVisited, true);

      // Reset the first fake
      fakeVisitor.reset();

      // Register the second fake
      handler.register(String, SecondFakeSelectionVisitor());

      // Check visitation for the second fake
      SecondFakeSelectionVisitor secondFakeVisitor = SecondFakeSelectionVisitor();
      handler.visit(secondSelection);
      expect(secondFakeVisitor.wasVisited, false);

      // Check that the first fake was not visited
      expect(fakeVisitor.wasVisited, false);

      // Reset the second fake
      secondFakeVisitor.reset();

      // Check visitation for the first fake
      handler.visit(firstSelection);
      expect(fakeVisitor.wasVisited, true);

      // Check that the second fake was not visited
      expect(secondFakeVisitor.wasVisited, false);
    });

    test('Check exception handling', () {
      BasicSelectionVisitorHandler handler = BasicSelectionVisitorHandler();
      Selection<double> firstSelection = Selection<double>();

      // Check the selection without registration
      expect(() => handler.visit(firstSelection), throwsException);
    });
  });
}
