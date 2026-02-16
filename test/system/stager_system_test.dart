import 'package:flutter_test/flutter_test.dart';
import 'package:stager_platform/system/selection_service.dart';
import 'package:stager_platform/system/stager_system.dart';

void main() {
  group('Selection Service test',() {
    test('Can retrieve the selection service', () {
      final service1 = SelectionService();
      final service2 = StagerSystem().selectionService();
      expect(identical(service1, service2), isTrue);
    });
  });
}