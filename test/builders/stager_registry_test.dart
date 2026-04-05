import 'package:flutter_test/flutter_test.dart';
import 'package:stager_platform/builders/basic_builder.dart';
import 'package:stager_platform/builders/stager_context.dart';
import 'package:stager_platform/mapping/kml_icon.dart';
import 'package:stager_platform/stager_registry.g.dart';

void main() {
  group("Basic linkage and instantiation tests", (){
    test("check registry for KMLIcon", () {
      // Check that the registry contains the KMLIcon builder
      expect(stagerRegistry.containsKey(KMLIcon), true);
      // Try to build one
      BasicBuilderHandler<KMLIcon> handler = stagerRegistry[KMLIcon]! as BasicBuilderHandler<KMLIcon>;
      String href = "https://example.com/test_kml_icon.png";
      StagerContext context = StagerContext({"href":href});
      KMLIcon icon = handler.build(context);
      // Check that the href is correct
      expect(icon, isNotNull);
      expect(icon.href, href);
    });
  });
}