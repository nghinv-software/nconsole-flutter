//
//  Generated file. Do not edit.
//

// clang-format off

#include "generated_plugin_registrant.h"

#include <fast_rsa/fast_rsa_plugin.h>
#include <nghinv_device_info/n_device_info_plugin_c_api.h>

void RegisterPlugins(flutter::PluginRegistry* registry) {
  FastRsaPluginRegisterWithRegistrar(
      registry->GetRegistrarForPlugin("FastRsaPlugin"));
  NDeviceInfoPluginCApiRegisterWithRegistrar(
      registry->GetRegistrarForPlugin("NDeviceInfoPluginCApi"));
}
