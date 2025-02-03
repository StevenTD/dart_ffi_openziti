import 'package:plugin_platform_interface/plugin_platform_interface.dart';

import 'dart_ffi_openziti_method_channel.dart';

abstract class DartFfiOpenzitiPlatform extends PlatformInterface {
  /// Constructs a DartFfiOpenzitiPlatform.
  DartFfiOpenzitiPlatform() : super(token: _token);

  static final Object _token = Object();

  static DartFfiOpenzitiPlatform _instance = MethodChannelDartFfiOpenziti();

  /// The default instance of [DartFfiOpenzitiPlatform] to use.
  ///
  /// Defaults to [MethodChannelDartFfiOpenziti].
  static DartFfiOpenzitiPlatform get instance => _instance;

  /// Platform-specific implementations should set this with their own
  /// platform-specific class that extends [DartFfiOpenzitiPlatform] when
  /// they register themselves.
  static set instance(DartFfiOpenzitiPlatform instance) {
    PlatformInterface.verifyToken(instance, _token);
    _instance = instance;
  }

  Future<String?> getPlatformVersion() {
    throw UnimplementedError('platformVersion() has not been implemented.');
  }
}
