// lib/stager/site_state_observer.dart
import 'package:stager/site_state.dart';
import 'package:stager/tree/node_observer.dart';

/// An interface for observers that are interested in changes to [SiteState].
abstract class SiteStateObserver implements NodeObserver<SiteState> {
  /// Called when the observed [SiteState] instance has been updated.
  @override
  void update(SiteState siteState);
}
