# The Stager Platform
[![pipeline status](https://gitlab.com/bandgap/stager-platform/stager/badges/main/pipeline.svg)](https://gitlab.com/bandgap/stager-platform/stager/-/commits/main)
[![coverage report](https://gitlab.com/bandgap/stager-platform/stager/badges/main/coverage.svg)](https://gitlab.com/bandgap/stager-platform/stager/-/commits/main)
[![SonarQube Cloud](https://sonarcloud.io/images/project_badges/sonarcloud-dark.svg)](https://sonarcloud.io/summary/new_code?id=bandgap_stager)

## Stager Widgets vs Editors

Stager distinguishes between widgets and editors. Any widget that edits a value is an editor and any widget that doesn't edit a value is just a normal widget. All editors are StatefulWidgets, and most widgets are StatelessWidgets.

The editors/standard_widgets.dart file defines a small set of useful widgets that can be created with handy builder functions. These functions are implemented in a factory in basic_widget_factory.dart.