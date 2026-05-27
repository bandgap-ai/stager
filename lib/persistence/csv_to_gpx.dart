import 'package:xml/xml.dart';

/// A utility class for converting CSV data to GPX format.
///
/// This class provides a method to transform CSV content into a standard GPX
/// waypoint structure.
class CsvToGpxConverter {
  /// Converts a [csvContent] string to a GPX format string.
  ///
  /// The [csvContent] must have a header row containing 'label', 'latitude',
  /// and 'longitude'.
  /// Rows without a 'label' value are skipped.
  ///
  /// Returns a GPX string representing the waypoints in the CSV.
  ///
  /// Throws an [ArgumentError] if the required headers are missing.
  String convert(String csvContent) {
    final List<String> lines = csvContent.split('\n');
    late final String gpxOutput;

    // Evaluate the most likely condition first: non-empty CSV.
    if (lines.isNotEmpty && lines[0].trim().isNotEmpty) {
      // Trim the header line and each column name to handle potential \r
      // characters from file reading or incidental whitespace.
      final List<String> header =
          lines[0].trim().split(',').map((e) => e.trim()).toList();

      final int labelIndex = header.indexOf('label');
      final int latIndex = header.indexOf('latitude');
      final int lonIndex = header.indexOf('longitude');

      // Check if all required headers are present.
      if (labelIndex != -1 && latIndex != -1 && lonIndex != -1) {
        final builder = XmlBuilder();
        builder.processing('xml', 'version="1.0" encoding="UTF-8"');
        builder.element('gpx', attributes: {
          'version': '1.1',
          'creator': 'Stager Platform',
          'xmlns': 'http://www.topografix.com/GPX/1/1',
        }, nest: () {
          // Iterate through the rows starting after the header.
          for (int i = 1; i < lines.length; i++) {
            final String line = lines[i].trim();

            // Skip empty lines.
            if (line.isNotEmpty) {
              final List<String> columns = line.split(',');

              // Ensure we have enough columns for the indices we found.
              final int maxIndex = [labelIndex, latIndex, lonIndex]
                  .reduce((a, b) => a > b ? a : b);

              if (columns.length > maxIndex) {
                final String label = columns[labelIndex].trim();
                final String lat = columns[latIndex].trim();
                final String lon = columns[lonIndex].trim();

                // Only include the point if a label is present.
                if (label.isNotEmpty) {
                  builder.element('wpt', attributes: {
                    'lat': lat,
                    'lon': lon,
                  }, nest: () {
                    builder.element('name', nest: label);
                  });
                }
              }
            }
          }
        });
        gpxOutput = builder.buildDocument().toXmlString(pretty: true);
      } else {
        throw ArgumentError(
          'CSV header must contain "label", "latitude", and "longitude".',
        );
      }
    } else {
      gpxOutput = '';
    }

    return gpxOutput;
  }
}
