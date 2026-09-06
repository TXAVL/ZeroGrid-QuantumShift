import 'dart:io';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/foundation.dart';

/// Lớp tiện ích thu thập FULL thông tin phần cứng & hệ thống thiết bị (TxaDevice)
class TxaDevice {
  static final DeviceInfoPlugin _deviceInfoPlugin = DeviceInfoPlugin();

  /// Lấy toàn bộ thông tin chi tiết của thiết bị (Hardware, OS, Security, Specs)
  static Future<Map<String, dynamic>> getDeviceInfoSummary() async {
    final map = <String, dynamic>{
      'platform': getPlatformName(),
      'timestamp': DateTime.now().toUtc().toIso8601String(),
    };

    try {
      if (!kIsWeb && Platform.isAndroid) {
        final info = await _deviceInfoPlugin.androidInfo;
        map['brand'] = info.brand;
        map['manufacturer'] = info.manufacturer;
        map['model'] = info.model;
        map['device'] = info.device;
        map['product'] = info.product;
        map['hardware'] = info.hardware;
        map['board'] = info.board;
        map['bootloader'] = info.bootloader;
        map['fingerprint'] = info.fingerprint;
        map['host'] = info.host;
        map['display'] = info.display;
        map['os_release'] = info.version.release;
        map['sdk_int'] = info.version.sdkInt;
        map['security_patch'] = info.version.securityPatch ?? 'Unknown';
        map['supported_abis'] = info.supportedAbis;
        map['is_physical_device'] = info.isPhysicalDevice;
        map['device_id'] = info.id;
        map['os_version'] = 'Android ${info.version.release} (SDK ${info.version.sdkInt})';
      } else if (!kIsWeb && Platform.isIOS) {
        final info = await _deviceInfoPlugin.iosInfo;
        map['brand'] = 'Apple';
        map['model'] = info.model;
        map['machine'] = info.utsname.machine;
        map['system_name'] = info.systemName;
        map['system_version'] = info.systemVersion;
        map['os_version'] = 'iOS ${info.systemVersion}';
        map['device_id'] = info.identifierForVendor ?? 'unknown_ios_id';
        map['is_physical_device'] = info.isPhysicalDevice;
      } else if (!kIsWeb && Platform.isWindows) {
        final info = await _deviceInfoPlugin.windowsInfo;
        map['brand'] = 'PC';
        map['computer_name'] = info.computerName;
        map['model'] = info.computerName;
        map['user_name'] = info.userName;
        map['number_of_cores'] = info.numberOfCores;
        map['ram_mb'] = info.systemMemoryInMegabytes;
        map['major_version'] = info.majorVersion;
        map['minor_version'] = info.minorVersion;
        map['build_number'] = info.buildNumber;
        map['os_version'] = 'Windows ${info.displayVersion} (Build ${info.buildNumber})';
        map['device_id'] = info.deviceId;
      } else {
        map['brand'] = 'Web/Generic';
        map['model'] = 'Browser';
        map['os_version'] = 'Web Engine';
        map['device_id'] = 'web_${DateTime.now().millisecondsSinceEpoch}';
      }
    } catch (e) {
      debugPrint("Error reading full device info: $e");
      map['brand'] = 'Generic';
      map['model'] = 'Unknown Device';
      map['os_version'] = 'Unknown OS';
      map['device_id'] = 'device_${DateTime.now().millisecondsSinceEpoch}';
    }

    return map;
  }

  /// Lấy chuỗi ID thiết bị độc nhất
  static Future<String> getUniqueDeviceId() async {
    final info = await getDeviceInfoSummary();
    return info['device_id']?.toString() ?? 'device_${DateTime.now().millisecondsSinceEpoch}';
  }

  /// Lấy tên thiết bị hiển thị dễ nhìn
  static Future<String> getDeviceDisplayName() async {
    final info = await getDeviceInfoSummary();
    final brand = info['brand']?.toString() ?? '';
    final model = info['model']?.toString() ?? '';
    if (brand.isNotEmpty && model.isNotEmpty) {
      if (model.toLowerCase().contains(brand.toLowerCase())) {
        return model;
      }
      return '$brand $model';
    }
    return model.isNotEmpty ? model : 'Unknown Device';
  }

  /// Tên hệ điều hành
  static String getPlatformName() {
    if (kIsWeb) return 'web';
    if (Platform.isAndroid) return 'android';
    if (Platform.isIOS) return 'ios';
    if (Platform.isWindows) return 'windows';
    if (Platform.isMacOS) return 'macos';
    if (Platform.isLinux) return 'linux';
    return 'unknown';
  }
}
