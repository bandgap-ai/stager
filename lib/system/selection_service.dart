import 'package:logger/logger.dart';

import 'selection_observer.dart';
import 'selection.dart';

class SelectionService {

  /// The id for the global selection.
  static const String globalSelectionId = "global";

  /// Logger
  final Logger logger = Logger();

  /// The current selections.
  final Map<String, Selection<dynamic>> _selections = {};

  late Selection<dynamic> _selection;

  // I think one way to do this that is in keeping with the no-null implementation
  // and Dart's preference for default arguments instead of overloads is to put
  // everything in a map with view ids. The global selection would be stored in
  // the "global" slot and any selections stored for specific views would be
  // stored in their own slots. This means that clear and isSet have to take
  // view ids too.

  /// Checks to see if a global selection is set.
  ///
  /// Returns true if a global selection is set, false otherwise.
  bool isSet([String viewId = globalSelectionId]) {
    return false;
  }

  /// Clears the current selection in the selection service. Be careful if you
  /// use this.
  void clear([String viewId = globalSelectionId]) {

  }

  set selection(Selection<dynamic> selection) {
    _selection = selection;
  }

  void setSelectionForView(Selection<dynamic> selection, [String viewId = globalSelectionId]) {
    _selections[viewId] = selection;
  }

  Selection<dynamic> get selection => _selection;

  Selection<dynamic> getSelectionForView([String viewId = globalSelectionId]) {

    // FIXME! Check null
    return _selections[viewId]!;
  }

  /// Attaches an [observer] to listen for selection changes.
  ///
  /// The observer will be notified immediately of the current selection value
  /// upon attachment, and subsequently whenever the selection changes.
  void attach(SelectionObserver observer) {
    //_observers.add(observer);
  }

  /// Detaches an [observer] to stop it from receiving updates.
  ///
  /// If the observer is not in the list, this method has no effect.
  void detach(SelectionObserver observer) {
    //_observers.remove(observer);
  }

  /// Notifies all attached observers of the current selection value.
  ///
  /// This method is called automatically when the [value] is set to a new
  /// value, but can also be called manually to force a notification.
  void notify() {
    //for (final observer in _observers) {
     // observer.update(_value);
   // }
  }

}