import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:dart_ffi_openziti/dart_ffi_openziti_method_channel.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  MethodChannelDartFfiOpenziti platform = MethodChannelDartFfiOpenziti();
  const MethodChannel channel = MethodChannel('dart_ffi_openziti');

  setUp(() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger.setMockMethodCallHandler(
      channel,
      (MethodCall methodCall) async {
        return '42';
      },
    );
  });

  tearDown(() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger.setMockMethodCallHandler(channel, null);
  });

  test('getPlatformVersion', () async {
    expect(await platform.getPlatformVersion(), '42');
  });
}
