import 'package:flutter_test/flutter_test.dart';
import 'package:stager_platform/persistence/csv_to_gpx.dart';

void main() {
  group('CsvToGpxConverter', () {
    test('converts CSV to GPX and filters rows without labels', () {
      // Initialize the converter and provide the sample CSV data with some 
      // labeled and unlabeled rows.
      final converter = CsvToGpxConverter();
      const csvData = '''row,column,label,latitude,longitude
1,5,,57.3788238,60.42885559
1,6,,57.3789007,60.42883306
1,7,sw corner,57.37897711,60.42881078
1,39,dead deserpentined,57.3811651,60.42822717''';

      // Perform the conversion to GPX.
      final result = converter.convert(csvData);

      // Verify that the resulting GPX string contains exactly the waypoints 
      // that had labels and that those labels are correctly mapped to names.
      expect(result, contains('<wpt lat="57.37897711" lon="60.42881078">'));
      expect(result, contains('<name>sw corner</name>'));
      expect(result, contains('<wpt lat="57.3811651" lon="60.42822717">'));
      expect(result, contains('<name>dead deserpentined</name>'));
      
      // Verify that waypoints without labels are not present.
      expect(result, isNot(contains('57.3788238')));
      expect(result, isNot(contains('57.3789007')));
    });

    test('handles CRLF line endings and trailing whitespace in headers', () {
      // Initialize the converter with a CSV string that specifically uses 
      // Windows-style CRLF endings (\r\n). This simulates a file read that 
      // might leave a \r on the last header field.
      final converter = CsvToGpxConverter();
      const csvData = 'label,latitude,longitude\r\n'
          'test label,57.38,60.42\r\n';

      // Perform the conversion. This should NOT throw an ArgumentError if 
      // trimming is implemented correctly.
      final result = converter.convert(csvData);

      // Verify that the waypoint was successfully created.
      expect(result, contains('<wpt lat="57.38" lon="60.42">'));
      expect(result, contains('<name>test label</name>'));
    });

    test('throws ArgumentError if required headers are missing', () {
      // Initialize the converter and provide CSV data with missing headers.
      final converter = CsvToGpxConverter();
      const invalidCsv = 'row,column,name,lat,lon\n1,2,test,57.0,60.0';

      // Verify that the converter throws an ArgumentError when it cannot 
      // find the required column names.
      expect(() => converter.convert(invalidCsv), throwsArgumentError);
    });
  });
}
