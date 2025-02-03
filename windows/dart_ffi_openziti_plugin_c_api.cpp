#include "include/dart_ffi_openziti/dart_ffi_openziti_plugin_c_api.h"

#include <flutter/plugin_registrar_windows.h>

#include "dart_ffi_openziti_plugin.h"

void DartFfiOpenzitiPluginCApiRegisterWithRegistrar(
    FlutterDesktopPluginRegistrarRef registrar) {
  dart_ffi_openziti::DartFfiOpenzitiPlugin::RegisterWithRegistrar(
      flutter::PluginRegistrarManager::GetInstance()
          ->GetRegistrar<flutter::PluginRegistrarWindows>(registrar));
}
