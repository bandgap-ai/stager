import 'package:stager/site_state.dart';
import 'package:stager/site_state_observer.dart';


/// This is a Mock [SiteStateObserver] for testing.
class MockSiteStateObserver implements SiteStateObserver {

  bool _updated = false;

  bool get updated => _updated;

  void reset() {
    _updated = false;
  }

  @override
  void update(SiteState siteState) {
    _updated = true;
  }
}