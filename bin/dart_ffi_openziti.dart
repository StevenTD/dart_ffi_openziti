import 'dart:ffi';
import 'dart:io';
import 'package:dart_ffi_openziti/dart_ffi_openziti.dart';
import 'package:http/http.dart' as http;

Future<void> main(List<String> arguments) async {
// Function to make an HTTP request using Ziti connection
  Future<void> makeHttpRequest(String url) async {
    // Define custom headers
    Map<String, String> headers = {
      'Host': 'wttr.in',
    };

    // Make HTTP GET request with headers
    final response = await http.get(
      Uri.parse(url),
      headers: headers, // Add custom headers here
    );

    if (response.statusCode == 200) {
      print('Success: ${response.body}');
    } else {
      print('Failed to get data: ${response.statusCode}');
    }
  }

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
      // Make HTTP request over Ziti
      String url =
          "http://wttr.ziti/Rochester?format=3"; // Replace with your URL
      await makeHttpRequest(url);
    } else {
      print("Failed to load Ziti context.");
    }

    shutdown();
  } catch (e) {
    print('Error: $e');
  }
}
