import 'package:flutter_test/flutter_test.dart';
import 'package:stager_platform/builders/basic_builder.dart';
import 'package:stager_platform/system/registry.dart';
import 'package:stager_platform/system/stager_context.dart';
import 'package:stager_platform/mapping/kml_icon.dart';
import 'package:stager_platform/stager_registry.g.dart';
import 'package:stager_platform/system/point.dart';

void main() {
  group("Generated Registry Tests", (){
    test("check registry for KMLIcon", () {
      // Check that the registry contains the KMLIcon builder
      expect(stagerRegistryMap.containsKey(KMLIcon), true);
      // Try to build one
      BasicBuilderHandler<KMLIcon> handler = stagerRegistryMap[KMLIcon]! as BasicBuilderHandler<KMLIcon>;
      String href = "https://example.com/test_kml_icon.png";
      StagerContext context = StagerContext({"href":href});
      KMLIcon icon = handler.build(context);
      // Check that the href is correct
      expect(icon, isNotNull);
      expect(icon.href, href);
    });
  });

  group ("User-facing API Tests", () {
    test("Check build()", () {
      // Point should be in the registry, so give it a go.
      // First, create the map of parameters. We just need the name.
      Map<String, Object> map = {"coords" : [1.0,2.0,3.0]};
      Object point = buildObject("Point", map);
      expect(point.runtimeType, Point);
      expect((point as Point).coords, [1.0,2.0,3.0]);
    });

    test("Check build() exceptions", () {
      // "PandaCupCake" should not be in the registry, so give it a go.
      Map<String, Object> map = {};
      expect(() => buildObject("PandaCupCake", map),
          throwsA(isA<RegistryException>().having((e) => e.message,
          "message", contains("No builder registered for type: PandaCupCake"))));
    });
  });

}