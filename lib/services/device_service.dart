import 'dart:io';

import 'package:battery_plus/battery_plus.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:system_information/models/device_stats.dart';
import 'package:system_information/services/metrics_channel.dart';

class DeviceService {
  final _deviceInfo = DeviceInfoPlugin();
  final _battery = Battery();
  final _metrics = MetricsChannel();

  // Datos que no cambian: se leen una vez y se cachean.
  _StaticInfo? _static;

  Future<DeviceStats> getDeviceStats() async {
    final info = _static ??= await _readStaticInfo();

    // Métricas volátiles en paralelo.
    final results = await Future.wait([
      _metrics.getMetrics(),
      _readBattery(),
    ]);

    final native = results[0] as NativeMetrics;
    final battery = results[1] as _BatteryInfo;

    return DeviceStats(
      deviceName: info.deviceName,
      osVersion: info.osVersion,
      cpuCores: info.cpuCores,
      cpuArch: info.cpuArch,
      cpuUsage: native.cpuUsage,
      ramUsed: native.ramUsed,
      ramTotal: native.ramTotal,
      storageUsed: native.storageUsed,
      storageTotal: native.storageTotal,
      batteryPercentage: battery.percentage,
      isCharging: battery.isCharging,
    );
  }

  Future<_StaticInfo> _readStaticInfo() async {
    var name = 'Dispositivo desconocido';
    var version = 'Desconocido';
    var arch = '';

    try {
      if (Platform.isAndroid) {
        final a = await _deviceInfo.androidInfo;
        name = '${a.manufacturer} ${a.model}';
        version = 'Android ${a.version.release} (API ${a.version.sdkInt})';
        arch = a.supportedAbis.isNotEmpty ? a.supportedAbis.first : '';
      } else if (Platform.isIOS) {
        final i = await _deviceInfo.iosInfo;
        name = i.name;
        version = '${i.systemName} ${i.systemVersion}';
        arch = i.utsname.machine;
      } else if (Platform.isMacOS) {
        final m = await _deviceInfo.macOsInfo;
        name = m.computerName;
        version = 'macOS ${m.osRelease}';
        arch = m.arch;
      } else if (Platform.isWindows) {
        final w = await _deviceInfo.windowsInfo;
        name = w.computerName;
        version = w.productName;
      } else if (Platform.isLinux) {
        final l = await _deviceInfo.linuxInfo;
        name = l.prettyName;
        version = l.version ?? l.name;
      }
    } catch (_) {
      // Si falla la lectura del dispositivo mantenemos los valores por defecto.
    }

    return _StaticInfo(
      deviceName: name,
      osVersion: version,
      cpuCores: Platform.numberOfProcessors,
      cpuArch: arch,
    );
  }

  Future<_BatteryInfo> _readBattery() async {
    try {
      final level = await _battery.batteryLevel;
      final state = await _battery.batteryState;
      return _BatteryInfo(
        percentage: level,
        isCharging: state == BatteryState.charging ||
            state == BatteryState.full,
      );
    } catch (_) {
      return const _BatteryInfo(percentage: 0, isCharging: false);
    }
  }

}

class _StaticInfo {
  final String deviceName;
  final String osVersion;
  final int cpuCores;
  final String cpuArch;

  const _StaticInfo({
    required this.deviceName,
    required this.osVersion,
    required this.cpuCores,
    required this.cpuArch,
  });
}

class _BatteryInfo {
  final int percentage;
  final bool isCharging;
  const _BatteryInfo({required this.percentage, required this.isCharging});
}
