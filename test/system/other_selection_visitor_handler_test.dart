// Flutter packages
import 'package:flutter_test/flutter_test.dart';

// Project files
import 'package:stager_platform/system/other_selection_visitor_handler.dart';
import 'package:stager_platform/system/selection.dart';
import 'package:stager_platform/system/selection_visitor.dart';

/// A mock visitor for testing visitation of [int] selections.
class MockIntVisitor implements SelectionVisitor<int> {
  bool wasVisited = false;
  int? visitedValue;

  @override
  void visit(int element) {
    wasVisited = true;
    visitedValue = element;
  }
}

/// A mock visitor for testing visitation of [String] selections.
class MockStringVisitor implements SelectionVisitor<String> {
  bool wasVisited = false;
  String? visitedValue;

  @override
  void visit(String element) {
    wasVisited = true;
    visitedValue = element;
  }
}

void main() {
  group('OtherSelectionVisitorHandler Tests', () {
    late OtherSelectionVisitorHandler handler;

    setUp(() {
      handler = OtherSelectionVisitorHandler();
    });

    test('should correctly register and visit a selection', () {
      // Arrange
      final visitor = MockIntVisitor();
      final selection = Selection<int>();
      selection.value = 42;
      handler.register(int, visitor);

      // Act
      handler.visit(selection);

      // Assert
      expect(visitor.wasVisited, isTrue);
      expect(visitor.visitedValue, 42);
    });

    test('should correctly route to the matching visitor among multiple registrations', () {
      // Arrange
      final intVisitor = MockIntVisitor();
      final stringVisitor = MockStringVisitor();
      handler.register(int, intVisitor);
      handler.register(String, stringVisitor);

      final selection = Selection<String>();
      selection.value = 'Stager';

      // Act
      handler.visit(selection);

      // Assert
      expect(stringVisitor.wasVisited, isTrue);
      expect(stringVisitor.visitedValue, 'Stager');
      expect(intVisitor.wasVisited, isFalse);
    });

    test('should throw Exception if no visitor is registered for the type', () {
      // Arrange
      final selection = Selection<double>();
      selection.value = 1.0;

      // Act & Assert
      expect(() => handler.visit(selection), throwsException);
    });
  });
}
