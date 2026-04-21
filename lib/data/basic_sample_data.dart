/// This file provides sample data for the tree structure in the Tracee application.
/// This data is used for development and testing purposes.
library;

import 'package:latlong2/latlong.dart';
import 'package:stager_platform/tree/tree.dart';

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
    id: 'meadowview',
    name: 'Meadowview Research Farm',
    initialProperties: {
      // Approximate center of Meadowview Research Farm
      'latitude': TypedValue<double>(36.73444),
      'longitude': TypedValue<double>(-81.86052),
    },
  );

  final planting2025 = ConcreteTreeNode(
    id: 'planting_2025',
    name: '2025 Planting',
    initialProperties: {
      // Location of the 2025 planting area
      'latitude': TypedValue<double>(36.73442),
      'longitude': TypedValue<double>(-81.86052),
      // Location of the 2025 planting area
      'outline': TypedValue<List<Map<String, TypedValue<double>>>>([
        // Define a rectangular outline around the planting area
        {'latitude': TypedValue<double>(36.73445), 'longitude': TypedValue<double>(-81.86050)}, // Top-left
        {'latitude': TypedValue<double>(36.73445), 'longitude': TypedValue<double>(-81.86060)}, // Top-right
        {'latitude': TypedValue<double>(36.73438), 'longitude': TypedValue<double>(-81.86060)}, // Bottom-right
        {'latitude': TypedValue<double>(36.73438), 'longitude': TypedValue<double>(-81.86050)}, // Bottom-left
      ]),
    },
  );

  final row1 = ConcreteTreeNode(
    id: 'row_1',
    name: 'Row 1',
    initialProperties: {
      // Start of Row 1
      'latitude': TypedValue<double>(36.73441),
      'longitude': TypedValue<double>(-81.86052),
    },
  );
  row1.addChild(ConcreteLeafNode(
      id: 'tree_1',
      name: 'Tree 1',
      initialProperties: {
        'latitude': TypedValue<double>(36.73441),
        'longitude': TypedValue<double>(-81.86053),
        'species': TypedValue<String>('American Chestnut'),
        'age': TypedValue<int>(1),
        'health': TypedValue<String>('Good'),
      }));
  row1.addChild(ConcreteLeafNode(
      id: 'tree_2',
      name: 'Tree 2',
      initialProperties: {
        'latitude': TypedValue<double>(36.73441),
        'longitude': TypedValue<double>(-81.86054),
        'species': TypedValue<String>('American Chestnut'),
        'age': TypedValue<int>(1),
        'health': TypedValue<String>('Good'),
      }));
  row1.addChild(ConcreteLeafNode(
      id: 'tree_3',
      name: 'Tree 3',
      initialProperties: {
        'latitude': TypedValue<double>(36.73441),
        'longitude': TypedValue<double>(-81.86055),
        'species': TypedValue<String>('American Chestnut'),
        'age': TypedValue<int>(1),
        'health': TypedValue<String>('Fair'),
      }));

  final row2 = ConcreteTreeNode(
    id: 'row_2',
    name: 'Row 2',
    initialProperties: {
      // Start of Row 2
      'latitude': TypedValue<double>(36.73440),
      'longitude': TypedValue<double>(-81.86052),
    },
  );
  row2.addChild(ConcreteLeafNode(
      id: 'tree_4',
      name: 'Tree 4',
      initialProperties: {
        'latitude': TypedValue<double>(36.73440),
        'longitude': TypedValue<double>(-81.86056),
        'species': TypedValue<String>('American Chestnut'),
        'age': TypedValue<int>(1),
        'health': TypedValue<String>('Good'),
      }));
  row2.addChild(ConcreteLeafNode(
      id: 'tree_5',
      name: 'Tree 5',
      initialProperties: {
        'latitude': TypedValue<double>(36.73440),
        'longitude': TypedValue<double>(-81.86057),
        'species': TypedValue<String>('American Chestnut'),
        'age': TypedValue<int>(1),
        'health': TypedValue<String>('Poor'),
      }));
  row2.addChild(ConcreteLeafNode(
      id: 'tree_6',
      name: 'Tree 6',
      initialProperties: {
        'latitude': TypedValue<double>(36.73440),
        'longitude': TypedValue<double>(-81.86059),
        'species': TypedValue<String>('American Chestnut'),
        'age': TypedValue<int>(1),
        'health': TypedValue<String>('Good'),
      }));

  planting2025.addChild(row1);
  planting2025.addChild(row2);

  final accessRoad = ConcreteLeafNode(
    id: 'access_road',
    name: 'Access Road',
    initialProperties: {
      // Location of an access road
      'latitude': TypedValue<double>(36.73408),
      'longitude': TypedValue<double>(-81.86114),
      'type': TypedValue<String>('gravel'),
      'length_m': TypedValue<double>(500.0),
    },
  );

  meadowview.addChild(planting2025);
  meadowview.addChild(accessRoad);

  final urbanPark = ConcreteTreeNode(
    id: 'urban_park',
    name: 'Urban Chestnut Park',
    initialProperties: {
      // Approximate center of a park in Philadelphia
      'latitude': TypedValue<double>(39.95),
      'longitude': TypedValue<double>(-75.16),
    },
  );

  final sectionA = ConcreteTreeNode(
    id: 'section_a',
    name: 'Section A',
    initialProperties: {
      'latitude': TypedValue<double>(39.951),
      'longitude': TypedValue<double>(-75.161),
      'outline': TypedValue<List<Map<String, TypedValue<double>>>>([
        // Define a triangular outline for Section A
        {'latitude': TypedValue<double>(39.9512), 'longitude': TypedValue<double>(-75.1608)}, // Top
        {'latitude': TypedValue<double>(39.9508), 'longitude': TypedValue<double>(-75.1615)}, // Bottom-right
        {'latitude': TypedValue<double>(39.9508), 'longitude': TypedValue<double>(-75.1605)}, // Bottom-left
      ]),
    },
  );
  sectionA.addChild(ConcreteLeafNode(
      id: 'tree_urban_1',
      name: 'Urban Tree 1',
      initialProperties: {
        'latitude': TypedValue<double>(39.951),
        'longitude': TypedValue<double>(-75.161),
        'species': TypedValue<String>('Hybrid Chestnut'),
        'planted_year': TypedValue<int>(2010)
      }));
  sectionA.addChild(ConcreteLeafNode(
      id: 'tree_urban_2',
      name: 'Urban Tree 2',
      initialProperties: {
        'latitude': TypedValue<double>(39.951),
        'longitude': TypedValue<double>(-75.1615),
        'species': TypedValue<String>('American Chestnut'),
        'planted_year': TypedValue<int>(2012)
      }));

  final playground = ConcreteLeafNode(
    id: 'playground',
    name: 'Playground Area',
    initialProperties: {
      'latitude': TypedValue<double>(39.949),
      'longitude': TypedValue<double>(-75.162),
      'amenity': TypedValue<String>('playground'),
      'surface': TypedValue<String>('wood_chips'),
    },
  );

  urbanPark.addChild(sectionA);
  urbanPark.addChild(playground);

  final adanor = ConcreteTreeNode(
    id: 'adanor',
    name: 'Adanor - Maple Trees',
    initialProperties: {
      'latitude': TypedValue<double>(39.25000),
      'longitude': TypedValue<double>(-77.76200),
    },
  );

  final westGrove = ConcreteTreeNode(
    id: 'west_grove',
    name: 'West Grove',
    initialProperties: {
      'latitude': TypedValue<double>(39.25010),
      'longitude': TypedValue<double>(-77.76040),
    },
  );

  westGrove.addChild(ConcreteLeafNode(
      id: 'maple_1',
      name: 'Maple 1',
      initialProperties: {
        'latitude': TypedValue<double>(39.249890),
        'longitude': TypedValue<double>(-77.760150),
        'species': TypedValue<String>('Silver/Red Maple'),
        'health': TypedValue<String>('Good'),
      }));
  westGrove.addChild(ConcreteLeafNode(
      id: 'maple_2',
      name: 'Maple 2',
      initialProperties: {
        'latitude': TypedValue<double>(39.249930),
        'longitude': TypedValue<double>(-77.760410),
        'species': TypedValue<String>('Silver/Red Maple'),
        'health': TypedValue<String>('Good'),
      }));
  westGrove.addChild(ConcreteLeafNode(
      id: 'maple_3',
      name: 'Maple 3',
      initialProperties: {
        'latitude': TypedValue<double>(39.249900),
        'longitude': TypedValue<double>(-77.760620),
        'species': TypedValue<String>('Silver/Red Maple'),
        'health': TypedValue<String>('Good'),
      }));
  westGrove.addChild(ConcreteLeafNode(
      id: 'maple_4',
      name: 'Maple 4',
      initialProperties: {
        'latitude': TypedValue<double>(39.250090),
        'longitude': TypedValue<double>(-77.760680),
        'species': TypedValue<String>('Silver/Red Maple'),
        'health': TypedValue<String>('Good'),
      }));
  westGrove.addChild(ConcreteLeafNode(
      id: 'maple_5',
      name: 'Maple 5',
      initialProperties: {
        'latitude': TypedValue<double>(39.250180),
        'longitude': TypedValue<double>(-77.760620),
        'species': TypedValue<String>('Silver/Red Maple'),
        'health': TypedValue<String>('Good'),
      }));
  westGrove.addChild(ConcreteLeafNode(
      id: 'maple_6',
      name: 'Maple 6',
      initialProperties: {
        'latitude': TypedValue<double>(39.250320),
        'longitude': TypedValue<double>(-77.760330),
        'species': TypedValue<String>('Silver/Red Maple'),
        'health': TypedValue<String>('Good'),
      }));
  westGrove.addChild(ConcreteLeafNode(
      id: 'maple_7',
      name: 'Maple 7',
      initialProperties: {
        'latitude': TypedValue<double>(39.250200),
        'longitude': TypedValue<double>(-77.760140),
        'species': TypedValue<String>('Silver/Red Maple'),
        'health': TypedValue<String>('Good'),
      }));
  westGrove.addChild(ConcreteLeafNode(
      id: 'maple_8',
      name: 'Maple 8',
      initialProperties: {
        'latitude': TypedValue<double>(39.250090),
        'longitude': TypedValue<double>(-77.760500),
        'species': TypedValue<String>('Silver/Red Maple'),
        'health': TypedValue<String>('Good'),
      }));
  westGrove.addChild(ConcreteLeafNode(
      id: 'maple_9',
      name: 'Maple 9',
      initialProperties: {
        'latitude': TypedValue<double>(39.250040),
        'longitude': TypedValue<double>(-77.760360),
        'species': TypedValue<String>('Silver/Red Maple'),
        'health': TypedValue<String>('Good'),
      }));

  final middleGrove = ConcreteTreeNode(
    id: 'middle_grove',
    name: 'Middle Grove',
    initialProperties: {
      'latitude': TypedValue<double>(39.25020),
      'longitude': TypedValue<double>(-77.76380),
    },
  );

  middleGrove.addChild(ConcreteLeafNode(
      id: 'chestnut_tubes',
      name: 'Chestnut tubes',
      initialProperties: {
        'latitude': TypedValue<double>(39.250030),
        'longitude': TypedValue<double>(-77.763860),
        'species': TypedValue<String>('LSA C. Dentata'),
        'health': TypedValue<String>('Unknown'),
      }));
  middleGrove.addChild(ConcreteLeafNode(
      id: 'maple_10',
      name: 'Maple 10',
      initialProperties: {
        'latitude': TypedValue<double>(39.250220),
        'longitude': TypedValue<double>(-77.763810),
        'species': TypedValue<String>('Silver/Red Maple'),
        'health': TypedValue<String>('Good'),
      }));
  middleGrove.addChild(ConcreteLeafNode(
      id: 'maple_11',
      name: 'Maple 11',
      initialProperties: {
        'latitude': TypedValue<double>(39.250320),
        'longitude': TypedValue<double>(-77.763750),
        'species': TypedValue<String>('Silver/Red Maple'),
        'health': TypedValue<String>('Good'),
      }));

  adanor.addChild(westGrove);
  adanor.addChild(middleGrove);

  final johnsCreek = ConcreteTreeNode(
    id: 'johns_creek',
    name: 'Johns Creek',
    initialProperties: {
      'latitude': TypedValue<double>(37.380000),
      'longitude': TypedValue<double>(-80.427600),
    },
  );

  const tacfSpecies = TypedValue<String>('TACF B3F3 C. Dentata x Mollisima');

  johnsCreek.addChild(ConcreteLeafNode(
      id: 'base_camp',
      name: 'Base camp',
      initialProperties: {'latitude': TypedValue<double>(37.379040), 'longitude': TypedValue<double>(-80.427570)}));
  johnsCreek.addChild(ConcreteLeafNode(
      id: '641',
      name: '641',
      initialProperties: {
        'latitude': TypedValue<double>(37.379630),
        'longitude': TypedValue<double>(-80.427530),
        'species': tacfSpecies
      }));
  johnsCreek.addChild(ConcreteLeafNode(
      id: '640',
      name: '640',
      initialProperties: {
        'latitude': TypedValue<double>(37.379640),
        'longitude': TypedValue<double>(-80.427540),
        'species': tacfSpecies
      }));
  johnsCreek.addChild(ConcreteLeafNode(
      id: '589',
      name: '589',
      initialProperties: {
        'latitude': TypedValue<double>(37.379700),
        'longitude': TypedValue<double>(-80.427580),
        'species': tacfSpecies
      }));
  johnsCreek.addChild(ConcreteLeafNode(
      id: '529',
      name: '529',
      initialProperties: {
        'latitude': TypedValue<double>(37.380090),
        'longitude': TypedValue<double>(-80.427670),
        'species': tacfSpecies
      }));
  johnsCreek.addChild(ConcreteLeafNode(
      id: '528',
      name: '528',
      initialProperties: {
        'latitude': TypedValue<double>(37.380040),
        'longitude': TypedValue<double>(-80.427650),
        'species': tacfSpecies
      }));
  johnsCreek.addChild(ConcreteLeafNode(
      id: '573',
      name: '573',
      initialProperties: {
        'latitude': TypedValue<double>(37.380190),
        'longitude': TypedValue<double>(-80.427620),
        'species': tacfSpecies
      }));
  johnsCreek.addChild(ConcreteLeafNode(
      id: '565',
      name: '565',
      initialProperties: {
        'latitude': TypedValue<double>(37.380480),
        'longitude': TypedValue<double>(-80.427640),
        'species': tacfSpecies
      }));
  johnsCreek.addChild(ConcreteLeafNode(
      id: 'pole_949',
      name: 'Pole 949 (near 553)',
      initialProperties: {'latitude': TypedValue<double>(37.382420), 'longitude': TypedValue<double>(-80.427630)}));
  johnsCreek.addChild(ConcreteLeafNode(
      id: '307',
      name: '307',
      initialProperties: {
        'latitude': TypedValue<double>(37.382130),
        'longitude': TypedValue<double>(-80.427790),
        'species': tacfSpecies
      }));
  johnsCreek.addChild(ConcreteLeafNode(
      id: '19',
      name: '19',
      initialProperties: {
        'latitude': TypedValue<double>(37.381090),
        'longitude': TypedValue<double>(-80.428150),
        'species': tacfSpecies
      }));

  final skyMeadows = ConcreteTreeNode(
    id: 'sky_meadows',
    name: 'Sky Meadows',
    initialProperties: {
      'latitude': TypedValue<double>(38.9908317),
      'longitude': TypedValue<double>(-77.9661061),
    },
  );

  final skyMeadowsTestPolygon = KMLPolygonNode(
      id: 'P1',
      name: 'testPoly',
      outline: [
        const LatLng(38.99100, -77.96610),
        const LatLng(38.99075, -77.96632),
        const LatLng(38.99075, -77.9659)
      ],
      styleManager: KMLStyleManager());
  skyMeadows.addChild(skyMeadowsTestPolygon);

  final tacfPlanting = ConcreteTreeNode(
    id: 'tacf_planting',
    name: 'TACF Planting',
    initialProperties: {
      'latitude': TypedValue<double>(38.98924852060698),
      'longitude': TypedValue<double>(-77.96862560999737),
    },
  );

  tacfPlanting.addChild(ConcreteLeafNode(
      id: 'sky_meadows_tree_1',
      name: 'Sky Meadows Tree 1',
      initialProperties: {
        'latitude': TypedValue<double>(38.989033187855455),
        'longitude': TypedValue<double>(-77.96854440131268),
        'species': tacfSpecies,
        'health': TypedValue<String>('Good'),
      }));

  skyMeadows.addChild(tacfPlanting);

  final knoxville = ConcreteTreeNode(
    id: 'knoxville',
    name: 'City of Knoxville',
    initialProperties: {
      'latitude': TypedValue<double>(35.96045020327116),
      'longitude': TypedValue<double>(-83.91684780417694),
    },
  );

  final cityCountyLawn = KMLPolygonNode(
    id: 'city_county_lawn',
    name: 'City County Bldg Lawn',
    outline: [
      const LatLng(35.96086794510828, -83.91823505202085),
      const LatLng(35.960200675079406, -83.91786155192725),
      const LatLng(35.960571649004365, -83.91687795207916),
      const LatLng(35.960731841751425, -83.9169568186328),
      const LatLng(35.9605836935831, -83.91734519920821),
      const LatLng(35.960745090761066, -83.91743745819547),
      const LatLng(35.960798086777416, -83.91744787453274),
      const LatLng(35.960879989641846, -83.91744489843639),
      const LatLng(35.960973936940526, -83.91740323308728),
      const LatLng(35.96103415950911, -83.91734222311183),
      const LatLng(35.96110401763115, -83.9172008585346),
      const LatLng(35.96125216482341, -83.9172886533773),
    ],
    styleManager: KMLStyleManager(),
  );
  knoxville.addChild(cityCountyLawn);

  knoxville.addChild(ConcreteLeafNode(
      id: 'knox_t1',
      name: 'T1',
      initialProperties: {
        'latitude': TypedValue<double>(35.96032717171685),
        'longitude': TypedValue<double>(-83.9177178521555)
      }));
  knoxville.addChild(ConcreteLeafNode(
      id: 'knox_t2',
      name: 'T2',
      initialProperties: {
        'latitude': TypedValue<double>(35.96086993079152),
        'longitude': TypedValue<double>(-83.917873420264)
      }));
  knoxville.addChild(ConcreteLeafNode(
      id: 'knox_t3',
      name: 'T3',
      initialProperties: {
        'latitude': TypedValue<double>(35.96086558873374),
        'longitude': TypedValue<double>(-83.91851715036813),
        'species': TypedValue<String>('Oak'),
        'health': TypedValue<String>('Good'),
      }));

  final thirdCreekGreenway = ConcreteCompositeNode(id: 'tcg', name: 'Third Creek Greenway',
    initialProperties: {
      'latitude': TypedValue<double>(35.94845624432757),
      'longitude': TypedValue<double>(-83.966116113303)});
  final thirdCreekGreenwayOutline = KMLPolygonNode(
    id: 'third_creek_greenway',
    name: 'Third Creek Greenway',
    outline: [
      const LatLng(35.951011092447814, -83.96930241434303),
      const LatLng(35.9483579792697, -83.96835411045664),
      const LatLng(35.9477499616183, -83.96868791342465),
      const LatLng(35.94743673857797, -83.9689989570994),
      const LatLng(35.94705595595465, -83.97108522564947),
      const LatLng(35.94533012783368, -83.97019761321181),
      const LatLng(35.950986526993695, -83.95808208275918),
      const LatLng(35.95218408399086, -83.9581351877768),
      const LatLng(35.948585216988796, -83.96570644600583),
      const LatLng(35.95168663944238, -83.96751201660554),
    ],
    styleManager: KMLStyleManager(),
  );
  thirdCreekGreenway.addChild(thirdCreekGreenwayOutline);
  knoxville.addChild(thirdCreekGreenway);

  return [meadowview, urbanPark, adanor, johnsCreek, skyMeadows, knoxville];
}
