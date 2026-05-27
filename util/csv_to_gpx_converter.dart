import 'dart:io';
import '../lib/persistence/csv_to_gpx.dart';

/// A command-line utility for converting CSV files to GPX format.
///
/// This utility reads a CSV file from the path provided as the first
/// command-line argument, converts its content to GPX format using
/// [CsvToGpxConverter], and prints the result to standard output.
///
/// Usage: `dart util/csv_to_gpx_converter.dart <input_file.csv>`
void main(List<String> args) {
  // Use the global exitCode from dart:io to manage process exit status.
  // The default is 0 (success).
  exitCode = 0;

  // Evaluate the most common "happy path" first: exactly one argument provided.
  if (args.length == 1) {
    final String filePath = args[0];
    final File file = File(filePath);

    // Verify file existence before attempting to read.
    if (file.existsSync()) {
      try {
        final String csvContent = file.readAsStringSync();
        final converter = CsvToGpxConverter();
        
        // Execute the conversion using the shared persistence logic.
        final String gpxOutput = converter.convert(csvContent);

        // Output the GPX XML to stdout for redirection or piping.
        stdout.write(gpxOutput);
      } catch (e) {
        // Log the error to stderr and set failure exit code.
        stderr.writeln('Error: An exception occurred while processing the file.');
        stderr.writeln(e);
        exitCode = 1;
      }
    } else {
      // Handle the case where the file path is invalid.
      stderr.writeln('Error: The specified file does not exist: $filePath');
      exitCode = 1;
    }
  } else {
    // Provide usage instructions if the CLI arguments are incorrect.
    stdout.writeln('Usage: dart util/csv_to_gpx_converter.dart <input_file.csv>');
    exitCode = 1;
  }
}
