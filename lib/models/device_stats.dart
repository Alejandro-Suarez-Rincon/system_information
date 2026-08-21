/// Modelo inmutable con los recursos del dispositivo.
///
/// Las magnitudes de memoria y almacenamiento se guardan en **bytes**.
/// [cpuUsage] es un porcentaje 0-100; un valor negativo indica que la
/// plataforma no permitió leer el uso de CPU (se muestra como "n/d").
class DeviceStats {
  final String deviceName;
  final String osVersion;
  final int cpuCores;
  final String cpuArch;
  final double cpuUsage;
  final int ramUsed;
  final int ramTotal;
  final int storageUsed;
  final int storageTotal;
  final int batteryPercentage;
  final bool isCharging;

  const DeviceStats({
    required this.deviceName,
    required this.osVersion,
    required this.cpuCores,
    required this.cpuArch,
    required this.cpuUsage,
    required this.ramUsed,
    required this.ramTotal,
    required this.storageUsed,
    required this.storageTotal,
    required this.batteryPercentage,
    required this.isCharging,
  });

  /// Valor por defecto mientras se cargan los datos reales.
  factory DeviceStats.empty() => const DeviceStats(
        deviceName: 'Cargando...',
        osVersion: '',
        cpuCores: 0,
        cpuArch: '',
        cpuUsage: -1,
        ramUsed: 0,
        ramTotal: 0,
        storageUsed: 0,
        storageTotal: 0,
        batteryPercentage: 0,
        isCharging: false,
      );

  bool get hasCpuUsage => cpuUsage >= 0;

  DeviceStats copyWith({
    String? deviceName,
    String? osVersion,
    int? cpuCores,
    String? cpuArch,
    double? cpuUsage,
    int? ramUsed,
    int? ramTotal,
    int? storageUsed,
    int? storageTotal,
    int? batteryPercentage,
    bool? isCharging,
  }) {
    return DeviceStats(
      deviceName: deviceName ?? this.deviceName,
      osVersion: osVersion ?? this.osVersion,
      cpuCores: cpuCores ?? this.cpuCores,
      cpuArch: cpuArch ?? this.cpuArch,
      cpuUsage: cpuUsage ?? this.cpuUsage,
      ramUsed: ramUsed ?? this.ramUsed,
      ramTotal: ramTotal ?? this.ramTotal,
      storageUsed: storageUsed ?? this.storageUsed,
      storageTotal: storageTotal ?? this.storageTotal,
      batteryPercentage: batteryPercentage ?? this.batteryPercentage,
      isCharging: isCharging ?? this.isCharging,
    );
  }
}
