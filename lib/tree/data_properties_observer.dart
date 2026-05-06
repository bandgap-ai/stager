import 'package:stager_platform/tree/data_properties.dart';
import 'package:stager_platform/tree/node_observer.dart';

/// An interface for observers that are interested in changes to [DataProperties].
///
/// Implementations of this interface will be notified when the data properties
/// of a node change, such as when binary attachments are added or removed.
abstract class DataPropertiesObserver implements NodeObserver<DataProperties> {
  /// Called when the observed [DataProperties] instance has been updated.
  ///
  /// [data]: The [DataProperties] instance that has been updated.
  @override
  void update(DataProperties data);
}
