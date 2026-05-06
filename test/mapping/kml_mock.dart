// test/helpers/kml_mock.dart
import 'dart:io';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

/// Registers a mock MethodChannel handler for the Stager native plugin.
///
/// The mock now checks that the `xmlPath` argument points to an existing file
/// on the file system before returning a success code. If the file does not
/// exist, it returns a non‑zero error code (1). This mimics a realistic native
/// implementation where the file must be readable.
Future<void> registerKmlMock() async {
  const MethodChannel channel = MethodChannel('stager_platform_native_plugins');

  TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
      .setMockMethodCallHandler(channel, (MethodCall call) async {
        switch (call.method) {
          case 'checkXMLFile':
            // Expect named arguments: {"xsdPath": "...", "xmlPath": "..."}
            final args = call.arguments as Map<dynamic, dynamic>;
            final String xsdPath = args['xsdPath'] as String? ?? '';
            final String xmlPath = args['xmlPath'] as String? ?? '';
            // Verify the file actually exists on disk.
            if (await File(xmlPath).exists() && await File(xsdPath).exists()) {
              return 0; // success – file exists
            }
            return 1; // error code indicating missing file
          default:
            throw PlatformException(
              code: 'UNIMPLEMENTED',
              message: 'No mock implementation for ${call.method}',
            );
        }
      });
}
