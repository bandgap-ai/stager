import 'package:logger/logger.dart';
import 'package:stager_platform/builders/stager_context.dart';

/// A generic builder class for creating objects of type T.
///
/// This class is primarily meant to be used via Stager's source generation
/// where it is picked up via an annotation and registered "dynamically."
class BasicBuilder {

  /// The builder name. It should be closely related to the object that will be
  /// built.
  final String name;

  /// Constructor. Clients must name their builders to register them.
  const BasicBuilder({required this.name});
}

/// This is a handler for building BasicBuilders. This uses delegation
/// to create an instance of the builder based on properties provided by the
/// client during annotation.
class BasicBuilderHandler<T> {
  final Logger logger = Logger();

  /// The builder name. It should be closely related to the object that will be
  /// built.
  final String name;

  /// The factory function delegated to create the actual instance.
  final T Function(StagerContext context) _factoryDelegate;

  /// Get the type.
  Type get type => T;

  /// Constructor taking the required name and the delegation function.
  BasicBuilderHandler({
    required this.name,
    required T Function(StagerContext context) delegate,
  }) : _factoryDelegate = delegate;

  /// The main lifecycle entry point for building an object.
  T build([StagerContext context = const StagerContext({})]) {
    logger.f('Building type $type with builder: $name');

    // Create the instance via the delegated factory function
    final builtObject = _factoryDelegate(context);

    return builtObject;
  }
}