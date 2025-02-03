#ifndef FLUTTER_PLUGIN_DART_FFI_OPENZITI_PLUGIN_H_
#define FLUTTER_PLUGIN_DART_FFI_OPENZITI_PLUGIN_H_

#include <flutter/method_channel.h>
#include <flutter/plugin_registrar_windows.h>

#include <memory>

namespace dart_ffi_openziti {

class DartFfiOpenzitiPlugin : public flutter::Plugin {
 public:
  static void RegisterWithRegistrar(flutter::PluginRegistrarWindows *registrar);

  DartFfiOpenzitiPlugin();

  virtual ~DartFfiOpenzitiPlugin();

  // Disallow copy and assign.
  DartFfiOpenzitiPlugin(const DartFfiOpenzitiPlugin&) = delete;
  DartFfiOpenzitiPlugin& operator=(const DartFfiOpenzitiPlugin&) = delete;

  // Called when a method is called on this plugin's channel from Dart.
  void HandleMethodCall(
      const flutter::MethodCall<flutter::EncodableValue> &method_call,
      std::unique_ptr<flutter::MethodResult<flutter::EncodableValue>> result);
};

}  // namespace dart_ffi_openziti

#endif  // FLUTTER_PLUGIN_DART_FFI_OPENZITI_PLUGIN_H_
