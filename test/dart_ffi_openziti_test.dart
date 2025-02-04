import 'dart:io';
import 'package:dart_ffi_openziti/dart_ffi_openziti_socket.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:dart_ffi_openziti/dart_ffi_openziti.dart';
import 'package:dart_ffi_openziti/dart_ffi_openziti_platform_interface.dart';
import 'package:dart_ffi_openziti/dart_ffi_openziti_method_channel.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';
import 'package:http/http.dart' as http;

class MockDartFfiOpenzitiPlatform
    with MockPlatformInterfaceMixin
    implements DartFfiOpenzitiPlatform {
  @override
  Future<String?> getPlatformVersion() => Future.value('42');
}

void main() {
  final DartFfiOpenzitiPlatform initialPlatform =
      DartFfiOpenzitiPlatform.instance;

  test('$MethodChannelDartFfiOpenziti is the default instance', () {
    expect(initialPlatform, isInstanceOf<MethodChannelDartFfiOpenziti>());
  });

  test('getPlatformVersion', () async {
    DartFfiOpenziti dartFfiOpenzitiPlugin = DartFfiOpenziti();
    MockDartFfiOpenzitiPlatform fakePlatform = MockDartFfiOpenzitiPlatform();
    DartFfiOpenzitiPlatform.instance = fakePlatform;

    expect(await dartFfiOpenzitiPlugin.getPlatformVersion(), '42');
  });

  test('initOpenZitiLib', () async {
    DartFfiOpenziti dartFfiOpenzitiPlugin = DartFfiOpenziti();
    expect(dartFfiOpenzitiPlugin.ziti_lib_init, isNotNull);
    expect(() => dartFfiOpenzitiPlugin.ziti_lib_init(), returnsNormally);
  });

  test('getOpenZitiVersion', () async {
    DartFfiOpenziti dartFfiOpenzitiPlugin = DartFfiOpenziti();
    final zitiVersion = dartFfiOpenzitiPlugin.zitiVersion();
    print(zitiVersion);
    expect(zitiVersion, isNotNull);
  });

  test('createSocket', () async {
    DartFfiOpenziti dartFfiOpenzitiPlugin = DartFfiOpenziti();
    final socket = dartFfiOpenzitiPlugin.zitiSocket(1);

    expect(socket, isNotNull);
  });

  test('testEnrollFunctionSaveToFile', () async {
    DartFfiOpenziti dartFfiOpenzitiPlugin = DartFfiOpenziti();
    dartFfiOpenzitiPlugin.ziti_lib_init();
    final jwtSrc =
        'C:/Users/steve/Git/flutter/dart_ffi_openziti/test/test-dart.jwt';
    final id = dartFfiOpenzitiPlugin.zitiEnroll(jwtSrc);
    //Save to file
    final file = File('identity.json');
    file.writeAsStringSync(id);
    expect(id, isNotNull);
  });

  test('loadZitiID', () async {
    DartFfiOpenziti dartFfiOpenzitiPlugin = DartFfiOpenziti();
    dartFfiOpenzitiPlugin.ziti_lib_init();
    dartFfiOpenzitiPlugin.zitiVersion();
    final socket = dartFfiOpenzitiPlugin.zitiSocket(1);
    print('Socket: $socket');
    String jsonString =
        await File('C:/Users/steve/Git/flutter/dart_ffi_openziti/identity.json')
            .readAsString();
    final contextPtr = dartFfiOpenzitiPlugin.loadZitiContext(jsonString);

    expect(contextPtr, isNotNull);
  });

  test('loadZitiConnect', () async {
    DartFfiOpenziti dartFfiOpenzitiPlugin = DartFfiOpenziti();
    dartFfiOpenzitiPlugin.ziti_lib_init();
    dartFfiOpenzitiPlugin.zitiVersion();
    final socket = dartFfiOpenzitiPlugin.zitiSocket(1);
    print('Socket: $socket');
    String jsonString =
        await File('C:/Users/steve/Git/flutter/dart_ffi_openziti/identity.json')
            .readAsString();
    final contextPtr = dartFfiOpenzitiPlugin.loadZitiContext(jsonString);
    print('Context: ${contextPtr.address}');
    final result = dartFfiOpenzitiPlugin.zitiConnectWrapper(
        socket, contextPtr, "ziti-weather-service");
    dartFfiOpenzitiPlugin.shutdown();
    expect(result, 0);
  });

  test('makeHttpGet', () async {
    DartFfiOpenziti dartFfiOpenzitiPlugin = DartFfiOpenziti();
    dartFfiOpenzitiPlugin.ziti_lib_init();
    dartFfiOpenzitiPlugin.zitiVersion();
    final socket = dartFfiOpenzitiPlugin.zitiSocket(1);
    print('Socket: $socket');
    String jsonString =
        await File('C:/Users/steve/Git/flutter/dart_ffi_openziti/identity.json')
            .readAsString();
    final contextPtr = dartFfiOpenzitiPlugin.loadZitiContext(jsonString);
    print('Context: ${contextPtr.address}');
    final result = dartFfiOpenzitiPlugin.zitiConnectWrapper(
        socket, contextPtr, "ziti-weather-service");

    final response =
        await http.get(Uri.parse('http://wttr.ziti/Rochester?format=3'));
    dartFfiOpenzitiPlugin.shutdown();
    expect(response, isNotNull);
  });

  test('connectZitiSocket', () async {
    // Initialize the Ziti library
    final ziti = DartFfiOpenziti();
    ziti.ziti_lib_init();

    // Print Ziti version for debugging
    final version = await ziti.zitiVersion();
    print('Ziti Version: $version');
    print('Loading id.');
    // Load Ziti identity from file
    String jsonString =
        await File('C:/Users/steve/Git/flutter/dart_ffi_openziti/identity.json')
            .readAsString();

    final contextPtr = ziti.loadZitiContext(jsonString);
    print('Context: ${contextPtr.address}');
    // final socket = ziti.zitiSocket(1);
    // print('Socket: $socket');
    // print('Creating socket');
    // Create a ZitiSocket with bindings configuration
    final sock = ZitiSocket(
      ziti: ziti,
      opts: {
        'bindings': {
          '0.0.0.0:8089': {
            'ztx': 'default',
            'service': 'ziti-weather-service',
            //  'terminator': 'my-terminator',
          },
        },
      },
    );

    print('Connect to service: $sock');

// Connect to the Ziti service
    sock.connect(['wttr.ziti', 80], jsonString);

// Bind the socket to a local address
    await sock.bind(['0.0.0.0', 8089]);
    // sock.listen();
// Listen for connections on the socket
    final client = await sock.accept();
    print('Client connected: ${client.getsockname()}');

// Now make the HTTP request (this works if the Ziti socket acts as an HTTP server)

    // // Start listening for incoming connections
    sock.listen();
    final response = await http.get(Uri.parse('http://localhost:8089'));
    print(response.body);

    // // Accept an incoming connection
    // final client = await sock.accept();
    // print('Client connected: ${client.getsockname()}');

    // // Close the client and server sockets
    // client.close();
    // sock.close();

    // // Shutdown the Ziti library
    // ziti.shutdown();

    // // Verify that the connection was successful
    // expect(sock.getsockname(), equals(['0.0.0.0', 0]));
  });
}
