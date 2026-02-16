import 'package:logger/logger.dart';
import 'package:stager_platform/editors/node_properties_view.dart';
import 'package:stager_platform/system/selection_visitor_handler.dart';

import 'no_selection_exception.dart';
import 'selection_observer.dart';
import 'selection.dart';

/// The SelectionService is a singleton service capable of managing selections
/// across widgets (views, editors, etc.) in a scalable, sensible way using the
/// [Selection], [SelectionObserver], [SelectionVisitor], and
/// [SelectionVisitorHandler] support classes.
/// 
/// Its primary role is to act as a broker for "global" selections viewed across
/// multiple widgets. For example, selecting a widget in a [TreeView] should be
/// reflected in other widgets, like a [NodePropertiesView], if the former
/// submits the selection to the SelectionService and the latter retrieves the
/// selection from the service. The global selection has selection id "global"
/// defined by const member `globalSelectionId`.
/// 
/// Local selections can also be stored in the service as well and registered
/// against their local view ids. This allows, for example, a 
/// [NodePropertiesView] to share a local option that can inform the view in the
/// [MapEditor] without changing the global selection that all widgets need.
/// 
/// The SelectionService replaces the `_selectedNode` pattern with a global 
/// registry of observable [Selection] objects. It facilitates cross-view 
/// communication, such as allowing a [MapEditor] to pan and zoom when a node 
/// is selected in a separate Tree View.
/// 
/// It provides a dynamic visitor interface via [SelectionVisitor] and 
/// [SelectionVisitorHandler] to process selections polymorphically.
///
/// This service enforces a strict "no-null" retrieval policy. If a selection 
/// is requested but not present, the service throws a [NoSelectionException] 
/// rather than returning null. Clients that want to explicitly clear a 
/// selection should call [clear].
/// 
/// The implementation follows a no-null philosophy and uses default arguments
/// to take advantage of the protective language features of Dart (which seem to
/// be most of the appeal). This is accomplished using an internal map and
/// exception handling instead of passing around null values and requiring null
/// value checks.
///
/// See [the original design plan](../docs/stager_map_editor_plan.md) for more
/// about the original need and plans for this class.
class SelectionService {
  /// The id for the global selection.
  static const String globalSelectionId = "global";

  /// The current selections.
  final Map<String, Selection<dynamic>> _selections = {};

  /// The observers.
  final Map<String, List<SelectionObserver>> _observers = {};

  /// Logger
  final Logger logger = Logger();
  
  /// Singleton instance of the selection service.
  static final SelectionService _singleton = SelectionService._internal();

  /// Internal constructor
  SelectionService._internal();
  
  /// Factory constructor for the singleton instance.
  factory SelectionService() {
    return _singleton;
  }

  /// Checks to see if a selection is set for a given view. If no view id is
  /// specified, the global selection is checked.
  ///
  /// Returns true if a selection is set for the view, false otherwise.
  bool isSet([String viewId = globalSelectionId]) {
    return _selections.containsKey(viewId);
  }

  /// Gets the list of view ids for which a selection is set.
  List<String> get viewIds => _selections.keys.toList();

  /// Clears all the selections in the selection service. Be careful with this
  /// function!
  ///
  /// Note that this function does not detach observers from the service.
  ///
  /// This function does nothing if no selections are set.
  void clearAll() {
    // Copy the observer map so the observers can be notified after they are
    // removed from the map of record.
    final Map<String, List<SelectionObserver>> observers = Map.from(_observers);
    _selections.clear();
    // Kaboom
    _notifyAll(observers);
  }

  /// Clears the current selection in the selection service for the specified
  /// view id or the global selection if a view id is not specified. Be careful
  /// with this function!
  ///
  /// This function does nothing if the selection is not set for the view id.
  ///
  /// Note that this function does not detach observers from the service.
  ///
  /// [viewId]: The id of the view for which the selection should be cleared. It
  /// defaults to the global selection.
  void clear([String viewId = globalSelectionId]) {
    // Only risk notifying all the observers if the selection is set.
    if (_selections.containsKey(viewId)) {
      _selections.remove(viewId);
      notify(viewId);
    }
  }

  /// Sets the global selection. This is a convenience routine that is
  /// equivalent to calling `setSelectionForView(selection)` with the default
  /// view id.
  set selection(Selection<dynamic> selection) {
    setSelectionForView(selection);
  }

  /// Sets the current selection in the selection service for the specified
  /// view id or the global selection if a view id is not specified.
  ///
  /// [selection]: The selection to set.
  /// [viewId]: The id of the view for which the selection should be set. It
  /// defaults to the global selection.
  void setSelectionForView(
    Selection<dynamic> selection, [
    String viewId = globalSelectionId,
  ]) {
    _selections[viewId] = selection;
    notify(viewId);
  }

  /// Gets the global selection. This is a convenience routine that is
  /// equivalent to calling `getSelectionForView(selection)` with the default
  /// view id.
  ///
  /// Returns the global selection.
  Selection<dynamic> get selection => getSelectionForView();

  /// Gets the current selection in the selection service for the specified
  /// view id or the global selection if a view id is not specified.
  ///
  /// [viewId]: The id of the view for which the selection should be set. It
  /// defaults to the global selection.
  ///
  /// Returns the selection for the specified view id or the global selection
  /// if a view id is not specified.
  Selection<dynamic> getSelectionForView([String viewId = globalSelectionId]) {
    if (_selections.containsKey(viewId)) {
      return _selections[viewId]!;
    } else {
      logger.e('No selection found for view "$viewId" in SelectionService.');
      throw NoSelectionException(viewId);
    }
  }

  /// Attaches an [observer] to listen for selection changes.
  ///
  /// The observer will be notified immediately of the current selection value
  /// upon attachment, and subsequently whenever the selection changes.
  ///
  /// [observer]: The observer to attach. If the observer is already attached,
  /// an exception will be thrown.
  /// [viewId]: The id of the view for which the observer should be attached.
  /// It defaults to the global selection.
  void attach(SelectionObserver observer, [String viewId = globalSelectionId]) {
    // See if there is a list of observers for this view id. If so, add the
    // new observer.
    if (_observers.containsKey(viewId)) {
      _attachSingleObserver(_observers[viewId]!, observer);
    } else {
      // Otherwise, create a new list of observers and add the new observer.
      _observers[viewId] = [observer];
    }

  }

  /// This is a private method that attaches a single observer to a list of
  /// observers.
  ///
  /// [observers]: The list of observers to attach to.
  /// [observer]: The observer to attach. If the observer is already attached,
  /// an exception will be thrown.
  void _attachSingleObserver(List<SelectionObserver> observers,
      SelectionObserver observer) {
    if (!observers.contains(observer)) {
      observers.add(observer);
    } else {
      String message = 'Observer already attached to SelectionService.';
      logger.e(message);
      throw Exception(message);
    }
  }

  /// Detaches an [observer] to stop it from receiving updates.
  ///
  /// If the observer is not in the list, this method has no effect.
  ///
  /// [observer]: The observer to detach.
  /// [viewId]: The id of the view for which the observer should be detached. It
  /// defaults to the global selection.
  void detach(SelectionObserver observer, [String viewId = globalSelectionId]) {
    if (_observers.containsKey(viewId)) {
      _observers[viewId]!.remove(observer);
    }
  }

  /// This is a private utility function for notifying all observers that all
  /// selections have cleared. Basically, it's a mushroom cloud.
  ///
  /// [observers]: The map of observers to notify.
  void _notifyAll(Map<String, List<SelectionObserver>> observers) {
    for (final viewId in _observers.keys) {
      final observers = _observers[viewId];
      for (final observer in observers!) {
        observer.update();
      }
    }
  }

  /// Notifies all attached observers of the current selection value.
  ///
  /// This method is called automatically when the [value] is set to a new
  /// value, but can also be called manually to force a notification.
  ///
  /// [viewId]: The id of the view for which observers should be notified. It
  /// defaults to the global selection.
  void notify([String viewId = globalSelectionId]) {
    if (_observers.containsKey(viewId)) {
      final observers = _observers[viewId];
      for (final observer in observers!) {
        observer.update();
      }
    }
  }
}
