// lib/stager/site_state_observer.dart
import 'package:stager/site_state.dart';

/// An interface for observers that are interested in changes to [SiteState].
abstract class SiteStateObserver {
  /// Called when the observed [SiteState] instance has been updated.
  void update(SiteState siteState);
}
