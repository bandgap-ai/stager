// Flutter packages
import 'package:flutter_test/flutter_test.dart';
import 'package:stager_platform/system/no_selection_exception.dart';

// Project files
import 'package:stager_platform/system/selection.dart';
import 'package:stager_platform/system/selection_service.dart';

import 'mock_selection_observer.dart';

void main() {
  group('SelectionService Tests', () {
    final SelectionService service = SelectionService();

    test('is a singleton', () {
      final service1 = SelectionService();
      final service2 = SelectionService();
      expect(identical(service1, service2), isTrue);
    });

    test('set/get global selection', () {
      final Selection<int> selection = Selection<int>(5);
      service.selection = selection;
      expect(service.selection, selection);
      // getSelectionForView should default to the global selection/view.
      expect(service.getSelectionForView(), selection);
    });

    test('set/get selection for specific view', () {
      final Selection<int> selection = Selection<int>(5);
      final Selection<String> selection2 = Selection<String>('five');
      service.selection = selection;
      expect(service.selection, selection);
      // Now set it for the specific view
      String viewId = 'meow';
      service.setSelectionForView(selection2,viewId);
      // Check it
      expect(service.getSelectionForView(viewId), selection2);
      // Make sure that didn't overwrite the global selection
      expect(service.selection != selection2, true);
      // Expect a NoSelectionException that prints the viewId in its message if
      // the viewId doesn't exist when getSelectionForView is called.
      expect(() => service.getSelectionForView('nope'), throwsA(isA<NoSelectionException>()));
    });

    test('isSet and clear work as expected', () {
      // Clear the service before testing since it is a singleton and all the
      // other tests are dirty, dirty tests!
      service.clearAll();
      expect(service.isSet(), isFalse);
      expect(service.viewIds.length,0);
      // Make a new global selection
      final Selection<int> selection = Selection<int>(5);
      // Set the global selection
      service.selection = selection;
      // Check the global selection
      expect(service.isSet(), isTrue);
      // Check that a view that hasn't been set returns false
      expect(service.isSet('nope'), isFalse);
      // Check that there is only one view returned with viewIds and that it is
      // only the global view
      expect(service.viewIds.length, 1);
      expect(service.viewIds[0], 'global');
      // Clear the ids and make sure that the global selection is no longer set
      service.clear();
      expect(service.isSet(), isFalse);
      // Reset the global connection, then add two more selections with other
      // view ids, and make sure that service.viewIds returns the all three
      // views.
      service.selection = selection;
      service.setSelectionForView(selection, 'meow');
      service.setSelectionForView(selection, 'woof');
      expect(service.viewIds.length, 3);
      expect(service.viewIds.contains('meow'), isTrue);
      expect(service.viewIds.contains('woof'), isTrue);
      expect(service.viewIds.contains('global'), isTrue);
    });

    test('attach/detach and notify observers', () {
      // Attach an observer to the service, then change the global selection to
      // trigger a notification to the observer.
      MockSelectionObserver observer = MockSelectionObserver();
      service.attach(observer);
      service.selection = Selection<int>(5);
      expect(observer.updated, isTrue);
      // Try to add the same observer again and make sure that it throws an
      // exception.
      expect(() => service.attach(observer), throwsA(isA<Exception>()));
      // Detach the observer, then change the global selection to trigger a
      // notification to the observer.
      service.detach(observer);
      observer.reset();
      service.selection = Selection<int>(10);
      expect(observer.updated, isFalse);

      // Make sure clearing and clearing all post notifications
      service.attach(observer);
      service.clear();
      expect(observer.updated, isTrue);

      // Now, register a second observer against a different view. Ensure that
      // setting the selection will dispactch correctly to the different
      // observers based on selections passed to the setter.
      MockSelectionObserver secondObserver = MockSelectionObserver();
      service.attach(secondObserver, 'meow');
      service.selection = Selection<int>(5);
      expect(observer.updated, isTrue);
      expect(secondObserver.updated, isFalse);
      observer.reset();
      // Update the 'meow' view. :-D
      service.setSelectionForView(Selection<int>(10), 'meow');
      // We're looking for a false value, meow.
      expect(observer.updated, isFalse);
      // The time is right meow for a true value.
      expect(secondObserver.updated, isTrue);
      // Meow, make sure that clearing the selections for all views notifies all
      // observers.
      observer.reset();
      secondObserver.reset();
      service.clear();
      expect(observer.updated, isTrue);
      // C'mon, meow! All views!
      observer.reset();
      service.clearAll();
      expect(observer.updated, isTrue);
      expect(secondObserver.updated, isTrue);
      // Alright, meow! We're done!
    });
  });
}
