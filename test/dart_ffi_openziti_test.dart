import 'dart:io';
import 'package:flutter_test/flutter_test.dart';
import 'package:dart_ffi_openziti/dart_ffi_openziti.dart';
import 'package:dart_ffi_openziti/dart_ffi_openziti_platform_interface.dart';
import 'package:dart_ffi_openziti/dart_ffi_openziti_method_channel.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';

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
}
