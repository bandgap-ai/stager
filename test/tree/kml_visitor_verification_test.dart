import 'package:flutter_test/flutter_test.dart';
import 'package:stager_platform/tree/node_visitor.dart';
import 'package:stager_platform/mapping/nodes/kml_placemark_node.dart';
import 'package:stager_platform/mapping/style/kml_style_manager.dart';

// A mock visitor to verify visitation
class MockVisitor implements NodeVisitor {
  final List<String> visitedIds = [];

  @override
  void visit(Object node) {
    if (node is KMLPlacemarkNode) {
      visitedIds.add(node.properties.getProperty("id").toString());
    }
  }
}

void main() {
  test('KmlPlacemarkNode accepts NodeVisitor', () {
    final manager = KMLStyleManager();
    final placemark = KMLPlacemarkNode(
      id: 'pm1',
      name: 'Test',
      styleManager: manager,
    );

    final visitor = MockVisitor();
    placemark.accept(visitor);

    expect(visitor.visitedIds, contains('pm1'));
  });
}
