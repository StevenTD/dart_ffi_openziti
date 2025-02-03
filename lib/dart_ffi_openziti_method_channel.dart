import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

import 'dart_ffi_openziti_platform_interface.dart';

/// An implementation of [DartFfiOpenzitiPlatform] that uses method channels.
class MethodChannelDartFfiOpenziti extends DartFfiOpenzitiPlatform {
  /// The method channel used to interact with the native platform.
  @visibleForTesting
  final methodChannel = const MethodChannel('dart_ffi_openziti');

  @override
  Future<String?> getPlatformVersion() async {
    final version = await methodChannel.invokeMethod<String>('getPlatformVersion');
    return version;
  }
}
