import 'dart:ffi';
import 'dart:io';
import 'package:dart_ffi_openziti/dart_ffi_openziti.dart';

Future<void> main(List<String> arguments) async {
  try {
    //dart_ffi_openziti.main();
    // print('Hello world: ${dart_ffi_openziti.main()}!');

    ziti_lib_init(); // Initialize Ziti library
    zitiVersion();

    final fd = zitiSocket(1); // Example socket type
    // Check the socket using Ziti_check_socket
    print('Socket check result: ${checkSocket(fd)}');
    //Example of Ziti enroll
    final jwt =
        "C:/Users/steve/Git/flutter/dart_ffi_openziti/lib/test-dart.jwt";

    // Read identity.json and extract the key, cert, and JWT
    String jsonString = await File('identity.json').readAsString();
    //Map<String, dynamic> identityData = json.decode(jsonString);

    //final enrolledIdentity = zitiEnroll(jwt);
    // print("Enrolled Identity: $enrolledIdentity");
    // Save the identity JSON to a file
    // final file = File('identity.json');
    //file.writeAsStringSync(enrolledIdentity);

    //CONNECTING
    final contextPtr = loadZitiContext(jsonString);

    if (contextPtr != nullptr) {
      print("Ziti context loaded successfully: ${contextPtr.address}");

      // Assuming you have a socket descriptor fd

      zitiConnectWrapper(fd, contextPtr, "ziti-weather-service");
      // Check the socket using Ziti_check_socket
      print('Socket check result: ${checkSocket(fd)}');
    } else {
      print("Failed to load Ziti context.");
    }

    shutdown();
  } catch (e) {
    print('Error: $e');
  }
}
