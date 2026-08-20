import 'package:battery_plus/battery_plus.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:system_information/models/device_stats.dart';

class DeviceService {
  final _deviceInfo = DeviceInfoPlugin();
  final _battery = Battery();

  Future<DeviceStats> getDeviceStats() async {
    final batteryLevel = await _battery.batteryLevel;
    final deviceInfo = await _getDeviceInfo();

    return DeviceStats(
      deviceName: deviceInfo['name'] ?? 'Unknown Device',
      osVersion: deviceInfo['version'] ?? 'Unknown',
      batteryPercentage: batteryLevel,
      cpuUsage: 45,
      ramUsage: 4000,
      ramTotal: 8000,
      storageUsed: 50000,
      storageTotal: 128000,
    );
  }

  Future<Map<String, String>> _getDeviceInfo() async {
    final info =await _deviceInfo.androidInfo;
    return {
      'name': info.model ?? 'Unknown',
      'version': 'Android ${info.version.release}',
    };
  }
}