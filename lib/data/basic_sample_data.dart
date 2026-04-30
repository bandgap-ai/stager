/// This file provides sample data for the tree structure in the Tracee application.
/// This data is used for development and testing purposes.
library;

import 'package:stager_platform/tree/tree.dart';
import 'package:stager_platform/system/point.dart';
import '../mapping/nodes/kml_polygon_node.dart';
import '../mapping/style/kml_style_manager.dart';
import '../system/typed_value.dart';

/// A list of [TreeNode]s representing sample sites for testing and development.
///
/// Each site simulates a farm or park with various site locations,
/// features, and objects, including chestnut trees.
/// Each node includes an ID, name, and optional geographical position.
final List<TreeNode> sampleSites = _buildSampleSites();

List<TreeNode> _buildSampleSites() {
  final meadowview = ConcreteTreeNode(
    name: 'Meadowview Research Farm',
  );
  // Approximate center of Meadowview Research Farm
  meadowview.position = Point(coords: [-81.86052, 36.73444]);

  final planting2025 = ConcreteCompositeNode(
    name: '2025 Planting',
  );
  // Location of the 2025 planting area
  planting2025.position = Point(coords: [-81.86052, 36.73442]);

  final planting2025Outline = KMLPolygonNode(
    name: '2025 Planting Outline',
    outline: [
      Point(coords: [-81.86050, 36.73445]),
      Point(coords: [-81.86060, 36.73445]),
      Point(coords: [-81.86060, 36.73438]),
      Point(coords: [-81.86050, 36.73438]),
    ],
    styleManager: KMLStyleManager(),
  );
  planting2025.addChild(planting2025Outline);

  final row1 = ConcreteCompositeNode(
    name: 'Row 1',
  );
  // Start of Row 1
  row1.position = Point(coords: [-81.86052, 36.73441]);

  row1.addChild(ConcreteLeafNode(
      name: 'Tree 1',
      initialProperties: {
        'species': TypedValue<String>('American Chestnut'),
        'age': TypedValue<int>(1),
        'health': TypedValue<String>('Good'),
      })
    ..position = Point(coords: [-81.86053, 36.73441]));

  row1.addChild(ConcreteLeafNode(
      name: 'Tree 2',
      initialProperties: {
        'species': TypedValue<String>('American Chestnut'),
        'age': TypedValue<int>(1),
        'health': TypedValue<String>('Good'),
      })
    ..position = Point(coords: [-81.86054, 36.73441]));

  row1.addChild(ConcreteLeafNode(
      name: 'Tree 3',
      initialProperties: {
        'species': TypedValue<String>('American Chestnut'),
        'age': TypedValue<int>(1),
        'health': TypedValue<String>('Fair'),
      })
    ..position = Point(coords: [-81.86055, 36.73441]));

  final row2 = ConcreteCompositeNode(
    name: 'Row 2',
  );
  // Start of Row 2
  row2.position = Point(coords: [-81.86052, 36.73440]);

  row2.addChild(ConcreteLeafNode(
      name: 'Tree 4',
      initialProperties: {
        'species': TypedValue<String>('American Chestnut'),
        'age': TypedValue<int>(1),
        'health': TypedValue<String>('Good'),
      })
    ..position = Point(coords: [-81.86056, 36.73440]));

  row2.addChild(ConcreteLeafNode(
      name: 'Tree 5',
      initialProperties: {
        'species': TypedValue<String>('American Chestnut'),
        'age': TypedValue<int>(1),
        'health': TypedValue<String>('Poor'),
      })
    ..position = Point(coords: [-81.86057, 36.73440]));

  row2.addChild(ConcreteLeafNode(
      name: 'Tree 6',
      initialProperties: {
        'species': TypedValue<String>('American Chestnut'),
        'age': TypedValue<int>(1),
        'health': TypedValue<String>('Good'),
      })
    ..position = Point(coords: [-81.86059, 36.73440]));

  planting2025.addChild(row1);
  planting2025.addChild(row2);

  final accessRoad = ConcreteLeafNode(
    name: 'Access Road',
    initialProperties: {
      'type': TypedValue<String>('gravel'),
      'length_m': TypedValue<double>(500.0),
    },
  )..position = Point(coords: [-81.86114, 36.73408]);

  meadowview.addChild(planting2025);
  meadowview.addChild(accessRoad);

  final urbanPark = ConcreteTreeNode(
    name: 'Urban Chestnut Park',
  );
  // Approximate center of a park in Philadelphia
  urbanPark.position = Point(coords: [-75.16, 39.95]);

  final sectionA = ConcreteCompositeNode(
    name: 'Section A',
  );
  sectionA.position = Point(coords: [-75.161, 39.951]);

  final sectionAOutline = KMLPolygonNode(
    name: 'Section A Outline',
    outline: [
      Point(coords: [-75.1608, 39.9512]),
      Point(coords: [-75.1615, 39.9508]),
      Point(coords: [-75.1605, 39.9508]),
    ],
    styleManager: KMLStyleManager(),
  );
  sectionA.addChild(sectionAOutline);

  sectionA.addChild(ConcreteLeafNode(
      name: 'Urban Tree 1',
      initialProperties: {
        'species': TypedValue<String>('Hybrid Chestnut'),
        'planted_year': TypedValue<int>(2010)
      })
    ..position = Point(coords: [-75.161, 39.951]));

  sectionA.addChild(ConcreteLeafNode(
      name: 'Urban Tree 2',
      initialProperties: {
        'species': TypedValue<String>('American Chestnut'),
        'planted_year': TypedValue<int>(2012)
      })
    ..position = Point(coords: [-75.1615, 39.951]));

  final playground = ConcreteLeafNode(
    name: 'Playground Area',
    initialProperties: {
      'amenity': TypedValue<String>('playground'),
      'surface': TypedValue<String>('wood_chips'),
    },
  )..position = Point(coords: [-75.162, 39.949]);

  urbanPark.addChild(sectionA);
  urbanPark.addChild(playground);

  final adanor = ConcreteTreeNode(
    name: 'Adanor - Maple Trees',
  );
  adanor.position = Point(coords: [-77.76200, 39.25000]);

  final westGrove = ConcreteCompositeNode(
    name: 'West Grove',
  );
  westGrove.position = Point(coords: [-77.76040, 39.25010]);

  westGrove.addChild(ConcreteLeafNode(
      name: 'Maple 1',
      initialProperties: {
        'species': TypedValue<String>('Silver/Red Maple'),
        'health': TypedValue<String>('Good'),
      })
    ..position = Point(coords: [-77.760150, 39.249890]));

  westGrove.addChild(ConcreteLeafNode(
      name: 'Maple 2',
      initialProperties: {
        'species': TypedValue<String>('Silver/Red Maple'),
        'health': TypedValue<String>('Good'),
      })
    ..position = Point(coords: [-77.760410, 39.249930]));

  westGrove.addChild(ConcreteLeafNode(
      name: 'Maple 3',
      initialProperties: {
        'species': TypedValue<String>('Silver/Red Maple'),
        'health': TypedValue<String>('Good'),
      })
    ..position = Point(coords: [-77.760620, 39.249900]));

  westGrove.addChild(ConcreteLeafNode(
      name: 'Maple 4',
      initialProperties: {
        'species': TypedValue<String>('Silver/Red Maple'),
        'health': TypedValue<String>('Good'),
      })
    ..position = Point(coords: [-77.760680, 39.250090]));

  westGrove.addChild(ConcreteLeafNode(
      name: 'Maple 5',
      initialProperties: {
        'species': TypedValue<String>('Silver/Red Maple'),
        'health': TypedValue<String>('Good'),
      })
    ..position = Point(coords: [-77.760620, 39.250180]));

  westGrove.addChild(ConcreteLeafNode(
      name: 'Maple 6',
      initialProperties: {
        'species': TypedValue<String>('Silver/Red Maple'),
        'health': TypedValue<String>('Good'),
      })
    ..position = Point(coords: [-77.760330, 39.250320]));

  westGrove.addChild(ConcreteLeafNode(
      name: 'Maple 7',
      initialProperties: {
        'species': TypedValue<String>('Silver/Red Maple'),
        'health': TypedValue<String>('Good'),
      })
    ..position = Point(coords: [-77.760140, 39.250200]));

  westGrove.addChild(ConcreteLeafNode(
      name: 'Maple 8',
      initialProperties: {
        'species': TypedValue<String>('Silver/Red Maple'),
        'health': TypedValue<String>('Good'),
      })
    ..position = Point(coords: [-77.760500, 39.250090]));

  westGrove.addChild(ConcreteLeafNode(
      name: 'Maple 9',
      initialProperties: {
        'species': TypedValue<String>('Silver/Red Maple'),
        'health': TypedValue<String>('Good'),
      })
    ..position = Point(coords: [-77.760360, 39.250040]));

  final middleGrove = ConcreteCompositeNode(
    name: 'Middle Grove',
  );
  middleGrove.position = Point(coords: [-77.76380, 39.25020]);

  middleGrove.addChild(ConcreteLeafNode(
      name: 'Chestnut tubes',
      initialProperties: {
        'species': TypedValue<String>('LSA C. Dentata'),
        'health': TypedValue<String>('Unknown'),
      })
    ..position = Point(coords: [-77.763860, 39.250030]));

  middleGrove.addChild(ConcreteLeafNode(
      name: 'Maple 10',
      initialProperties: {
        'species': TypedValue<String>('Silver/Red Maple'),
        'health': TypedValue<String>('Good'),
      })
    ..position = Point(coords: [-77.763810, 39.250220]));

  middleGrove.addChild(ConcreteLeafNode(
      name: 'Maple 11',
      initialProperties: {
        'species': TypedValue<String>('Silver/Red Maple'),
        'health': TypedValue<String>('Good'),
      })
    ..position = Point(coords: [-77.763750, 39.250320]));

  adanor.addChild(westGrove);
  adanor.addChild(middleGrove);

  final johnsCreek = ConcreteTreeNode(
    name: 'Johns Creek',
  );
  johnsCreek.position = Point(coords: [-80.427600, 37.380000]);

  const tacfSpecies = TypedValue<String>('TACF B3F3 C. Dentata x Mollisima');

  johnsCreek.addChild(ConcreteLeafNode(
      name: 'Base camp',
  )..position = Point(coords: [-80.427570, 37.379040]));

  johnsCreek.addChild(ConcreteLeafNode(
      name: '641',
      initialProperties: {
        'species': tacfSpecies
      })
    ..position = Point(coords: [-80.427530, 37.379630]));

  johnsCreek.addChild(ConcreteLeafNode(
      name: '640',
      initialProperties: {
        'species': tacfSpecies
      })
    ..position = Point(coords: [-80.427540, 37.379640]));

  johnsCreek.addChild(ConcreteLeafNode(
      name: '589',
      initialProperties: {
        'species': tacfSpecies
      })
    ..position = Point(coords: [-80.427580, 37.379700]));

  johnsCreek.addChild(ConcreteLeafNode(
      name: '529',
      initialProperties: {
        'species': tacfSpecies
      })
    ..position = Point(coords: [-80.427670, 37.380090]));

  johnsCreek.addChild(ConcreteLeafNode(
      name: '528',
      initialProperties: {
        'species': tacfSpecies
      })
    ..position = Point(coords: [-80.427650, 37.380040]));

  johnsCreek.addChild(ConcreteLeafNode(
      name: '573',
      initialProperties: {
        'species': tacfSpecies
      })
    ..position = Point(coords: [-80.427620, 37.380190]));

  johnsCreek.addChild(ConcreteLeafNode(
      name: '565',
      initialProperties: {
        'species': tacfSpecies
      })
    ..position = Point(coords: [-80.427640, 37.380480]));

  johnsCreek.addChild(ConcreteLeafNode(
      name: 'Pole 949 (near 553)',
  )..position = Point(coords: [-80.427630, 37.382420]));

  johnsCreek.addChild(ConcreteLeafNode(
      name: '307',
      initialProperties: {
        'species': tacfSpecies
      })
    ..position = Point(coords: [-80.427790, 37.382130]));

  johnsCreek.addChild(ConcreteLeafNode(
      name: '19',
      initialProperties: {
        'species': tacfSpecies
      })
    ..position = Point(coords: [-80.428150, 37.381090]));

  final skyMeadows = ConcreteTreeNode(
    name: 'Sky Meadows',
  );
  skyMeadows.position = Point(coords: [-77.9661061, 38.9908317]);

  final skyMeadowsTestPolygon = KMLPolygonNode(
      name: 'testPoly',
      outline: [
        Point(coords: [-77.96610, 38.99100]),
        Point(coords: [-77.96632, 38.99075]),
        Point(coords: [-77.9659, 38.99075])
      ],
      styleManager: KMLStyleManager());
  skyMeadows.addChild(skyMeadowsTestPolygon);

  final tacfPlanting = ConcreteCompositeNode(
    name: 'TACF Planting',
  );
  tacfPlanting.position = Point(coords: [-77.96862560999737, 38.98924852060698]);

  tacfPlanting.addChild(ConcreteLeafNode(
      name: 'Sky Meadows Tree 1',
      initialProperties: {
        'species': tacfSpecies,
        'health': TypedValue<String>('Good'),
      })
    ..position = Point(coords: [-77.96854440131268, 38.989033187855455]));

  skyMeadows.addChild(tacfPlanting);

  final knoxville = ConcreteTreeNode(
    name: 'City of Knoxville',
  );
  knoxville.position = Point(coords: [-83.91684780417694, 35.96045020327116]);

  final cityCountyLawn = KMLPolygonNode(
    name: 'City County Bldg Lawn',
    outline: [
      Point(coords: [-83.91823505202085, 35.96086794510828]),
      Point(coords: [-83.91786155192725, 35.960200675079406]),
      Point(coords: [-83.91687795207916, 35.960571649004365]),
      Point(coords: [-83.9169568186328, 35.960731841751425]),
      Point(coords: [-83.91734519920821, 35.9605836935831]),
      Point(coords: [-83.91743745819547, 35.960745090761066]),
      Point(coords: [-83.91744787453274, 35.960798086777416]),
      Point(coords: [-83.91744489843639, 35.960879989641846]),
      Point(coords: [-83.91740323308728, 35.960973936940526]),
      Point(coords: [-83.91734222311183, 35.96103415950911]),
      Point(coords: [-83.9172008585346, 35.96110401763115]),
      Point(coords: [-83.9172886533773, 35.96125216482341]),
    ],
    styleManager: KMLStyleManager(),
  );
  knoxville.addChild(cityCountyLawn);

  knoxville.addChild(ConcreteLeafNode(
      name: 'T1',
  )..position = Point(coords: [-83.9177178521555, 35.96032717171685]));

  knoxville.addChild(ConcreteLeafNode(
      name: 'T2',
  )..position = Point(coords: [-83.917873420264, 35.96086993079152]));

  knoxville.addChild(ConcreteLeafNode(
      name: 'T3',
      initialProperties: {
        'species': TypedValue<String>('Oak'),
        'health': TypedValue<String>('Good'),
      })
    ..position = Point(coords: [-83.91851715036813, 35.96086558873374]));

  final thirdCreekGreenway = ConcreteCompositeNode(name: 'Third Creek Greenway');
  thirdCreekGreenway.position = Point(coords: [-83.966116113303, 35.94845624432757]);

  final thirdCreekGreenwayOutline = KMLPolygonNode(
    name: 'Third Creek Greenway',
    outline: [
      Point(coords: [-83.96930241434303, 35.951011092447814]),
      Point(coords: [-83.96835411045664, 35.9483579792697]),
      Point(coords: [-83.96868791342465, 35.9477499616183]),
      Point(coords: [-83.9689989570994, 35.94743673857797]),
      Point(coords: [-83.97108522564947, 35.94705595595465]),
      Point(coords: [-83.97019761321181, 35.94533012783368]),
      Point(coords: [-83.95808208275918, 35.950986526993695]),
      Point(coords: [-83.9581351877768, 35.95218408399086]),
      Point(coords: [-83.96570644600583, 35.948585216988796]),
      Point(coords: [-83.96751201660554, 35.95168663944238]),
    ],
    styleManager: KMLStyleManager(),
  );
  thirdCreekGreenway.addChild(thirdCreekGreenwayOutline);
  knoxville.addChild(thirdCreekGreenway);

  return [meadowview, urbanPark, adanor, johnsCreek, skyMeadows, knoxville];
}
